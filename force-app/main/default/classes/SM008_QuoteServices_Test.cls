/**
* @author Achraf ABOUL
* @created 28/02/2020
* @description Test Class of SM008_QuoteServices.
* @Modified by Hanae
*/
@isTest
public class SM008_QuoteServices_Test {
    private static final Id B2C_RT_ID =                 EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Famille);
    private static final Id ContratA_RT_ID =            EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c', Label.LPCR_ContratA);

    private static final Id CONTRACT_CONTRAT_ACCUEIL_RT_ID =        EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract, Label.LPCR_ContratA);
    private static final Id CONTRACT_RESERVATRICE_RT_ID =           EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract, Label.LPCR_Reservataire);
    private static final Id CONTRACT_REFERENCEMENT_RT_ID =          EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract, Label.LPCR_Referencement);

@testSetup 
    static void testSetup(){
        List<sObject> bulkify = new List<sObject>();

        //bulkify the retrieving of record types ids from all object in one query
        List<RecordType> AllRts = [SELECT sobjecttype,developername,id FROM recordtype];
        Map<String,Id> RTNameIdAccount = new Map<String,Id>();
        Map<String,Id> RTNameIdContact = new Map<String,Id>();
        Map<String,Id> RTNameIdQuote = new Map<String,Id>();
        Map<String,Id> RTNameIdContract = new Map<String,Id>();
        for(RecordType rt : AllRts){
            switch on rt.sobjecttype {
                when 'Account' {		
                    RTNameIdAccount.put(rt.developername,rt.id);
                }	
                when 'Contact' {		
                    RTNameIdContact.put(rt.developername,rt.id);
                }
                when 'SBQQ__Quote__c' {		
                    RTNameIdQuote.put(rt.developername,rt.id);
                }
                when 'Contract' {		
                    RTNameIdContract.put(rt.developername,rt.id);
                }
            }
        }
        id recTypeId =          RTNameIdAccount.get('Creche');
        id recTypeFamilleId =   RTNameIdAccount.get('Famille');
        id recTypeEnfantId =            RTNameIdContact.get('Enfant');
        id recTypecontactFamilleId =    RTNameIdContact.get('Famille');
        id acceuilRecTypeId =       RTNameIdQuote.get(Label.LPCR_ContratA);
        id referencementRecTypeId = RTNameIdQuote.get('Referencement');
        id reservataireRecTypeId =  RTNameIdQuote.get('Reservataire');
        /////////////*****************/////////////


        blng__LegalEntity__c entiteJuridique = UM002_TestDataFactory.setupLegalEntity();
        LPCR_Planning__c planningEnfant = new LPCR_Planning__c();	
        insert planningEnfant;
        Contact contact = UM002_TestDataFactory.createContact('contact Enfant',recTypeEnfantId);
        Contact conErpresentant1 = UM002_TestDataFactory.createContact('contact Rep1',recTypecontactFamilleId);
        Contact conErpresentant2 = UM002_TestDataFactory.createContact('contact Rep2',recTypecontactFamilleId);
        
        List<Account> accCreche = UM002_TestDataFactory.createAccountWithRecType(1, 'Compte Crèche MAC1', recTypeId, 'MAC');
        List<Account> accFamille = UM002_TestDataFactory.createAccountWithRecType(1, 'Compte Famille MAC1', recTypeFamilleId, '');
        
        bulkify = new List<sObject>();
        bulkify.addAll(accCreche);
        bulkify.addAll(accFamille);
        insert bulkify;
        Account acCreche = accCreche.get(0);
        Account accc = accFamille.get(0);

        Contract mainCon = UM002_TestDataFactory.createContract(accc.Id);
         
        /////////////*****************/////////////
        


        //  CONTRACTs SECTION
        List<Contract> Renewalcontract = UM002_TestDataFactory.createContracts(1,accc.Id,'0001',date.newInstance(System.Today().year(), 07, 02), date.newInstance(System.Today().year(), 12, 31),123, 'Sans renouvellement', 'Non', Null, 'MAC' );
        List<Contract> Renewalcontract2 = UM002_TestDataFactory.createContracts(1,accc.Id,'0002',date.newInstance(System.Today().year(), 07, 02), date.newInstance(System.Today().year()+1, 05, 25),123, 'Express', 'Non', Null, 'MAC' );
        List<Account> accCreche3 = UM002_TestDataFactory.createAccountWithRecType(1, 'Compte Crèche MICRO', recTypeId, 'MICRO');
        List<Contract> Renewalcontract3 = UM002_TestDataFactory.createContracts(1,accc.Id,'0003',date.newInstance(System.Today().year(), 07, 02), date.newInstance(System.Today().year(), 12, 31),123, 'Tacite', 'Non', Null,'MICRO' );
        List<Contract> Renewalcontract4 = UM002_TestDataFactory.createContracts(1,accc.Id,'0004',date.newInstance(System.Today().year(), 07, 02), date.newInstance(System.Today().year()+1, 09, 15),123, 'Express', 'Non', Null, 'MICRO' );
        List<Contract> Renewalcontract6 = UM002_TestDataFactory.createContracts(1,accc.Id,'0006',date.newInstance(System.Today().year(), 07, 02), date.newInstance(System.Today().year(), 08, 31),123, 'Express', 'Non', Null, 'MICRO' );
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
        for(Contract eachContract : Renewalcontract6){
             eachContract.LPCR_EntiteJuridique__c = entiteJuridique.Id;
             eachContract.LPCR_ContactEnfant__c = contact.Id;
             eachContract.LPCR_ContractEntreprise__c = mainCon.Id;
             eachContract.LPCR_ContactRepresentant1__c = conErpresentant1.Id;
             eachContract.LPCR_ContactRepresentant2__c = conErpresentant2.Id;
             eachContract.LPCR_CongesJours__c = 33;
             eachContract.LPCR_DureePreavisMois__c = '3';
             eachContract.LPCR_TypeAccueil__c = 'Occasionnel';
             eachContract.LPCR_MethodeRenouvellement__c = 'Tacite';
             eachContract.LPCR_IndexationConvenue__c = 'Non';
        }
        bulkify = new List<sObject>();
        bulkify.addAll(Renewalcontract);
        bulkify.addAll(Renewalcontract2);
        bulkify.addAll(accCreche3);
        bulkify.addAll(Renewalcontract3);
        bulkify.addAll(Renewalcontract4);
        bulkify.addAll(Renewalcontract6);
        insert bulkify;
        Contract con = Renewalcontract.get(0);
        Contract con2 = Renewalcontract2.get(0);
        Contract con3 = Renewalcontract3.get(0);
        Contract con4 = Renewalcontract4.get(0);
        Contract con6 = Renewalcontract6.get(0);


        /////////////*****************/////////////

        // OPPS SECTION
        List<Opportunity> renwalOpps = UM002_TestDataFactory.createOpportunities(1, 'opp Famille MAC1', 'Prospecting', 'Oui', 'Advance', 'Invoice Plan',con.Id, Null );
        List<Opportunity> renwalOpps2 = UM002_TestDataFactory.createOpportunities(1, 'opp Famille MAC2', 'Prospecting', 'Oui', 'Advance', 'Invoice Plan',con2.Id, Null );
        List<Opportunity> renwalOpps3 = UM002_TestDataFactory.createOpportunities(1, 'opp Famille MICRO', 'Prospecting', 'Oui', 'Advance', 'Invoice Plan',con3.Id,Null );
        List<Opportunity> renwalOpps4 = UM002_TestDataFactory.createOpportunities(1, 'opp Famille MICRO2', 'Prospecting', 'Oui', 'Advance', 'Invoice Plan',con4.Id,Null );
        List<Opportunity> renwalOpps6 = UM002_TestDataFactory.createOpportunities(1, 'opp NON', 'Prospecting', 'Oui', 'Advance', 'Invoice Plan', Null ,con6.Id );
        for(Opportunity eachOppty : renwalOpps){eachOppty.LPCR_PlanningEnfant__c = planningEnfant.ID;}
        for(Opportunity eachOppty : renwalOpps6){eachOppty.LPCR_PlanningEnfant__c = planningEnfant.ID;}
        bulkify = new List<sObject>();
        bulkify.addAll(renwalOpps);
        bulkify.addAll(renwalOpps2);
        bulkify.addAll(renwalOpps3);
        bulkify.addAll(renwalOpps4);
        bulkify.addAll(renwalOpps6);
        insert bulkify;

        //////
        List<Account> accounts = UM002_TestDataFactory.createAccounts(5, 'testAccount');
        List<Opportunity> opps = UM002_TestDataFactory.createOpportunities(5, 'testOpp', 'Prospecting');
        bulkify = new List<sObject>();
        bulkify.addAll(accounts);
        bulkify.addAll(opps);
        insert bulkify;

        //////
        List<SBQQ__Quote__c> quotes = UM002_TestDataFactory.createQuotes(5, accounts, opps);
        Account acc = UM002_TestDataFactory.createAccounts(1, 'test').get(0);acc.RecordTypeId = B2C_RT_ID;
        List<Account> accountsMac = UM002_TestDataFactory.createAccountWithRecType(1, 'Accounts',recTypeId, 'MAC');
        List<Account> accountsMicro = UM002_TestDataFactory.createAccountWithRecType(1, 'Accounts', recTypeId, 'MICRO');
        bulkify = new List<sObject>();
        bulkify.addAll(quotes);
        bulkify.add(acc);
        bulkify.add(UM002_TestDataFactory.createOpportunities(1, 'test', 'Prospecting').get(0));
        bulkify.addAll(accountsMac);
        bulkify.addAll(accountsMicro);
        insert bulkify;

    }


    
    @isTest
    public static void updateOppsFromQuotes_Test(){
        Test.startTest();
        List<SBQQ__Quote__c> quotes = [SELECT Id, SBQQ__Status__c from SBQQ__Quote__c];
        for(SBQQ__Quote__c eachQuote : quotes){
            eachQuote.SBQQ__Status__c = 'Signé';
        }
        TM000_TriggerHandler.runUpdateOnce = true;
        update quotes;
        List<Opportunity> resultOpps = [SELECT Id, StageName FROM Opportunity WHERE StageName = 'Signée'];
        System.assertEquals(5, resultOpps.size(), 'Error in SM008_QuoteServices_Test : problem in updating Opportunity');
        Test.stopTest();
        
    }

    @isTest
    private static void updateAccountsFromQuotes_Test(){

        Account acc1 = new Account(Name = 'acc1');
        insert acc1;
        List<Opportunity> opps = UM002_TestDataFactory.createOpportunities(1, 'testOpp', 'Prospecting');
        insert opps;

        Id priceBook = Test.getStandardPricebookId();

        SBQQ__Quote__c q1 = new SBQQ__Quote__c(  SBQQ__Opportunity2__c = opps.get(0).Id, SBQQ__Account__c = acc1.Id,
                                                        SBQQ__PriceBook__c = priceBook,
                                                        SBQQ__StartDate__c = date.today(),
                                                        LPCR_Creation_conforme__c = true,
                                                        SBQQ__Status__c = 'Draft');
        SBQQ__Quote__c q2 = new SBQQ__Quote__c(  SBQQ__Opportunity2__c = opps.get(0).Id, SBQQ__Account__c = acc1.Id,
                                                        SBQQ__PriceBook__c = priceBook,
                                                        SBQQ__StartDate__c = date.today(),
                                                        LPCR_Creation_conforme__c = true,
                                                        SBQQ__Status__c = 'Draft');
        SBQQ__Quote__c q3 = new SBQQ__Quote__c(  SBQQ__Opportunity2__c = opps.get(0).Id, SBQQ__Account__c = acc1.Id,
                                                        SBQQ__PriceBook__c = priceBook,
                                                        SBQQ__StartDate__c = date.today(),
                                                        LPCR_Creation_conforme__c = true,
                                                        SBQQ__Status__c = 'Draft');

        Test.startTest();
        insert (new List<SBQQ__Quote__c>{q1,q2,q3});

        Account accRes1 = [SELECT id,LPCR_Statut__c,(SELECT Id,SBQQ__Status__c FROM SBQQ__Quotes__r) FROM Account WHERE id=:acc1.id];
        
        System.assertEquals('Prospect', accRes1.LPCR_Statut__c);

        q2.SBQQ__Status__c = 'Actif';
        TM000_TriggerHandler.runUpdateOnce = true;
        update q2;
        Account accRes2 = [SELECT id,LPCR_Statut__c,(SELECT Id,SBQQ__Status__c FROM SBQQ__Quotes__r) FROM Account WHERE id=:acc1.id];
        System.assertEquals('Client', accRes2.LPCR_Statut__c);

        q2.SBQQ__Status__c = 'Terminé';
        TM000_TriggerHandler.runUpdateOnce = true;
        update q2;
        Account accRes3 = [SELECT id,LPCR_Statut__c FROM Account WHERE id=:acc1.id];
        System.assertEquals('Prospect', accRes3.LPCR_Statut__c);


        q1.SBQQ__Status__c = 'Terminé';
        q3.SBQQ__Status__c = 'Terminé';
        TM000_TriggerHandler.runUpdateOnce = true;
        update (new List<SBQQ__Quote__c>{q1,q3});
        Account accRes4 = [SELECT id,LPCR_Statut__c FROM Account WHERE id=:acc1.id];
        System.assertEquals('Ancien client', accRes4.LPCR_Statut__c);
        
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
                                        LPCR_DateFin__c = Date.newInstance(2020, 05, 30),LPCR_MethodeRenouvellement__c = 'Express' );
            con.RecordTypeId = CONTRACT_RESERVATRICE_RT_ID;
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

    @isTest()
    public static void updateQuotesB2CRenMacLCY_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            Id acceuilRecTypeId =ContratA_RT_ID;// EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Contrat_Accueil');
            
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
            quote.SBQQ__StartDate__c = System.Today();
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
            Id acceuilRecTypeId =ContratA_RT_ID;// EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Contrat_Accueil');
            
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
            Id acceuilRecTypeId = ContratA_RT_ID;//EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Contrat_Accueil');
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
            System.assertEquals(null, quote3.SBQQ__RenewalUpliftRate__c, 'Quote SBQQ__RenewalUpliftRate__c not equals to 0');
            Test.stopTest();
        }
    }
           
    @isTest()
    public static void updateQuotesB2CRenMicroMSep_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            Id acceuilRecTypeId =ContratA_RT_ID;// EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Contrat_Accueil');
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
            Id acceuilRecTypeId = ContratA_RT_ID;//EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Contrat_Accueil');
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
            Id acceuilRecTypeId = ContratA_RT_ID;//EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Contrat_Accueil');
            //B2C Quote MAC more than Current Year before update
            
            List<Account> accs = [SELECT Id, name , LPCR_TypeCreche__c , LPCR_EntiteJuridique__c, LPCR_TypeFacturation__c from Account WHERE name ='Compte Crèche MAC1' LIMIT 1];
            
            System.debug('**accounts : ' + accs);
            Account acc = accs.get(0);
            
            List<Opportunity> oppties = [SELECT Id , Name , LPCR_IndexationConvenue__c , LPCR_TypeFacturation__c , LPCR_BillingFrequency__c from Opportunity WHERE name ='opp Famille MAC1' LIMIT 1 ];
            System.debug('**oppties : ' + oppties);
            Opportunity opp = oppties.get(0);

            SBQQ__Quote__c quoteQ1 = new SBQQ__Quote__c(
                SBQQ__Opportunity2__c = opp.Id,
                SBQQ__Account__c = acc.Id,
                SBQQ__Type__c = 'Re-Quote',
		        LPCR_Creation_conforme__c = true,    
                RecordTypeId = acceuilRecTypeId,
                LPCR_Creche__c = acc.Id,
                LPCR_DateDebut__c = date.newInstance(System.Today().year(), 06, 04),
                LPCR_DateFin__c = date.newInstance(System.Today().year()+1, 06, 31),
                SBQQ__EndDate__c = date.newInstance(System.Today().year(), 12, 31)
                );
            insert quoteQ1;

            System.debug('after insert : ' + [SELECT Id ,LPCR_TypeCreche__c , LPCR_DateDebut__c FROM SBQQ__Quote__c WHERE Id =: quoteQ1.Id]);

            quoteQ1.LPCR_DateDebut__c = date.newInstance(System.Today().year(), 06, 04);
            quoteQ1.SBQQ__Type__c = 'Quote';
            System.debug('TM Before My Update*******');
            TM000_TriggerHandler.runUpdateOnce = true;
            update quoteQ1;
            System.debug('TM After My Update********');

            SBQQ__Quote__c q = [SELECT Id ,LPCR_TypeCreche__c , SBQQ__StartDate__c, LPCR_DateDebut__c,LPCR_DateFin__c, SBQQ__EndDate__c , LPCR_TypeFacturation__c FROM SBQQ__Quote__c 
                        WHERE SBQQ__Type__c= 'Quote' AND  Id = :quoteQ1.Id];
            System.debug('**quoteQ1 after up' + quoteQ1);


            System.assertEquals(q.LPCR_TypeFacturation__c, acc.LPCR_TypeFacturation__c, 'Quote LPCR_TypeFacturation__c not equals to acc LPCR_TypeFacturation__c');
            System.assertEquals(q.LPCR_TypeCreche__c, acc.LPCR_TypeCreche__c, 'Quote LPCR_TypeCreche__c not equals to acc LPCR_TypeCreche__c');
            System.assertEquals(q.LPCR_DateDebut__c,q.SBQQ__StartDate__c,  'Quote SBQQ__StartDate__c not equals to quoteQ LPCR_DateDebut__c');
            System.assertEquals(date.newInstance(System.Today().year(), 12, 31),q.SBQQ__EndDate__c, 'Quote SBQQ__EndDate__c not equals to quote Date');
            Test.stopTest();
        }
    }
            
            
    @isTest()        
    public static void updateQuotesB2CQuoMicroLCY_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            Id acceuilRecTypeId = ContratA_RT_ID;//EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Contrat_Accueil');
            List<Account> accs3 = [SELECT Id, name , LPCR_TypeCreche__c , LPCR_EntiteJuridique__c from Account WHERE name ='Compte Crèche MICRO' LIMIT 1];
            Account acc3 = accs3.get(0);
            List<Opportunity> oppties = [SELECT Id , Name , LPCR_IndexationConvenue__c , LPCR_TypeFacturation__c , LPCR_BillingFrequency__c from Opportunity WHERE name ='opp Famille MAC1' LIMIT 1 ];
            //B2C Quote Micro less than Current Year
            SBQQ__Quote__c quoteQ2 = UM002_TestDataFactory.createQuotes(1, accs3, oppties,'Quote', acceuilRecTypeId, acc3.Id).get(0);
            quoteQ2.LPCR_DateDebut__c = date.newInstance(System.Today().year(), 06, 02);
            quoteQ2.LPCR_DateFin__c = date.newInstance(System.Today().year(), 06, 31);
                        quoteQ2.SBQQ__RenewalUpliftRate__c = 10;

            insert quoteQ2;
            quoteQ2 = [SELECT Id ,LPCR_TypeCreche__c , SBQQ__StartDate__c, LPCR_DateDebut__c,LPCR_DateFin__c, SBQQ__EndDate__c,LPCR_EntiteJuridique__c,LPCR_IndexationConvenue__c, SBQQ__RenewalUpliftRate__c from SBQQ__Quote__c WHERE SBQQ__Type__c= 'Quote' AND  Id = :quoteQ2.Id];
            Double upliftRate = [SELECT Id ,MasterLabel,LPCR_RenewalUpliftRate__c FROM LPCR_Default_Uplift_Rate__mdt WHERE MasterLabel = 'MICRO' LIMIT 1].LPCR_RenewalUpliftRate__c;
            System.assertEquals(quoteQ2.LPCR_TypeCreche__c, acc3.LPCR_TypeCreche__c, 'Quote LPCR_TypeCreche__c not equals to acc LPCR_TypeCreche__c');
            System.assertEquals(quoteQ2.SBQQ__StartDate__c, quoteQ2.LPCR_DateDebut__c, 'Quote SBQQ__StartDate__c not equals to quoteQ LPCR_DateDebut__c');
            System.assertEquals(quoteQ2.SBQQ__EndDate__c, quoteQ2.LPCR_DateFin__c, 'Quote SBQQ__EndDate__c not equals to quoteQ LPCR_DateFin__c');
            System.assertEquals(quoteQ2.LPCR_EntiteJuridique__c, acc3.LPCR_EntiteJuridique__c, 'Quote LPCR_EntiteJuridique__c not equals to acc LPCR_EntiteJuridique__c');
            System.assertEquals('Oui',quoteQ2.LPCR_IndexationConvenue__c, 'Quote LPCR_IndexationConvenue__c not equals to non');
            System.assertEquals(upliftRate,quoteQ2.SBQQ__RenewalUpliftRate__c, 'Quote SBQQ__RenewalUpliftRate__c not equals to default uplift rate');
            Test.stopTest();
        }
    }



    @isTest()
    public static void updateQuotesB2CQuoMicroMCY_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            Id acceuilRecTypeId =ContratA_RT_ID;// EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Contrat_Accueil');
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
            Id acceuilRecTypeId = ContratA_RT_ID;//EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Contrat_Accueil');
            //B2C Amendment Non
            List<Account> accs3 = [SELECT Id, name , LPCR_TypeCreche__c , LPCR_EntiteJuridique__c from Account WHERE name ='Compte Crèche MICRO' LIMIT 1];
            Account acc3 = accs3.get(0);
            List<Contract> contract6 = [Select Id,RecordTypeId, LPCR_DateDebut__c , LPCR_DateFin__c , LPCR_ChiffreAffaire__c  , SBQQ__RenewalUpliftRate__c, LPCR_TypeCreche__c,LPCR_EntiteJuridique__c,LPCR_ContactEnfant__c,LPCR_Creche__c,LPCR_ContractEntreprise__c,LPCR_ContactRepresentant1__c,LPCR_ContactRepresentant2__c,LPCR_DureePreavisMois__c,LPCR_CongesJours__c,LPCR_TypeAccueil__c  From Contract WHERE Name = '0006' Limit 1];
            Contract con6 = contract6.get(0);
            con6.RecordTypeId =CONTRACT_CONTRAT_ACCUEIL_RT_ID;
            con6.LPCR_Creche__c = acc3.Id;
            update con6;
            List<Opportunity> oppties6 = [SELECT Id , Name, LPCR_TypeFacturation__c ,LPCR_PlanningEnfant__c from Opportunity WHERE name ='opp NON' LIMIT 1 ];
            Opportunity opp6 = oppties6.get(0);
            SBQQ__Quote__c quote6 = UM002_TestDataFactory.createQuotes(1, accs3, oppties6,'Amendment', acceuilRecTypeId, acc3.Id).get(0);
            quote6.RecordTypeId = acceuilRecTypeId;
            insert quote6;
            quote6 = [SELECT Id ,LPCR_TypeCreche__c , LPCR_IndexationConvenue__c,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c, LPCR_DateDebut__c,LPCR_DateFin__c, SBQQ__EndDate__c,LPCR_ChiffreAffaire__c, LPCR_MethodeRenouvellement__c, SBQQ__RenewalUpliftRate__c,LPCR_EntiteJuridique__c,LPCR_ContactEnfant__c,LPCR_Creche__c,LPCR_ContractEntreprise__c,LPCR_ContactRepresentant1__c,LPCR_ContactRepresentant2__c,LPCR_DureePreavisMois__c,LPCR_CongesJours__c,LPCR_TypeAccueil__c,LPCR_PlanningEnfant__c,LPCR_BatchCommande__c   from SBQQ__Quote__c WHERE SBQQ__Type__c= 'Amendment' AND  Id = :quote6.Id];
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
            System.assertEquals('MICRO', quote6.LPCR_BatchCommande__c, 'Quote LPCR_BatchCommande__c not equals to MICRO');
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
            con2.RecordTypeId = CONTRACT_RESERVATRICE_RT_ID;
            update con2;
            SBQQ__Quote__c quote7 = UM002_TestDataFactory.createQuotes(1, accs, oppties2,'Renewal', referencementRecTypeId, acc.Id).get(0);
            insert quote7;
            quote7 = [SELECT Id ,RecordTypeId, LPCR_IndexationConvenue__c, LPCR_TypeFacturation__c, SBQQ__BillingFrequency__c , LPCR_DateDebut__c,LPCR_DateFin__c, SBQQ__EndDate__c,LPCR_ChiffreAffaire__c, LPCR_MethodeRenouvellement__c, SBQQ__RenewalUpliftRate__c, LPCR_BatchCommande__c  from SBQQ__Quote__c WHERE SBQQ__Type__c= 'Renewal' AND  Id = :quote7.Id];
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

            
            SBQQ__Quote__c quote8 = new SBQQ__Quote__c(
                SBQQ__Opportunity2__c = opp.Id,
                SBQQ__Account__c = acc.Id,
                SBQQ__Type__c = 'Re-Quote',
		        LPCR_Creation_conforme__c = true,    
                RecordTypeId = reservataireRecTypeId,
                LPCR_Creche__c = acc.id,
                SBQQ__StartDate__c = date.today(),
                SBQQ__EndDate__c = date.newInstance(System.Today().year(), 12, 31)
            );
            insert quote8;

            SBQQ__Quote__c q = [SELECT SBQQ__Type__c FROM SBQQ__Quote__c WHERE id=:quote8.id];
            System.debug('q type : ' + q.SBQQ__Type__c);

            quote8.SBQQ__Type__c = 'Renewal';

            TM000_TriggerHandler.runUpdateOnce = true;
            update quote8;

            SBQQ__Quote__c q2 = [SELECT SBQQ__Type__c FROM SBQQ__Quote__c WHERE id=:quote8.id];
            System.debug('q2 type : ' + q2.SBQQ__Type__c); 


            SBQQ__Quote__c qResult = [SELECT Id ,LPCR_TypeCreche__c , LPCR_IndexationConvenue__c,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c,
                                            LPCR_DateDebut__c,LPCR_DateFin__c, SBQQ__EndDate__c,LPCR_ChiffreAffaire__c, LPCR_MethodeRenouvellement__c  
                                        FROM SBQQ__Quote__c 
                                        WHERE SBQQ__Type__c= 'Renewal' AND  Id = :quote8.Id];

            System.assertEquals(con.LPCR_DateDebut__c,              qResult.LPCR_DateDebut__c,  'Quote LPCR_DateDebut__c not equals to con LPCR_DateDebut__c');
            System.assertEquals(con.LPCR_DateFin__c,                qResult.LPCR_DateFin__c,  'Quote LPCR_DateFin__c not equals to con LPCR_DateFin__c');
            System.assertEquals(con.LPCR_MethodeRenouvellement__c,  qResult.LPCR_MethodeRenouvellement__c, 'Quote LPCR_MethodeRenouvellement__c not equals to oppt LPCR_MethodeRenouvellement__c');
            System.assertEquals(qResult.LPCR_DateFin__c,             qResult.SBQQ__EndDate__c,  'Quote SBQQ__EndDate__c not equals to Quote LPCR_DateFin__c');
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
            Id referencementRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote,Label.LPCR_Referencement);
            Id referencementContractReTID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Contract','Reservataire');       
            //B2B Amendment
            List<Account> accs = [SELECT Id, name   from Account WHERE name ='Compte Crèche MAC1' LIMIT 1];
            Account acc = accs.get(0);
            List<Opportunity> oppties4 = [SELECT Id  from Opportunity WHERE name ='opp NON' LIMIT 1 ];
            Opportunity opp4 = oppties4.get(0);
            List<Contract> contract4 = [Select Id, LPCR_DateDebut__c , LPCR_DateFin__c , LPCR_ChiffreAffaire__c , LPCR_MethodeRenouvellement__c,LPCR_IndexationConvenue__c  From Contract WHERE Name = '0006' Limit 1];
            Contract con4 = contract4.get(0);
            con4.RecordTypeId = referencementContractReTID;
            update con4;
            SBQQ__Quote__c quote12 = UM002_TestDataFactory.createQuotes(1, accs, oppties4,'Amendment', referencementRecTypeId, acc.Id).get(0);
            quote12.RecordTypeId = referencementRecTypeId;
            insert quote12;
            quote12 = [SELECT Id, LPCR_DateDebut__c,LPCR_DateFin__c,LPCR_ChiffreAffaire__c , LPCR_MethodeRenouvellement__c, LPCR_IndexationConvenue__c from SBQQ__Quote__c WHERE SBQQ__Type__c= 'Amendment' AND  Id = :quote12.Id ];
            System.assertEquals(quote12.LPCR_DateDebut__c, con4.LPCR_DateDebut__c, 'Quote LPCR_DateDebut__c not equals to con LPCR_DateDebut__c');
            System.assertEquals(quote12.LPCR_DateFin__c, con4.LPCR_DateFin__c , 'Quote LPCR_DateFin__c not equals to con LPCR_DateFin__c');
            System.assertEquals(con4.LPCR_MethodeRenouvellement__c, quote12.LPCR_MethodeRenouvellement__c, 'Quote LPCR_MethodeRenouvellement__c not equals to con LPCR_MethodeRenouvellement__c');
            System.assertEquals(con4.LPCR_IndexationConvenue__c, quote12.LPCR_IndexationConvenue__c, 'Quote LPCR_MethodeRenouvellement__c not equals to con LPCR_MethodeRenouvellement__c');
            Test.stopTest();
            
            
        } 
    }

    @isTest()
    public static void updateQuoteLineChiffreAffaire_Test(){

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

            
            SBQQ__Quote__c simpleQuote = new SBQQ__Quote__c(
                SBQQ__Opportunity2__c = opp.Id,
                SBQQ__Account__c = acc.Id,
                SBQQ__Type__c = 'Quote',
		        LPCR_Creation_conforme__c = true,    
                RecordTypeId = reservataireRecTypeId,
                LPCR_Creche__c = acc.id,
                SBQQ__StartDate__c = date.today(),
                SBQQ__EndDate__c = date.newInstance(System.Today().year(), 12, 31)
            );
            insert simpleQuote;

            Id standardPricebookId = Test.getStandardPricebookId();
            UM002_TestDataFactory.insertBillingCustomSettings();
        
            blng__LegalEntity__c billingLegalEntity = UM002_TestDataFactory.setupLegalEntity();
            
            blng__RevenueRecognitionRule__c revRecRule = UM002_TestDataFactory.setupRevRec(billingLegalEntity.Id);
            
            blng__BillingRule__c billingRule = UM002_TestDataFactory.setupBillingRule(billingLegalEntity.Id);
            
            blng__TaxRule__c taxRule = UM002_TestDataFactory.setupTaxRule(billingLegalEntity.Id);
            
            Product2 prod = UM002_TestDataFactory.createProduct('BerceauMicrotest', billingRule.Id, revRecRule.Id,taxRule.Id );
            prod.SBQQ__SubscriptionPricing__c ='Fixed Price';
            insert prod;
            
            PricebookEntry priceBookEntry1 = UM002_TestDataFactory.createPricebookEntry(standardPricebookId,prod.Id);
            insert priceBookEntry1;
            
            SBQQ__QuoteLine__c quoteLine = UM002_TestDataFactory.createQuoteLine(prod.Id, simpleQuote.Id, priceBookEntry1.Id, 200,1);
            insert quoteLine;

            simpleQuote.SBQQ__EndDate__c = date.newInstance(System.Today().year(), 12, 17);
            update simpleQuote;

            List<Opportunity> oppAmends = UM002_TestDataFactory.createOpportunities(1, 'testOppAmend', 'Prospecting');
            Opportunity oppAmend = oppAmends.get(0);
            oppAmend.SBQQ__AmendedContract__c = con.Id;
            insert oppAmends;

            SBQQ__Quote__c amendmentQuote = new SBQQ__Quote__c(
                SBQQ__Opportunity2__c = oppAmend.id,
                SBQQ__Account__c = acc.Id,
                SBQQ__Type__c = 'Amendment',
		        LPCR_Creation_conforme__c = true,    
                RecordTypeId = reservataireRecTypeId,
                LPCR_Creche__c = acc.id,
                SBQQ__StartDate__c = date.today(),
                SBQQ__EndDate__c = date.newInstance(System.Today().year(), 12, 31),
                SBQQ__MasterContract__c = con.Id
            );
            insert amendmentQuote;

            SBQQ__QuoteLine__c quoteLineAmend = UM002_TestDataFactory.createQuoteLine(prod.Id, amendmentQuote.Id, priceBookEntry1.Id, 200,1);
            insert quoteLineAmend;

            amendmentQuote.SBQQ__EndDate__c = date.newInstance(System.Today().year(), 12, 17);
            update amendmentQuote;

            Test.stopTest();       
        } 
    }

    @isTest()
    public static void updateDueToResilisationAnticipe_Test(){

        System.runAs(UM002_TestDataFactory.createUser()){

            Test.startTest();
            Id referencementRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Referencement');
            Id reservataireRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Reservataire');
            //B2B Renewal Express Current Year before update
            List<Account> accs = [SELECT Id, name   from Account WHERE name ='Compte Crèche MAC1' LIMIT 1];
            Account acc = accs.get(0);
            List<Opportunity> oppties = [SELECT Id , Name from Opportunity WHERE name ='opp Famille MAC1' LIMIT 1];
            Opportunity opp = oppties.get(0);
            List<Contract> contract = [Select Id, LPCR_DateDebut__c , LPCR_DateFin__c , LPCR_ChiffreAffaire__c , LPCR_MethodeRenouvellement__c  From Contract WHERE Name = '0001' Limit 1];
            Contract con = contract.get(0);

            SBQQ__Quote__c simpleQuote = new SBQQ__Quote__c(
                SBQQ__Opportunity2__c = opp.Id,
                SBQQ__Account__c = acc.Id,
                SBQQ__Type__c = 'Quote',
		        LPCR_Creation_conforme__c = true,    
                RecordTypeId = reservataireRecTypeId,
                LPCR_Creche__c = acc.id,
                SBQQ__StartDate__c = date.today(),
                SBQQ__EndDate__c = date.newInstance(System.Today().year(), 12, 31)
            );
            insert simpleQuote;

            Id standardPricebookId = Test.getStandardPricebookId();
            UM002_TestDataFactory.insertBillingCustomSettings();
        
            blng__LegalEntity__c billingLegalEntity = UM002_TestDataFactory.setupLegalEntity();
            blng__RevenueRecognitionRule__c revRecRule = UM002_TestDataFactory.setupRevRec(billingLegalEntity.Id);
            blng__BillingRule__c billingRule = UM002_TestDataFactory.setupBillingRule(billingLegalEntity.Id);
            blng__TaxRule__c taxRule = UM002_TestDataFactory.setupTaxRule(billingLegalEntity.Id);
            Product2 prod = UM002_TestDataFactory.createProduct('test', billingRule.Id, revRecRule.Id,taxRule.Id );
            prod.SBQQ__SubscriptionPricing__c ='Fixed Price';
            insert prod;
            
            PricebookEntry priceBookEntry1 = UM002_TestDataFactory.createPricebookEntry(standardPricebookId,prod.Id);
            insert priceBookEntry1;
            
            SBQQ__QuoteLine__c quoteLine = UM002_TestDataFactory.createQuoteLine(prod.Id, simpleQuote.Id, priceBookEntry1.Id, 200,1);
            insert quoteLine;

            simpleQuote.SBQQ__EndDate__c = date.newInstance(System.Today().year(), 12, 17);
            update simpleQuote;

            List<Opportunity> oppAmends = UM002_TestDataFactory.createOpportunities(1, 'testOppAmend', 'Prospecting');
            Opportunity oppAmend = oppAmends.get(0);
            oppAmend.SBQQ__AmendedContract__c = con.Id;
            insert oppAmends;

            SBQQ__Quote__c amendmentQuote = new SBQQ__Quote__c(
                SBQQ__Opportunity2__c = oppAmend.id,
                SBQQ__Account__c = acc.Id,
                SBQQ__Type__c = 'Amendment',
                LPCR_TypeAvenant__c = 'Résiliation',
		        LPCR_Creation_conforme__c = true,    
                RecordTypeId = reservataireRecTypeId,
                LPCR_Creche__c = acc.id,
                SBQQ__StartDate__c = date.today(),
                SBQQ__EndDate__c = date.newInstance(System.Today().year(), 12, 31),
                SBQQ__MasterContract__c = con.Id
            );
            insert amendmentQuote;

            amendmentQuote.LPCR_DateDebut__c = date.today();
            update amendmentQuote;

            System.assertEquals(amendmentQuote.LPCR_AnnulationAnticipee__c, false, 'Error in SM008_QuoteServices_Test : problem setting LPCR_AnnulationAnticipee__c flag');
            Test.stopTest();       
        } 
    }
    @isTest()
    public static void updateMontantIndexation(){
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
        	//quote before 
      		SBQQ__Quote__c quote1 = UM002_TestDataFactory.createQuotes(1, accs, oppties).get(0);
        	quote1.SBQQ__RenewalUpliftRate__c=3;
        	insert quote1;
            SBQQ__Quote__c quote = UM002_TestDataFactory.createQuotes(1, accs, oppties).get(0);
            quote.SBQQ__Type__c='Renewal';
           // quote.LPCR_TypeEnregistrement__c = Label.LPCR_ContratA;
            quote.RecordTypeId = ContratA_RT_ID;
            insert quote;
            Id standardPricebookId = Test.getStandardPricebookId();
            UM002_TestDataFactory.insertBillingCustomSettings();
        
            blng__LegalEntity__c billingLegalEntity = UM002_TestDataFactory.setupLegalEntity();
                
            blng__RevenueRecognitionRule__c revRecRule = UM002_TestDataFactory.setupRevRec(billingLegalEntity.Id);
                
            blng__BillingRule__c billingRule = UM002_TestDataFactory.setupBillingRule(billingLegalEntity.Id);
            
            blng__TaxRule__c taxRule = UM002_TestDataFactory.setupTaxRule(billingLegalEntity.Id);
            
            Product2 prod = UM002_TestDataFactory.createProduct('BerceauMicrotest', billingRule.Id, revRecRule.Id,taxRule.Id );
            prod.SBQQ__SubscriptionPricing__c ='Fixed Price';
            insert prod;
            PricebookEntry priceBookEntry1 = UM002_TestDataFactory.createPricebookEntry(standardPricebookId,prod.Id);
                insert priceBookEntry1;
                
            SBQQ__QuoteLine__c quoteLine = UM002_TestDataFactory.createQuoteLine(prod.Id, quote1.Id, priceBookEntry1.Id, 200,1);
            insert quoteLine;
            con2.SBQQ__Quote__c=quote1.ID;
            update con2;
        
        Test.stopTest();
        quote = [SELECT Id ,LPCR_IndexationConvenue__c,ApprovalStatus__c,LPCR_SommePrixAnnuel__c,LPCR_MontantIndexation__c, recordtype.developername, recordtypeid,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c,LPCR_PlanningEnfant__c,SBQQ__SalesRep__c, LPCR_ResponsableADV__c, LPCR_ResponsableServiceFamille__c from SBQQ__Quote__c WHERE SBQQ__Type__c= 'Renewal' AND  Id = :quote.Id];
        
    }
    @isTest()
    public static void updateDate_Test(){

        System.runAs(UM002_TestDataFactory.createUser()){
            
        
            Test.startTest();
                Id reservataireRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Reservataire');
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
                //quote before 
                SBQQ__Quote__c quote1 = UM002_TestDataFactory.createQuotes(1, accs, oppties).get(0);
                quote1.SBQQ__RenewalUpliftRate__c=3;
                
                quote1.recordtypeid=ContratA_RT_ID;
                insert quote1;
                SBQQ__Quote__c quote = UM002_TestDataFactory.createQuotes(1, accs, oppties).get(0);
                quote.SBQQ__Type__c='Renewal';
                
                List<Account> accs2 = [SELECT Id, name   from Account WHERE name ='Compte Crèche MAC1' LIMIT 1];
                Account acc = accs2.get(0);
                List<Contract> contract = [Select Id, LPCR_DateDebut__c , LPCR_DateFin__c , LPCR_ChiffreAffaire__c , LPCR_MethodeRenouvellement__c  From Contract WHERE Name = '0001' Limit 1];
                Contract con = contract.get(0);
                List<Opportunity> oppAmends = UM002_TestDataFactory.createOpportunities(1, 'testOppAmend', 'Prospecting');
                Opportunity oppAmend = oppAmends.get(0);
                SBQQ__Quote__c amendmentQuote = new SBQQ__Quote__c(
                SBQQ__Opportunity2__c = oppAmend.id,
                SBQQ__Account__c = acc.Id,
                SBQQ__Type__c = 'Amendment',
		        LPCR_Creation_conforme__c = true,    
                RecordTypeId = reservataireRecTypeId,
                LPCR_Creche__c = acc.id,
                SBQQ__StartDate__c = date.today(),
                SBQQ__EndDate__c = date.newInstance(System.Today().year(), 12, 31),
                SBQQ__MasterContract__c = con.Id,LPCR_TypeAvenant__c ='Résiliation'
            );
                insert amendmentQuote;
                quote.RecordTypeId = ContratA_RT_ID;
                insert quote;
                Id standardPricebookId = Test.getStandardPricebookId();
                UM002_TestDataFactory.insertBillingCustomSettings();
            
                blng__LegalEntity__c billingLegalEntity = UM002_TestDataFactory.setupLegalEntity();
                    
                blng__RevenueRecognitionRule__c revRecRule = UM002_TestDataFactory.setupRevRec(billingLegalEntity.Id);
                    
                blng__BillingRule__c billingRule = UM002_TestDataFactory.setupBillingRule(billingLegalEntity.Id);
                
                blng__TaxRule__c taxRule = UM002_TestDataFactory.setupTaxRule(billingLegalEntity.Id);
                
                Product2 prod = UM002_TestDataFactory.createProduct('BerceauMicrotest', billingRule.Id, revRecRule.Id,taxRule.Id );
                prod.SBQQ__SubscriptionPricing__c ='Fixed Price';
                insert prod;
                PricebookEntry priceBookEntry1 = UM002_TestDataFactory.createPricebookEntry(standardPricebookId,prod.Id);
                    insert priceBookEntry1;
                    
                
                con2.SBQQ__Quote__c=quote1.ID;
                update con2;
                Map<Id, SBQQ__Quote__c> mapOld= new Map<Id, SBQQ__Quote__c>([SELECT Id, SBQQ__Status__c from SBQQ__Quote__c where id=:amendmentQuote.ID]);
               //updtae quote1
               //
               //
               SBQQ__QuoteLine__c quoteLine = UM002_TestDataFactory.createQuoteLine(prod.Id, amendmentQuote.Id, priceBookEntry1.Id, 200,1);
                insert quoteLine;
               amendmentQuote.LPCR_DateResiliation__c=System.today()+5;
               update amendmentQuote;
                Map<Id, SBQQ__Quote__c> mapNew=new  Map<Id, SBQQ__Quote__c> ([SELECT Id, SBQQ__Status__c from SBQQ__Quote__c where id=:amendmentQuote.ID]);
                
               // update mapNew.values();
                
                String strnewQuotesMap=JSON.serialize(mapNew);
                String stroldQuotesMap=JSON.serialize(mapOld);
                //invoke method 
                SM008_QuoteServices.updateStartDate( strnewQuotesMap , stroldQuotesMap );
            Test.stopTest();       
        } 
    }
}