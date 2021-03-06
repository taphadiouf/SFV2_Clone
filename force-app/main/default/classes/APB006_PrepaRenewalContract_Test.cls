/**
* @author Achraf ABOUL(aaboul@salesforce.com)
* @date 01/06/2020
* @Description Test Class for APB004_ActivateOrder and APB005_GenerateContractFromOrder and APB006_PrepaRenewalContract and SM008_QuoteServices 
*/
@isTest
public with sharing class APB006_PrepaRenewalContract_Test {
    // These attributes are from the APB006 Test class
    private static final Id standardPricebookId = Test.getStandardPricebookId();
    private static final Integer NUMBER_OF_B2C = 1;
    private static final Integer NUMBER_OF_B2B = 0; // we set this to 0 due to the lookupfilter on Contract.AccountId which force the RT of the related account to (and just to) Famille
    private static final Integer NUMBER_OF_CRECHE = 1;
    private static final Id B2B_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Entreprise);
    private static final Id B2C_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Famille);
    private static final Id CRECHE_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Creche);
    @testsetup
    static void setup() {
        

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









    //This test is from the APB006 Test Class
    @isTest
    private static void testAPB006PrepaRenewalContract(){
            
        //Data setup from The APB006 Test Class

        List<Account> accountsCreche = new List<Account>();
        List<Account> accounts = new List<Account>();

        for (Integer i = 0; i < NUMBER_OF_B2C; i++) {
            Account tmpAccount = UM002_TestDataFactory.createAccByRT('Customer B2C ' + i, B2C_RT_ID);
            tmpAccount.LPCR_IDCompteFamille__c = 'extId-' + i;
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
        List<Opportunity> opps = UM002_TestDataFactory.createOpportunities((NUMBER_OF_B2C) * 2, 'test', 'Prospecting');
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

        Test.startTest();
        insert quotes;
        List<SBQQ__QuoteLine__c> qlines = new List<SBQQ__QuoteLine__c> ();
        List<Opportunity> opptToUpdate = new List<Opportunity> ();
        
        
        integer qSize = quotes.size();

        for(Integer i=0;i<qSize;i++){
            SBQQ__Quote__c q = quotes[i];

            qlines.add(UM002_TestDataFactory.createQuoteLine(prod.Id, q.Id, priceBookEntry1.Id, 200, 1));
            opptToUpdate.add(new Opportunity(id = q.SBQQ__Opportunity2__c, SBQQ__PrimaryQuote__c = q.Id));

            q.SBQQ__Ordered__c = true; 
            q.LPCR_IndexationConvenue__c = 'Oui';
            q.LPCR_TypeFacturation__c = 'Advance';
            q.SBQQ__BillingFrequency__c = 'Invoice Plan';
            q.SBQQ__RenewalUpliftRate__c = 2;
        }

        insert qlines;

        List<SObject> toUpdate = new list<SObject>();
        toUpdate.addAll(opptToUpdate);
        toUpdate.addAll(quotes);
        update toUpdate;
        //The ' WHERE Name != 'from_setup' statement is to get just the orders created in this method and not the ones created in setup method
        List<Order> orders = [SELECT Id, Name, SBQQ__Contracted__c, Status, OpportunityId, EffectiveDate, AccountId, SBQQ__Quote__c FROM Order WHERE Name != 'from_setup'];
        
        integer oSize = orders.size();

        for(Integer i=0;i<oSize;i++){
            orders[i].status = 'Activated';
        }
        update orders;

        List<Contract> contracts = new List<Contract>();
        Map<Id, Id> crecheByCustomer = new Map<Id, Id>();
        counter = 0;
        Id ReservataireRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract,Label.LPCR_Reservataire);
        
        
        for(Integer i=0;i<oSize;i++){
            Order order = orders[i];
            Contract tmpContract = UM002_TestDataFactory.createContract(order.AccountId, order.SBQQ__Quote__c, order.Id);
            tmpContract.LPCR_RenouvellementAutomatique__c = true;
            tmpContract.StartDate = System.today().addMonths(-1);
            tmpContract.SBQQ__RenewalQuoted__c = false;
            tmpContract.ContractTerm = 1;
            tmpContract.recordTypeId = ReservataireRT;
            tmpContract.SBQQ__RenewalQuoted__c=false;
            tmpContract.LPCR_TypeFacturation__c = 'Advance';
            tmpContract.EndDate = System.today().addDays(-1);
            tmpContract.LPCR_Creche__c = accountsCreche.get(0).id;
            tmpContract.Status='Draft';

            contracts.add(tmpContract);
        }


        insert contracts; 

        // adjust contract LPCR_JoursAvance__c
        contracts = [SELECT Id, LPCR_Creche__c,LPCR_JoursAvance__c, EndDate FROM Contract];

        integer cSize = contracts.size();
        for(Integer i=0;i<cSize;i++){
            Contract c = contracts[i];

            if (c != null && c.EndDate != null) {
                Integer diffEndDate = c.EndDate.daysBetween(System.today());
                c.LPCR_JoursAvance__c = (c.EndDate < System.today()) ? diffEndDate : -1 * diffEndDate;
                c.LPCR_Creche__c = accountsCreche.get(0).id;
            }
        }
        update contracts;

        for(Integer i=0;i<cSize;i++){
            contracts[i].Status='Activated';
        }
        update contracts;

        APB006_PrepaRenewalContract btch = new APB006_PrepaRenewalContract();
        Database.executeBatch(btch, 2000);
        Test.stopTest();

        List<Contract> listAllContracts = [SELECT Id, SBQQ__Order__c, TECH_AjoutFraisGestion__c, LPCR_TypeFacturation__c, Status, StartDate, ContractTerm,LPCR_DateRenouvellement__c,LPCR_RenouvellementAutomatique__c, SBQQ__RenewalQuoted__c, LPCR_JoursAvance__c, SBQQ__RenewalForecast__c, EndDate FROM Contract];

        System.assertEquals((NUMBER_OF_B2C) * 2, listAllContracts.size());

    }
}