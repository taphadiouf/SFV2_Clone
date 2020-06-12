/**
* @author Hanae MAKBOUB
* @date 19/05/2020
* @description Test class for Service class LPCR_ModificationEntrante__c
*/
@isTest
public class SM013_ModificationEntranteServices_Test {
    private static final Id B2C_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Famille);
    private static final Id CONTACT_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contact, Label.LPCR_Parent);
    private static final Id standardPricebookId = Test.getStandardPricebookId();
    
    @testSetup 
    static void testSetup(){
        List<Account> accounts = UM002_TestDataFactory.createAccounts(100, 'testAccount');
        List<Opportunity> opps = UM002_TestDataFactory.createOpportunities(100, 'testOpp', 'Prospecting');
        insert accounts;
        insert opps;
        List<SBQQ__Quote__c> quotes = UM002_TestDataFactory.createQuotes(100, accounts, opps);
        insert quotes;
        List<LPCR_ModificationEntrante__c> modifEntrantesValides = UM002_TestDataFactory.createModificationsEntrantes(50,quotes,'Validation Contrat Directrice');
        insert modifEntrantesValides;
        List<LPCR_ModificationEntrante__c> modifEntrantes = UM002_TestDataFactory.createModificationsEntrantes(50,quotes,'Modification Adresse Contact Parent	');
        insert modifEntrantes;
        
        Id standardPricebookId = Test.getStandardPricebookId();
        UM002_TestDataFactory.insertBillingCustomSettings();
        blng__LegalEntity__c billingLegalEntity = UM002_TestDataFactory.setupLegalEntity();
        blng__RevenueRecognitionRule__c revRecRule = UM002_TestDataFactory.setupRevRec(billingLegalEntity.Id);
        blng__BillingRule__c billingRule = UM002_TestDataFactory.setupBillingRule(billingLegalEntity.Id);
        blng__TaxRule__c taxRule = UM002_TestDataFactory.setupTaxRule(billingLegalEntity.Id);
        
        Product2 prod = UM002_TestDataFactory.createFixedPriceProduct('test', billingRule.Id, revRecRule.Id,taxRule.Id );
        prod.SBQQ__SubscriptionPricing__c ='Fixed Price';
        prod.SBQQ__BillingFrequency__c = 'Monthly';
        prod.SBQQ__BillingType__c = 'Advance';
        prod.SBQQ__ChargeType__c = 'Recurring';
        prod.SBQQ__SubscriptionTerm__c = 12;
        prod.SBQQ__SubscriptionType__c = 'Renewable';
        insert prod;
        
        PricebookEntry priceBookEntry1 = UM002_TestDataFactory.createPricebookEntry(standardPricebookId,prod.Id);
        insert priceBookEntry1;
        
    }
    @isTest
    public static void updateQuotesFromModifEntrantes_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            List<SBQQ__Quote__c> quotesValides = [SELECT Id, SBQQ__Status__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Validé Directrice'];
            System.assertEquals(50, quotesValides.size(), 'Error in SM013_ModificationEntranteServices_Test : problem in updating quotesValides');
            List<SBQQ__Quote__c> quotesNonValides = [SELECT Id, SBQQ__Status__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c != 'Validé Directrice'];
            System.assertEquals(50, quotesNonValides.size(), 'Error in SM013_ModificationEntranteServices_Test : problem in updating quotesNonValides');
            Test.stopTest();
        }
    }
    
    @isTest 
    public static void sendAgreementFromModifEntrantes_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Date firstDayOfCurrentMonthDate = Date.newInstance(Date.today().Year(), Date.today().month() ,1) ;
            Product2 prod = [SELECT Id FROM Product2 WHERE Name =: 'test' LIMIT 1];
            PricebookEntry pbEntry = [SELECT Id FROM PricebookEntry WHERE Product2Id =: prod.id LIMIT 1];            
            
            Account acc = [SELECT Id,SBQQ__RenewalModel__c,RecordTypeId FROM Account WHERE Name =: 'testAccount' LIMIT 1];
            acc.SBQQ__RenewalModel__c = 'Contract Based';
            acc.RecordTypeId = B2C_RT_ID;
            acc.LPCR_ResponsableServiceFamille__c = UserInfo.getUserId();
            update acc;
            
            Contact cont = UM002_TestDataFactory.createContacts(1, CONTACT_RT_ID, 'test_lastname', 'test_address').get(0);
            insert cont;
            
            Opportunity opp = [SELECT Id,AccountId FROM Opportunity WHERE Name =: 'testOpp' LIMIT 1];
            opp.AccountId = acc.id;
            update opp;
            
            SBQQ__Quote__c quote = [SELECT Id,SBQQ__Type__c,SBQQ__SubscriptionTerm__c,SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c =: opp.Id LIMIT 1];
            quote.SBQQ__Type__c='Quote';
            quote.SBQQ__StartDate__c = System.today();
            quote.SBQQ__SubscriptionTerm__c = 12;
            update quote;
            
            List<SBQQ__QuoteLine__c> qlines = new List<SBQQ__QuoteLine__c> ();
            qlines.add(UM002_TestDataFactory.createQuoteLine(prod.Id, quote.Id, pbEntry.Id, 200, 1));
            insert qlines;
            
            LPCR_RessourceFamille__c ressourceFamille = UM002_TestDataFactory.createRessourceFamille(firstDayOfCurrentMonthDate,acc.id,'Test');
            insert ressourceFamille;
            
            Contract contract = UM002_TestDataFactory.createContract(acc.id,quote.id,opp.id,Date.Today().addmonths(3));
            Insert contract;
            
            LPCR_ModificationEntrante__c modif = UM002_TestDataFactory.createModificationsEntrante('Date Fin Contrat',quote.id,acc.id,cont.id,contract.id,10);
            insert modif;           
            
            Test.startTest();
 		    modif.LPCR_EtatTraitement__c = true;
            update modif;      
            Test.stopTest();
            
        }
    }
}