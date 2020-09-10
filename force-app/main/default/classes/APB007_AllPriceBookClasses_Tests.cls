/**
* @author Achraf ABOUL(aaboul@salesforce.com)
* @date 01/06/2020
* @Description Test Class for APB004_ActivateOrder and APB005_GenerateContractFromOrder and APB006_PrepaRenewalContract and SM008_QuoteServices 
*/
@isTest
public with sharing class APB007_AllPriceBookClasses_Tests {
    // These attributes are from the APB006 Test class
    private static final Integer NUMBER_OF_B2C = 3;
    private static final Integer NUMBER_OF_B2B = 0; // we set this to 0 due to the lookupfilter on Contract.AccountId which force the RT of the related account to (and just to) Famille
    private static final Integer NUMBER_OF_CRECHE = 3;
    private static final Id B2B_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Entreprise);
    private static final Id B2C_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Famille);
    private static final Id CRECHE_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Creche);
    @testsetup
    static void setup() {
        Id standardPricebookId = Test.getStandardPricebookId();

         UM002_TestDataFactory.insertBillingCustomSettings();
        
        blng__LegalEntity__c billingLegalEntity = UM002_TestDataFactory.setupLegalEntity();
        
        blng__RevenueRecognitionRule__c revRecRule = UM002_TestDataFactory.setupRevRec(billingLegalEntity.Id);
        
        blng__BillingRule__c billingRule = UM002_TestDataFactory.setupBillingRule(billingLegalEntity.Id);
        
        blng__TaxRule__c taxRule = UM002_TestDataFactory.setupTaxRule(billingLegalEntity.Id);
        
        Account acc = UM002_TestDataFactory.createAccounts(1,'test').get(0);
        insert acc;
        
        Opportunity opp = UM002_TestDataFactory.createOpportunities(1, 'test', 'Prospecting').get(0);
        insert opp;
        SBQQ__Quote__c quote = UM002_TestDataFactory.createQuote('test',opp.Id, acc.Id, standardPricebookId, 'Quote');

        quote.SBQQ__Primary__c =true;
        insert quote;
      
      
        
        Product2 prod = UM002_TestDataFactory.createProduct('test', billingRule.Id, revRecRule.Id,taxRule.Id );
        //This line is for the APB006 test
        prod.SBQQ__SubscriptionPricing__c ='Fixed Price';
        insert prod;
        
        PricebookEntry priceBookEntry1 = UM002_TestDataFactory.createPricebookEntry(standardPricebookId,prod.Id);
		insert priceBookEntry1;
        
        SBQQ__QuoteLine__c quoteLine = UM002_TestDataFactory.createQuoteLine(prod.Id, quote.Id, priceBookEntry1.Id, 200,1);
        insert quoteLine;
        opp.SBQQ__PrimaryQuote__c =quote.Id;
        update opp;
       
        quote.SBQQ__Ordered__c  = true;     
        update quote;

        //This part is for APB005
        Order order = Database.query('SELECT Id , Status ,OpportunityId,EffectiveDate FROM Order WHERE SBQQ__Quote__c  = \''+quote.Id+'\'');
        order.status ='Activated';
        //The purpose of this line is to differ between the order created in this setup and the orders created in the testAPB006PrepaRenewalContract method
        order.Name ='from_setup';
        update order;
        
    }
    //This test is from APB004_ActivateOrder_Test
    @isTest
    private static void activateOrderBatch_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){            
            Test.startTest();            
            SBQQ__Quote__c quote = Database.query('SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__BillingCity__c = \'test\'');
        	Order order = Database.query('SELECT Id , Status ,OpportunityId,EffectiveDate FROM Order WHERE SBQQ__Quote__c  = \''+quote.Id+'\'');
      
            APB004_ActivateOrder activateOrderBatch = new APB004_ActivateOrder();
            activateOrderBatch.execute(null);
            
        	order = Database.query('SELECT Id , Status ,OpportunityId,EffectiveDate FROM Order WHERE SBQQ__Quote__c  = \''+quote.Id+'\'');
            System.assertEquals('Activated', order.Status,'status is not get activated');
            Test.stopTest();
        }
    }
    //This test is from APB005_GenerateContractFromOrder_Test
    @isTest
    private static void genContFromOrderBatch_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){            
            Test.startTest();            
            SBQQ__Quote__c quote = Database.query('SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__BillingCity__c = \'test\'');
        	Order order = Database.query('SELECT Id , Status ,SBQQ__Contracted__c FROM Order WHERE SBQQ__Quote__c  = \''+quote.Id+'\'');
      
            APB005_GenerateContractFromOrder generateContractFromOrderBatch = new APB005_GenerateContractFromOrder();
            generateContractFromOrderBatch.execute(null);
            Test.stopTest();
            
        	order = Database.query('SELECT Id ,ContractId ,SBQQ__Contracted__c, Status  FROM Order WHERE SBQQ__Quote__c  = \''+quote.Id+'\'');
            System.assertEquals('Activated', order.Status,'status is not get activated');
            System.assertEquals(true, order.SBQQ__Contracted__c,'SBQQ__Contracted__c is false');
      
        }
    }
    //This test is from the APB006 Test Class
    @isTest
    private static void testAPB006PrepaRenewalContract(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
        //Data setup from The APB006 Test Class

        List<Account> accountsCreche = new List<Account>();
        List<Account> accounts = new List<Account>();

        for (Integer i = 0; i < NUMBER_OF_B2C; i++) {
            Account tmpAccount = UM002_TestDataFactory.createAccByRT('Customer B2C ' + i, B2C_RT_ID);
            tmpAccount.LPCR_IDCompteFamille__c = 'extId-' + i;
            accounts.add(tmpAccount);
        }

        for (Integer i = 0; i < NUMBER_OF_B2B; i++) {
            Account tmpAccount = UM002_TestDataFactory.createAccByRT('Customer B2B ' + i, B2B_RT_ID);
            accounts.add(tmpAccount);
        }

        for (Integer i = 0; i < NUMBER_OF_CRECHE; i++) {
            Account tmpAccount = UM002_TestDataFactory.createAccByRT('Creche' + i, CRECHE_RT_ID);
            tmpAccount.LPCR_TypeCreche__c = Math.mod(i, 2) == 0
                ? 'MAC'
                : 'MICRO';
                tmpAccount.LPCR_TypeMensualisation__c = 11;
            accountsCreche.add(tmpAccount);
        }
        //accounts.addAll(accountsCreche);
        insert accounts;
        insert accountsCreche;

        Id standardPricebookId = Test.getStandardPricebookId();

        Product2 prod = [SELECT Id from Product2 WHERE Name = 'test' limit 1];
        
        PricebookEntry priceBookEntry1 = [SELECT Id FROM PricebookEntry limit 1];
        
        //create 2 oppty for each customer
        List<Opportunity> opps = UM002_TestDataFactory.createOpportunities((NUMBER_OF_B2C + NUMBER_OF_B2B) * 2, 'test', 'Prospecting');
        insert opps;

        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        Integer counter = 0;
        for (Integer i = 0; i < accounts.size(); i++) {
            if (accounts.get(i).recordTypeId != CRECHE_RT_ID) {
                SBQQ__Quote__c tmpPrimaryQuote1 = UM002_TestDataFactory.createQuote('test', opps.get(counter++).Id, accounts.get(i).Id, standardPricebookId, 'Quote');
                tmpPrimaryQuote1.SBQQ__Primary__c = true;
                quotes.add(tmpPrimaryQuote1);

                SBQQ__Quote__c tmpPrimaryQuote2 = UM002_TestDataFactory.createQuote('test', opps.get(counter++).Id, accounts.get(i).Id, standardPricebookId, 'Quote');
                tmpPrimaryQuote2.SBQQ__Primary__c = true;
                quotes.add(tmpPrimaryQuote2);
            }
        }
        insert quotes;
        
        List<SBQQ__QuoteLine__c> qlines = new List<SBQQ__QuoteLine__c> ();
        List<Opportunity> opptToUpdate = new List<Opportunity> ();
        for (SBQQ__Quote__c q : quotes) {
            qlines.add(UM002_TestDataFactory.createQuoteLine(prod.Id, q.Id, priceBookEntry1.Id, 200, 1));
            opptToUpdate.add(new Opportunity(id = q.SBQQ__Opportunity2__c, SBQQ__PrimaryQuote__c = q.Id));

            q.SBQQ__Ordered__c = true; 
            q.LPCR_IndexationConvenue__c = 'Oui';
            q.LPCR_TypeFacturation__c = 'Arrears';
            q.SBQQ__BillingFrequency__c = 'Invoice Plan';
            q.SBQQ__RenewalUpliftRate__c = 2;
        }
        insert qlines;
        update opptToUpdate;
        update quotes;
        //The ' WHERE Name != 'from_setup' statement is to get just the orders created in this method and not the ones created in setup method
        List<Order> orders = [SELECT Id, Name, SBQQ__Contracted__c, Status, OpportunityId, EffectiveDate, AccountId, SBQQ__Quote__c FROM Order WHERE Name != 'from_setup'];
        for (Order order : orders) {
            order.status = 'Activated';
            //order.SBQQ__Contracted__c=true; 
        }
        update orders;

        List<Contract> contracts = new List<Contract>();
        Map<Id, Id> crecheByCustomer = new Map<Id, Id>();
        counter = 0;
        for (Order order : orders) {
            Contract tmpContract = UM002_TestDataFactory.createContract(order.AccountId, order.SBQQ__Quote__c, order.Id);
            tmpContract.LPCR_RenouvellementAutomatique__c = true;
            tmpContract.StartDate = System.today().addMonths(-1);
            tmpContract.SBQQ__RenewalQuoted__c = false;
            tmpContract.ContractTerm = 1;
            if (!crecheByCustomer.containsKey(order.AccountId)) {
                crecheByCustomer.put(order.AccountId, accountsCreche.get(Math.mod(counter++, 2)).Id);
            } 

            tmpContract.LPCR_Creche__c = crecheByCustomer.get(order.AccountId);
            tmpContract.Status='Draft';

            contracts.add(tmpContract);
        }
        insert contracts; 

        // adjust contract LPCR_JoursAvance__c
        contracts = [SELECT Id, LPCR_JoursAvance__c, EndDate FROM Contract];
        for (Contract c : contracts) {
            Integer diffEndDate = c.EndDate.daysBetween(System.today());
            c.LPCR_JoursAvance__c = c.EndDate < System.today()
                ? diffEndDate
                : -1 * diffEndDate;
        }

        update contracts;

        for (Contract c : contracts) {
            c.Status='Activated';
        }
        update contracts;
        //End Of Data setup from The APB006 Test Class

        
       
            APB006_PrepaRenewalContract btch = new APB006_PrepaRenewalContract();
            Database.executeBatch(btch, 2000);
            List<Contract> listAllContracts = [SELECT Id, SBQQ__Order__c, TECH_AjoutFraisGestion__c, LPCR_TypeFacturation__c, Status, StartDate, ContractTerm,LPCR_DateRenouvellement__c,LPCR_RenouvellementAutomatique__c, SBQQ__RenewalQuoted__c, LPCR_JoursAvance__c, SBQQ__RenewalForecast__c, EndDate FROM Contract];
            List<Contract> listContractsWithFees = [SELECT Id, SBQQ__Order__c, TECH_AjoutFraisGestion__c, LPCR_TypeFacturation__c, Status, StartDate, ContractTerm,LPCR_DateRenouvellement__c,LPCR_RenouvellementAutomatique__c, SBQQ__RenewalQuoted__c, LPCR_JoursAvance__c, SBQQ__RenewalForecast__c, EndDate FROM Contract WHERE TECH_AjoutFraisGestion__c = true];
            // Assert to verify that just a subset of contract (50% - 1 for each pair customer / creche) have been updated by the batch 
            System.assertEquals((NUMBER_OF_B2C + NUMBER_OF_B2B) * 2, listAllContracts.size());
            //System.assertEquals(NUMBER_OF_B2C + NUMBER_OF_B2B, listContractsWithFees.size());
            Test.stopTest();

            
        }
    }
}