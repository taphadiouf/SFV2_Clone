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
            opp.LPCR_IndexationConvenue__c='Oui';
            opp.LPCR_TypeFacturation__c='Arrears';
            opp.LPCR_BillingFrequency__c='Invoice Plan';
            update opp;
            SBQQ__Quote__c quote = UM002_TestDataFactory.createQuotes(1, accs, oppties).get(0);
            quote.SBQQ__Type__c='Renewal';
            
            insert quote;
            
            quote = [SELECT Id ,LPCR_IndexationConvenue__c,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c from SBQQ__Quote__c WHERE SBQQ__Type__c= 'Renewal' AND  Id = :quote.Id];
            System.assertNotEquals(null,quote.LPCR_IndexationConvenue__c,'LPCR_IndexationConvenue__c is null');
            System.assertEquals(quote.LPCR_IndexationConvenue__c, opp.LPCR_IndexationConvenue__c, 'Quote LPCR_IndexationConvenue__c not equals to oppt LPCR_IndexationConvenue__c');
            System.assertEquals(quote.LPCR_TypeFacturation__c, opp.LPCR_TypeFacturation__c, 'Quote LPCR_TypeFacturation__c not equals to oppt LPCR_TypeFacturation__c');
            System.assertEquals(quote.SBQQ__BillingFrequency__c, opp.LPCR_BillingFrequency__c, 'Quote LPCR_BillingFrequency__c not equals to oppt LPCR_BillingFrequency__c');
            Test.stopTest();
            
        } }
    
    @isTest
    public static void setQuoteFieldsFromContract_Test(){
        User usr = UM002_TestDataFactory.createUser();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'LPCR_Admin' LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps.Id);
        System.runAs(usr){
            Test.startTest();
            List<Account> accs = [SELECT Id, name from Account WHERE name ='test' LIMIT 1];
            List<Opportunity> oppties = [SELECT Id , Name from Opportunity WHERE name = 'test' LIMIT 1];
            Opportunity opp = oppties.get(0);
            opp.LPCR_IndexationConvenue__c='Oui';
            opp.LPCR_TypeFacturation__c='Arrears';
            opp.LPCR_BillingFrequency__c='Invoice Plan';
            update opp;
            
            SBQQ__Quote__c quote = UM002_TestDataFactory.createQuotes(1, accs, oppties).get(0);
            quote.SBQQ__Type__c='Renewal';
            quote.SBQQ__Primary__c = true;
            quote.SBQQ__StartDate__c = System.today();
            quote.SBQQ__SubscriptionTerm__c = 12;
            insert quote;
            
            Contract con = new Contract(AccountID = accs.get(0).id,SBQQ__Quote__c = quote.id,SBQQ__Opportunity__c = oppties.get(0).id,
                                        StartDate =System.today(),ContractTerm = 12,LPCR_DateDebut__c =Date.newInstance(2020, 05, 01),
                                        LPCR_DateFin__c = Date.newInstance(2020, 05, 30),LPCR_RenouvellementConvenu__c = 'Non',LPCR_MethodeRenouvellement__c = 'Express' );
            Insert con;
            List<Contract> conList = [select id, SBQQ__RenewalForecast__c,SBQQ__RenewalQuoted__c,LPCR_DateFin__c,LPCR_DateDebut__c,LPCR_MethodeRenouvellement__c,LPCR_RenouvellementConvenu__c from Contract WHERE AccountID =: accs.get(0).Id LIMIT 1 ];
            Contract conInsert = conList.get(0);
            conInsert.SBQQ__RenewalForecast__c = true;
            conInsert.SBQQ__RenewalQuoted__c = true;
            
            Update conInsert;
            Opportunity opportunityRenewal = [SELECT Id ,SBQQ__RenewedContract__c from Opportunity WHERE SBQQ__RenewedContract__c = :conInsert.id Limit 1]; 
            SBQQ__Quote__c quoteRenewal = [select id,LPCR_DateFin__c,LPCR_DateDebut__c,LPCR_MethodeRenouvellement__c,LPCR_RenouvellementConvenu__c  from SBQQ__Quote__c where SBQQ__Opportunity2__c = :opportunityRenewal.id and SBQQ__Type__c ='Renewal'];
            System.assertEquals(quoteRenewal.LPCR_DateFin__c, conInsert.LPCR_DateFin__c, 'Quote LPCR_DateFin__c  equals to contract LPCR_DateFin__c');
            System.assertEquals(quoteRenewal.LPCR_DateDebut__c, conInsert.LPCR_DateDebut__c, 'Quote LPCR_DateDebut__c  equals to contract LPCR_DateDebut__c');
            System.assertEquals(quoteRenewal.LPCR_MethodeRenouvellement__c, conInsert.LPCR_MethodeRenouvellement__c, 'Quote LPCR_MethodeRenouvellement__c  equals to contract LPCR_MethodeRenouvellement__c');
            
            Test.stopTest();   
        }
    } 
}