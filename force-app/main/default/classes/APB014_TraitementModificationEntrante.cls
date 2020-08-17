/**
* @author Saurabh
* @date 27/05/2021
* @Description Batch for Traitement Modification Entrante
*/

global class APB014_TraitementModificationEntrante implements Database.Batchable<sObject>,Schedulable,Database.AllowsCallouts{
    String query;

    global APB014_TraitementModificationEntrante() {

    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date today = date.today();
        query = 'SELECT Id,LPCR_EtatTraitement__c,LPCR_Invoice__c,LPCR_TypePlanning__c,LPCR_Garde__c,LPCR_Rue__c,LPCR_Ville__c,LPCR_Pays__c,LPCR_CodePostal__c,LPCR_SituationFamiliale__c,LPCR_TypeAccueil__c,LPCR_DateEffet__c,LPCR_Evenement__c,LPCR_Quantite__c,LPCR_Compte__c,LPCR_RessourceFamille__c,LPCR_IDUnique__c,LPCR_OuiNon__c,LPCR_Contact__c,LPCR_Date__c,LPCR_Section__c,LPCR_Contract__c,LPCR_HeureDateDebut__c,LPCR_HeureDateFin__c,LPCR_Commentaire__c,LPCR_Devis__c,LPCR_Statut__c FROM LPCR_ModificationEntrante__c WHERE LPCR_DateEffet__c <=: today AND LPCR_EtatTraitement__c = false AND LPCR_Statut__c = \'Validée\' ';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<LPCR_ModificationEntrante__c> scope) {
        PAD.log('APB014_TraitementModificationEntrante', 'execute','scope to execute : '+scope );
        
        Set<Id> modificationEntranteIds = UM003_TypeManager.getIdsOfListObjects(scope);
        SM022_ModificationEntranteServices.updateQuotesFromModifEntrantesBatch(scope);
         
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    
    global void execute(SchedulableContext sc) {
        
        APB014_TraitementModificationEntrante sc1 = new APB014_TraitementModificationEntrante();
        
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
                sc1 = new APB014_TraitementModificationEntrante();
                Datetime dt = Datetime.now().addMinutes(30);  // i.e. 30 mins
                String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
                Id schedId = System.Schedule('APB014_TraitementModificationEntrante'+timeForScheduler,timeForScheduler,sc1);
            }
        }  
        
    }

}
