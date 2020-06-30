/**
* @author Fowdar Akshaye
* @created 03/06/2020
* @description Test Class for SM014_OrderServices_Test
*/
@isTest
public class SM014_OrderServices_Test {
    
    @testsetup
    static void setup(){
        Id standardPricebookId = Test.getStandardPricebookId();
        
        UM002_TestDataFactory.insertBillingCustomSettings();
        
        blng__LegalEntity__c billingLegalEntity = UM002_TestDataFactory.setupLegalEntity();
        
        blng__RevenueRecognitionRule__c revRecRule = UM002_TestDataFactory.setupRevRec(billingLegalEntity.Id);
        
        blng__BillingRule__c billingRule = UM002_TestDataFactory.setupBillingRule(billingLegalEntity.Id);
        
        blng__TaxRule__c taxRule = UM002_TestDataFactory.setupTaxRule(billingLegalEntity.Id);
        
        Id familleAccountRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Famille);
        Account acc = UM002_TestDataFactory.createAccounts(1,familleAccountRT,'test').get(0);
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
        insert quoteLine;
        opp.SBQQ__PrimaryQuote__c =quote.Id;
        update opp;
        
        
    }
    
    @isTest
    private static void setOrderFieldsTest(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Account acc = [SELECT Id from Account WHERE name ='test' LIMIT 1];
            SBQQ__Quote__c quote = Database.query('SELECT Id,LPCR_CompteFacturation__c,LPCR_IndexationConvenue__c,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c,LPCR_MasterDevis__c ,LPCR_DateDebut__c,LPCR_DateFin__c,LPCR_ChiffreAffaire__c, LPCR_MethodeRenouvellement__c,SBQQ__RenewalUpliftRate__c,LPCR_TypeEntreprise__c,LPCR_PlanningEnfant__c FROM SBQQ__Quote__c WHERE SBQQ__BillingCity__c = \'test\'');
            quote.SBQQ__Ordered__c  = true; 
            quote.LPCR_IndexationConvenue__c='Oui';
            quote.LPCR_TypeFacturation__c='Arrears';
            quote.SBQQ__BillingFrequency__c='Invoice Plan';
            quote.LPCR_DateDebut__c = Date.today();
            quote.LPCR_DateFin__c = Date.today() + 10;
            quote.LPCR_ChiffreAffaire__c = 1000;
            quote.SBQQ__RenewalUpliftRate__c = 2; 
            quote.LPCR_BatchCommande__c = 'Batch 2';

           quote.LPCR_CompteFacturation__c = acc.Id;
            
            Test.startTest();
            update quote;
            Test.stopTest();
            
            Order order = Database.query('SELECT Id ,blng__BillingAccount__c,LPCR_TypeFacturation__c,LPCR_FrequenceFacturation__c , Status ,blng__InvoiceBatch__c FROM Order WHERE SBQQ__Quote__c  = \''+quote.Id+'\'');
            System.assertEquals('Batch 2', order.blng__InvoiceBatch__c,'blng__InvoiceBatch__c on the quote is not the same on the order');
			System.assertEquals(quote.SBQQ__BillingFrequency__c, order.LPCR_FrequenceFacturation__c,'SBQQ__BillingFrequency__c on the quote is not the same on the order');
			System.assertEquals(quote.LPCR_TypeFacturation__c, order.LPCR_TypeFacturation__c,'LPCR_TypeFacturation__c on the quote is not the same on the order');
    
            System.assertEquals(quote.LPCR_CompteFacturation__c, order.blng__BillingAccount__c,'blng__BillingAccount__c on the Order is not the same on the Quote LPCR_CompteFacturation__c');

        }
    }
    
}