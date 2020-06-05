/**
* @author Achraf ABOUL
* @created 28/02/2020
* @description Test Class of SM008_QuoteServices.
* @Modified by Hanae
*/
@isTest
public class SM008_QuoteServices_Test {
    
    @testSetup 
    static void testSetup(){
               
        /////////////*****************/////////////
        List<Account> accCreche = UM002_TestDataFactory.createAccountWithRecType(1, 'Compte Crèche MAC1', '0123N000000P8kwQAC', 'MAC');
        insert accCreche;
        List<Account> accFamille = UM002_TestDataFactory.createAccountWithRecType(1, 'Compte Famille MAC1', '0123N000000P8kyQAC', '');
        insert accFamille;
        Account acc = accFamille.get(0);
        List<Contract> Renewalcontract = UM002_TestDataFactory.createContracts(1,acc.Id,'0001',date.newInstance(System.Today().year(), 06, 02), date.newInstance(System.Today().year(), 06, 31),123, 'Express', 'Non', Null );
        insert Renewalcontract;
        Contract con = Renewalcontract.get(0);
        List<Opportunity> renwalOpps = UM002_TestDataFactory.createOpportunities(1, 'opp Famille MAC1', 'Prospecting', 'Oui', 'Advance', 'Invoice Plan',con.Id, Null );
        insert renwalOpps;
        
        //////////
        List<Contract> Renewalcontract2 = UM002_TestDataFactory.createContracts(1,acc.Id,'0002',date.newInstance(System.Today().year(), 06, 02), date.newInstance(System.Today().year()+1, 05, 25),123, 'Express', 'Non', Null );
        insert Renewalcontract2;
        Contract con2 = Renewalcontract2.get(0);
        List<Opportunity> renwalOpps2 = UM002_TestDataFactory.createOpportunities(1, 'opp Famille MAC2', 'Prospecting', 'Oui', 'Advance', 'Invoice Plan',con2.Id, Null );
        insert renwalOpps2;
        
        
        //////////
        List<Account> accCreche3 = UM002_TestDataFactory.createAccountWithRecType(1, 'Compte Crèche MICRO', '0123N000000P8kwQAC', 'MICRO');
        insert accCreche3;
        List<Contract> Renewalcontract3 = UM002_TestDataFactory.createContracts(1,acc.Id,'0003',date.newInstance(System.Today().year(), 06, 02), date.newInstance(System.Today().year(), 06, 31),123, 'Express', 'Non', Null );
        insert Renewalcontract3;
        Contract con3 = Renewalcontract3.get(0);
        List<Opportunity> renwalOpps3 = UM002_TestDataFactory.createOpportunities(1, 'opp Famille MICRO', 'Prospecting', 'Oui', 'Advance', 'Invoice Plan',con3.Id,Null );
        insert renwalOpps3;
        
        
        ////////
        List<Contract> Renewalcontract4 = UM002_TestDataFactory.createContracts(1,acc.Id,'0004',date.newInstance(System.Today().year(), 06, 02), date.newInstance(System.Today().year()+1, 09, 15),123, 'Express', 'Non', Null );
        insert Renewalcontract4;
        Contract con4 = Renewalcontract4.get(0);
        List<Opportunity> renwalOpps4 = UM002_TestDataFactory.createOpportunities(1, 'opp Famille MICRO2', 'Prospecting', 'Oui', 'Advance', 'Invoice Plan',con4.Id,Null );
        insert renwalOpps4;
        
        
        
        //////
        List<Contract> Renewalcontract5 = UM002_TestDataFactory.createContracts(1,acc.Id,'0005',date.newInstance(System.Today().year(), 06, 02), date.newInstance(System.Today().year(), 06, 31),123, 'Express', 'Oui', 4 );
        insert Renewalcontract5;
        Contract con5 = Renewalcontract5.get(0);
        List<Opportunity> renwalOpps5 = UM002_TestDataFactory.createOpportunities(1, 'opp OUI', 'Prospecting', 'Oui', 'Advance', 'Invoice Plan', Null , con5.Id );
        insert renwalOpps5;
        List<Contract> Renewalcontract6 = UM002_TestDataFactory.createContracts(1,acc.Id,'0006',date.newInstance(System.Today().year(), 06, 02), date.newInstance(System.Today().year(), 06, 31),123, 'Express', 'Non', Null );
        insert Renewalcontract6;
        Contract con6 = Renewalcontract6.get(0);
        List<Opportunity> renwalOpps6 = UM002_TestDataFactory.createOpportunities(1, 'opp NON', 'Prospecting', 'Oui', 'Advance', 'Invoice Plan', Null ,con6.Id );
        insert renwalOpps6;
        /////////////*****************/////////////
        
        
        
        
        
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
        List<Account> resultAccounts = [SELECT Id,Name, LPCR_Statut__c FROM Account WHERE LPCR_Statut__c= 'Client' AND Name = 'testAccount'];
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
    

   // @isTest
   /* public static void setQuoteFieldsFromContract_Test(){
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
    } */

    
    //added by Hanae
    @isTest
    public static void generateAgreementTemp_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            List<SBQQ__Quote__c> macQuotesList = [Select Id,SBQQ__Status__c,LPCR_Creche__c, LPCR_Creche__r.LPCR_TypeCreche__c From SBQQ__Quote__c  ];
            Map<Id,SBQQ__Quote__c> oldQuoteMap = new Map<Id,SBQQ__Quote__c>();
            for(SBQQ__Quote__c eachQuote: macQuotesList){
                oldQuoteMap.put(eachQuote.Id,eachQuote);
            }
            for(SBQQ__Quote__c eachQuote: macQuotesList){
                eachQuote.SBQQ__Status__c = 'Validé directrice';
            }
            update macQuotesList;
            Map<Id,SBQQ__Quote__c> newQuoteMap = new Map<Id,SBQQ__Quote__c>([Select Id,SBQQ__Status__c,LPCR_Creche__c, LPCR_Creche__r.LPCR_TypeCreche__c From SBQQ__Quote__c Where SBQQ__Status__c = 'Validé directrice' ]);
            Map<Id,Set<Id>> mapQuoteIDAgreementID = SM008_QuoteServices.generateAgreementTemp(newQuoteMap,oldQuoteMap);
            Test.stopTest();
        }
    }
    
    
    
    
    
    
    ////////////*******************///////////////////
    @isTest()
    public static void updateQuotes_Test(){
        
        System.runAs(UM002_TestDataFactory.createUser()){
           Test.startTest();
            //Renewal Mac less than CY
            List<Account> accs = [SELECT Id, name , LPCR_TypeCreche__c from Account WHERE name ='Compte Crèche MAC1' LIMIT 1];
            Account acc = accs.get(0);
            system.debug('acc'+acc);
            List<Opportunity> oppties = [SELECT Id , Name , LPCR_IndexationConvenue__c , LPCR_TypeFacturation__c , LPCR_BillingFrequency__c from Opportunity WHERE name ='opp Famille MAC1' LIMIT 1 ];
            system.debug('oppties'+oppties);
            Opportunity opp = oppties.get(0);
            system.debug('opp'+opp);
            List<Contract> contract = [Select Id, LPCR_DateDebut__c , LPCR_DateFin__c , LPCR_ChiffreAffaire__c , LPCR_MethodeRenouvellement__c , LPCR_RenouvellementConvenu__c From Contract WHERE Name = '0001' Limit 1];
            system.debug('contract'+contract);
            Contract con = contract.get(0);
            system.debug('con'+con);
            SBQQ__Quote__c quote = UM002_TestDataFactory.createQuotes(1, accs, oppties,'Renewal', '0123N000000P8lNQAS', acc.Id).get(0);
            insert quote;
            system.debug('quote'+quote);
            quote = [SELECT Id ,LPCR_TypeCreche__c , LPCR_IndexationConvenue__c,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c, LPCR_DateDebut__c,LPCR_DateFin__c, SBQQ__EndDate__c,LPCR_ChiffreAffaire__c, LPCR_MethodeRenouvellement__c, LPCR_RenouvellementConvenu__c, SBQQ__RenewalUpliftRate__c  from SBQQ__Quote__c WHERE SBQQ__Type__c= 'Renewal' AND  Id = :quote.Id];
            System.assertNotEquals(null,quote.LPCR_IndexationConvenue__c,'LPCR_IndexationConvenue__c is null');
            System.assertEquals(quote.LPCR_TypeCreche__c, acc.LPCR_TypeCreche__c, 'Quote LPCR_TypeCreche__c not equals to acc LPCR_TypeCreche__c');
            System.assertEquals(quote.LPCR_IndexationConvenue__c, opp.LPCR_IndexationConvenue__c, 'Quote LPCR_IndexationConvenue__c not equals to oppt LPCR_IndexationConvenue__c');
            System.assertEquals(quote.LPCR_TypeFacturation__c, opp.LPCR_TypeFacturation__c, 'Quote LPCR_TypeFacturation__c not equals to oppt LPCR_TypeFacturation__c');
            System.assertEquals(quote.SBQQ__BillingFrequency__c, opp.LPCR_BillingFrequency__c, 'Quote LPCR_BillingFrequency__c not equals to oppt LPCR_BillingFrequency__c');
            System.assertEquals(quote.LPCR_DateDebut__c, con.LPCR_DateDebut__c, 'Quote LPCR_DateDebut__c not equals to con LPCR_DateDebut__c');
            System.assertEquals(quote.LPCR_DateFin__c, con.LPCR_DateFin__c, 'Quote LPCR_DateFin__c not equals to con LPCR_DateFin__c');
            System.assertEquals(quote.SBQQ__EndDate__c, con.LPCR_DateFin__c, 'Quote SBQQ__EndDate__c not equals to con LPCR_DateFin__c');
            System.assertEquals(quote.LPCR_ChiffreAffaire__c, con.LPCR_ChiffreAffaire__c, 'Quote LPCR_ChiffreAffaire__c not equals to con LPCR_ChiffreAffaire__c');
            System.assertEquals(quote.LPCR_MethodeRenouvellement__c, con.LPCR_MethodeRenouvellement__c, 'Quote LPCR_MethodeRenouvellement__c not equals to con LPCR_MethodeRenouvellement__c');
            System.assertEquals(quote.LPCR_RenouvellementConvenu__c, con.LPCR_RenouvellementConvenu__c, 'Quote LPCR_MethodeRenouvellement__c not equals to con LPCR_MethodeRenouvellement__c');
            System.assertEquals(quote.SBQQ__RenewalUpliftRate__c, 0, 'Quote SBQQ__RenewalUpliftRate__c not equals to 0');
            
            
            
			
            
            
            
            //Renwal Mac more than CY 
           	Date quoteDate = date.newInstance(System.Today().year(), 12, 31);
            List<Opportunity> oppties2 = [SELECT Id , Name , LPCR_IndexationConvenue__c , LPCR_TypeFacturation__c , LPCR_BillingFrequency__c from Opportunity WHERE name ='opp Famille MAC2' LIMIT 1 ];
            system.debug('oppties2'+oppties2);
            Opportunity opp2 = oppties2.get(0);
            system.debug('opp2'+opp2);
            List<Contract> contract2 = [Select Id, LPCR_DateDebut__c , LPCR_DateFin__c , LPCR_ChiffreAffaire__c , LPCR_MethodeRenouvellement__c , LPCR_RenouvellementConvenu__c From Contract WHERE Name = '0002' Limit 1];
            system.debug('contract2'+contract2);
            Contract con2 = contract2.get(0);
            system.debug('con2'+con2);
            SBQQ__Quote__c quote2 = UM002_TestDataFactory.createQuotes(1, accs, oppties2,'Renewal', '0123N000000P8lNQAS', acc.Id).get(0);
            insert quote2;
            system.debug('quote2'+quote2);
            quote2 = [SELECT Id ,LPCR_TypeCreche__c , LPCR_IndexationConvenue__c,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c, LPCR_DateDebut__c,LPCR_DateFin__c, SBQQ__EndDate__c,LPCR_ChiffreAffaire__c, LPCR_MethodeRenouvellement__c, LPCR_RenouvellementConvenu__c, SBQQ__RenewalUpliftRate__c  from SBQQ__Quote__c WHERE SBQQ__Type__c= 'Renewal' AND  Id = :quote2.Id];
            system.debug('quote2'+quote2);
            system.debug('quote2.SBQQ__EndDate__c'+quote2.SBQQ__EndDate__c);
            System.assertNotEquals(null,quote2.LPCR_IndexationConvenue__c,'LPCR_IndexationConvenue__c is null');
            System.assertEquals(quote2.LPCR_TypeCreche__c, acc.LPCR_TypeCreche__c, 'Quote LPCR_TypeCreche__c not equals to acc LPCR_TypeCreche__c');
            System.assertEquals(quote2.LPCR_IndexationConvenue__c, opp2.LPCR_IndexationConvenue__c, 'Quote LPCR_IndexationConvenue__c not equals to oppt LPCR_IndexationConvenue__c');
            System.assertEquals(quote2.LPCR_TypeFacturation__c, opp2.LPCR_TypeFacturation__c, 'Quote LPCR_TypeFacturation__c not equals to oppt LPCR_TypeFacturation__c');
            System.assertEquals(quote2.SBQQ__BillingFrequency__c, opp2.LPCR_BillingFrequency__c, 'Quote LPCR_BillingFrequency__c not equals to oppt LPCR_BillingFrequency__c');
            System.assertEquals(quote2.LPCR_DateDebut__c, con2.LPCR_DateDebut__c, 'Quote LPCR_DateDebut__c not equals to con LPCR_DateDebut__c');
            System.assertEquals(quote2.LPCR_DateFin__c, con2.LPCR_DateFin__c , 'Quote LPCR_DateFin__c not equals to con LPCR_DateFin__c');
            System.assertEquals(quote2.LPCR_ChiffreAffaire__c, con2.LPCR_ChiffreAffaire__c, 'Quote LPCR_ChiffreAffaire__c not equals to con LPCR_ChiffreAffaire__c');
            System.assertEquals(quote2.LPCR_MethodeRenouvellement__c, con2.LPCR_MethodeRenouvellement__c, 'Quote LPCR_MethodeRenouvellement__c not equals to con LPCR_MethodeRenouvellement__c');
            System.assertEquals(quote2.LPCR_RenouvellementConvenu__c, con2.LPCR_RenouvellementConvenu__c, 'Quote LPCR_MethodeRenouvellement__c not equals to con LPCR_MethodeRenouvellement__c');
            System.assertEquals(quote2.SBQQ__RenewalUpliftRate__c, 0, 'Quote SBQQ__RenewalUpliftRate__c not equals to 0');
            System.assertEquals(quoteDate, quote2.SBQQ__EndDate__c);
            
            
            
            
            
            
            //Renwal Micro less than Sep
             List<Account> accs3 = [SELECT Id, name , LPCR_TypeCreche__c from Account WHERE name ='Compte Crèche MICRO' LIMIT 1];
            Account acc3 = accs3.get(0);
            system.debug('acc3'+acc3);
            List<Opportunity> oppties3 = [SELECT Id , Name , LPCR_IndexationConvenue__c , LPCR_TypeFacturation__c , LPCR_BillingFrequency__c from Opportunity WHERE name ='opp Famille MICRO' LIMIT 1 ];
            system.debug('oppties3'+oppties3);
            Opportunity opp3 = oppties3.get(0);
            system.debug('opp3'+opp3);
            List<Contract> contract3 = [Select Id, LPCR_DateDebut__c , LPCR_DateFin__c , LPCR_ChiffreAffaire__c , LPCR_MethodeRenouvellement__c , LPCR_RenouvellementConvenu__c, SBQQ__RenewalUpliftRate__c From Contract WHERE Name = '0003' Limit 1];
            system.debug('contract3'+contract3);
            Contract con3 = contract3.get(0);
            system.debug('con3'+con3);
            SBQQ__Quote__c quote3 = UM002_TestDataFactory.createQuotes(1, accs3, oppties3,'Renewal', '0123N000000P8lNQAS', acc3.Id).get(0);
            insert quote3;
            system.debug('quote3'+quote3);
            quote3 = [SELECT Id ,LPCR_TypeCreche__c , LPCR_IndexationConvenue__c,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c, LPCR_DateDebut__c,LPCR_DateFin__c, SBQQ__EndDate__c,LPCR_ChiffreAffaire__c, LPCR_MethodeRenouvellement__c, LPCR_RenouvellementConvenu__c, SBQQ__RenewalUpliftRate__c  from SBQQ__Quote__c WHERE SBQQ__Type__c= 'Renewal' AND  Id = :quote3.Id];
            system.debug('quote3'+quote3);
            system.debug('quote3.SBQQ__EndDate__c'+quote3.SBQQ__EndDate__c);
            System.assertNotEquals(null,quote3.LPCR_IndexationConvenue__c,'LPCR_IndexationConvenue__c is null');
            System.assertEquals(quote3.LPCR_TypeCreche__c, acc3.LPCR_TypeCreche__c, 'Quote LPCR_TypeCreche__c not equals to acc LPCR_TypeCreche__c');
            System.assertEquals(quote3.LPCR_IndexationConvenue__c, opp3.LPCR_IndexationConvenue__c, 'Quote LPCR_IndexationConvenue__c not equals to oppt LPCR_IndexationConvenue__c');
            System.assertEquals(quote3.LPCR_TypeFacturation__c, opp3.LPCR_TypeFacturation__c, 'Quote LPCR_TypeFacturation__c not equals to oppt LPCR_TypeFacturation__c');
            System.assertEquals(quote3.SBQQ__BillingFrequency__c, opp3.LPCR_BillingFrequency__c, 'Quote LPCR_BillingFrequency__c not equals to oppt LPCR_BillingFrequency__c');
            System.assertEquals(quote3.LPCR_DateDebut__c, con3.LPCR_DateDebut__c, 'Quote LPCR_DateDebut__c not equals to con LPCR_DateDebut__c');
            System.assertEquals(quote3.LPCR_DateFin__c, con3.LPCR_DateFin__c , 'Quote LPCR_DateFin__c not equals to con LPCR_DateFin__c');
            System.assertEquals(quote3.SBQQ__EndDate__c, con3.LPCR_DateFin__c , 'Quote SBQQ__EndDate__c not equals to con3 LPCR_DateFin__c');
            System.assertEquals(quote3.LPCR_ChiffreAffaire__c, con3.LPCR_ChiffreAffaire__c, 'Quote LPCR_ChiffreAffaire__c not equals to con LPCR_ChiffreAffaire__c');
            System.assertEquals(quote3.LPCR_MethodeRenouvellement__c, con3.LPCR_MethodeRenouvellement__c, 'Quote LPCR_MethodeRenouvellement__c not equals to con LPCR_MethodeRenouvellement__c');
            System.assertEquals(quote3.LPCR_RenouvellementConvenu__c, con3.LPCR_RenouvellementConvenu__c, 'Quote LPCR_MethodeRenouvellement__c not equals to con LPCR_MethodeRenouvellement__c');
            System.assertEquals(quote3.SBQQ__RenewalUpliftRate__c, 0, 'Quote SBQQ__RenewalUpliftRate__c not equals to 0');
            
            
            //Renwal Micro More than Sep
            
            List<Opportunity> oppties4 = [SELECT Id , Name , LPCR_IndexationConvenue__c , LPCR_TypeFacturation__c , LPCR_BillingFrequency__c from Opportunity WHERE name ='opp Famille MICRO2' LIMIT 1 ];
            system.debug('oppties4'+oppties4);
            Opportunity opp4 = oppties4.get(0);
            system.debug('opp4'+opp4);
            List<Contract> contract4 = [Select Id, LPCR_DateDebut__c , LPCR_DateFin__c , LPCR_ChiffreAffaire__c , LPCR_MethodeRenouvellement__c , LPCR_RenouvellementConvenu__c From Contract WHERE Name = '0004' Limit 1];
            system.debug('contract4'+contract4);
            Contract con4 = contract4.get(0);
            system.debug('con4'+con4);
            system.debug('con4.LPCR_DateFin__c'+con4.LPCR_DateFin__c);
            SBQQ__Quote__c quote4 = UM002_TestDataFactory.createQuotes(1, accs3, oppties4,'Renewal', '0123N000000P8lNQAS', acc3.Id).get(0);
            insert quote4;
            system.debug('quote4'+quote4);
            quote4 = [SELECT Id ,LPCR_TypeCreche__c , LPCR_IndexationConvenue__c,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c, LPCR_DateDebut__c,LPCR_DateFin__c, SBQQ__EndDate__c,LPCR_ChiffreAffaire__c, LPCR_MethodeRenouvellement__c, LPCR_RenouvellementConvenu__c, SBQQ__RenewalUpliftRate__c  from SBQQ__Quote__c WHERE SBQQ__Type__c= 'Renewal' AND  Id = :quote4.Id];
            system.debug('quote4'+quote4);
            system.debug('quote4.SBQQ__EndDate__c'+quote4.SBQQ__EndDate__c);
            System.assertNotEquals(null,quote4.LPCR_IndexationConvenue__c,'LPCR_IndexationConvenue__c is null');
            System.assertEquals(quote4.LPCR_TypeCreche__c, acc3.LPCR_TypeCreche__c, 'Quote LPCR_TypeCreche__c not equals to acc LPCR_TypeCreche__c');
            System.assertEquals(quote4.LPCR_IndexationConvenue__c, opp4.LPCR_IndexationConvenue__c, 'Quote LPCR_IndexationConvenue__c not equals to oppt LPCR_IndexationConvenue__c');
            System.assertEquals(quote4.LPCR_TypeFacturation__c, opp4.LPCR_TypeFacturation__c, 'Quote LPCR_TypeFacturation__c not equals to oppt LPCR_TypeFacturation__c');
            System.assertEquals(quote4.SBQQ__BillingFrequency__c, opp4.LPCR_BillingFrequency__c, 'Quote LPCR_BillingFrequency__c not equals to oppt LPCR_BillingFrequency__c');
            System.assertEquals(quote4.LPCR_DateDebut__c, con4.LPCR_DateDebut__c, 'Quote LPCR_DateDebut__c not equals to con LPCR_DateDebut__c');
            System.assertEquals(quote4.LPCR_DateFin__c, con4.LPCR_DateFin__c , 'Quote LPCR_DateFin__c not equals to con LPCR_DateFin__c');
            System.assertEquals(quote4.SBQQ__EndDate__c, date.newInstance(System.Today().year(), 08, 31) , 'Quote SBQQ__EndDate__c not equals to con3 LPCR_DateFin__c');
            System.assertEquals(quote4.LPCR_ChiffreAffaire__c, con4.LPCR_ChiffreAffaire__c, 'Quote LPCR_ChiffreAffaire__c not equals to con LPCR_ChiffreAffaire__c');
            System.assertEquals(quote4.LPCR_MethodeRenouvellement__c, con4.LPCR_MethodeRenouvellement__c, 'Quote LPCR_MethodeRenouvellement__c not equals to con LPCR_MethodeRenouvellement__c');
            System.assertEquals(quote4.LPCR_RenouvellementConvenu__c, con4.LPCR_RenouvellementConvenu__c, 'Quote LPCR_MethodeRenouvellement__c not equals to con LPCR_MethodeRenouvellement__c');
            System.assertEquals(quote4.SBQQ__RenewalUpliftRate__c, 0, 'Quote SBQQ__RenewalUpliftRate__c not equals to 0');
            
            
            
            
            
            //Quote Mac less than CY
            SBQQ__Quote__c quoteQ = UM002_TestDataFactory.createQuotes(1, accs, oppties,'Quote', '0123N000000P8lNQAS', acc.Id).get(0);
            quoteQ.LPCR_DateDebut__c = date.newInstance(System.Today().year(), 06, 02);// date.newInstance(System.Today().year(), 06, 31)
            quoteQ.LPCR_DateFin__c = date.newInstance(System.Today().year(), 06, 31);
            insert quoteQ;
            system.debug('quoteQ'+quoteQ);
            quoteQ = [SELECT Id ,LPCR_TypeCreche__c , SBQQ__StartDate__c, LPCR_DateDebut__c,LPCR_DateFin__c, SBQQ__EndDate__c  from SBQQ__Quote__c WHERE SBQQ__Type__c= 'Quote' AND  Id = :quoteQ.Id];
            System.assertEquals(quoteQ.LPCR_TypeCreche__c, acc.LPCR_TypeCreche__c, 'Quote LPCR_TypeCreche__c not equals to acc LPCR_TypeCreche__c');
            System.assertEquals(quoteQ.SBQQ__StartDate__c, quoteQ.LPCR_DateDebut__c, 'Quote SBQQ__StartDate__c not equals to quoteQ LPCR_DateDebut__c');
            System.assertEquals(quoteQ.SBQQ__EndDate__c, quoteQ.LPCR_DateFin__c, 'Quote SBQQ__EndDate__c not equals to quoteQ LPCR_DateFin__c');
            
            //Quote Mc more than CY
            SBQQ__Quote__c quoteQ1 = UM002_TestDataFactory.createQuotes(1, accs, oppties,'Quote', '0123N000000P8lNQAS', acc.Id).get(0);
            quoteQ1.LPCR_DateDebut__c = date.newInstance(System.Today().year(), 06, 04);// date.newInstance(System.Today().year(), 06, 31)
            quoteQ1.LPCR_DateFin__c = date.newInstance(System.Today().year()+1, 06, 31);
            insert quoteQ1;
            system.debug('quoteQ1'+quoteQ1);
            quoteQ1 = [SELECT Id ,LPCR_TypeCreche__c , SBQQ__StartDate__c, LPCR_DateDebut__c,LPCR_DateFin__c, SBQQ__EndDate__c  from SBQQ__Quote__c WHERE SBQQ__Type__c= 'Quote' AND  Id = :quoteQ1.Id];
            System.assertEquals(quoteQ1.LPCR_TypeCreche__c, acc.LPCR_TypeCreche__c, 'Quote LPCR_TypeCreche__c not equals to acc LPCR_TypeCreche__c');
            System.assertEquals(quoteQ1.SBQQ__StartDate__c, quoteQ1.LPCR_DateDebut__c, 'Quote SBQQ__StartDate__c not equals to quoteQ LPCR_DateDebut__c');
            System.assertEquals(quoteQ1.SBQQ__EndDate__c, date.newInstance(System.Today().year(), 12, 31), 'Quote SBQQ__EndDate__c not equals to quote Date');
            
            //Quote Micro less than CY
            SBQQ__Quote__c quoteQ2 = UM002_TestDataFactory.createQuotes(1, accs, oppties,'Quote', '0123N000000P8lNQAS', acc3.Id).get(0);
            quoteQ2.LPCR_DateDebut__c = date.newInstance(System.Today().year(), 06, 02);// date.newInstance(System.Today().year(), 06, 31)
            quoteQ2.LPCR_DateFin__c = date.newInstance(System.Today().year(), 06, 31);
            insert quoteQ2;
            system.debug('quoteQ2'+quoteQ2);
            quoteQ2 = [SELECT Id ,LPCR_TypeCreche__c , SBQQ__StartDate__c, LPCR_DateDebut__c,LPCR_DateFin__c, SBQQ__EndDate__c  from SBQQ__Quote__c WHERE SBQQ__Type__c= 'Quote' AND  Id = :quoteQ2.Id];
            System.assertEquals(quoteQ2.LPCR_TypeCreche__c, acc3.LPCR_TypeCreche__c, 'Quote LPCR_TypeCreche__c not equals to acc LPCR_TypeCreche__c');
            System.assertEquals(quoteQ2.SBQQ__StartDate__c, quoteQ2.LPCR_DateDebut__c, 'Quote SBQQ__StartDate__c not equals to quoteQ LPCR_DateDebut__c');
            System.assertEquals(quoteQ2.SBQQ__EndDate__c, quoteQ2.LPCR_DateFin__c, 'Quote SBQQ__EndDate__c not equals to quoteQ LPCR_DateFin__c');
            
            //Quote Micro more than CY
            SBQQ__Quote__c quoteQ3 = UM002_TestDataFactory.createQuotes(1, accs, oppties,'Quote', '0123N000000P8lNQAS', acc3.Id).get(0);
            quoteQ3.LPCR_DateDebut__c = date.newInstance(System.Today().year(), 06, 04);
            quoteQ3.LPCR_DateFin__c = date.newInstance(System.Today().year()+1, 09, 31);
            insert quoteQ3;
            system.debug('quoteQ3'+quoteQ3);
            quoteQ3 = [SELECT Id ,LPCR_TypeCreche__c , SBQQ__StartDate__c, LPCR_DateDebut__c,LPCR_DateFin__c, SBQQ__EndDate__c  from SBQQ__Quote__c WHERE SBQQ__Type__c= 'Quote' AND  Id = :quoteQ3.Id];
            System.assertEquals(quoteQ3.LPCR_TypeCreche__c, acc3.LPCR_TypeCreche__c, 'Quote LPCR_TypeCreche__c not equals to acc LPCR_TypeCreche__c');
            System.assertEquals(quoteQ3.SBQQ__StartDate__c, quoteQ1.LPCR_DateDebut__c, 'Quote SBQQ__StartDate__c not equals to quoteQ LPCR_DateDebut__c');
            System.assertEquals(quoteQ3.SBQQ__EndDate__c, date.newInstance(System.Today().year(), 08, 31), 'Quote SBQQ__EndDate__c not equals to quote Date');
            
            
            
            
            
            
            
            //Amendment Oui
            List<Contract> contract5 = [Select Id, LPCR_DateDebut__c , LPCR_DateFin__c , LPCR_ChiffreAffaire__c , LPCR_MethodeRenouvellement__c , LPCR_RenouvellementConvenu__c, SBQQ__RenewalUpliftRate__c From Contract WHERE Name = '0005' Limit 1];
            Contract con5 = contract5.get(0);
            List<Opportunity> oppties5 = [SELECT Id , Name , LPCR_IndexationConvenue__c , LPCR_TypeFacturation__c , LPCR_BillingFrequency__c from Opportunity WHERE name ='opp OUI' LIMIT 1 ];
            Opportunity opp5 = oppties5.get(0);
            SBQQ__Quote__c quote5 = UM002_TestDataFactory.createQuotes(1, accs3, oppties5,'Amendment', '0123N000000P8lNQAS', acc3.Id).get(0);
            insert quote5;
            system.debug('quote5'+quote5);
            quote5 = [SELECT Id ,LPCR_TypeCreche__c , LPCR_IndexationConvenue__c,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c, LPCR_DateDebut__c,LPCR_DateFin__c, SBQQ__EndDate__c,LPCR_ChiffreAffaire__c, LPCR_MethodeRenouvellement__c, LPCR_RenouvellementConvenu__c, SBQQ__RenewalUpliftRate__c  from SBQQ__Quote__c WHERE SBQQ__Type__c= 'Amendment' AND  Id = :quote5.Id];
            System.assertEquals(quote5.LPCR_DateDebut__c, con5.LPCR_DateDebut__c, 'Quote LPCR_DateDebut__c not equals to con LPCR_DateDebut__c');
            System.assertEquals(quote5.LPCR_DateFin__c, con5.LPCR_DateFin__c , 'Quote LPCR_DateFin__c not equals to con LPCR_DateFin__c');
            System.assertEquals(quote5.LPCR_ChiffreAffaire__c, con5.LPCR_ChiffreAffaire__c, 'Quote LPCR_ChiffreAffaire__c not equals to con LPCR_ChiffreAffaire__c');
            System.assertEquals(quote5.LPCR_MethodeRenouvellement__c, con5.LPCR_MethodeRenouvellement__c, 'Quote LPCR_MethodeRenouvellement__c not equals to con LPCR_MethodeRenouvellement__c');
            System.assertEquals(quote5.LPCR_RenouvellementConvenu__c, con5.LPCR_RenouvellementConvenu__c, 'Quote LPCR_MethodeRenouvellement__c not equals to con LPCR_MethodeRenouvellement__c');
            System.assertEquals(quote5.SBQQ__RenewalUpliftRate__c, con5.SBQQ__RenewalUpliftRate__c, 'Quote SBQQ__RenewalUpliftRate__c not equals to con SBQQ__RenewalUpliftRate__c');
            
            
            
            
            //Amendment Non
            List<Contract> contract6 = [Select Id, LPCR_DateDebut__c , LPCR_DateFin__c , LPCR_ChiffreAffaire__c , LPCR_MethodeRenouvellement__c , LPCR_RenouvellementConvenu__c, SBQQ__RenewalUpliftRate__c From Contract WHERE Name = '0006' Limit 1];
            Contract con6 = contract6.get(0);
             List<Opportunity> oppties6 = [SELECT Id , Name , LPCR_IndexationConvenue__c , LPCR_TypeFacturation__c , LPCR_BillingFrequency__c from Opportunity WHERE name ='opp NON' LIMIT 1 ];
            Opportunity opp6 = oppties6.get(0);
            SBQQ__Quote__c quote6 = UM002_TestDataFactory.createQuotes(1, accs3, oppties6,'Amendment', '0123N000000P8lNQAS', acc3.Id).get(0);
            insert quote6;
            quote6 = [SELECT Id ,LPCR_TypeCreche__c , LPCR_IndexationConvenue__c,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c, LPCR_DateDebut__c,LPCR_DateFin__c, SBQQ__EndDate__c,LPCR_ChiffreAffaire__c, LPCR_MethodeRenouvellement__c, LPCR_RenouvellementConvenu__c, SBQQ__RenewalUpliftRate__c  from SBQQ__Quote__c WHERE SBQQ__Type__c= 'Amendment' AND  Id = :quote6.Id];
            System.assertEquals(quote6.LPCR_DateDebut__c, con6.LPCR_DateDebut__c, 'Quote LPCR_DateDebut__c not equals to con LPCR_DateDebut__c');
            System.assertEquals(quote6.LPCR_DateFin__c, con6.LPCR_DateFin__c , 'Quote LPCR_DateFin__c not equals to con LPCR_DateFin__c');
            System.assertEquals(quote6.LPCR_ChiffreAffaire__c, con6.LPCR_ChiffreAffaire__c, 'Quote LPCR_ChiffreAffaire__c not equals to con LPCR_ChiffreAffaire__c');
            System.assertEquals(quote6.LPCR_MethodeRenouvellement__c, con6.LPCR_MethodeRenouvellement__c, 'Quote LPCR_MethodeRenouvellement__c not equals to con LPCR_MethodeRenouvellement__c');
            System.assertEquals(quote6.LPCR_RenouvellementConvenu__c, con6.LPCR_RenouvellementConvenu__c, 'Quote LPCR_MethodeRenouvellement__c not equals to con LPCR_MethodeRenouvellement__c');
            System.assertEquals(quote6.SBQQ__RenewalUpliftRate__c, 0, 'Quote SBQQ__RenewalUpliftRate__c not equals to 0');
            
            Test.stopTest();
           
            
        } }
    
}