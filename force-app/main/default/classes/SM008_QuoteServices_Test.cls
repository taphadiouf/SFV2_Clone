/**
* @author Achraf ABOUL
* @created 28/02/2020
* @description Test Class of SM008_QuoteServices.
* @Modified by Hanae
*/
@isTest
public class SM008_QuoteServices_Test {
    private static final Id B2C_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Famille);
    private static final Id ContratA_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c', Label.LPCR_ContratA);
        private static final Id CONTRACT_CONTRAT_ACCUEIL_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract, Label.LPCR_ContratA);
            private static final Id CONTRACT_RESERVATRICE_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract, Label.LPCR_Reservataire);
                private static final Id CONTRACT_REFERENCEMENT_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract, Label.LPCR_Referencement);

@testSetup 
    static void testSetup(){
        
        /////////////*****************/////////////
        
        Id acceuilRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote, Label.LPCR_ContratA);//EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Contrat_Accueil');
        Id referencementRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Referencement');
        Id reservataireRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Reservataire');
        Id recTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Account', 'Creche' );
        Id recTypeFamilleId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Account', 'Famille' );
         Id recTypeEnfantId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Contact', 'Enfant' );
        Id recTypecontactFamilleId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Contact', 'Famille' );

        
        blng__LegalEntity__c entiteJuridique = UM002_TestDataFactory.setupLegalEntity();
        LPCR_Planning__c planningEnfant = new LPCR_Planning__c();	
        insert planningEnfant;
        Contact contact = UM002_TestDataFactory.createContact('contact Enfant',recTypeEnfantId);
        Contact conErpresentant1 = UM002_TestDataFactory.createContact('contact Rep1',recTypecontactFamilleId);
        Contact conErpresentant2 = UM002_TestDataFactory.createContact('contact Rep2',recTypecontactFamilleId);
        
        
        
        
        List<Account> accCreche = UM002_TestDataFactory.createAccountWithRecType(1, 'Compte Crèche MAC1', recTypeId, 'MAC');
        insert accCreche;
        Account acCreche = accCreche.get(0);
        List<Account> accFamille = UM002_TestDataFactory.createAccountWithRecType(1, 'Compte Famille MAC1', recTypeFamilleId, '');
        insert accFamille;
        Account accc = accFamille.get(0);

         Contract mainCon = UM002_TestDataFactory.createContract(accc.Id);


         List<Contract> Renewalcontract = UM002_TestDataFactory.createContracts(1,accc.Id,'0001',date.newInstance(System.Today().year(), 07, 02), date.newInstance(System.Today().year(), 12, 31),123, 'Sans renouvellement', 'Non', Null, 'MAC' );
        for(Contract eachContract : Renewalcontract){
            eachContract.LPCR_EntiteJuridique__c = entiteJuridique.Id;
            eachContract.LPCR_ContactEnfant__c = contact.Id;
            eachContract.LPCR_Creche__c = acCreche.Id;
            eachContract.LPCR_ContractEntreprise__c = mainCon.Id;
            eachContract.LPCR_ContactRepresentant1__c = conErpresentant1.Id;
            eachContract.LPCR_ContactRepresentant2__c = conErpresentant2.Id;
            eachContract.LPCR_CongesJours__c = 33;
            eachContract.LPCR_DureePreavisMois__c = '3';
            eachContract.LPCR_TypeAccueil__c = 'Occasionnel';
            
        }       
         insert Renewalcontract;
        Contract con = Renewalcontract.get(0);
        List<Opportunity> renwalOpps = UM002_TestDataFactory.createOpportunities(1, 'opp Famille MAC1', 'Prospecting', 'Oui', 'Advance', 'Invoice Plan',con.Id, Null );
         for(Opportunity eachOppty : renwalOpps){
            eachOppty.LPCR_PlanningEnfant__c = planningEnfant.ID;
        }
        insert renwalOpps;
        
        //////////
        List<Contract> Renewalcontract2 = UM002_TestDataFactory.createContracts(1,accc.Id,'0002',date.newInstance(System.Today().year(), 07, 02), date.newInstance(System.Today().year()+1, 05, 25),123, 'Express', 'Non', Null, 'MAC' );
        insert Renewalcontract2;
        Contract con2 = Renewalcontract2.get(0);
        List<Opportunity> renwalOpps2 = UM002_TestDataFactory.createOpportunities(1, 'opp Famille MAC2', 'Prospecting', 'Oui', 'Advance', 'Invoice Plan',con2.Id, Null );
        insert renwalOpps2;
        
        
        //////////
        List<Account> accCreche3 = UM002_TestDataFactory.createAccountWithRecType(1, 'Compte Crèche MICRO', recTypeId, 'MICRO');
        insert accCreche3;
        List<Contract> Renewalcontract3 = UM002_TestDataFactory.createContracts(1,accc.Id,'0003',date.newInstance(System.Today().year(), 07, 02), date.newInstance(System.Today().year(), 12, 31),123, 'Tacite', 'Non', Null,'MICRO' );
        insert Renewalcontract3;
        Contract con3 = Renewalcontract3.get(0);
        List<Opportunity> renwalOpps3 = UM002_TestDataFactory.createOpportunities(1, 'opp Famille MICRO', 'Prospecting', 'Oui', 'Advance', 'Invoice Plan',con3.Id,Null );
        insert renwalOpps3;
        
        
        ////////
        List<Contract> Renewalcontract4 = UM002_TestDataFactory.createContracts(1,accc.Id,'0004',date.newInstance(System.Today().year(), 07, 02), date.newInstance(System.Today().year()+1, 09, 15),123, 'Express', 'Non', Null, 'MICRO' );
        insert Renewalcontract4;
        Contract con4 = Renewalcontract4.get(0);
        List<Opportunity> renwalOpps4 = UM002_TestDataFactory.createOpportunities(1, 'opp Famille MICRO2', 'Prospecting', 'Oui', 'Advance', 'Invoice Plan',con4.Id,Null );
        insert renwalOpps4;
        
        
        
        //////
        List<Contract> Renewalcontract6 = UM002_TestDataFactory.createContracts(1,accc.Id,'0006',date.newInstance(System.Today().year(), 07, 02), date.newInstance(System.Today().year(), 08, 31),123, 'Express', 'Non', Null, 'MICRO' );
        for(Contract eachContract : Renewalcontract6){
            eachContract.LPCR_EntiteJuridique__c = entiteJuridique.Id;
            eachContract.LPCR_ContactEnfant__c = contact.Id;
            eachContract.LPCR_Creche__c = acCreche.Id;
            eachContract.LPCR_ContractEntreprise__c = mainCon.Id;
            eachContract.LPCR_ContactRepresentant1__c = conErpresentant1.Id;
            eachContract.LPCR_ContactRepresentant2__c = conErpresentant2.Id;
            eachContract.LPCR_CongesJours__c = 33;
            eachContract.LPCR_DureePreavisMois__c = '3';
            eachContract.LPCR_TypeAccueil__c = 'Occasionnel';
            
        }
        insert Renewalcontract6;
        Contract con6 = Renewalcontract6.get(0);
        List<Opportunity> renwalOpps6 = UM002_TestDataFactory.createOpportunities(1, 'opp NON', 'Prospecting', 'Oui', 'Advance', 'Invoice Plan', Null ,con6.Id );
         for(Opportunity eachOppty : renwalOpps6){
            eachOppty.LPCR_PlanningEnfant__c = planningEnfant.ID;
        }
        insert renwalOpps6;
        /////////////*****************/////////////
        
        
        
        
        
        List<Account> accounts = UM002_TestDataFactory.createAccounts(100, 'testAccount');
        
        List<Opportunity> opps = UM002_TestDataFactory.createOpportunities(100, 'testOpp', 'Prospecting');
        
        insert accounts;
        insert opps;
        List<SBQQ__Quote__c> quotes = UM002_TestDataFactory.createQuotes(100, accounts, opps);
        insert quotes;
        Account acc = UM002_TestDataFactory.createAccounts(1, 'test').get(0);
        acc.RecordTypeId = B2C_RT_ID;
        insert acc;
        insert UM002_TestDataFactory.createOpportunities(1, 'test', 'Prospecting').get(0);
        
        
        
        //added by Hanae
        List<Account> accountsMac = UM002_TestDataFactory.createAccountWithRecType(10, 'Accounts',recTypeId, 'MAC');
        insert accountsMac;
        List<Account> accountsMicro = UM002_TestDataFactory.createAccountWithRecType(10, 'Accounts', recTypeId, 'MICRO');
        insert accountsMicro;
       /*List<SBQQ__Quote__c> quotesMac = UM002_TestDataFactory.createQuotes(10, accountsMac, opps);
        for(SBQQ__Quote__c eachContract : quotesMac){
            eachContract.SBQQ__Status__c = 'Draft';
        }
        insert quotesMac;
        List<SBQQ__Quote__c> quotesMicro = UM002_TestDataFactory.createQuotes(10, accountsMicro, opps);
        for(SBQQ__Quote__c eachContract : quotesMicro){
            eachContract.SBQQ__Type__c = 'Renewal';
            eachContract.SBQQ__Status__c = 'Draft';
        }
        insert quotesMicro; */        


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
            LPCR_Planning__c planningEnfant = new LPCR_Planning__c();	
            insert planningEnfant;
            List<Account> accs = [SELECT Id, name from Account WHERE name ='test' LIMIT 1];
            List<Contract> Renewalcontract = UM002_TestDataFactory.createContracts(1,accs[0].Id,'0006',date.newInstance(System.Today().year(), 07, 02), date.newInstance(System.Today().year(), 08, 31),123, 'Express', 'Non', Null, Null );
            insert Renewalcontract;
            Contract con2 = Renewalcontract.get(0);
            con2.LPCR_Sales_Rep__c = UserInfo.getUserId();
            con2.LPCR_ResponsableADV__c = UserInfo.getUserId();
            con2.LPCR_ResponsableServiceFamille__c = UserInfo.getUserId();
            con2.RecordTypeId = CONTRACT_CONTRAT_ACCUEIL_RT_ID;

            update con2;
            
            
            List<Opportunity> oppties = [SELECT Id , Name from Opportunity WHERE name = 'test' LIMIT 1];
            Opportunity opp = oppties.get(0);
            opp.LPCR_IndexationConvenue__c='Oui';
            opp.LPCR_TypeFacturation__c='Arrears';
            opp.LPCR_BillingFrequency__c='Invoice Plan';
            opp.LPCR_PlanningEnfant__c = planningEnfant.id;
            opp.SBQQ__RenewedContract__c = con2.id;
            update opp;
            SBQQ__Quote__c quote = UM002_TestDataFactory.createQuotes(1, accs, oppties).get(0);
            quote.SBQQ__Type__c='Renewal';
           // quote.LPCR_TypeEnregistrement__c = Label.LPCR_ContratA;
             quote.RecordTypeId = ContratA_RT_ID;

            
            insert quote;
            
            quote = [SELECT Id ,LPCR_IndexationConvenue__c,ApprovalStatus__c, recordtype.developername, recordtypeid,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c,LPCR_PlanningEnfant__c,SBQQ__SalesRep__c, LPCR_ResponsableADV__c, LPCR_ResponsableServiceFamille__c from SBQQ__Quote__c WHERE SBQQ__Type__c= 'Renewal' AND  Id = :quote.Id];
           // System.assertEquals('Contrat_Accueil_Approuve',quote.recordtype.developername,'Type enregistrement not updated');
            System.assertEquals(Label.LPCR_ApprovalStatusApproved,quote.ApprovalStatus__c,'Approval status not updated');
            System.assertNotEquals(null,quote.LPCR_IndexationConvenue__c,'LPCR_IndexationConvenue__c is null');
            System.assertEquals(quote.LPCR_IndexationConvenue__c, opp.LPCR_IndexationConvenue__c, 'Quote LPCR_IndexationConvenue__c not equals to oppt LPCR_IndexationConvenue__c');
            System.assertEquals(quote.LPCR_TypeFacturation__c, opp.LPCR_TypeFacturation__c, 'Quote LPCR_TypeFacturation__c not equals to oppt LPCR_TypeFacturation__c');
            System.assertEquals(quote.SBQQ__BillingFrequency__c, opp.LPCR_BillingFrequency__c, 'Quote LPCR_BillingFrequency__c not equals to oppt LPCR_BillingFrequency__c');
            System.assertEquals(quote.LPCR_PlanningEnfant__c, opp.LPCR_PlanningEnfant__c, 'Quote LPCR_PlanningEnfant__c not equals to oppt LPCR_PlanningEnfant__c');
            System.assertEquals(quote.SBQQ__SalesRep__c,  UserInfo.getUserId(), 'Quote SBQQ__SalesRep__c not equals to oppt LPCR_PlanningEnfant__c');
            System.assertEquals(quote.LPCR_ResponsableADV__c,  UserInfo.getUserId(), 'Quote LPCR_ResponsableADV__c not equals to oppt LPCR_PlanningEnfant__c');
            System.assertEquals(quote.LPCR_ResponsableServiceFamille__c,  UserInfo.getUserId(), 'Quote LPCR_ResponsableServiceFamille__c not equals to oppt LPCR_PlanningEnfant__c');
            Test.stopTest();
            
        } }
    @isTest 
    public static void setQuoteFields_Test2(){    
        
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            LPCR_Planning__c planningEnfant = new LPCR_Planning__c();	
            insert planningEnfant;
            List<Account> accs = [SELECT Id, name from Account WHERE name ='test' LIMIT 1];
            List<Opportunity> oppties = [SELECT Id , Name from Opportunity WHERE name = 'test' LIMIT 1];
            Opportunity opp = oppties.get(0);
            update opp;
            SBQQ__Quote__c quote = UM002_TestDataFactory.createQuotes(1, accs, oppties).get(0);
            quote.RecordTypeId = ContratA_RT_ID;
            
            Contract con = new Contract(AccountID = accs.get(0).id,SBQQ__Opportunity__c = oppties.get(0).id,
                                        LPCR_Sales_Rep__c = UserInfo.getUserId(), LPCR_ResponsableADV__c = UserInfo.getUserId(), LPCR_ResponsableServiceFamille__c = UserInfo.getUserId(),
                                        StartDate =System.today(),ContractTerm = 12,LPCR_DateDebut__c =Date.newInstance(2020, 05, 01),
                                        LPCR_DateFin__c = Date.newInstance(2020, 05, 30),LPCR_MethodeRenouvellement__c = 'Express', RecordTypeId = CONTRACT_REFERENCEMENT_RT_ID );
            Insert con;
            
            quote.LPCR_ContractEntreprise__c  = con.Id;
            
            insert quote;
            
            quote = [SELECT Id ,LPCR_IndexationConvenue__c,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c,LPCR_PlanningEnfant__c,SBQQ__SalesRep__c, LPCR_ResponsableADV__c, LPCR_ResponsableServiceFamille__c from SBQQ__Quote__c WHERE  Id = :quote.Id];
            System.assertEquals(quote.SBQQ__SalesRep__c,  UserInfo.getUserId(), 'Quote SBQQ__SalesRep__c not equals to oppt LPCR_PlanningEnfant__c');
            System.assertEquals(quote.LPCR_ResponsableADV__c,  UserInfo.getUserId(), 'Quote LPCR_ResponsableADV__c not equals to oppt LPCR_PlanningEnfant__c');
            System.assertEquals(quote.LPCR_ResponsableServiceFamille__c,  UserInfo.getUserId(), 'Quote LPCR_ResponsableServiceFamille__c not equals to oppt LPCR_PlanningEnfant__c');
            Test.stopTest();
            
        } }
    
    
    
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
    /*
     *deleted in IS-1165
@IsTest
    static void setTypeEnregistrement_Test(){
        
        Test.startTest();
        
        Opportunity currentOpportunity = [SELECT Id, LPCR_TypeEnregistrement__c FROM Opportunity limit 1];
        currentOpportunity.LPCR_TypeEnregistrement__c = 'TestTypeEnregistrement';
        update currentOpportunity;
        List<Opportunity> opps = new List<Opportunity>();
        opps.add(currentOpportunity);
        Id accountCrecheRTId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Creche);
        Account currentAccount = [SELECT Id FROM Account WHERE RecordTypeId= :accountCrecheRTId limit 1];
        List<Account> accs = new List<Account>();
        accs.add(currentAccount);

        SBQQ__Quote__c newQuote = UM002_TestDataFactory.createQuoteswithStatus(1, accs, opps, 'Draft').get(0);
        newQuote.SBQQ__Type__c = 'Renewal';
        insert newQuote;
        
        newQuote = [SELECT Id,LPCR_TypeEnregistrement__c FROM SBQQ__Quote__c WHERE Id = :newQuote.Id limit 1];
      
        System.assertEquals('TestTypeEnregistrement', newQuote.LPCR_TypeEnregistrement__c);
        Test.stopTest();
       
        
    }
    
    */
    
    
    
    
    ////////////*******************///////////////////
    @isTest()
    public static void updateQuotesB2CRenMacLCY_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            Id acceuilRecTypeId =EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote, Label.LPCR_ContratA);// EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Contrat_Accueil');
            
            //B2C Renewal Mac less than Current Year
            List<Account> accs = [SELECT Id, name , LPCR_TypeCreche__c , LPCR_EntiteJuridique__c, LPCR_TypeFacturation__c from Account WHERE name ='Compte Crèche MAC1' LIMIT 1];
            Account acc = accs.get(0);
            List<Opportunity> oppties = [SELECT Id ,LPCR_PlanningEnfant__c, Name , LPCR_IndexationConvenue__c , LPCR_TypeFacturation__c , LPCR_BillingFrequency__c from Opportunity WHERE name ='opp Famille MAC1' LIMIT 1 ];
            Opportunity opp = oppties.get(0);
            List<Contract> contract = [Select Id,LPCR_EntiteJuridique__c,LPCR_DureePreavisMois__c,LPCR_Creche__c,LPCR_ContactRepresentant1__c,LPCR_ContactRepresentant2__c,LPCR_ContractEntreprise__c,LPCR_TypeCreche__c,RecordTypeId, LPCR_DateDebut__c , LPCR_DateFin__c , LPCR_ChiffreAffaire__c,LPCR_ContactEnfant__c,LPCR_CongesJours__c,LPCR_TypeAccueil__c   From Contract WHERE Name = '0001' Limit 1];
            Contract con = contract.get(0);
            con.RecordTypeId = CONTRACT_CONTRAT_ACCUEIL_RT_ID;
            update con;
            SBQQ__Quote__c quote = UM002_TestDataFactory.createQuotes(1, accs, oppties,'Renewal', acceuilRecTypeId, acc.Id).get(0);
            quote.RecordTypeId = acceuilRecTypeId;
            quote.LPCR_DateFin__c = date.newInstance(System.Today().year()+1, 12, 31);
            insert quote;
           
            quote = [SELECT Id ,LPCR_TypeCreche__c , LPCR_IndexationConvenue__c,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c, LPCR_DateDebut__c,LPCR_DateFin__c, SBQQ__EndDate__c,LPCR_ChiffreAffaire__c, SBQQ__RenewalUpliftRate__c, LPCR_EntiteJuridique__c, LPCR_BatchCommande__c ,LPCR_PlanningEnfant__c,LPCR_ContactEnfant__c,LPCR_Creche__c,LPCR_ContractEntreprise__c,LPCR_ContactRepresentant1__c,LPCR_ContactRepresentant2__c,LPCR_DureePreavisMois__c,LPCR_CongesJours__c,LPCR_TypeAccueil__c from SBQQ__Quote__c WHERE SBQQ__Type__c= 'Renewal' AND  Id = :quote.Id];
            System.assertNotEquals(null,quote.LPCR_IndexationConvenue__c,'LPCR_IndexationConvenue__c is null');
              System.assertEquals(quote.LPCR_TypeCreche__c, con.LPCR_TypeCreche__c, 'Quote LPCR_TypeCreche__c not equals to con LPCR_TypeCreche__c');
            System.assertEquals(quote.LPCR_PlanningEnfant__c, opp.LPCR_PlanningEnfant__c, 'Quote LPCR_PlanningEnfant__c not equals to oppt LPCR_PlanningEnfant__c');
            System.assertEquals(quote.LPCR_ContactEnfant__c, con.LPCR_ContactEnfant__c, 'Quote LPCR_ContactEnfant__c not equals to con LPCR_ContactEnfant__c');
            System.assertEquals(quote.LPCR_Creche__c, con.LPCR_Creche__c, 'Quote LPCR_Creche__c not equals to con LPCR_Creche__c');
            System.assertEquals(quote.LPCR_ContractEntreprise__c, con.LPCR_ContractEntreprise__c, 'Quote LPCR_ContractEntreprise__c not equals to con LPCR_ContractEntreprise__c');
            System.assertEquals(quote.LPCR_ContactRepresentant1__c, con.LPCR_ContactRepresentant1__c, 'Quote LPCR_ContactRepresentant1__c not equals to con LPCR_ContactRepresentant1__c');
            System.assertEquals(quote.LPCR_ContactRepresentant2__c, con.LPCR_ContactRepresentant2__c, 'Quote LPCR_ContactRepresentant2__c not equals to con LPCR_ContactRepresentant2__c');
            System.assertEquals(quote.LPCR_CongesJours__c, con.LPCR_CongesJours__c, 'Quote LPCR_CongesJours__c not equals to con LPCR_CongesJours__c');
            System.assertEquals(quote.LPCR_DureePreavisMois__c, con.LPCR_DureePreavisMois__c, 'Quote LPCR_DureePreavisMois__c not equals to con LPCR_DureePreavisMois__c');
            System.assertEquals(quote.LPCR_TypeAccueil__c, con.LPCR_TypeAccueil__c, 'Quote LPCR_TypeAccueil__c not equals to con LPCR_TypeAccueil__c');
                       System.assertEquals(quote.LPCR_IndexationConvenue__c, opp.LPCR_IndexationConvenue__c, 'Quote LPCR_IndexationConvenue__c not equals to oppt LPCR_IndexationConvenue__c');
            System.assertEquals(quote.LPCR_TypeFacturation__c, opp.LPCR_TypeFacturation__c, 'Quote LPCR_TypeFacturation__c not equals to oppt LPCR_TypeFacturation__c');
            System.assertEquals(quote.SBQQ__BillingFrequency__c, opp.LPCR_BillingFrequency__c, 'Quote LPCR_BillingFrequency__c not equals to oppt LPCR_BillingFrequency__c');
            System.assertEquals(quote.LPCR_DateDebut__c, con.LPCR_DateDebut__c, 'Quote LPCR_DateDebut__c not equals to con LPCR_DateDebut__c');
            System.assertEquals(quote.LPCR_DateFin__c, con.LPCR_DateFin__c, 'Quote LPCR_DateFin__c not equals to con LPCR_DateFin__c');
            System.assertEquals(quote.SBQQ__EndDate__c, con.LPCR_DateFin__c, 'Quote SBQQ__EndDate__c not equals to con LPCR_DateFin__c');
            System.assertEquals(quote.LPCR_ChiffreAffaire__c, con.LPCR_ChiffreAffaire__c, 'Quote LPCR_ChiffreAffaire__c not equals to con LPCR_ChiffreAffaire__c');
            System.assertEquals(con.LPCR_EntiteJuridique__c, quote.LPCR_EntiteJuridique__c, 'Quote LPCR_EntiteJuridique__c not equals to con LPCR_EntiteJuridique__c');
            System.assertEquals(quote.SBQQ__RenewalUpliftRate__c, null, 'Quote SBQQ__RenewalUpliftRate__c not equals to 0');
            System.assertEquals(quote.LPCR_BatchCommande__c, 'MAC', 'Quote LPCR_TypeCreche__c not equals to MAC');
            Test.stopTest();
        }
    }
            
            
            
    @isTest()        
    public static void updateQuotesB2CRenMacMCY_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            Id acceuilRecTypeId =EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote, Label.LPCR_ContratA);// EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Contrat_Accueil');
            
            //B2C Renwal Mac more than Current Year 
            List<Account> accs = [SELECT Id, name , LPCR_TypeCreche__c , LPCR_EntiteJuridique__c, LPCR_TypeFacturation__c from Account WHERE name ='Compte Crèche MAC1' LIMIT 1];
            Account acc = accs.get(0);
            Date quoteDate = date.newInstance(System.Today().year(), 12, 31);
            List<Opportunity> oppties2 = [SELECT Id , Name , LPCR_IndexationConvenue__c , LPCR_TypeFacturation__c , LPCR_BillingFrequency__c from Opportunity WHERE name ='opp Famille MAC2' LIMIT 1 ];
            Opportunity opp2 = oppties2.get(0);
            List<Contract> contract2 = [Select Id,RecordTypeId, LPCR_TypeCreche__c,LPCR_DateDebut__c , LPCR_DateFin__c , LPCR_ChiffreAffaire__c   From Contract WHERE Name = '0002' Limit 1];
            Contract con2 = contract2.get(0);
              
            con2.RecordTypeId = CONTRACT_CONTRAT_ACCUEIL_RT_ID;
            update con2;
            SBQQ__Quote__c quote2 = UM002_TestDataFactory.createQuotes(1, accs, oppties2,'Renewal', acceuilRecTypeId, acc.Id).get(0);
             quote2.RecordTypeId = acceuilRecTypeId;
            insert quote2;
            quote2 = [SELECT Id ,LPCR_TypeCreche__c , LPCR_IndexationConvenue__c,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c, LPCR_DateDebut__c,LPCR_DateFin__c, SBQQ__EndDate__c,LPCR_ChiffreAffaire__c, LPCR_EntiteJuridique__c, SBQQ__RenewalUpliftRate__c  from SBQQ__Quote__c WHERE SBQQ__Type__c= 'Renewal' AND  Id = :quote2.Id];
            System.assertNotEquals(null,quote2.LPCR_IndexationConvenue__c,'LPCR_IndexationConvenue__c is null');
            System.assertEquals(quote2.LPCR_TypeCreche__c, con2.LPCR_TypeCreche__c, 'Quote LPCR_TypeCreche__c not equals to acc LPCR_TypeCreche__c');
            System.assertEquals(quote2.LPCR_IndexationConvenue__c, opp2.LPCR_IndexationConvenue__c, 'Quote LPCR_IndexationConvenue__c not equals to oppt LPCR_IndexationConvenue__c');
            System.assertEquals(quote2.LPCR_TypeFacturation__c, opp2.LPCR_TypeFacturation__c, 'Quote LPCR_TypeFacturation__c not equals to oppt LPCR_TypeFacturation__c');
            System.assertEquals(quote2.SBQQ__BillingFrequency__c, opp2.LPCR_BillingFrequency__c, 'Quote LPCR_BillingFrequency__c not equals to oppt LPCR_BillingFrequency__c');
            System.assertEquals(quote2.LPCR_DateDebut__c, con2.LPCR_DateDebut__c, 'Quote LPCR_DateDebut__c not equals to con LPCR_DateDebut__c');
            System.assertEquals(quote2.LPCR_DateFin__c, con2.LPCR_DateFin__c , 'Quote LPCR_DateFin__c not equals to con LPCR_DateFin__c');
            System.assertEquals(quote2.LPCR_ChiffreAffaire__c, con2.LPCR_ChiffreAffaire__c, 'Quote LPCR_ChiffreAffaire__c not equals to con LPCR_ChiffreAffaire__c');
            System.assertEquals(quote2.LPCR_EntiteJuridique__c, acc.LPCR_EntiteJuridique__c, 'Quote LPCR_EntiteJuridique__c not equals to acc LPCR_EntiteJuridique__c');
            System.assertEquals(quote2.SBQQ__RenewalUpliftRate__c, null, 'Quote SBQQ__RenewalUpliftRate__c not equals to 0');
            System.assertEquals(quoteDate, quote2.SBQQ__EndDate__c);
            Test.stopTest();
        }
    }
            
            
            
    @isTest()        
    public static void updateQuotesB2CRenMicroLSep_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            Id acceuilRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote, Label.LPCR_ContratA);//EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Contrat_Accueil');
            //B2C Renwal Micro less than Sep
            List<Account> accs3 = [SELECT Id, name , LPCR_TypeCreche__c , LPCR_EntiteJuridique__c from Account WHERE name ='Compte Crèche MICRO' LIMIT 1];
            Account acc3 = accs3.get(0);
            List<Opportunity> oppties3 = [SELECT Id , Name , LPCR_IndexationConvenue__c , LPCR_TypeFacturation__c , LPCR_BillingFrequency__c from Opportunity WHERE name ='opp Famille MICRO' LIMIT 1 ];
            Opportunity opp3 = oppties3.get(0);
            List<Contract> contract3 = [Select Id,RecordTypeId, LPCR_DateDebut__c , LPCR_DateFin__c , LPCR_ChiffreAffaire__c  , SBQQ__RenewalUpliftRate__c ,LPCR_TypeCreche__c From Contract WHERE Name = '0003' Limit 1];
            Contract con3 = contract3.get(0);
             
            con3.RecordTypeId = CONTRACT_CONTRAT_ACCUEIL_RT_ID;
            update con3;
            SBQQ__Quote__c quote3 = UM002_TestDataFactory.createQuotes(1, accs3, oppties3,'Renewal', acceuilRecTypeId, acc3.Id).get(0);
             quote3.RecordTypeId = acceuilRecTypeId;
            insert quote3;
            quote3 = [SELECT Id ,LPCR_TypeCreche__c , LPCR_IndexationConvenue__c,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c, LPCR_DateDebut__c,LPCR_DateFin__c, SBQQ__EndDate__c,LPCR_ChiffreAffaire__c, LPCR_EntiteJuridique__c, SBQQ__RenewalUpliftRate__c, LPCR_BatchCommande__c  from SBQQ__Quote__c WHERE SBQQ__Type__c= 'Renewal' AND  Id = :quote3.Id];
            System.assertNotEquals(null,quote3.LPCR_IndexationConvenue__c,'LPCR_IndexationConvenue__c is null');
            System.assertEquals(quote3.LPCR_TypeCreche__c, con3.LPCR_TypeCreche__c, 'Quote LPCR_TypeCreche__c not equals to acc LPCR_TypeCreche__c');
            System.assertEquals(quote3.LPCR_IndexationConvenue__c, opp3.LPCR_IndexationConvenue__c, 'Quote LPCR_IndexationConvenue__c not equals to oppt LPCR_IndexationConvenue__c');
            System.assertEquals(quote3.LPCR_TypeFacturation__c, opp3.LPCR_TypeFacturation__c, 'Quote LPCR_TypeFacturation__c not equals to oppt LPCR_TypeFacturation__c');
            System.assertEquals(quote3.SBQQ__BillingFrequency__c, opp3.LPCR_BillingFrequency__c, 'Quote LPCR_BillingFrequency__c not equals to oppt LPCR_BillingFrequency__c');
            System.assertEquals(quote3.LPCR_DateDebut__c, con3.LPCR_DateDebut__c, 'Quote LPCR_DateDebut__c not equals to con LPCR_DateDebut__c');
            System.assertEquals(quote3.LPCR_DateFin__c, con3.LPCR_DateFin__c , 'Quote LPCR_DateFin__c not equals to con LPCR_DateFin__c');
            System.assertEquals(quote3.SBQQ__EndDate__c, con3.LPCR_DateFin__c , 'Quote SBQQ__EndDate__c not equals to con3 LPCR_DateFin__c');
            System.assertEquals(quote3.LPCR_ChiffreAffaire__c, con3.LPCR_ChiffreAffaire__c, 'Quote LPCR_ChiffreAffaire__c not equals to con LPCR_ChiffreAffaire__c');
            System.assertEquals(quote3.LPCR_EntiteJuridique__c, acc3.LPCR_EntiteJuridique__c, 'Quote LPCR_EntiteJuridique__c not equals to acc LPCR_EntiteJuridique__c');
            System.assertEquals(quote3.SBQQ__RenewalUpliftRate__c, null, 'Quote SBQQ__RenewalUpliftRate__c not equals to 0');
            System.assertEquals(quote3.LPCR_BatchCommande__c, 'MICRO', 'Quote LPCR_TypeCreche__c not equals to MICRO');
            Test.stopTest();
        }
    }
           
    @isTest()
    public static void updateQuotesB2CRenMicroMSep_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            Id acceuilRecTypeId =EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote, Label.LPCR_ContratA);// EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Contrat_Accueil');
            //B2C Renwal Micro More than Sep
            List<Account> accs3 = [SELECT Id, name , LPCR_TypeCreche__c , LPCR_EntiteJuridique__c from Account WHERE name ='Compte Crèche MICRO' LIMIT 1];
            Account acc3 = accs3.get(0);
            List<Opportunity> oppties4 = [SELECT Id , Name , LPCR_IndexationConvenue__c , LPCR_TypeFacturation__c , LPCR_BillingFrequency__c from Opportunity WHERE name ='opp Famille MICRO2' LIMIT 1 ];
            Opportunity opp4 = oppties4.get(0);
            List<Contract> contract4 = [Select Id, RecordTypeId,LPCR_DateDebut__c , LPCR_DateFin__c , LPCR_ChiffreAffaire__c   From Contract WHERE Name = '0004' Limit 1];
            Contract con4 = contract4.get(0);
            
            con4.RecordTypeId = CONTRACT_CONTRAT_ACCUEIL_RT_ID;
            update con4;
            SBQQ__Quote__c quote4 = UM002_TestDataFactory.createQuotes(1, accs3, oppties4,'Renewal', acceuilRecTypeId, acc3.Id).get(0);
            quote4.RecordTypeId = acceuilRecTypeId;
            insert quote4;
            quote4 = [SELECT Id ,LPCR_TypeCreche__c , LPCR_IndexationConvenue__c,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c, LPCR_DateDebut__c,LPCR_DateFin__c, SBQQ__EndDate__c,LPCR_ChiffreAffaire__c, LPCR_EntiteJuridique__c, SBQQ__RenewalUpliftRate__c  from SBQQ__Quote__c WHERE SBQQ__Type__c= 'Renewal' AND  Id = :quote4.Id];
            System.assertNotEquals(null,quote4.LPCR_IndexationConvenue__c,'LPCR_IndexationConvenue__c is null');
            System.assertEquals(quote4.LPCR_TypeCreche__c, acc3.LPCR_TypeCreche__c, 'Quote LPCR_TypeCreche__c not equals to acc LPCR_TypeCreche__c');
            System.assertEquals(quote4.LPCR_IndexationConvenue__c, opp4.LPCR_IndexationConvenue__c, 'Quote LPCR_IndexationConvenue__c not equals to oppt LPCR_IndexationConvenue__c');
            System.assertEquals(quote4.LPCR_TypeFacturation__c, opp4.LPCR_TypeFacturation__c, 'Quote LPCR_TypeFacturation__c not equals to oppt LPCR_TypeFacturation__c');
            System.assertEquals(quote4.SBQQ__BillingFrequency__c, opp4.LPCR_BillingFrequency__c, 'Quote LPCR_BillingFrequency__c not equals to oppt LPCR_BillingFrequency__c');
            System.assertEquals(quote4.LPCR_DateDebut__c, con4.LPCR_DateDebut__c, 'Quote LPCR_DateDebut__c not equals to con LPCR_DateDebut__c');
            System.assertEquals(quote4.LPCR_DateFin__c, con4.LPCR_DateFin__c , 'Quote LPCR_DateFin__c not equals to con LPCR_DateFin__c');

            System.assertEquals(quote4.LPCR_ChiffreAffaire__c, con4.LPCR_ChiffreAffaire__c, 'Quote LPCR_ChiffreAffaire__c not equals to con LPCR_ChiffreAffaire__c');
            System.assertEquals(quote4.LPCR_EntiteJuridique__c, acc3.LPCR_EntiteJuridique__c, 'Quote LPCR_EntiteJuridique__c not equals to acc LPCR_EntiteJuridique__c');

            System.assertEquals(quote4.SBQQ__EndDate__c, date.newInstance(System.Today().year(), 12, 31) , 'Quote SBQQ__EndDate__c not equals to con3 LPCR_DateFin__c');
            System.assertEquals(quote4.SBQQ__RenewalUpliftRate__c, null, 'Quote SBQQ__RenewalUpliftRate__c not equals to 0');
            Test.stopTest();
        }
    }
            
            
    @isTest()        
    public static void updateQuotesB2CQuoMacLCY_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            Id acceuilRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote, Label.LPCR_ContratA);//EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Contrat_Accueil');
            //B2C Quote Mac less than Current Year
            List<Account> accs = [SELECT Id, name , LPCR_TypeCreche__c , LPCR_EntiteJuridique__c, LPCR_TypeFacturation__c from Account WHERE name ='Compte Crèche MAC1' LIMIT 1];
            Account acc = accs.get(0);
            List<Opportunity> oppties = [SELECT Id , Name , LPCR_IndexationConvenue__c , LPCR_TypeFacturation__c , LPCR_BillingFrequency__c from Opportunity WHERE name ='opp Famille MAC1' LIMIT 1 ];
            SBQQ__Quote__c quoteQ = UM002_TestDataFactory.createQuotes(1, accs, oppties,'Quote', acceuilRecTypeId, acc.Id).get(0);
            quoteQ.LPCR_DateDebut__c = date.newInstance(System.Today().year(), 06, 02);
            quoteQ.LPCR_DateFin__c = date.newInstance(System.Today().year(), 06, 31);
            insert quoteQ;
            quoteQ = [SELECT Id ,LPCR_TypeCreche__c , SBQQ__StartDate__c, LPCR_DateDebut__c,LPCR_DateFin__c, SBQQ__EndDate__c, LPCR_TypeFacturation__c, LPCR_IndexationConvenue__c,LPCR_EntiteJuridique__c from SBQQ__Quote__c WHERE SBQQ__Type__c= 'Quote' AND  Id = :quoteQ.Id];
            System.assertEquals(quoteQ.LPCR_TypeCreche__c, acc.LPCR_TypeCreche__c, 'Quote LPCR_TypeCreche__c not equals to acc LPCR_TypeCreche__c');
            System.assertEquals(quoteQ.LPCR_TypeFacturation__c, acc.LPCR_TypeFacturation__c, 'Quote LPCR_TypeFacturation__c not equals to acc LPCR_TypeFacturation__c');
            System.assertEquals(quoteQ.SBQQ__StartDate__c, quoteQ.LPCR_DateDebut__c, 'Quote SBQQ__StartDate__c not equals to quoteQ LPCR_DateDebut__c');
            System.assertEquals(quoteQ.SBQQ__EndDate__c, quoteQ.LPCR_DateFin__c, 'Quote SBQQ__EndDate__c not equals to quoteQ LPCR_DateFin__c');
             System.assertEquals(quoteQ.LPCR_EntiteJuridique__c, acc.LPCR_EntiteJuridique__c, 'Quote LPCR_EntiteJuridique__c not equals to acc LPCR_EntiteJuridique__c');
            System.assertEquals('Non',quoteQ.LPCR_IndexationConvenue__c, 'Quote LPCR_IndexationConvenue__c not equals to non');
            Test.stopTest();
        }
    }


    @isTest()        
    public static void updateQuotesB2CQuoMacMCYBU_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            Id acceuilRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote, Label.LPCR_ContratA);//EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Contrat_Accueil');
            //B2C Quote MAC more than Current Year before update
            List<Account> accs = [SELECT Id, name , LPCR_TypeCreche__c , LPCR_EntiteJuridique__c, LPCR_TypeFacturation__c from Account WHERE name ='Compte Crèche MAC1' LIMIT 1];
            Account acc = accs.get(0);
            List<Opportunity> oppties = [SELECT Id , Name , LPCR_IndexationConvenue__c , LPCR_TypeFacturation__c , LPCR_BillingFrequency__c from Opportunity WHERE name ='opp Famille MAC1' LIMIT 1 ];
            SBQQ__Quote__c quoteQ1 = UM002_TestDataFactory.createQuotes(1, accs, oppties,'Re-Quote', acceuilRecTypeId, acc.Id).get(0);
            quoteQ1.LPCR_DateDebut__c = date.newInstance(System.Today().year(), 06, 04);
            quoteQ1.LPCR_DateFin__c = date.newInstance(System.Today().year()+1, 06, 31);
            insert quoteQ1;
            quoteQ1.SBQQ__Type__c = 'Quote';
            update quoteQ1;
            quoteQ1 = [SELECT Id ,LPCR_TypeCreche__c , SBQQ__StartDate__c, LPCR_DateDebut__c,LPCR_DateFin__c, SBQQ__EndDate__c , LPCR_TypeFacturation__c from SBQQ__Quote__c WHERE SBQQ__Type__c= 'Quote' AND  Id = :quoteQ1.Id];
            System.assertEquals(quoteQ1.LPCR_TypeFacturation__c, acc.LPCR_TypeFacturation__c, 'Quote LPCR_TypeFacturation__c not equals to acc LPCR_TypeFacturation__c');
            System.assertEquals(quoteQ1.LPCR_TypeCreche__c, acc.LPCR_TypeCreche__c, 'Quote LPCR_TypeCreche__c not equals to acc LPCR_TypeCreche__c');
            System.assertEquals(quoteQ1.SBQQ__StartDate__c, quoteQ1.LPCR_DateDebut__c, 'Quote SBQQ__StartDate__c not equals to quoteQ LPCR_DateDebut__c');
            System.assertEquals(quoteQ1.SBQQ__EndDate__c, date.newInstance(System.Today().year(), 12, 31), 'Quote SBQQ__EndDate__c not equals to quote Date');
            Test.stopTest();
        }
    }
            
            
    @isTest()        
    public static void updateQuotesB2CQuoMicroLCY_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            Id acceuilRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote, Label.LPCR_ContratA);//EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Contrat_Accueil');
            List<Account> accs3 = [SELECT Id, name , LPCR_TypeCreche__c , LPCR_EntiteJuridique__c from Account WHERE name ='Compte Crèche MICRO' LIMIT 1];
            Account acc3 = accs3.get(0);
            List<Opportunity> oppties = [SELECT Id , Name , LPCR_IndexationConvenue__c , LPCR_TypeFacturation__c , LPCR_BillingFrequency__c from Opportunity WHERE name ='opp Famille MAC1' LIMIT 1 ];
            //B2C Quote Micro less than Current Year
            SBQQ__Quote__c quoteQ2 = UM002_TestDataFactory.createQuotes(1, accs3, oppties,'Quote', acceuilRecTypeId, acc3.Id).get(0);
            quoteQ2.LPCR_DateDebut__c = date.newInstance(System.Today().year(), 06, 02);
            quoteQ2.LPCR_DateFin__c = date.newInstance(System.Today().year(), 06, 31);
                        quoteQ2.SBQQ__RenewalUpliftRate__c = 10;

            insert quoteQ2;
            quoteQ2 = [SELECT Id ,LPCR_TypeCreche__c , SBQQ__StartDate__c, LPCR_DateDebut__c,LPCR_DateFin__c, SBQQ__EndDate__c,LPCR_EntiteJuridique__c,LPCR_IndexationConvenue__c from SBQQ__Quote__c WHERE SBQQ__Type__c= 'Quote' AND  Id = :quoteQ2.Id];
            System.assertEquals(quoteQ2.LPCR_TypeCreche__c, acc3.LPCR_TypeCreche__c, 'Quote LPCR_TypeCreche__c not equals to acc LPCR_TypeCreche__c');
            System.assertEquals(quoteQ2.SBQQ__StartDate__c, quoteQ2.LPCR_DateDebut__c, 'Quote SBQQ__StartDate__c not equals to quoteQ LPCR_DateDebut__c');
            System.assertEquals(quoteQ2.SBQQ__EndDate__c, quoteQ2.LPCR_DateFin__c, 'Quote SBQQ__EndDate__c not equals to quoteQ LPCR_DateFin__c');
            System.assertEquals(quoteQ2.LPCR_EntiteJuridique__c, acc3.LPCR_EntiteJuridique__c, 'Quote LPCR_EntiteJuridique__c not equals to acc LPCR_EntiteJuridique__c');
            System.assertEquals('Oui',quoteQ2.LPCR_IndexationConvenue__c, 'Quote LPCR_IndexationConvenue__c not equals to non');
            Test.stopTest();
        }
    }



    @isTest()
    public static void updateQuotesB2CQuoMicroMCY_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            Id acceuilRecTypeId =EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote, Label.LPCR_ContratA);// EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Contrat_Accueil');
            //B2C Quote Micro more than Current Year
            List<Account> accs3 = [SELECT Id, name , LPCR_TypeCreche__c , LPCR_EntiteJuridique__c from Account WHERE name ='Compte Crèche MICRO' LIMIT 1];
            Account acc3 = accs3.get(0);
            List<Opportunity> oppties = [SELECT Id , Name , LPCR_IndexationConvenue__c , LPCR_TypeFacturation__c , LPCR_BillingFrequency__c from Opportunity WHERE name ='opp Famille MAC1' LIMIT 1 ];
            SBQQ__Quote__c quoteQ3 = UM002_TestDataFactory.createQuotes(1, accs3, oppties,'Quote', acceuilRecTypeId, acc3.Id).get(0);
            quoteQ3.LPCR_DateDebut__c = date.newInstance(System.Today().year(), 06, 04);
            quoteQ3.LPCR_DateFin__c = date.newInstance(System.Today().year()+1, 09, 31);
                        quoteQ3.SBQQ__RenewalUpliftRate__c = 10;
insert quoteQ3;
            quoteQ3 = [SELECT Id ,LPCR_TypeCreche__c , SBQQ__StartDate__c, LPCR_DateDebut__c,LPCR_DateFin__c, SBQQ__EndDate__c  from SBQQ__Quote__c WHERE SBQQ__Type__c= 'Quote' AND  Id = :quoteQ3.Id];
            System.assertEquals(quoteQ3.LPCR_TypeCreche__c, acc3.LPCR_TypeCreche__c, 'Quote LPCR_TypeCreche__c not equals to acc LPCR_TypeCreche__c');
            System.assertEquals(quoteQ3.SBQQ__StartDate__c, quoteQ3.LPCR_DateDebut__c, 'Quote SBQQ__StartDate__c not equals to quoteQ LPCR_DateDebut__c');
            System.assertEquals(quoteQ3.SBQQ__EndDate__c, date.newInstance(System.Today().year(), 08, 31), 'Quote SBQQ__EndDate__c not equals to quote Date');
            Test.stopTest();
        }
    }
            
    @isTest()      
    public static void updateQuotesB2CAmend_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            Id acceuilRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote, Label.LPCR_ContratA);//EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Contrat_Accueil');
            //B2C Amendment Non
            List<Account> accs3 = [SELECT Id, name , LPCR_TypeCreche__c , LPCR_EntiteJuridique__c from Account WHERE name ='Compte Crèche MICRO' LIMIT 1];
            Account acc3 = accs3.get(0);
            List<Contract> contract6 = [Select Id,RecordTypeId, LPCR_DateDebut__c , LPCR_DateFin__c , LPCR_ChiffreAffaire__c  , SBQQ__RenewalUpliftRate__c, LPCR_TypeCreche__c,LPCR_EntiteJuridique__c,LPCR_ContactEnfant__c,LPCR_Creche__c,LPCR_ContractEntreprise__c,LPCR_ContactRepresentant1__c,LPCR_ContactRepresentant2__c,LPCR_DureePreavisMois__c,LPCR_CongesJours__c,LPCR_TypeAccueil__c  From Contract WHERE Name = '0006' Limit 1];
            Contract con6 = contract6.get(0);
            con6.RecordTypeId =CONTRACT_CONTRAT_ACCUEIL_RT_ID;
            update con6;
            List<Opportunity> oppties6 = [SELECT Id , Name, LPCR_TypeFacturation__c ,LPCR_PlanningEnfant__c from Opportunity WHERE name ='opp NON' LIMIT 1 ];
            Opportunity opp6 = oppties6.get(0);
            SBQQ__Quote__c quote6 = UM002_TestDataFactory.createQuotes(1, accs3, oppties6,'Amendment', acceuilRecTypeId, acc3.Id).get(0);
            quote6.RecordTypeId = acceuilRecTypeId;
            insert quote6;
            quote6 = [SELECT Id ,LPCR_TypeCreche__c , LPCR_IndexationConvenue__c,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c, LPCR_DateDebut__c,LPCR_DateFin__c, SBQQ__EndDate__c,LPCR_ChiffreAffaire__c, LPCR_MethodeRenouvellement__c, SBQQ__RenewalUpliftRate__c,LPCR_EntiteJuridique__c,LPCR_ContactEnfant__c,LPCR_Creche__c,LPCR_ContractEntreprise__c,LPCR_ContactRepresentant1__c,LPCR_ContactRepresentant2__c,LPCR_DureePreavisMois__c,LPCR_CongesJours__c,LPCR_TypeAccueil__c,LPCR_PlanningEnfant__c   from SBQQ__Quote__c WHERE SBQQ__Type__c= 'Amendment' AND  Id = :quote6.Id];
            System.assertEquals(quote6.LPCR_DateDebut__c, con6.LPCR_DateDebut__c, 'Quote LPCR_DateDebut__c not equals to con LPCR_DateDebut__c');
            System.assertEquals(quote6.LPCR_DateFin__c, con6.LPCR_DateFin__c , 'Quote LPCR_DateFin__c not equals to con LPCR_DateFin__c');
            //System.assertEquals(quote6.LPCR_ChiffreAffaire__c, con6.LPCR_ChiffreAffaire__c, 'Quote LPCR_ChiffreAffaire__c not equals to con LPCR_ChiffreAffaire__c');
            System.assertEquals(quote6.LPCR_TypeFacturation__c, opp6.LPCR_TypeFacturation__c, 'Quote LPCR_MethodeRenouvellement__c not equals to con LPCR_MethodeRenouvellement__c');
            System.assertEquals(quote6.SBQQ__RenewalUpliftRate__c, null, 'Quote SBQQ__RenewalUpliftRate__c not equals to 0');
            
            
            System.assertEquals(quote6.LPCR_TypeCreche__c, con6.LPCR_TypeCreche__c, 'Quote LPCR_TypeCreche__c not equals to con LPCR_TypeCreche__c');
            System.assertEquals(quote6.LPCR_PlanningEnfant__c, opp6.LPCR_PlanningEnfant__c, 'Quote LPCR_PlanningEnfant__c not equals to oppt LPCR_PlanningEnfant__c');
            System.assertEquals(quote6.LPCR_ContactEnfant__c, con6.LPCR_ContactEnfant__c, 'Quote LPCR_ContactEnfant__c not equals to con LPCR_ContactEnfant__c');
            System.assertEquals(quote6.LPCR_Creche__c, con6.LPCR_Creche__c, 'Quote LPCR_Creche__c not equals to con LPCR_Creche__c');
            System.assertEquals(quote6.LPCR_ContractEntreprise__c, con6.LPCR_ContractEntreprise__c, 'Quote LPCR_ContractEntreprise__c not equals to con LPCR_ContractEntreprise__c');
            System.assertEquals(quote6.LPCR_ContactRepresentant1__c, con6.LPCR_ContactRepresentant1__c, 'Quote LPCR_ContactRepresentant1__c not equals to con LPCR_ContactRepresentant1__c');
            System.assertEquals(quote6.LPCR_ContactRepresentant2__c, con6.LPCR_ContactRepresentant2__c, 'Quote LPCR_ContactRepresentant2__c not equals to con LPCR_ContactRepresentant2__c');
            System.assertEquals(quote6.LPCR_CongesJours__c, con6.LPCR_CongesJours__c, 'Quote LPCR_CongesJours__c not equals to con LPCR_CongesJours__c');
            System.assertEquals(quote6.LPCR_DureePreavisMois__c, con6.LPCR_DureePreavisMois__c, 'Quote LPCR_DureePreavisMois__c not equals to con LPCR_DureePreavisMois__c');
            System.assertEquals(quote6.LPCR_TypeAccueil__c, con6.LPCR_TypeAccueil__c, 'Quote LPCR_TypeAccueil__c not equals to con LPCR_TypeAccueil__c');
            Test.stopTest();
        }
        
        
    }
    
    
    
    
    
    ////////////////////////////////////////
    
    @isTest()
    public static void updateQuotesB2BRenSRMCY_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            Id referencementRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Referencement');
            Id reservataireRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Reservataire');
            //B2B Renewal Sans renouvellement More than Current Year
            List<Account> accs = [SELECT Id, name   from Account WHERE name ='Compte Crèche MAC1' LIMIT 1];
            Account acc = accs.get(0);
            List<Opportunity> oppties2 = [SELECT Id , Name , LPCR_IndexationConvenue__c , LPCR_TypeFacturation__c , LPCR_BillingFrequency__c from Opportunity WHERE name ='opp Famille MAC2' LIMIT 1 ];
            Opportunity opp2 = oppties2.get(0);
            List<Contract> contract2 = [Select Id, LPCR_DateDebut__c , LPCR_DateFin__c , LPCR_ChiffreAffaire__c , LPCR_MethodeRenouvellement__c  From Contract WHERE Name = '0002' Limit 1];
            Contract con2 = contract2.get(0);
            SBQQ__Quote__c quote7 = UM002_TestDataFactory.createQuotes(1, accs, oppties2,'Renewal', referencementRecTypeId, acc.Id).get(0);
            insert quote7;
            quote7 = [SELECT Id ,LPCR_IndexationConvenue__c, LPCR_TypeFacturation__c, SBQQ__BillingFrequency__c , LPCR_DateDebut__c,LPCR_DateFin__c, SBQQ__EndDate__c,LPCR_ChiffreAffaire__c, LPCR_MethodeRenouvellement__c, SBQQ__RenewalUpliftRate__c, LPCR_BatchCommande__c  from SBQQ__Quote__c WHERE SBQQ__Type__c= 'Renewal' AND  Id = :quote7.Id];
            System.assertEquals(quote7.LPCR_IndexationConvenue__c, opp2.LPCR_IndexationConvenue__c, 'Quote LPCR_IndexationConvenue__c not equals to oppt LPCR_IndexationConvenue__c');
            System.assertEquals(quote7.LPCR_TypeFacturation__c, opp2.LPCR_TypeFacturation__c, 'Quote LPCR_TypeFacturation__c not equals to oppt LPCR_TypeFacturation__c');
            System.assertEquals(quote7.SBQQ__BillingFrequency__c, opp2.LPCR_BillingFrequency__c, 'Quote LPCR_BillingFrequency__c not equals to oppt LPCR_BillingFrequency__c');
            System.assertEquals(quote7.LPCR_DateDebut__c, con2.LPCR_DateDebut__c, 'Quote LPCR_DateDebut__c not equals to con LPCR_DateDebut__c');
            System.assertEquals(quote7.LPCR_DateFin__c, con2.LPCR_DateFin__c , 'Quote LPCR_DateFin__c not equals to con LPCR_DateFin__c');
            System.assertEquals(quote7.LPCR_MethodeRenouvellement__c, con2.LPCR_MethodeRenouvellement__c, 'Quote LPCR_MethodeRenouvellement__c not equals to oppt LPCR_MethodeRenouvellement__c');
            System.assertEquals(quote7.SBQQ__EndDate__c, date.newInstance(System.Today().year(), 12, 31), 'Quote SBQQ__EndDate__c not equals to date.newInstance(System.Today().year(), 06, 31)');
            //System.assertEquals(quote7.SBQQ__RenewalUpliftRate__c, 0, 'Quote SBQQ__RenewalUpliftRate__c not equals to 0');
            System.assertEquals(quote7.LPCR_BatchCommande__c, 'B2B', 'Quote LPCR_TypeCreche__c not equals to B2B');
            Test.stopTest();            
        } 
    }
    @isTest()
    public static void updateQuotesB2BRenExCYBU_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            Id referencementRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Referencement');
            Id reservataireRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Reservataire');
            //B2B Renewal Express Current Year before update
            List<Account> accs = [SELECT Id, name   from Account WHERE name ='Compte Crèche MAC1' LIMIT 1];
            Account acc = accs.get(0);
            List<Opportunity> oppties = [SELECT Id , Name from Opportunity WHERE name ='opp Famille MAC1' LIMIT 1 ];
            Opportunity opp = oppties.get(0);
            List<Contract> contract = [Select Id, LPCR_DateDebut__c , LPCR_DateFin__c , LPCR_ChiffreAffaire__c , LPCR_MethodeRenouvellement__c  From Contract WHERE Name = '0001' Limit 1];
            Contract con = contract.get(0);
            SBQQ__Quote__c quote8 = UM002_TestDataFactory.createQuotes(1, accs, oppties,'Re-Quote', reservataireRecTypeId, acc.Id).get(0);
            quote8.LPCR_DateFin__c = date.newInstance(System.Today().year()+1, 12, 31);
            insert quote8;
            quote8.SBQQ__Type__c = 'Renewal';
            update quote8;
            quote8 = [SELECT Id ,LPCR_TypeCreche__c , LPCR_IndexationConvenue__c,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c, LPCR_DateDebut__c,LPCR_DateFin__c, SBQQ__EndDate__c,LPCR_ChiffreAffaire__c, LPCR_MethodeRenouvellement__c  from SBQQ__Quote__c WHERE SBQQ__Type__c= 'Renewal' AND  Id = :quote8.Id];
            System.assertEquals(quote8.LPCR_DateDebut__c, con.LPCR_DateDebut__c, 'Quote LPCR_DateDebut__c not equals to con LPCR_DateDebut__c');
            System.assertEquals(quote8.LPCR_DateFin__c, con.LPCR_DateFin__c, 'Quote LPCR_DateFin__c not equals to con LPCR_DateFin__c');
            System.assertEquals(quote8.LPCR_MethodeRenouvellement__c, con.LPCR_MethodeRenouvellement__c, 'Quote LPCR_MethodeRenouvellement__c not equals to oppt LPCR_MethodeRenouvellement__c');
            System.assertEquals(quote8.SBQQ__EndDate__c, quote8.LPCR_DateFin__c, 'Quote SBQQ__EndDate__c not equals to Quote LPCR_DateFin__c');
            Test.stopTest();            
        } 
    }
    @isTest()
    public static void updateQuotesB2BTacite_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            Id referencementRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Referencement');
            Id reservataireRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Reservataire');
            //B2B Renewal Tacite 
            List<Account> accs = [SELECT Id, name   from Account WHERE name ='Compte Crèche MAC1' LIMIT 1];
            Account acc = accs.get(0);
            List<Opportunity> oppties3 = [SELECT Id , Name , LPCR_IndexationConvenue__c , LPCR_TypeFacturation__c , LPCR_BillingFrequency__c from Opportunity WHERE name ='opp Famille MICRO' LIMIT 1 ];
            Opportunity opp3 = oppties3.get(0);
            List<Contract> contract3 = [Select Id, LPCR_DateDebut__c , LPCR_DateFin__c , LPCR_ChiffreAffaire__c , LPCR_MethodeRenouvellement__c , SBQQ__RenewalUpliftRate__c From Contract WHERE Name = '0003' Limit 1];
            Contract con3 = contract3.get(0);
            SBQQ__Quote__c quote9 = UM002_TestDataFactory.createQuotes(1, accs, oppties3,'Renewal', referencementRecTypeId, acc.Id).get(0);
            insert quote9;
            quote9 = [SELECT Id ,LPCR_TypeCreche__c , LPCR_IndexationConvenue__c,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c, LPCR_DateDebut__c,LPCR_DateFin__c, SBQQ__EndDate__c,LPCR_ChiffreAffaire__c, LPCR_MethodeRenouvellement__c, SBQQ__RenewalUpliftRate__c  from SBQQ__Quote__c WHERE SBQQ__Type__c= 'Renewal' AND  Id = :quote9.Id];
            System.assertEquals(quote9.LPCR_IndexationConvenue__c, opp3.LPCR_IndexationConvenue__c, 'Quote LPCR_IndexationConvenue__c not equals to oppt LPCR_IndexationConvenue__c');
            System.assertEquals(quote9.LPCR_TypeFacturation__c, opp3.LPCR_TypeFacturation__c, 'Quote LPCR_TypeFacturation__c not equals to oppt LPCR_TypeFacturation__c');
            System.assertEquals(quote9.SBQQ__BillingFrequency__c, opp3.LPCR_BillingFrequency__c, 'Quote LPCR_BillingFrequency__c not equals to oppt LPCR_BillingFrequency__c');
            System.assertEquals(quote9.LPCR_DateDebut__c, con3.LPCR_DateDebut__c, 'Quote LPCR_DateDebut__c not equals to con LPCR_DateDebut__c');
            System.assertEquals(quote9.LPCR_DateFin__c, con3.LPCR_DateFin__c , 'Quote LPCR_DateFin__c not equals to con LPCR_DateFin__c');
            System.assertEquals(quote9.LPCR_MethodeRenouvellement__c, con3.LPCR_MethodeRenouvellement__c, 'Quote LPCR_MethodeRenouvellement__c not equals to oppt LPCR_MethodeRenouvellement__c');
            System.assertEquals(quote9.SBQQ__EndDate__c, date.newInstance(System.Today().year(), 12, 31), 'Quote SBQQ__EndDate__c not equals to date.newInstance(System.Today().year(), 06, 31)');
            //System.assertEquals(quote9.SBQQ__RenewalUpliftRate__c, 0, 'Quote SBQQ__RenewalUpliftRate__c not equals to 0');
            Test.stopTest();            
        } 
    }
    @isTest()        
    public static void updateQuotesB2BQuoLCY_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            Id referencementRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Referencement');
            Id reservataireRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Reservataire');
            //B2B Quote less than Current Year
            List<Account> accs = [SELECT Id, name   from Account WHERE name ='Compte Crèche MAC1' LIMIT 1];
            Account acc = accs.get(0);
            List<Opportunity> oppties3 = [SELECT Id , Name , LPCR_IndexationConvenue__c , LPCR_TypeFacturation__c , LPCR_BillingFrequency__c from Opportunity WHERE name ='opp Famille MICRO' LIMIT 1 ];
            SBQQ__Quote__c quote10 = UM002_TestDataFactory.createQuotes(1, accs, oppties3,'Quote', referencementRecTypeId, acc.Id).get(0);
            quote10.LPCR_DateDebut__c = date.newInstance(System.Today().year(), 06, 02);
            quote10.LPCR_DateFin__c = date.newInstance(System.Today().year(), 06, 31);
            insert quote10;
            quote10 = [SELECT Id ,LPCR_DateDebut__c,LPCR_DateFin__c, SBQQ__EndDate__c,SBQQ__StartDate__c  from SBQQ__Quote__c WHERE SBQQ__Type__c= 'Quote' AND  Id = :quote10.Id];
            System.assertEquals(quote10.SBQQ__StartDate__c, quote10.LPCR_DateDebut__c, 'Quote SBQQ__StartDate__c not equals to Quote LPCR_DateDebut__c');
            System.assertEquals(quote10.SBQQ__EndDate__c, quote10.LPCR_DateFin__c, 'Quote SBQQ__EndDate__c not equals to Quote LPCR_DateFin__c');
            Test.stopTest();            
        } 
    }



    @isTest()
    public static void updateQuotesB2BQuoMCY_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            Id referencementRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Referencement');
            Id reservataireRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Reservataire');
            //B2B Quote more than Current Year
            List<Account> accs = [SELECT Id, name   from Account WHERE name ='Compte Crèche MAC1' LIMIT 1];
            Account acc = accs.get(0);
            List<Opportunity> oppties3 = [SELECT Id , Name , LPCR_IndexationConvenue__c , LPCR_TypeFacturation__c , LPCR_BillingFrequency__c from Opportunity WHERE name ='opp Famille MICRO' LIMIT 1 ];
            SBQQ__Quote__c quote11 = UM002_TestDataFactory.createQuotes(1, accs, oppties3,'Quote', reservataireRecTypeId, acc.Id).get(0);
            quote11.LPCR_DateDebut__c = date.newInstance(System.Today().year(), 06, 02);
            quote11.LPCR_DateFin__c = date.newInstance(System.Today().year()+1, 06, 31);
            insert quote11;
            quote11 = [SELECT Id  , LPCR_DateDebut__c,LPCR_DateFin__c, SBQQ__EndDate__c,SBQQ__StartDate__c   from SBQQ__Quote__c WHERE SBQQ__Type__c= 'Quote' AND  Id = :quote11.Id];
            System.assertEquals(quote11.SBQQ__StartDate__c, quote11.LPCR_DateDebut__c, 'Quote SBQQ__StartDate__c not equals to Quote LPCR_DateDebut__c');
            System.assertEquals(quote11.SBQQ__EndDate__c, date.newInstance(System.Today().year(), 12, 31), 'Quote SBQQ__EndDate__c not equals todate.newInstance(System.Today().year()+1, 06, 31);');
            Test.stopTest();            
        } 
    }


    @isTest()
    public static void updateQuotesB2BAmend_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            Id referencementRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Referencement');
            Id reservataireRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Reservataire');       
            //B2B Amendment
            List<Account> accs = [SELECT Id, name   from Account WHERE name ='Compte Crèche MAC1' LIMIT 1];
            Account acc = accs.get(0);
            List<Opportunity> oppties4 = [SELECT Id  from Opportunity WHERE name ='opp NON' LIMIT 1 ];
            Opportunity opp4 = oppties4.get(0);
            List<Contract> contract4 = [Select Id, LPCR_DateDebut__c , LPCR_DateFin__c , LPCR_ChiffreAffaire__c   From Contract WHERE Name = '0006' Limit 1];
            Contract con4 = contract4.get(0);
            SBQQ__Quote__c quote12 = UM002_TestDataFactory.createQuotes(1, accs, oppties4,'Amendment', referencementRecTypeId, acc.Id).get(0);
            insert quote12;
            quote12 = [SELECT Id, LPCR_DateDebut__c,LPCR_DateFin__c,LPCR_ChiffreAffaire__c  from SBQQ__Quote__c WHERE SBQQ__Type__c= 'Amendment' AND  Id = :quote12.Id];
            System.assertEquals(quote12.LPCR_DateDebut__c, con4.LPCR_DateDebut__c, 'Quote LPCR_DateDebut__c not equals to con LPCR_DateDebut__c');
            System.assertEquals(quote12.LPCR_DateFin__c, con4.LPCR_DateFin__c , 'Quote LPCR_DateFin__c not equals to con LPCR_DateFin__c');
            Test.stopTest();
            
            
        } }
    
}