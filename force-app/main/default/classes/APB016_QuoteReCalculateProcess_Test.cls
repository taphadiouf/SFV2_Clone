@isTest
public with sharing class APB016_QuoteReCalculateProcess_Test {
    
    
    @isTest
    static void testAPB016_QuoteReCalculateProcess_Test() {

        //ACC OPP QUOTE
        List<Account> accs = UM002_TestDataFactory.createAccounts(1,'testAccount');
        insert accs;
        List<Opportunity> oppties = UM002_TestDataFactory.createOpportunities(1, 'testOpp', 'Prospecting');
        insert oppties;
        SBQQ__Quote__c quote =UM002_TestDataFactory.createQuotes(1, accs, oppties).get(0);
        insert quote;


        UM002_TestDataFactory.insertBillingCustomSettings();
        //Not Used
        blng__LegalEntity__c billingLegalEntity = UM002_TestDataFactory.setupLegalEntity();
        //Used
        blng__RevenueRecognitionRule__c revRecRule = UM002_TestDataFactory.setupRevRec(billingLegalEntity.Id);
        blng__BillingRule__c billingRule = UM002_TestDataFactory.setupBillingRule(billingLegalEntity.Id);
        blng__TaxRule__c taxRule = UM002_TestDataFactory.setupTaxRule(billingLegalEntity.Id);
        Id standardPricebookId = Test.getStandardPricebookId();

        Map<String, Object> defaultVal; 

        //Produit
        defaultVal = new Map<String, Object> {
            'Name' => 'prod-test',
            'isActive' => true,
            'blng__BillingRule__c' => billingRule.Id,
            'blng__RevenueRecognitionRule__c' => revRecRule.Id,
            'blng__TaxRule__c' => taxRule.Id,
            'SBQQ__SubscriptionPricing__c' => 'Fixed Price',
            'SBQQ__SubscriptionTerm__c' => 12,
            'ProductCode' => Label.LPCR_RegistrationFeeMac
        };
        Product2 prod = (Product2) UM002_TestDataFactory.createSObject('Product2', defaultVal);
        insert prod;

        //PriceBook
        defaultVal = new Map<String, Object> {
            'isActive' => true,
            'UnitPrice' => 100,
            'Product2Id' => prod.Id,
            'Pricebook2Id' => standardPricebookId
        };
        PricebookEntry priceBookEntry = (PricebookEntry) UM002_TestDataFactory.createSObject('PricebookEntry', defaultVal);
        insert priceBookEntry;

        // QUOTE LINE
        Integer price = 200;
        SBQQ__QuoteLine__c quoteLine = UM002_TestDataFactory.createQuoteLine((string)prod.Id, (string)quote.Id, (string)priceBookEntry.Id, (decimal)price, 1);
        quoteLine.LPCR_Quote_Recalculated__c = false;
        insert quoteLine;

        test.startTest();

        APB016_QuoteReCalculateProcess sc1 = new APB016_QuoteReCalculateProcess();
        sc1.quoteIds.add(quote.Id);
        sc1.execute(null);

        test.stopTest();

        SBQQ__QuoteLine__c quoteAfter = [SELECT LPCR_Quote_Recalculated__c FROM SBQQ__QuoteLine__c WHERE id=:quoteLine.id];
        System.Assert(quoteAfter.LPCR_Quote_Recalculated__c);
    }
}
