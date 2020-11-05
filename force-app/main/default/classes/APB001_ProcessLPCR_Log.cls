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
        UM001_LogManager.writeLogActivityWithoutFuture('Batch to delete documents of LPCR_Log__c','APB001_ProcessLPCR_Log', 'Batch' , null,
                                                         'Execute method started with scope : ' + String.valueOf(logs), UM010_Constant.SUCCESS);  
        String ErrMsg;
        set<String> docIds = new set<String> ();
        set<String> delIds = new set<String> ();
        for(LPCR_Log__c eachLog : logs){
            docIds.add(eachLog.LPCR_TargetObject__c);
        }
        List<Attachment> lstAtta = [SELECT Id FROM Attachment WHERE Id IN: docIds];
        for(Attachment eachatt : lstAtta){
            delIds.add('' +eachatt.Id);
        }
        List<LPCR_Log__c> lstPurgedDoc =[SELECT Id, LPCR_TargetObject__c FROM LPCR_Log__c WHERE LPCR_TargetObject__c IN : delIds];
        try {
            delete lstAtta;
            PAD.log('APB001_ProcessLPCR_Log', 'execute', 'The documents are deleted successfully');
            UM001_LogManager.writeLogActivityWithoutFuture('Batch to delete documents of LPCR_Log__c','APB001_ProcessLPCR_Log', 'Batch' , null, lstAtta.size() + ' Logs deleted', UM010_Constant.SUCCESS);  
        } catch (Exception e) {
            ErrMsg = String.valueOf(e.getMessage());
        } finally {
            if(ErrMsg != null && String.isNotBlank(ErrMsg)){
                UM001_LogManager.writeLogActivityWithoutFuture('Batch to delete documents of LPCR_Log__c','APB001_ProcessLPCR_Log', 'Batch' , null, 'Error while deleting the documents' + ErrMsg, UM010_Constant.ERROR);  
            }
        }



        ErrMsg = null;
        // check if all delete success..
        lstAtta = [SELECT Id FROM Attachment WHERE Id IN: docIds ];
        if(lstAtta.isEmpty() ){
            for(LPCR_Log__c eachLog : lstPurgedDoc){
                eachLog.LPCR_Result__c = 'Purged';
            }
            try {
                update lstPurgedDoc;
                PAD.log('APB001_ProcessLPCR_Log', 'execute', 'The documents are deleted successfully');
                UM001_LogManager.writeLogActivityWithoutFuture('Batch to delete documents of LPCR_Log__c','APB001_ProcessLPCR_Log', 'Batch' , null, 'Set Logs LPCR_Result__c to Purged', UM010_Constant.SUCCESS);  
            } catch (Exception e) {
                ErrMsg = e.getMessage();
            } finally {
                if(ErrMsg != null && String.isNotBlank(ErrMsg)){
                    UM001_LogManager.writeLogActivityWithoutFuture('Batch to delete documents of LPCR_Log__c','APB001_ProcessLPCR_Log', 'Batch' , null, 'Error while setting Logs LPCR_Result__c to Purged. Exception : ' + ErrMsg, UM010_Constant.ERROR);  
                }
            }
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