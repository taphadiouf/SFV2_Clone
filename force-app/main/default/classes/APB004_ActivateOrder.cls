/**
* @author Ayoub Ouarti
* @date 18/03/2020
* @Description Batch for Activating the order
*/
global class APB004_ActivateOrder  implements Database.Batchable<sObject>,Schedulable {
    String query;
    
    global APB004_ActivateOrder() {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        query = 'SELECT Id,Status FROM Order WHERE Status =\'Draft\'';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Order> scope) {
        
        PAD.log('APB004_ActivateOrder', 'execute','scope to execute : ' + scope );
        
        Set<Id> orderIds = UM003_TypeManager.getIdsOfListObjects(scope);
        List<Order> listOforder = [SELECT Id,Status FROM Order WHERE Id in :orderIds ];   
		List<LPCR_Log__c> listOfLog = new List<LPCR_Log__c>();
        
        for (Order eachOrder : listOforder) {
            
            eachOrder.status ='Activated';
			listOfLog.add(UM001_LogManager.getWriteLogActivityForBulkInsert('Activating Order', 'APB004_ActivateOrder', 'Batch', String.valueOf(eachOrder.Id), '', 'SUCCESS'));            
        }
        
        update listOforder;  
        insert listOfLog;
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    
    global void execute(SchedulableContext sc) {
        
        APB004_ActivateOrder sc1 = new APB004_ActivateOrder();
        
        // schedule the apex class only if their is not existing job running
        boolean isBatchJobRunning = UM004_BatchUtility.isBatchJobRunning('APB003_CreateOrderFromorder');
        
        // check if there is any open place to schedule the class
        boolean isJobQueueFull = UM004_BatchUtility.isBatchJobQueueFull();
        
        if(isBatchJobRunning == UM004_BatchUtility.BOOLEAN_FALSE){
            if (isJobQueueFull == UM004_BatchUtility.BOOLEAN_FALSE) {
                sc1 = new APB004_ActivateOrder();
                Database.executeBatch(this, 1);
            } else {
                //schedule this same schedulable class again in 30 mins
                sc1 = new APB004_ActivateOrder();
                Datetime dt = Datetime.now().addMinutes(30);  // i.e. 30 mins
                String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
                Id schedId = System.Schedule('APB004_ActivateOrder'+timeForScheduler,timeForScheduler,sc1);
            }
        }  
        
    } 
}