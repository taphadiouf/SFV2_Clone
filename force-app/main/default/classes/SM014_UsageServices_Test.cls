/**
* @author Ayoub Ouarti
* @created 09/06/2020
* @description Covering SM014_UsageServices Class
*/
@isTest
public class SM014_UsageServices_Test {
    
    
    
    
    @testSetup static void setup() {
        Id accountEntrepriseRTId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Entreprise);
        Id accountCrecheTId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Creche);
             

        Id standardPricebookId = Test.getStandardPricebookId();
        
        UM002_TestDataFactory.insertBillingCustomSettings();
        
        Account acc = UM002_TestDataFactory.createAccounts(1,accountEntrepriseRTId,'testACC').get(0);
       // acc.RecordTypeID=accountEntrepriseRTId;
        insert acc;
        Pad.log('TEEEEST', 'setup', 'accountEntrepriseRTId '+acc.RecordTypeID);
        blng__LegalEntity__c billingLegalEntity = UM002_TestDataFactory.setupLegalEntity();
        
        blng__RevenueRecognitionRule__c revRecRule = UM002_TestDataFactory.setupRevRec(billingLegalEntity.Id);
        
        blng__BillingRule__c billingRule = UM002_TestDataFactory.setupBillingRule(billingLegalEntity.Id);
        
        blng__TaxRule__c taxRule = UM002_TestDataFactory.setupTaxRule(billingLegalEntity.Id);
        
        Product2 prod = UM002_TestDataFactory.createProduct('testPROD', billingRule.Id, revRecRule.Id,taxRule.Id );
        prod.SBQQ__SubscriptionPricing__c ='Fixed Price';
        insert prod;
        
        PricebookEntry priceBookEntry1 = UM002_TestDataFactory.createPricebookEntry(standardPricebookId,prod.Id);
        insert priceBookEntry1;
        
        
    } 
    
    @isTest
    static void setUsageFields_Test() {
        System.runAs(UM002_TestDataFactory.createUser()){
            Account acc = [Select Id, Name from Account where name like 'testACC'];
            Product2 prod = [Select Id, Name from Product2 where name like 'testPROD'];
            Test.startTest(); 
            blng__Usage__c usage = new blng__Usage__c(/*blng__MatchingId__c='TEMPVALUE',*/blng__StartDateTime__c =Date.today()
                                                      ,blng__EndDateTime__c =Date.today().addDays(60)
                                                      ,LPCR_Product__c =prod.Id
                                                      ,blng__Account__c=acc.Id);
            insert usage;
            Test.stopTest();
            
            usage = [Select LPCR_Product__r.Name,blng__Account__r.Name, blng__MatchingId__c from blng__Usage__c where blng__Account__c = :acc.Id AND LPCR_Product__c = :prod.Id ];
            
            System.assertNotEquals(null, usage.blng__MatchingId__c,'blng__MatchingId__c on Usage is null');
            System.assertEquals( prod.Name+acc.Name,usage.blng__MatchingId__c,'blng__MatchingId__c on Usage is wrong');
            
        }
    }
    
}