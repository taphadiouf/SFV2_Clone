/**
* @author Ayoub Ouarti
* @date 18/03/2020
* @Description Test class for APB003_CreateOrderFromQuote 
*/
@isTest
public class APB003_CreateOrderFromQuote_Test {
    @testsetup
    static void setup() {
        
        List<Account> accs = UM002_TestDataFactory.createAccounts(1,'test');
        insert accs;
        
        List<Opportunity> oppties = UM002_TestDataFactory.createOpportunities(1, 'test', 'Prospecting');
        insert oppties;
        SBQQ__Quote__c quote =UM002_TestDataFactory.createQuotes(1, accs, oppties).get(0);
        insert quote;
        oppties.get(0).SBQQ__PrimaryQuote__c =quote.Id;
        update oppties;
        
    }
    @isTest
    private static void test(){
        System.runAs(UM002_TestDataFactory.createUser()){            
            Test.startTest();
            Opportunity oppty=[SELECT Id,SBQQ__PrimaryQuote__c, Name from Opportunity where Name ='test'];
            
            SBQQ__Quote__c quote = [SELECT Id ,SBQQ__Primary__c,SBQQ__Status__c,SBQQ__Opportunity2__c from SBQQ__Quote__c where Id = :oppty.SBQQ__PrimaryQuote__c ];
            quote.SBQQ__Primary__c=true;
            quote.SBQQ__Status__c='Prêt pour commande';
            update quote;
            APB003_CreateOrderFromQuote createOrderFromQuoteBatch = new APB003_CreateOrderFromQuote();
            createOrderFromQuoteBatch.execute(null);
            Test.stopTest();
            
            quote = [SELECT Id, name,SBQQ__Status__c,SBQQ__Ordered__c,SBQQ__Opportunity2__c from SBQQ__Quote__c where SBQQ__Opportunity2__c =:oppty.Id ];           
            System.assertEquals(true, quote.SBQQ__Ordered__c,'SBQQ__Ordered__c is false');
            
        }
    }


    @isTest
    static void testCommandeEnv(){
        Test.startTest();
        Id referencementRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote,Label.LPCR_Referencement);

        Opportunity oppty=[SELECT Id,SBQQ__PrimaryQuote__c, Name from Opportunity where Name ='test'];
        
        SBQQ__Quote__c quote = [SELECT Id ,SBQQ__Primary__c,SBQQ__Status__c,SBQQ__Opportunity2__c from SBQQ__Quote__c where Id = :oppty.SBQQ__PrimaryQuote__c ];
        quote.SBQQ__Primary__c=true;
        quote.LPCR_BonCommandeEnvoye__c = true;
        quote.RecordTypeId = referencementRecTypeId;
        quote.SBQQ__Status__c='Prêt pour commande';
        update quote;

        Id standardPricebookId;
        if([SELECT Id FROM Pricebook2 WHERE IsStandard=true].size() > 0){
           standardPricebookId = [SELECT Id FROM Pricebook2 WHERE IsStandard=true].Id;
        }else{
            standardPricebookId = Test.getStandardPricebookId();
        }
        UM002_TestDataFactory.insertBillingCustomSettings();
        blng__LegalEntity__c billingLegalEntity = UM002_TestDataFactory.setupLegalEntity();
        blng__RevenueRecognitionRule__c revRecRule = UM002_TestDataFactory.setupRevRec(billingLegalEntity.Id);
        blng__BillingRule__c billingRule = UM002_TestDataFactory.setupBillingRule(billingLegalEntity.Id);
        blng__TaxRule__c taxRule = UM002_TestDataFactory.setupTaxRule(billingLegalEntity.Id);
        Product2 prod = UM002_TestDataFactory.createProduct('test', billingRule.Id, revRecRule.Id,taxRule.Id );
        insert prod;
        PricebookEntry priceBookEntry1 = UM002_TestDataFactory.createPricebookEntry(standardPricebookId,prod.Id);
		insert priceBookEntry1;
        SBQQ__QuoteLine__c quoteLine = UM002_TestDataFactory.createQuoteLine(prod.Id, quote.Id, priceBookEntry1.Id, 200,1);
        insert quoteLine;

        APB003_CreateOrderFromQuote createOrderFromQuoteBatch = new APB003_CreateOrderFromQuote();
        createOrderFromQuoteBatch.execute(null);
        Test.stopTest();
     
        SBQQ__QuoteLine__c qResult = [Select id,LPCR_LigneBonCommandeEnvoye__c from SBQQ__QuoteLine__c LIMIT 1];
        System.assertEquals(true, qResult.LPCR_LigneBonCommandeEnvoye__c,'LPCR_LigneBonCommandeEnvoye__c is false');
        
    }
}