/**
* @author Ayoub Ouarti
* @date 18/03/2020
* @Description Test class for APB004_ActivateOrder 
*/
@isTest
public class APB004_ActivateOrder_Test {
    @testsetup
    static void setup() {
        //This setup is in the APB007_AllPriceBookClasses_Tests class 

   
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
        insert prod;
        
        PricebookEntry priceBookEntry1 = UM002_TestDataFactory.createPricebookEntry(standardPricebookId,prod.Id);
		insert priceBookEntry1;
        
        SBQQ__QuoteLine__c quoteLine = UM002_TestDataFactory.createQuoteLine(prod.Id, quote.Id, priceBookEntry1.Id, 200,1);
        insert quoteLine;
        opp.SBQQ__PrimaryQuote__c =quote.Id;
        update opp;
       
        quote.SBQQ__Ordered__c  = true;     
        update quote;
    }
    @isTest
    private static void activateOrderBatch_Test(){
        //This method is called in APB007_AllPriceBookClasses_Tests class with the same name
        
        System.runAs(UM002_TestDataFactory.createUser()){            
            Test.startTest();            
            SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__BillingCity__c=:'test'];
            Order order = [SELECT Id , Status ,OpportunityId,EffectiveDate FROM Order WHERE SBQQ__Quote__c=:quote.id];
            APB004_ActivateOrder activateOrderBatch = new APB004_ActivateOrder();
            activateOrderBatch.execute(null);
            Test.stopTest();
            
        	order = Database.query('SELECT Id , Status ,OpportunityId,EffectiveDate FROM Order WHERE SBQQ__Quote__c  = \''+quote.Id+'\'');
            System.assertEquals('Activated', order.Status,'status is not get activated');
            
        }
    
    }
}