/**
*@author Achraf ABOUL(aaboul@salesforce.com)
*@date 21/05/2020
*&description test class for APC006_CloneQuoteLines
*/
@isTest
public with sharing class APC006_CloneQuoteLines_Test {
    @TestSetup
    static void setup(){
        Id standardPricebookId;
        if([SELECT Id FROM Pricebook2 WHERE IsStandard=true].size() > 0){
            standardPricebookId = [SELECT Id FROM Pricebook2 WHERE IsStandard=true].Id;
        }else{
            standardPricebookId = Test.getStandardPricebookId();
        }
        SBQQ__Quote__c quote = UM002_TestDataFactory.createQuote(standardPricebookId, 'Quote');
        quote.SBQQ__Primary__c =true;
        insert quote;
        
        Product2 prod = UM002_TestDataFactory.createProduct('test');
        insert prod;
        
        PricebookEntry priceBookEntry1 = UM002_TestDataFactory.createPricebookEntry(standardPricebookId,prod.Id);
		insert priceBookEntry1;
        
        SBQQ__QuoteLine__c quoteLine1 = UM002_TestDataFactory.createQuoteLine(prod.Id, quote.Id, priceBookEntry1.Id, 200,1);
        quoteLine1.LPCR_CloneCancel__c = true;
        quoteLine1.SBQQ__Number__c = 1;
        insert quoteLine1;

        SBQQ__QuoteLine__c quoteLine2 = UM002_TestDataFactory.createQuoteLine(prod.Id, quote.Id, priceBookEntry1.Id, 200,1);
        quoteLine2.SBQQ__RequiredBy__c = quoteLine1.Id;
        quoteLine2.LPCR_CloneCancel__c = true;
        quoteLine2.SBQQ__Number__c = 2;
        insert quoteLine2;
       
    }
    @IsTest
    static void cloneAndResetQL_Test(){
        Id quoteId = [SELECT Id from SBQQ__Quote__c limit 1].get(0).Id;
        Test.startTest(); 
        APC006_CloneQuoteLines.cloneAndResetQL(quoteId);
        Test.stopTest();
    }

    @IsTest
    static void cloneAndResetQL_Exception1_Test(){
        Id quoteId = [SELECT Id from SBQQ__Quote__c limit 1].get(0).Id;
        Test.startTest(); 
        APC006_CloneQuoteLines.testRunningFlag1 = true;
        APC006_CloneQuoteLines.cloneAndResetQL(quoteId);
        Test.stopTest();
    }
    @IsTest
    static void cloneAndResetQL_Exception2_Test(){
        Id quoteId = [SELECT Id from SBQQ__Quote__c limit 1].get(0).Id;
        Test.startTest(); 
        APC006_CloneQuoteLines.testRunningFlag2 = true;
        APC006_CloneQuoteLines.cloneAndResetQL(quoteId);
        Test.stopTest();
    }
}