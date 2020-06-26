/**
* @author Ayoub Ouarti
* @date 17/03/2020
* @Description Batch for checking the box renewal quoted on the contract which will create the renewal opp and quote.
*/
global class APB002_RenewalContract implements Database.Batchable<sObject>,Schedulable {
    String query;
    
    global APB002_RenewalContract() {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date today = date.today();
        
        query = 'SELECT Id FROM Contract WHERE Status =\'Activated\' AND LPCR_RenouvellementAutomatique__c = true AND  LPCR_DateRenouvellement__c <= :today AND LPCR_DateRenouvellement__c != null AND (SBQQ__RenewalQuoted__c = false OR SBQQ__RenewalForecast__c = false) ';//AND Termination_Date__c = null' ;
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contract> scope) {
           PAd.log('APB002_RenewalContract', 'execute', 'scope to execute : '+scope);

        Set<Id> contractIds = UM003_TypeManager.getIdsOfListObjects(scope);
        List<Contract> listOfContract = [SELECT Id,Name,EndDate,LPCR_RenouvellementAutomatique__c, SBQQ__RenewalQuoted__c,LPCR_JoursAvance__c FROM Contract 
                                         WHERE Id in :contractIds ];   
        for (Contract eachContract : listOfContract) {
            eachContract.SBQQ__RenewalQuoted__c=true;
            PAd.log('APB002_RenewalContract', 'execute', 'Updating contract '+eachContract);
        }
        
        update listOfContract;        
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    
    global void execute(SchedulableContext sc) {
        
        APB002_RenewalContract sc1 = new APB002_RenewalContract();
       
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
                sc1 = new APB002_RenewalContract();
                Datetime dt = Datetime.now().addMinutes(30);  // i.e. 30 mins
                String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
                Id schedId = System.Schedule('APB002_RenewalContract'+timeForScheduler,timeForScheduler,sc1);
            }
        }  
        
    } 
}