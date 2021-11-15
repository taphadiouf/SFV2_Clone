/**
 * @description       : 
 * @author            : Widaad Papauretty
 * @group             : 
 * @last modified on  : 11-15-2021
 * @last modified by  : Widaad Papauretty
**/

@isTest
public with sharing class APB023_CreateIndexationAmendment_Test {
    
    private static final Id standardPricebookId = Test.getStandardPricebookId();
    private static final Id contratResaID  = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract, Label.LPCR_Reservataire);
    private static final Id CRECHE_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Creche);
    
    @testsetup
    static void setup() {
        

         UM002_TestDataFactory.insertBillingCustomSettings();
        
        blng__LegalEntity__c billingLegalEntity = UM002_TestDataFactory.setupLegalEntity();
        blng__RevenueRecognitionRule__c revRecRule = UM002_TestDataFactory.setupRevRec(billingLegalEntity.Id);
        blng__BillingRule__c billingRule = UM002_TestDataFactory.setupBillingRule(billingLegalEntity.Id);
        blng__TaxRule__c taxRule = UM002_TestDataFactory.setupTaxRule(billingLegalEntity.Id);

        Account acc = UM002_TestDataFactory.createAccounts(1,'test').get(0);

        Account compteCreche=UM002_TestDataFactory.createAccounts(1,CRECHE_RT_ID,'testcreche').get(0);

        insert new List<Account>{acc, compteCreche};

        Opportunity opp = UM002_TestDataFactory.createOpportunities(1, 'test', 'Prospecting').get(0);
        insert opp;

        SBQQ__Quote__c quote = UM002_TestDataFactory.createQuote('test',opp.Id, acc.Id, standardPricebookId, 'Quote');

        quote.SBQQ__Primary__c =true;
        insert quote;

        Product2 prod = UM002_TestDataFactory.createProduct('test', billingRule.Id, revRecRule.Id,taxRule.Id );
       
        prod.SBQQ__SubscriptionPricing__c ='Fixed Price';
        insert prod;

        PricebookEntry priceBookEntry1 = UM002_TestDataFactory.createPricebookEntry(standardPricebookId,prod.Id);
		insert priceBookEntry1;

        SBQQ__QuoteLine__c quoteLine = UM002_TestDataFactory.createQuoteLine(prod.Id, quote.Id, priceBookEntry1.Id, 200,1);
        quoteline.LPCR_Creche__c = compteCreche.id;
        insert quoteLine;

        opp.SBQQ__PrimaryQuote__c =quote.Id;
        update opp;
        
    }

    @isTest
    private static void testAPB023(){

        Test.startTest();
        Account acc = [SELECT Id, name from Account where name ='test' LIMIT 1];

        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c WHERE	SBQQ__Account__c=: acc.id];

        quote.SBQQ__Ordered__c = true;
        quote.LPCR_DateRevisionPrix__c = System.today().addDays(35);
        update quote;

        Order order = [SELECT Id FROM Order WHERE SBQQ__Quote__c  =: quote.Id];
        order.Status = 'Activated';
        order.SBQQ__Contracted__c = true;
        update order;

        Contract contract = UM002_TestDataFactory.createContract(acc.id, quote.id, order.Id);
        contract.RecordTypeId = contratResaID;
        contract.LPCR_DateRevisionPrix__c = System.today().addDays(35);
        insert contract;

        List<Contract> lstContracts = [SELECT Id, LPCR_TechDateRevisionActuel__c,LPCR_DateRevisionPrix__c, RecordTypeId FROM Contract WHERE SBQQ__Order__c =:order.Id];

        System.debug('contract: '+lstContracts);

        List<Contract> testContracts = [SELECT id ,LPCR_IndexationConvenue__c,LPCR_DateRevisionPrix__c,LPCR_InitAutoAvecDateDebut__c,SBQQ__RenewalUpliftRate__c,SBQQ__Order__c FROM Contract WHERE  LPCR_DateRevisionPrix__c !=null and LPCR_TechDateRevisionActuel__c =TODAY and RecordTypeId =:contratResaID];

        
        System.debug('test: ' +testContracts);
        APB023_CreateIndexationAmendment createIndexationAmendment = new APB023_CreateIndexationAmendment();
        Database.executeBatch(createIndexationAmendment, 200);

        Test.stopTest();
        createIndexationAmendment.execute(null);
    }
}
