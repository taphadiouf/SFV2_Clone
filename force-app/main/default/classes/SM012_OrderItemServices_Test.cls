/**
* @author Ayoub Ouarti
* @date 26/03/2020
* @description test class for SM012_OrderItemServices
*/
@isTest
public with sharing class SM012_OrderItemServices_Test {
    
    @TestSetup
    static void setup(){
        Id standardPricebookId = Test.getStandardPricebookId();
        
        UM002_TestDataFactory.insertBillingCustomSettings();
        
        blng__LegalEntity__c billingLegalEntity = UM002_TestDataFactory.setupLegalEntity();
        
        blng__RevenueRecognitionRule__c revRecRule = UM002_TestDataFactory.setupRevRec(billingLegalEntity.Id);
        
        blng__BillingRule__c billingRule = UM002_TestDataFactory.setupBillingRule(billingLegalEntity.Id);
        
        blng__TaxRule__c taxRule = UM002_TestDataFactory.setupTaxRule(billingLegalEntity.Id);
        
        Account acc = UM002_TestDataFactory.createAccounts(1,'test').get(0);
        acc.SBQQ__RenewalModel__c ='Contract Based';
        insert acc;
        
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
        quoteLine.LPCR_EntiteJuridique__c= UM002_TestDataFactory.setupLegalEntity().Id;
        insert quoteLine;
        opp.SBQQ__PrimaryQuote__c =quote.Id;
        update opp;
        
        
        
        
    }
    
    @IsTest
    static void setLegalEntityOnOrderItem_Test(){
        
        
        System.runAs(UM002_TestDataFactory.createUser()){
            SBQQ__Quote__c quote = [SELECT Id,SBQQ__Ordered__c FROM SBQQ__Quote__c WHERE SBQQ__BillingCity__c = 'test'];
           
            Test.startTest(); 
            quote.SBQQ__Ordered__c  = true; 
            update quote;
          
            Test.stopTest();
            Order order = [SELECT Id , Status,SBQQ__Quote__c  FROM Order WHERE SBQQ__Quote__c = :quote.Id];            
            
            List<OrderItem> listOrderItem = [SELECT Id,blng__LegalEntity__c, SBQQ__QuoteLine__r.LPCR_EntiteJuridique__c	 FROM OrderItem WHERE OrderId = :order.Id];
            
            for(OrderItem eachOrderItem : listOrderItem){
                System.assertNotEquals(null, eachOrderItem.blng__LegalEntity__c,'Legal Entity is Null in the OrderItem');
                System.assertEquals(eachOrderItem.SBQQ__QuoteLine__r.LPCR_EntiteJuridique__c, eachOrderItem.blng__LegalEntity__c,'Legal Entity in order item is not  equal to quote line legal entity');
            }
        }
        
        
    }
}