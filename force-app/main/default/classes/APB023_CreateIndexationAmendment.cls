global class APB023_CreateIndexationAmendment implements Database.Batchable<sObject>,Database.AllowsCallouts,Schedulable {
    String query;
    final String ClassName = APB023_CreateIndexationAmendment.class.getName();
    final private static String TYPEAVENANT_INDEXATION = 'Amendement d\'indexation';

    global APB023_CreateIndexationAmendment() {
        
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'start', 'Batch' , null, 'Starting Batch', UM010_Constant.SUCCESS);
        Id contratResaID  = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract, Label.LPCR_Reservataire);
        //select Contract for which amendement indexation needs to be created
        return Database.getQueryLocator([Select id ,LPCR_IndexationConvenue__c,LPCR_DateRevisionPrix__c,LPCR_InitAutoAvecDateDebut__c,SBQQ__RenewalUpliftRate__c,SBQQ__Order__c From Contract where  LPCR_DateRevisionPrix__c !=null and LPCR_TechDateRevisionActuel__c =TODAY and RecordTypeId =:contratResaID]);
        
    }
    public void execute(Database.BatchableContext BC, list<Contract> scope){
        List<SBQQ__QuoteLine__c> listCloneQuoteLine = new List<SBQQ__QuoteLine__c>();
        List<Contract> lstContractUpd= new List<Contract>();
        for(Contract tmpContract : scope){
            
            UM006_ContractAmender amender = new UM006_ContractAmender();
            WRP001_QuoteModel quote = amender.load(tmpContract.Id);
            UM007_QuoteReader reader = new UM007_QuoteReader();
            WRP001_QuoteModel quoteModel = reader.read(quote.record.id);
            APC006_CloneQuoteLinesIndexation.cloneAndResetQL(quoteModel.record.id, tmpContract.SBQQ__RenewalUpliftRate__c, tmpContract.LPCR_DateRevisionPrix__c);
            
            quoteModel.record.SBQQ__RenewalUpliftRate__c = tmpContract.SBQQ__RenewalUpliftRate__c;
            quoteModel.record.LPCR_DateRevisionPrix__c = tmpContract.LPCR_DateRevisionPrix__c.addYears(1);
            quoteModel.record.LPCR_TypeAvenant__c = TYPEAVENANT_INDEXATION;
            
            SBQQ__Quote__c quote1 = quoteModel.record;
            update quote1;
            
            
            quoteModel = reader.read(quote.record.id);
            
            for(WRP002_QuoteLineModel eachQuoteLine : quoteModel.lineItems){
                if (eachQuoteLine.record.LPCR_IndexationQuote__c  == true) {
                    
                    SBQQ__QuoteLine__c updateQLI = eachQuoteLine.record;
                    listCloneQuoteLine.add(updateQLI);            	
                }
            }
            tmpContract.SBQQ__AmendmentStartDate__c=null;
            lstContractUpd.add(tmpContract);
        }
        if(listCloneQuoteLine.size() > 0 ){
            update listCloneQuoteLine;
        }
        if(lstContractUpd.size() > 0 ){
            update lstContractUpd;
        }
        
    }
    public void finish(Database.BatchableContext BC){
        
        
    }
    global void execute(SchedulableContext sc) {
        APB023_CreateIndexationAmendment sc1 = new APB023_CreateIndexationAmendment();
        //PDO : Modify waiting time for test 
        Datetime dt = Datetime.now().addMinutes(30);
        String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
        // schedule the apex class only if their is not existing job running
        boolean isBatchJobRunning = UM004_BatchUtility.isBatchJobRunning('APB023_CreateIndexationAmendment');
        
        // check if there is any open place to schedule the class
        boolean isJobQueueFull = UM004_BatchUtility.isBatchJobQueueFull();
        
        if(isBatchJobRunning == UM004_BatchUtility.BOOLEAN_FALSE){
            if (isJobQueueFull == UM004_BatchUtility.BOOLEAN_FALSE) {
                sc1 = new APB023_CreateIndexationAmendment();
                Database.executeBatch(this, 1);
            } else {
                //schedule this same schedulable class again in 30 mins
                 Id schedId = System.Schedule('APB023_CreateIndexationAmendment'+timeForScheduler,timeForScheduler,new APB023_CreateIndexationAmendment());
            }
        }  
    }
}