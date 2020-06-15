/**
*@author Achraf ABOUL(aaboul@salesforce.com)
*@Created 08/06/2020
*&description test class for APC008_ResetQuoteLines
*/
@isTest
public class APC008_ResetQuoteLines_Test {
    @TestSetup
    static void setup(){
        Id standardPricebookId = Test.getStandardPricebookId();

        SBQQ__Quote__c quote = UM002_TestDataFactory.createQuote(standardPricebookId, 'Quote');
        quote.SBQQ__Primary__c =true;
        insert quote;
        
        Product2 prod = UM002_TestDataFactory.createProduct('test');
        insert prod;
        
        PricebookEntry priceBookEntry1 = UM002_TestDataFactory.createPricebookEntry(standardPricebookId,prod.Id);
		insert priceBookEntry1;
        
        SBQQ__QuoteLine__c quoteLine1 = UM002_TestDataFactory.createQuoteLine(prod.Id, quote.Id, priceBookEntry1.Id, 200,1);
        quoteLine1.SBQQ__Quantity__c = 10;
        insert quoteLine1;

        SBQQ__QuoteLine__c quoteLine2 = UM002_TestDataFactory.createQuoteLine(prod.Id, quote.Id, priceBookEntry1.Id, 200,1);
        quoteLine2.SBQQ__RequiredBy__c = quoteLine1.Id;
        quoteLine2.SBQQ__Quantity__c = 10;
        insert quoteLine2;
       
    }
    @IsTest
    static void cloneAndResetQL_Test(){
        Id quoteId = [SELECT Id from SBQQ__Quote__c limit 1].get(0).Id;
        Test.startTest(); 
        APC008_ResetQuoteLines.resetQuantity(quoteId);
        Test.stopTest();
        List<SBQQ__QuoteLine__c> qlines = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quantity__c = 0 ];
        System.assertEquals(2, qlines.size());
    }

    @IsTest
    static void cloneAndResetQL_Exception1_Test(){
        Id quoteId = [SELECT Id from SBQQ__Quote__c limit 1].get(0).Id;
        Test.startTest(); 
        APC008_ResetQuoteLines.testRunningFlag1 = true;
        APC008_ResetQuoteLines.resetQuantity(quoteId);
        Test.stopTest();
    }
}