/**
* @author Erwan Yhuellou
* @date 08/12/2020
* @Description Batch for setting QL Bon de Commande Field to envoyé (only for referencement quote)
*/
global class APB020_EnvoieBonCommande  implements Database.Batchable<sObject>,Schedulable {
    String query;
    final String ClassName = APB020_EnvoieBonCommande.class.getName();
    global APB020_EnvoieBonCommande() {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {

        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'start', 'Batch' , null, 'Starting Batch', UM010_Constant.SUCCESS);
        PAD.log(ClassName, 'start','Database.BatchableContext BC');        
        query = 'SELECT Id,RecordTypeId,LPCR_BonCommandeEnvoye__c,SBQQ__Status__c ,SBQQ__Ordered__c, LPCR_TypeCreche__c, SBQQ__Type__c, LPCR_RecalculationMACDone__c   FROM SBQQ__Quote__c WHERE SBQQ__Status__c =\'Prêt pour commande\' AND SBQQ__Ordered__c  = false';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<SBQQ__Quote__c> scope) {
        
        UM001_LogManager.writeLogActivityWithoutFuture( ClassName, 'Scope size', 'Batch' , null, String.valueOf(scope.size()), UM010_Constant.SUCCESS); 
        List<Exception> errors = new List<Exception>();
        String ErrMsg;

        try {

            try {
                updateRelatedQuotelines(scope);
                UM001_LogManager.writeLogActivityWithoutFuture( ClassName, 'Updating the quote lines',
                                                                'Batch' , null,
                                                                'Successfully updated (BonCommande) list of quote lines for the Quotes:(' + scope.size() + ')'+ UM003_TypeManager.getIdsOfListObjects(scope), 
                                                                UM010_Constant.SUCCESS);          
            } catch (Exception e) {
                ErrMsg = e.getMessage();
            } finally {
                if(ErrMsg != null && String.isNotBlank(ErrMsg)){
                    UM001_LogManager.writeLogActivityWithoutFuture(ClassName,  'Updating the quote lines','Batch' , null,'Error while updating list of quote lines (LPCR_LigneBonCommandeEnvoye__c=true)' + ErrMsg, UM010_Constant.ERROR);              
                }
            }
            ErrMsg = null;
            PAD.log(ClassName, 'execute','scope :'+ scope.size()+'');        
            
            
        } catch(Exception e) {
            errors.add(e);
        }
        
        if (!errors.isEmpty()) {
            UM001_LogManager.writeLogActivityWithoutFuture(ClassName, 'execute', 'Batch' , null,'Processing with errors occurred : ' + errors, UM010_Constant.ERROR);
        }
            
    }

    global void updateRelatedQuotelines(List<SBQQ__Quote__c> quotes){

        Id referencementRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote,Label.LPCR_Referencement);
        Id referencementApprRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote,Label.LPCR_Referencement_Approuve);

        //Gather refer quotes that their LPCR_BonCommandeEnvoye__c changed to true.
        List<SBQQ__Quote__c> quotesToProcess = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c q : quotes){
            
            if( (q.LPCR_BonCommandeEnvoye__c == true) &&
                (q.RecordTypeId == referencementRecTypeId || q.RecordTypeId == referencementApprRecTypeId)                 
                ){
                    quotesToProcess.add(q); 
            }
        }
        //Retrieve their quotesLines having LPCR_LigneBonCommandeEnvoye__c = false and set it to true
        Set<Id> idsQuotes = UM003_TypeManager.getIdsOfListObjects(quotesToProcess);
        List<SBQQ__QuoteLine__c> qLines = [  SELECT id,LPCR_LigneBonCommandeEnvoye__c 
                                            FROM SBQQ__QuoteLine__c 
                                            WHERE SBQQ__Quote__c IN :idsQuotes AND LPCR_LigneBonCommandeEnvoye__c=false];
                                            
        if( !UM003_TypeManager.isNullOrEmpty(qLines)){
            
            for (SBQQ__QuoteLine__c ql : qLines) {
                ql.LPCR_LigneBonCommandeEnvoye__c = true;
            }
            update qLines;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'finish', 'Batch' , null, 'Finished Batch Processing', UM010_Constant.SUCCESS);
    }
    /*
    *   @description : this method execute the batch
    *   @param SchedulableContext sc
    *   @returns void
    */
    global void execute(SchedulableContext sc) {
        PAD.log(ClassName, 'execute','sc ');     
        APB020_EnvoieBonCommande sc1 = new APB020_EnvoieBonCommande();
        Datetime dt = Datetime.now().addMinutes(30);  // i.e. 30 mins
        String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
        // schedule the apex class only if their is not existing job running
        boolean isBatchJobRunning = UM004_BatchUtility.isBatchJobRunning(ClassName);
        
        // check if there is any open place to schedule the class
        boolean isJobQueueFull = UM004_BatchUtility.isBatchJobQueueFull();
        
        if(isBatchJobRunning == UM004_BatchUtility.BOOLEAN_FALSE){
            if (isJobQueueFull == UM004_BatchUtility.BOOLEAN_FALSE) {
                sc1 = new APB020_EnvoieBonCommande();
                Database.executeBatch(this, 1);
            } else {
                //schedule this same schedulable class again in 30 mins
                Id schedId = System.Schedule(ClassName+timeForScheduler,timeForScheduler,new APB020_EnvoieBonCommande());
            }
        }  
        
    } 
}