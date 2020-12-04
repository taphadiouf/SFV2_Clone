/**
* @author Erwan Yhuellou
* @date 04/12/2020
* @Description Batch to delete old LPCR_Log__c
*/
global class APB000_DeleteOldLogs implements Database.Batchable<sObject>, Schedulable {
    
    final String ClassName = APB000_DeleteOldLogs.class.getName();
    
    global Database.QueryLocator  start(Database.BatchableContext bc) {

        String tmpLabel = UM010_Constant.LOG_SEND_DOC_TO_GED;

        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'start', 'Batch' , null, 'Starting Batch', UM010_Constant.SUCCESS); 

        return Database.getQueryLocator([SELECT Id, LPCR_TargetObject__c FROM LPCR_Log__c WHERE Name != :tmpLabel AND CreateDate < LAST_MONTH]);
        
    }
    global void execute(Database.BatchableContext bc, List<LPCR_Log__c> logs){

        Exception[] errors = new Exception[0];

        try {
            UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'execute', 'Batch' , null, 'logs.size():' + logs.size(), UM010_Constant.SUCCESS); 
            delete logs;

        } catch(Exception e) {
            errors.add(e);
        }

        if (!errors.isEmpty()) {
            UM001_LogManager.writeLogActivityWithoutFuture(ClassName, 'execute', 'Batch' , null,'Processing with errors occurred : ' + errors, UM010_Constant.ERROR);
        } 
    }
    global void finish(Database.BatchableContext bc){
        
        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'finish', 'Batch' , null, 'Finished Batch Processing', UM010_Constant.SUCCESS); 
    }

     
    global void execute(SchedulableContext sc) {
        
        APB000_DeleteOldLogs sc1 = new APB000_DeleteOldLogs();
        Datetime dt = Datetime.now().addMinutes(30);  // i.e. 30 mins
        String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
        // schedule the apex class only if their is not existing job running
        boolean isBatchJobRunning = UM004_BatchUtility.isBatchJobRunning('APB000_DeleteOldLogs');
        
        // check if there is any open place to schedule the class
        boolean isJobQueueFull = UM004_BatchUtility.isBatchJobQueueFull();
        
        if(isBatchJobRunning == UM004_BatchUtility.BOOLEAN_FALSE){
            if (isJobQueueFull == UM004_BatchUtility.BOOLEAN_FALSE) {
                sc1 = new APB000_DeleteOldLogs();
                Database.executeBatch(this, 200);
            } else {
                //schedule this same schedulable class again in 30 mins
                Id schedId = System.Schedule('APB000_DeleteOldLogs' + timeForScheduler, timeForScheduler, new APB000_DeleteOldLogs());
            }
        }  
        
    } 
}