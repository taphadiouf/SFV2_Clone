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
            opp.LPCR_TypeFacturation__c='Arrears';
            opp.LPCR_BillingFrequency__c='Invoice Plan';
            update opp;
            SBQQ__Quote__c quote = UM002_TestDataFactory.createQuotes(1, accs, oppties).get(0);
            
            insert quote;
            
            quote = [SELECT Id ,LPCR_RenouvellementConvenu__c,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c from SBQQ__Quote__c WHERE Id = :quote.Id];
            System.assertNotEquals(null,quote.LPCR_RenouvellementConvenu__c,'LPCR_RenouvellementConvenu__c is null');
            System.assertEquals(quote.LPCR_RenouvellementConvenu__c, opp.LPCR_RenouvellementConvenu__c, 'Quote LPCR_RenouvellementConvenu__c not equals to oppt LPCR_RenouvellementConvenu__c');
            System.assertEquals(quote.LPCR_TypeFacturation__c, opp.LPCR_TypeFacturation__c, 'Quote LPCR_TypeFacturation__c not equals to oppt LPCR_TypeFacturation__c');
            System.assertEquals(quote.SBQQ__BillingFrequency__c, opp.LPCR_BillingFrequency__c, 'Quote LPCR_BillingFrequency__c not equals to oppt LPCR_BillingFrequency__c');
            Test.stopTest();
            
        } }
    //added by hanae on the 02/04/2020
    @isTest
    public static void IncrementAccCreche_Test(){
        Id rc = [SELECT Id FROM RecordType WHERE SObjectType = :'Account' AND Name = :'Crèche'].Id;
        List<Account> crecheAccs = UM002_TestDataFactory.createCrecheAccountsWithQuote(100,'crecheAcct',rc,2);
        insert crecheAccs;
        List<Account> crecheAccswithoutQuote = UM002_TestDataFactory.createCrecheAccountsWithQuote(100,'crecheAccountWQ',rc,null );
        insert crecheAccswithoutQuote;
        Map<Id,Account> mapAccounts = new Map<Id,Account>([SELECT Id,Name,LPCR_NombreContrat__c FROM Account WHERE RecordType.Name = 'Crèche' AND LPCR_NombreContrat__c = 2 ]);
        List<SBQQ__Quote__c> crecheQuotes = UM002_TestDataFactory.createaccountQuotes(mapAccounts.keyset());
        insert crecheQuotes;
		Map<Id,Account> mapAccs = new Map<Id,Account>([SELECT Id,Name,LPCR_NombreContrat__c FROM Account WHERE RecordType.Name = 'Crèche' AND LPCR_NombreContrat__c = null ]);
        List<SBQQ__Quote__c> crecheQuotes1 = UM002_TestDataFactory.createaccountQuotes(mapAccs.keyset());
        insert crecheQuotes1;
        Map<Id, SBQQ__Quote__c> newQuote = new Map<Id, SBQQ__Quote__c>();
        
        

        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            Account crecheAcc = [Select Id, Name,LPCR_NombreContrat__c FROM Account WHERE Name ='crecheAcct' LIMIT 1 ];
            System.assertEquals(3,crecheAcc.LPCR_NombreContrat__c);
            Account crecheAcc1 = [Select Id, Name,LPCR_NombreContrat__c FROM Account WHERE Name ='crecheAccountWQ' LIMIT 1 ];
            System.assertEquals(1,crecheAcc1.LPCR_NombreContrat__c);
            Test.stopTest();
        }
        
    }
}