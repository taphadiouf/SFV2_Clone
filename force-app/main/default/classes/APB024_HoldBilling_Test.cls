/**
 * @description       :
 * @author            : Widaad Papauretty
 * @group             :
 * @last modified on  : 11-16-2021
 * @last modified by  : Widaad Papauretty
 **/
@isTest
public with sharing class APB024_HoldBilling_Test {
    private static final Id standardPricebookId = Test.getStandardPricebookId();
    private static final Id contratResaID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract, Label.LPCR_Reservataire);
    private static final Id CRECHE_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Creche);

    @testsetup
    static void setup() {
        SBQQ.TriggerControl.disable();
        try {
            UM002_TestDataFactory.insertBillingCustomSettings();

            blng__LegalEntity__c billingLegalEntity = UM002_TestDataFactory.setupLegalEntity();
            blng__RevenueRecognitionRule__c revRecRule = UM002_TestDataFactory.setupRevRec(billingLegalEntity.Id);
            blng__BillingRule__c billingRule = UM002_TestDataFactory.setupBillingRule(billingLegalEntity.Id);
            blng__TaxRule__c taxRule = UM002_TestDataFactory.setupTaxRule(billingLegalEntity.Id);

            Account acc = UM002_TestDataFactory.createAccounts(1, 'test').get(0);

            Account compteCreche = UM002_TestDataFactory.createAccounts(1, CRECHE_RT_ID, 'testcreche').get(0);

            insert new List<Account>{ acc, compteCreche };

            Opportunity opp = UM002_TestDataFactory.createOpportunities(1, 'test', 'Prospecting').get(0);
            insert opp;

            SBQQ__Quote__c quote = UM002_TestDataFactory.createQuote('test', opp.Id, acc.Id, standardPricebookId, 'Quote');
            quote.LPCR_IndexationConvenue__c = 'Non';
            quote.SBQQ__Primary__c = true;
            quote.SBQQ__Ordered__c = true;
            quote.LPCR_DateRevisionPrix__c = System.today();
            insert quote;

            Product2 prod = UM002_TestDataFactory.createProduct('test', billingRule.Id, revRecRule.Id, taxRule.Id);
            prod.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            insert prod;

            PricebookEntry priceBookEntry1 = UM002_TestDataFactory.createPricebookEntry(standardPricebookId, prod.Id);
            insert priceBookEntry1;

            SBQQ__QuoteLine__c quoteLine = UM002_TestDataFactory.createQuoteLine(prod.Id, quote.Id, priceBookEntry1.Id, 200, 1);
            quoteline.LPCR_Creche__c = compteCreche.id;
            insert quoteLine;

            opp.SBQQ__PrimaryQuote__c = quote.Id;
            update opp;

            Contract contract = UM002_TestDataFactory.createContract(acc.id, quote.id, opp.id, System.today().addDays(30));
            contract.LPCR_DateRevisionPrix__c = System.today();
            contract.LPCR_IndexationConvenue__c = 'Non';
            contract.SBQQ__RenewalUpliftRate__c = null;
            contract.SBQQ__Quote__c = quote.id;
            insert contract;

            Order order = UM002_TestDataFactory.createOrder(acc.Id, contract.id, date.today(), 'test', 'Draft', '1');
            order.Pricebook2Id = standardPricebookId;
            order.SBQQ__Quote__c = quote.id;
            order.type = 'New';
            insert order;

            contract.SBQQ__Order__c = order.id;
            update contract;

            OrderItem orderItem = UM002_TestDataFactory.createOrderProduct(priceBookEntry1.id, order.Id, prod.id, 'Recurring', 'Quarterly', 100);
            orderItem.blng__RevenueRecognitionRule__c = revRecRule.id;
            orderItem.blng__BillingRule__c = billingRule.id;
            orderItem.blng__TaxRule__c = taxRule.id;
            insert orderItem;
        } finally {
            SBQQ.TriggerControl.enable();
        }
    }

    @isTest
    private static void testAPB024() {
        Test.startTest();

        APB024_HoldBilling holdBilling = new APB024_HoldBilling();
        Database.executeBatch(holdBilling, 1);

        Test.stopTest();

        holdBilling.execute(null);
    }
}
