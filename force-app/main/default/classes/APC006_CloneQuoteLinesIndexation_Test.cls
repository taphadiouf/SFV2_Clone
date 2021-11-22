/**
 * @description       : 
 * @author            : Widaad Papauretty
 * @group             : 
 * @last modified on  : 11-16-2021
 * @last modified by  : Widaad Papauretty
**/
@isTest
public with sharing class APC006_CloneQuoteLinesIndexation_Test {
    private static final Id CRECHE_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Creche);

    @TestSetup
    static void setup(){
        Id standardPricebookId = Test.getStandardPricebookId();
        
        Account compteCreche = UM002_TestDataFactory.createAccounts(1, CRECHE_RT_ID, 'testcreche').get(0);

        insert new List<Account>{compteCreche };

        SBQQ__Quote__c quote = UM002_TestDataFactory.createQuote(standardPricebookId, 'Quote');
        quote.SBQQ__Primary__c =true;
        insert quote;
        
        Product2 prod = UM002_TestDataFactory.createProduct('test');
        insert prod;
        
        PricebookEntry priceBookEntry1 = UM002_TestDataFactory.createPricebookEntry(standardPricebookId,prod.Id);
		insert priceBookEntry1;
        
        SBQQ.TriggerControl.disable();
        SBQQ__QuoteLine__c quoteLine1 = UM002_TestDataFactory.createQuoteLine(prod.Id, quote.Id, priceBookEntry1.Id, 200,1);
        quoteLine1.LPCR_CloneCancel__c = true;
        quoteLine1.SBQQ__Number__c = 1;
        quoteLine1.SBQQ__CustomerPrice__c = 200;
        quoteLine1.SBQQ__ProrateMultiplier__c = 5; 
        quoteLine1.LPCR_Creche__c = compteCreche.id;
        insert quoteLine1;

        SBQQ__QuoteLineConsumptionSchedule__c qlCS = new SBQQ__QuoteLineConsumptionSchedule__c (SBQQ__QuoteLine__c = quoteLine1.id,
        SBQQ__BillingTermUnit__c = 'Month', SBQQ__BillingTerm__c = 1, SBQQ__Category__c = 'Rates',  SBQQ__RatingMethod__c = 'Tier', SBQQ__Type__c = 'Range');
        insert qlCS;

        SBQQ__QuoteLineConsumptionRate__c qlCR = new SBQQ__QuoteLineConsumptionRate__c (SBQQ__QuoteLineConsumptionSchedule__c = qlCS.id, SBQQ__LowerBound__c = 1, SBQQ__Price__c= 1.03, SBQQ__PricingMethod__c = 'PerUnit', SBQQ__ProcessingOrder__c = 10);
        insert qlCR;
        SBQQ.TriggerControl.enable();
       
    }
    @IsTest
    static void cloneAndResetQL_Test(){
        Id quoteId = [SELECT Id from SBQQ__Quote__c limit 1].get(0).Id;
        Test.startTest(); 
        APC006_CloneQuoteLinesIndexation.cloneAndResetQL(quoteId, 3, System.today());
        Test.stopTest();
    }

}
