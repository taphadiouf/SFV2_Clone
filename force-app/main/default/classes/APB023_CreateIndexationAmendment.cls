global class APB023_CreateIndexationAmendment implements Database.Batchable<sObject>,Database.AllowsCallouts,Schedulable {
    String query;
    final String ClassName = APB023_CreateIndexationAmendment.class.getName();
    global APB023_CreateIndexationAmendment() {
        
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {

        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'start', 'Batch' , null, 'Starting Batch', UM010_Constant.SUCCESS);
        //select Contract for which amendement indexation needs to be created
        //return Database.getQueryLocator([Select id ,LPCR_IndexationConvenue__c,LPCR_DateRevisionPrix__c,LPCR_InitAutoAvecDateDebut__c,SBQQ__RenewalUpliftRate__c,SBQQ__Order__c From Contract where  LPCR_DateRevisionPrix__c=TODAY ]);
        return Database.getQueryLocator([Select id ,LPCR_IndexationConvenue__c,LPCR_DateRevisionPrix__c,LPCR_InitAutoAvecDateDebut__c,SBQQ__RenewalUpliftRate__c,SBQQ__Order__c From Contract where  id='8000E0000017gyoQAA' ]);
                                        
    }
    public void execute(Database.BatchableContext BC, list<Contract> scope){
        
        for(Contract tmpContract : scope){
            //indexation convenue facturation specifique
            //if(tmpContract.LPCR_IndexationConvenue__c =='Oui' ){
                UM006_ContractAmender amender = new UM006_ContractAmender();
                WRP001_QuoteModel quote = amender.load(tmpContract.Id);
                UM007_QuoteReader reader = new UM007_QuoteReader();
                WRP001_QuoteModel quoteModel = reader.read(quote.record.id);
                APC006_CloneQuoteLinesIndexation.cloneAndResetQL(quoteModel.record.id, tmpContract.SBQQ__RenewalUpliftRate__c, tmpContract.LPCR_DateRevisionPrix__c);

                quoteModel.record.SBQQ__RenewalUpliftRate__c = tmpContract.SBQQ__RenewalUpliftRate__c;
                quoteModel.record.LPCR_DateRevisionPrix__c = tmpContract.LPCR_DateRevisionPrix__c.addYears(1);
            
                SBQQ__Quote__c quote1 = quoteModel.record;
                update quote1;


                quoteModel = reader.read(quote.record.id);

                List<SBQQ__QuoteLine__c> listCloneQuoteLine = new List<SBQQ__QuoteLine__c>();
                for(WRP002_QuoteLineModel eachQuoteLine : quoteModel.lineItems){

                    System.Debug('>> AUTOMATION - eachQuoteLine.record:' + eachQuoteLine.record);

                    if (eachQuoteLine.record.LPCR_IndexationQuote__c  == true) {

                        SBQQ__QuoteLine__c updateQLI = eachQuoteLine.record;
                        listCloneQuoteLine.add(updateQLI);            	
                    }
                }

                update listCloneQuoteLine;



            //tmpContract.UpliftNow__c = false;
            update tmpContract;
           // }
            
        
            
        }
        //indexation pas convenue , order item ( hold billing blng__HoldBilling__c on OrderItem):another batch 
        
        
        
    }
    public void finish(Database.BatchableContext BC){
        
    }
    global void execute(SchedulableContext sc) {
    }
}

