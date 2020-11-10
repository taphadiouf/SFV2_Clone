/**
* @author Saurabh Singh
* @date 04/11/2020
* @Description Batch for process renewel contract
*/
global class APB018_ProcessRenewalContract implements Database.Batchable<sObject>,Schedulable {
    String query;
    
    global APB018_ProcessRenewalContract() {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date today = date.today();
        
        query = 'SELECT Id,SBQQ__MasterContract__c  FROM SBQQ__Quote__c WHERE SBQQ__Type__c =\'Amendment\' AND LPCR_TypeAvenant__c = \'Résiliation\'  AND SBQQ__Ordered__c = True AND SBQQ__Status__c != \'Terminé\' AND SBQQ__StartDate__c <= :today ';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<SBQQ__Quote__c> scope) {
        PAD.log('APB018_ProcessRenewalContract', 'execute', 'scope to execute : '+scope);
		
        Set<Id> quoteIds = UM003_TypeManager.getIdsOfListObjects(scope);
        Set<String> masterContractIds = UM003_TypeManager.getFieldsOfListObjects(scope, 'SBQQ__MasterContract__c');
        Set<String> masterContractQuoteIds = new Set<String>();        
        Set<String> masterQuoteContractIds = new Set<String>();
        String errorMsg = '';
        
        List<LPCR_Log__c> listOfLog = new List<LPCR_Log__c>();
        List<SBQQ__Quote__c> updateQuoteList = new List<SBQQ__Quote__c>();
        
        List<Contract> listOfMasterContract = [SELECT Id,Status,SBQQ__Quote__c,SBQQ__Quote__r.SBQQ__MasterContract__c FROM Contract 
                                         WHERE Id in :masterContractIds ]; 
        
        System.debug('>> APB018_ProcessRenewalContract , execute : listOfMasterContract = '+ listOfMasterContract);
		
        for(Contract eachContract : listOfMasterContract) {
            if(eachContract.SBQQ__Quote__c != null){
                masterContractQuoteIds.add(eachContract.SBQQ__Quote__c);
                if(eachContract.SBQQ__Quote__r.SBQQ__MasterContract__c != null){
                    masterQuoteContractIds.add(eachContract.SBQQ__Quote__r.SBQQ__MasterContract__c);
                }
            } 
            eachContract.Status = 'Terminé';
            listOfLog.add(UM001_LogManager.getWriteLogActivityForBulkInsert('', 'APB018_ProcessRenewalContract', 'Batch', String.valueOf(eachContract.Id), '', 'SUCCESS'));             
        }
		
        if(masterQuoteContractIds.size() > 0){
            for(Contract eachContract : [SELECT Id,Status,SBQQ__Quote__c FROM Contract WHERE Id in :masterQuoteContractIds ]){
                if(eachContract.SBQQ__Quote__c != null){
                    masterContractQuoteIds.add(eachContract.SBQQ__Quote__c);
                }
            }  
        }   
        
        for(SBQQ__Quote__c eachQuote : [SELECT Id,SBQQ__Status__c FROM SBQQ__Quote__c WHERE Id IN: masterContractQuoteIds OR Id IN: quoteIds]){
            eachQuote.SBQQ__Status__c = 'Terminé';
            updateQuoteList.add(eachQuote);
        }
		
        if(updateQuoteList.size() > 0){
            try{
                update updateQuoteList;
                update listOfMasterContract;
            }catch(Exception ex){
                PAD.log('APB018_ProcessRenewalContract','execute','Exception : '+ex.getMessage());
                errorMsg = String.valueOf(ex.getMessage());
            }
            finally {
                if (String.isNotBlank(errorMsg)) {
                    UM001_LogManager.writeLogActivityWithoutFuture('Update Contract Status','APB018_ProcessRenewalContract', 'Batch', '',  'Error:' + errorMsg, UM010_Constant.ERROR);  
                } else {
                    insert listOfLog;
                }               
            }
        }

    }
    
    global void finish(Database.BatchableContext BC) {
    }
    
    global void execute(SchedulableContext sc) {
        
        APB018_ProcessRenewalContract sc1 = new APB018_ProcessRenewalContract();

        Datetime dt = Datetime.now().addMinutes(30);
        String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
        // schedule the apex class only if their is not existing job running
        boolean isBatchJobRunning = UM004_BatchUtility.isBatchJobRunning('APB018_ProcessRenewalContract');
        
        // check if there is any open place to schedule the class
        boolean isJobQueueFull = UM004_BatchUtility.isBatchJobQueueFull();
        
        if(isBatchJobRunning == UM004_BatchUtility.BOOLEAN_FALSE){
            if (isJobQueueFull == UM004_BatchUtility.BOOLEAN_FALSE) {
                sc1 = new APB018_ProcessRenewalContract();
                Database.executeBatch(this, 1);
            } else {
                //schedule this same schedulable class again in 30 mins

                Id schedId = System.Schedule('APB018_ProcessRenewalContract'+timeForScheduler,timeForScheduler,new APB018_ProcessRenewalContract());
            }
        }  
        
    } 
}