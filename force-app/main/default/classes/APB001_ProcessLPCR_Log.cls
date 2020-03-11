/**
* @author Hanae Makboub
* @date 26/02/2020
* @Description Batch to delete documents of LPCR_Log__c
*/
global class APB001_ProcessLPCR_Log implements Database.Batchable<sObject> {
    
    
    global Database.QueryLocator  start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, LPCR_TargetObject__c FROM LPCR_Log__c WHERE LPCR_Result__c = 'Sent' AND LPCR_Type__c='Document LPCR']);
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
                eachLog.LPCR_Result__c = 'Purgé ';
            }
            update lstPurgedDoc;
        }else{
            System.debug('The documents are not deleted');
        }
    }
    global void finish(Database.BatchableContext bc){
        
    }
}