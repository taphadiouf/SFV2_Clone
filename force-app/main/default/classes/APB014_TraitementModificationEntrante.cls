/**
* @author Saurabh
* @date 27/05/2021
* @Description Batch for Traitement Modification Entrante
*/

global class APB014_TraitementModificationEntrante implements Database.Batchable<sObject>,Schedulable,Database.Stateful,Database.AllowsCallouts{
    
    global set<id> allSuccessId = new set<id>();
    final String ClassName = APB014_TraitementModificationEntrante.class.getName();

    global APB014_TraitementModificationEntrante() {

    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'start', 'Batch' , null, 'Starting Batch', UM010_Constant.SUCCESS); 

        return Database.getQueryLocator([
                                            SELECT Id,LPCR_EtatTraitement__c,LPCR_Invoice__c,LPCR_TypePlanning__c,LPCR_Garde__c,LPCR_Rue__c,LPCR_Ville__c,LPCR_Pays__c,LPCR_CodePostal__c,LPCR_SituationFamiliale__c,LPCR_TypeAccueil__c,LPCR_DateEffet__c,LPCR_Evenement__c,LPCR_Quantite__c,LPCR_Compte__c,LPCR_RessourceFamille__c,LPCR_IDUnique__c,LPCR_OuiNon__c,LPCR_Contact__c,LPCR_Date__c,LPCR_Section__c,LPCR_Contract__c,LPCR_HeureDateDebut__c,LPCR_HeureDateFin__c,LPCR_Commentaire__c,LPCR_Devis__c,LPCR_Statut__c 
                                            FROM LPCR_ModificationEntrante__c 
                                            WHERE LPCR_DateEffet__c <= TODAY AND LPCR_EtatTraitement__c = false AND 
                                            LPCR_Statut__c = 'Validée' and CreatedBy.Name != 'Integration LPCR' and CreatedBy.Name != 'Recette DEV' 
                                        ]);
    }
    
    global void execute(Database.BatchableContext BC, List<LPCR_ModificationEntrante__c> scope) {

        Exception[] errors = new Exception[0];

        Set<Id> modificationEntranteIds = UM003_TypeManager.getIdsOfListObjects(scope);
        Set<Id> newQuoteIds = new Set<Id>();
        
        try {

            newQuoteIds = SM022_ModificationEntranteServices.updateQuotesFromModifEntrantesBatch(scope);
            PAD.log('APB014_TraitementModificationEntrante', 'execute','quote ids ' + newQuoteIds );
            
            if(newQuoteIds != null && newQuoteIds.size() > 0){
                allSuccessId.addAll(newQuoteIds);
            }
            UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'execute', 'Batch' , null, 'Scope size : '  + scope.size() + '\n Quotes Processed :' + newQuoteIds, UM010_Constant.SUCCESS); 

        } catch(Exception e) {
            errors.add(e);
        }

        if (!errors.isEmpty()) {
            UM001_LogManager.writeLogActivityWithoutFuture(ClassName, 'execute', 'Batch' , null,'Processing with errors occurred : ' + errors, UM010_Constant.ERROR);
        } 
         
    }
    
    global void finish(Database.BatchableContext BC) {

        if (allSuccessId != null && allSuccessId.size() > 0) {

            UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'finish', 'Batch' , null, ClassName + ' Finished. Scheduling APB0016 to run in 2 minutes with quote lines scope :' + String.valueOf(allSuccessId), UM010_Constant.SUCCESS); 

            APB016_QuoteReCalculateProcess sc = new APB016_QuoteReCalculateProcess();
            sc.quoteIds = allSuccessId;
            
            Datetime dt = Datetime.now().addMinutes(2);  // i.e. 2 mins
            String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
            Id schedId = System.Schedule('APB016_QuoteReCalculateProcess'+timeForScheduler,timeForScheduler,sc);
        }  
        
        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'finish', 'Batch' , null, 'Finished Batch Processing', UM010_Constant.SUCCESS); 
    }
    
    global void execute(SchedulableContext sc) {
        
        APB014_TraitementModificationEntrante sc1 = new APB014_TraitementModificationEntrante();
        Datetime dt = Datetime.now().addMinutes(30);  // i.e. 30 mins
        String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
        // schedule the apex class only if their is not existing job running
        boolean isBatchJobRunning = UM004_BatchUtility.isBatchJobRunning('APB014_TraitementModificationEntrante');
        
        // check if there is any open place to schedule the class
        boolean isJobQueueFull = UM004_BatchUtility.isBatchJobQueueFull();
        
        if(isBatchJobRunning == UM004_BatchUtility.BOOLEAN_FALSE){
            if (isJobQueueFull == UM004_BatchUtility.BOOLEAN_FALSE) {
                sc1 = new APB014_TraitementModificationEntrante();
                Database.executeBatch(this, 1);
            } else {
                //schedule this same schedulable class again in 30 mins
                Id schedId = System.Schedule('APB014_TraitementModificationEntrante'+timeForScheduler,timeForScheduler,new APB014_TraitementModificationEntrante());
            }
        }  
        
    }

}
