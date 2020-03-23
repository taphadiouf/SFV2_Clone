/**
* @author Achraf ABOUL
* @created 28/02/2020
* @description Test Class of SM008_QuoteServices.
*/
@isTest
public class SM008_QuoteServices_Test {
    
    @testSetup 
    static void testSetup(){
        List<Account> accounts = UM002_TestDataFactory.createAccounts(100, 'testAccount');
        
        List<Opportunity> opps = UM002_TestDataFactory.createOpportunities(100, 'testOpp', 'Prospecting');
        
        insert accounts;
        insert opps;
        List<SBQQ__Quote__c> quotes = UM002_TestDataFactory.createQuotes(100, accounts, opps);
        insert quotes;
        insert UM002_TestDataFactory.createAccounts(1, 'test').get(0);
        insert UM002_TestDataFactory.createOpportunities(1, 'test', 'Prospecting').get(0);
        
    } 
    @isTest
    public static void updateOppsFromQuotes_Test(){
        Test.startTest();
        List<SBQQ__Quote__c> quotes = [SELECT Id, SBQQ__Status__c from SBQQ__Quote__c];
        for(SBQQ__Quote__c eachQuote : quotes){
            eachQuote.SBQQ__Status__c = 'Accepted';
        }
        update quotes;
        List<Account> resultAccounts = [SELECT Id, LPCR_Statut__c FROM Account WHERE LPCR_Statut__c= 'Client'];
        List<Opportunity> resultOpps = [SELECT Id, StageName FROM Opportunity WHERE StageName = 'Signée'];
        System.assertEquals(100, resultAccounts.size(), 'Error in SM008_QuoteServices_Test : problem in updating Account');
        System.assertEquals(100, resultOpps.size(), 'Error in SM008_QuoteServices_Test : problem in updating Opportunity');
        Test.stopTest();
        
    }
    @isTest
    public static void updateAccountsFromQuotes_Test(){
    }
    
    
    @isTest //added by Ayoub
    public static void setQuoteFields_Test(){
        
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            List<Account> accs = [SELECT Id, name from Account WHERE name ='test' LIMIT 1];
            List<Opportunity> oppties = [SELECT Id , Name from Opportunity WHERE name = 'test' LIMIT 1];
            Opportunity opp = oppties.get(0);
            opp.LPCR_RenouvellementConvenu__c='Oui';
            update opp;
            SBQQ__Quote__c quote = UM002_TestDataFactory.createQuotes(1, accs, oppties).get(0);
            insert quote;
            
            quote = [SELECT Id ,LPCR_RenouvellementConvenu__c from SBQQ__Quote__c WHERE Id = :quote.Id];
            System.assertNotEquals(null,quote.LPCR_RenouvellementConvenu__c,'LPCR_RenouvellementConvenu__c is null');
            System.assertEquals(quote.LPCR_RenouvellementConvenu__c, opp.LPCR_RenouvellementConvenu__c, 'Quote LPCR_RenouvellementConvenu__c not equals to oppt LPCR_RenouvellementConvenu__c');
            Test.stopTest();
            
        } }
}