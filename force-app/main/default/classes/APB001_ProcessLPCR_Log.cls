/**
* @author Hanae Makboub
* @date 26/02/2020
* @Description Batch to delete documents of LPCR_Log__c
*/
global class APB001_ProcessLPCR_Log implements Database.Batchable<sObject>, Schedulable {
    
    
    global Database.QueryLocator  start(Database.BatchableContext bc) {
        String tmpLabel = UM010_Constant.LOG_SEND_DOC_TO_GED;
        return Database.getQueryLocator([SELECT Id, LPCR_TargetObject__c FROM LPCR_Log__c WHERE Name = :tmpLabel AND LPCR_Result__c = 'Success']);
        
    }
    global void execute(Database.BatchableContext bc, List<LPCR_Log__c> logs){
        set<String> docIds = new set<String> ();
        set<String> delIds = new set<String> ();
        for(LPCR_Log__c eachLog : logs){
            docIds.add(eachLog.LPCR_TargetObject__c);
        }
        List<Attachment> lstAtta = [SELECT Id FROM Attachment WHERE Id IN: docIds];
        for(Attachment eachatt : lstAtta){
            delIds.add('' +eachatt.Id);
        }
        List<LPCR_Log__c> lstPurgedDoc =[Select Id, LPCR_TargetObject__c From LPCR_Log__c Where LPCR_TargetObject__c IN : delIds];
        delete lstAtta;
        lstAtta = [SELECT Id FROM Attachment WHERE Id IN: docIds ];
        if(lstAtta.isEmpty() ){
            for(LPCR_Log__c eachLog : lstPurgedDoc){
                eachLog.LPCR_Result__c = 'Purged';
            }
            update lstPurgedDoc;
        }else{
            PAD.log('APB001_ProcessLPCR_Log', 'execute', 'The documents are not deleted');
        }
    }
    global void finish(Database.BatchableContext bc){
        
    }

     
    global void execute(SchedulableContext sc) {
        
        APB001_ProcessLPCR_Log sc1 = new APB001_ProcessLPCR_Log();
        Datetime dt = Datetime.now().addMinutes(30);  // i.e. 30 mins
        String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
        // schedule the apex class only if their is not existing job running
        boolean isBatchJobRunning = UM004_BatchUtility.isBatchJobRunning('APB001_ProcessLPCR_Log');
        
        // check if there is any open place to schedule the class
        boolean isJobQueueFull = UM004_BatchUtility.isBatchJobQueueFull();
        
        if(isBatchJobRunning == UM004_BatchUtility.BOOLEAN_FALSE){
            if (isJobQueueFull == UM004_BatchUtility.BOOLEAN_FALSE) {
                sc1 = new APB001_ProcessLPCR_Log();
                Database.executeBatch(this, 200);
            } else {
                //schedule this same schedulable class again in 30 mins

                Id schedId = System.Schedule('APB001_ProcessLPCR_Log' + timeForScheduler, timeForScheduler, new APB001_ProcessLPCR_Log());
            }
        }  
        
    } 
}