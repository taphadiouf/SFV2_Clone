/**
* @author Ayoub Ouarti
* @date 18/03/2020
* @Description Batch for checking the box ordered on the quote which will create the order
*/
global class APB003_CreateOrderFromQuote  implements Database.Batchable<sObject>,Schedulable {
    String query;
    
    global APB003_CreateOrderFromQuote() {
        
    }
     /*
    *   @description : this method search the Quotes with SBQQ__Status__c = 'Prêt pour commande\' AND SBQQ__Ordered__c  = false', to generate order
    *   @param Database.BatchableContext BC
    *   @returns Database.QueryLocator
    */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        PAD.log('APB003_CreateOrderFromQuote', 'start','Database.BatchableContext BC');        
        query = 'SELECT Id,SBQQ__Status__c ,SBQQ__Ordered__c  FROM SBQQ__Quote__c WHERE SBQQ__Status__c =\'Prêt pour commande\' AND SBQQ__Ordered__c  = false';
        
        return Database.getQueryLocator(query);
    }
    /*
    *   @description : this method generate Orders for the Quotes with SBQQ__Status__c = 'Prêt pour commande\' AND SBQQ__Ordered__c  = false', to generate order
    *   @param Database.BatchableContext BC, List<SBQQ__Quote__c> scope
    *   @returns void
    */
    global void execute(Database.BatchableContext BC, List<SBQQ__Quote__c> scope) {
        
        PAD.log('APB003_CreateOrderFromQuote', 'execute','scope :'+ scope.size()+'');        
        
        Set<Id> quoteIds = UM003_TypeManager.getIdsOfListObjects(scope);
        List<SBQQ__Quote__c> listOfquote = [SELECT Id,SBQQ__Status__c ,SBQQ__Ordered__c  FROM SBQQ__Quote__c WHERE Id in :quoteIds ];   
        List<LPCR_Log__c> listOfLog = new List<LPCR_Log__c>();
        
        for (SBQQ__Quote__c eachquote : listOfquote) {
           
            eachquote.SBQQ__Ordered__c = true;
            listOfLog.add(UM001_LogManager.getWriteLogActivityForBulkInsert('Creating Order From Quote', 'APB003_CreateOrderFromQuote', 'Batch', String.valueOf(eachquote.Id), '', 'SUCCESS'));
        }
        update listOfquote; 
        insert listOfLog;
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    /*
    *   @description : this method execute the batch
    *   @param SchedulableContext sc
    *   @returns void
    */
    global void execute(SchedulableContext sc) {
        PAD.log('APB003_CreateOrderFromQuote', 'execute','sc ');     
        APB003_CreateOrderFromQuote sc1 = new APB003_CreateOrderFromQuote();
        
        // schedule the apex class only if their is not existing job running
        boolean isBatchJobRunning = UM004_BatchUtility.isBatchJobRunning('APB003_CreateOrderFromQuote');
        
        // check if there is any open place to schedule the class
        boolean isJobQueueFull = UM004_BatchUtility.isBatchJobQueueFull();
        
        if(isBatchJobRunning == UM004_BatchUtility.BOOLEAN_FALSE){
            if (isJobQueueFull == UM004_BatchUtility.BOOLEAN_FALSE) {
                sc1 = new APB003_CreateOrderFromQuote();
                Database.executeBatch(this, 1);
            } else {
                //schedule this same schedulable class again in 30 mins
                sc1 = new APB003_CreateOrderFromQuote();
                Datetime dt = Datetime.now().addMinutes(30);  // i.e. 30 mins
                String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
                Id schedId = System.Schedule('APB003_CreateOrderFromQuote'+timeForScheduler,timeForScheduler,sc1);
            }
        }  
        
    } 
}