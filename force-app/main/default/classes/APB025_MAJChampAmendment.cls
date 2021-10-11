global class APB025_MAJChampAmendment implements Database.Batchable<sObject>,Database.AllowsCallouts,Schedulable {
    //Batch to be executed for update of Date amendement for uplift to be included in desired date 
    String query;
    final String ClassName = APB025_MAJChampAmendment.class.getName();
    global APB025_MAJChampAmendment() {
        
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {

        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'start', 'Batch' , null, 'Starting Batch', UM010_Constant.SUCCESS);
        //select Contract for which amendement indexation needs to be created
        return Database.getQueryLocator([Select id ,LPCR_IndexationConvenue__c,LPCR_DateRevisionPrix__c,LPCR_InitAutoAvecDateDebut__c,SBQQ__RenewalUpliftRate__c,SBQQ__Order__c From Contract where  LPCR_DateRevisionPrix__c !=null]);
                                        
    }
    public void execute(Database.BatchableContext BC, list<Contract> scope){
        List<Contract> lstContractUpd= new List<Contract>();
        List<LPCR_Log__c> listOfLog = new List<LPCR_Log__c>();
		for(Contract tmpContract : scope){
			tmpContract.SBQQ__AmendmentStartDate__c=tmpContract.LPCR_DateRevisionPrix__c;
           	lstContractUpd.add(tmpContract);
            listOfLog.add(UM001_LogManager.getWriteLogActivityForBulkInsert('', ClassName, 'Batch', String.valueOf(tmpContract.Id), '', 'SUCCESS'));             
           
        }
        if(lstContractUpd.size() > 0 ){
            update lstContractUpd;
            insert listOfLog;
        }
        
    }
    public void finish(Database.BatchableContext BC){
        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'finish', 'Batch' , null, 'Finished Batch Processing', UM010_Constant.SUCCESS);
        PAD.log(ClassName, 'finish', 'Start finish method');
        // schedule the apex class only if their is not existing job running
        boolean isBatchJobRunning = UM004_BatchUtility.isBatchJobRunning('APB023_CreateIndexationAmendment');
        // check if there is any open place to schedule the class
        boolean isJobQueueFull = UM004_BatchUtility.isBatchJobQueueFull();
        if(!isBatchJobRunning && !isJobQueueFull && !Test.isRunningTest()) {
            PAD.log(ClassName, 'finish', 'launching APB023_CreateIndexationAmendment');
		    Database.executeBatch(new APB023_CreateIndexationAmendment(), 1);
        }
    }
    global void execute(SchedulableContext sc) {
    }
}