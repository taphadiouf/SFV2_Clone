/**
* @author Ayoub Ouarti
* @date 19/03/2020
* @Description Batch for Generate the Contract from the order
*/
global class APB005_GenerateContractFromOrder  implements Database.Batchable<sObject>,Schedulable {
    String query;
    
    global APB005_GenerateContractFromOrder() {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        query = 'SELECT Id,Status,SBQQ__Contracted__c FROM Order WHERE Status =\'Activated\' AND SBQQ__Contracted__c =false';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Order> scope) {
        System.debug('scope to execute : '+scope);
        
        Set<Id> orderIds = UM003_TypeManager.getIdsOfListObjects(scope);
        List<Order> listOforder = [SELECT Id,Status,SBQQ__Contracted__c FROM Order WHERE Id in :orderIds ];   
        for (Order eachOrder : listOforder) {
            eachOrder.SBQQ__Contracted__c =true;
            System.debug('Updating order '+eachOrder.SBQQ__Contracted__c);
        }
        
        update listOforder;        
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    
    global void execute(SchedulableContext sc) {
        
        APB005_GenerateContractFromOrder sc1 = new APB005_GenerateContractFromOrder();
        
        // schedule the apex class only if their is not existing job running
        boolean isBatchJobRunning = UM004_BatchUtility.isBatchJobRunning('APB003_CreateOrderFromorder');
        
        // check if there is any open place to schedule the class
        boolean isJobQueueFull = UM004_BatchUtility.isBatchJobQueueFull();
        
        if(isBatchJobRunning == UM004_BatchUtility.BOOLEAN_FALSE){
            if (isJobQueueFull == UM004_BatchUtility.BOOLEAN_FALSE) {
                sc1 = new APB005_GenerateContractFromOrder();
                Database.executeBatch(this, 1);
            } else {
                //schedule this same schedulable class again in 30 mins
                sc1 = new APB005_GenerateContractFromOrder();
                Datetime dt = Datetime.now().addMinutes(30);  // i.e. 30 mins
                String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
                Id schedId = System.Schedule('APB005_GenerateContractFromOrder'+timeForScheduler,timeForScheduler,sc1);
            }
        }  
        
    } 
}