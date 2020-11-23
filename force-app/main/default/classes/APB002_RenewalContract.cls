/**
* @author Ayoub Ouarti
* @date 17/03/2020
* @Description Batch for checking the box renewal quoted on the contract which will create the renewal opp and quote.
*/
global class APB002_RenewalContract implements Database.Batchable<sObject>,Schedulable {
    
    String query;
    final String ClassName = APB002_RenewalContract.class.getName();

    global APB002_RenewalContract() {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'start', 'Batch' , null, 'Starting Batch', UM010_Constant.SUCCESS); 

        Date today = date.today();
        
        query = 'SELECT Id FROM Contract WHERE Status =\'Activated\' AND LPCR_RenouvellementAutomatique__c = true AND  LPCR_DateRenouvellement__c <= :today AND LPCR_DateRenouvellement__c != null AND (SBQQ__RenewalQuoted__c = false OR SBQQ__RenewalForecast__c = false) ';//AND Termination_Date__c = null' ;
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contract> scope) {
        
        
        List<Exception> errors = new List<Exception>();
        try {
                
            PAD.log(ClassName, 'execute', 'scope to execute : '+scope);
            
            Set<Id> contractIds = UM003_TypeManager.getIdsOfListObjects(scope);
            Set<String> masterContractQuoteIds = new Set<String>();        
            Set<String> masterQuoteContractIds = new Set<String>();
            List<LPCR_Log__c> listOfLog = new List<LPCR_Log__c>();
            List<SBQQ__Quote__c> updateQuoteList = new List<SBQQ__Quote__c>();
            
            List<Contract> listOfContract = [SELECT Id,Name,Status,SBQQ__Quote__c,SBQQ__Quote__r.SBQQ__MasterContract__c,EndDate,LPCR_RenouvellementAutomatique__c, SBQQ__RenewalQuoted__c,LPCR_JoursAvance__c FROM Contract 
                                            WHERE Id in :contractIds ];   
            
            for(Contract eachContract : listOfContract) {
                if(eachContract.SBQQ__Quote__c != null){
                    masterContractQuoteIds.add(eachContract.SBQQ__Quote__c);
                    if(eachContract.SBQQ__Quote__r.SBQQ__MasterContract__c != null){
                        masterQuoteContractIds.add(eachContract.SBQQ__Quote__r.SBQQ__MasterContract__c);
                    }
                } 
                eachContract.Status = 'Terminé';
                listOfLog.add(UM001_LogManager.getWriteLogActivityForBulkInsert('', ClassName, 'Batch', String.valueOf(eachContract.Id), '', 'SUCCESS'));             
            }
            
            if(masterQuoteContractIds.size() > 0){
                for(Contract eachContract : [SELECT Id,Status,SBQQ__Quote__c FROM Contract WHERE Id in :masterQuoteContractIds ]){
                    if(eachContract.SBQQ__Quote__c != null){
                        masterContractQuoteIds.add(eachContract.SBQQ__Quote__c);
                    }
                }  
            }   
            
            for(SBQQ__Quote__c eachQuote : [SELECT Id,SBQQ__Status__c FROM SBQQ__Quote__c WHERE Id IN: masterContractQuoteIds]){
                eachQuote.SBQQ__Status__c = 'Terminé';
                updateQuoteList.add(eachQuote);
            }
            
            for (Contract eachContract : listOfContract) {
                eachContract.SBQQ__RenewalQuoted__c=true;
                PAD.log(ClassName, 'execute', 'Updating contract '+eachContract);
            } 
            
            String errorMsg='';
            if(updateQuoteList.size() > 0){
                try{
                    update updateQuoteList;
                    update listOfContract;
                }catch(Exception ex){
                    PAD.log(ClassName,'execute','Exception : '+ex.getMessage());
                    errorMsg = String.valueOf(ex.getMessage());
                }
                finally {
                    if (String.isNotBlank(errorMsg)) {
                        UM001_LogManager.writeLogActivityWithoutFuture('Update Contract Status',ClassName, 'Batch', '',  'Error:' + errorMsg, UM010_Constant.ERROR);  
                    } else {
                        insert listOfLog;
                    }               
                }
            }
            
        } catch (Exception e ) {
            errors.add(e);
        } finally {
            if (!errors.isEmpty()) {
                UM001_LogManager.writeLogActivityWithoutFuture(ClassName, 'execute', 'Batch' , null,'Processing with errors occurred : ' + errors, UM010_Constant.ERROR);
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'finish', 'Batch' , null, 'Finished Batch Processing', UM010_Constant.SUCCESS);
    }
    
    global void execute(SchedulableContext sc) {
        
        APB002_RenewalContract sc1 = new APB002_RenewalContract();
        
        Datetime dt = Datetime.now().addMinutes(30);
        String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
        // schedule the apex class only if their is not existing job running
        boolean isBatchJobRunning = UM004_BatchUtility.isBatchJobRunning('APB002_RenewalContract');
        
        // check if there is any open place to schedule the class
        boolean isJobQueueFull = UM004_BatchUtility.isBatchJobQueueFull();
        
        if(isBatchJobRunning == UM004_BatchUtility.BOOLEAN_FALSE){
            if (isJobQueueFull == UM004_BatchUtility.BOOLEAN_FALSE) {
                sc1 = new APB002_RenewalContract();
                Database.executeBatch(this, 1);
            } else {
                //schedule this same schedulable class again in 30 mins
                
                Id schedId = System.Schedule('APB002_RenewalContract'+timeForScheduler,timeForScheduler,new APB002_RenewalContract());
            }
        }  
        
    } 
}