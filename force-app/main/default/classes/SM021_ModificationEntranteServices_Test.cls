/**
* @author Hanae MAKBOUB
* @date 19/05/2020
* @description Test class for Service class LPCR_ModificationEntrante__c
*/
@isTest
public class SM021_ModificationEntranteServices_Test {
    private static final Id B2C_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Famille);
    private static final Id CONTACT_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contact, Label.LPCR_Famille);
    private static final Id QUOTE_CONTRAT_ACCUEIL_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote, Label.LPCR_ContratA);
    private static final Id ORDER_CONTRAT_ACCUEIL_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Order, Label.LPCR_ContratA);
    private static final Id standardPricebookId = Test.getStandardPricebookId();

    @testSetup
    static void testSetup(){
        List<Account> accounts = UM002_TestDataFactory.createAccounts(100, 'testAccount');
        List<Opportunity> opps = UM002_TestDataFactory.createOpportunities(100, 'testOpp', 'Prospecting');
        insert accounts;
        insert opps;
        List<SBQQ__Quote__c> quotes = UM002_TestDataFactory.createQuotes(100, accounts, opps);
        insert quotes;
        List<Contract> contracts = UM002_TestDataFactory.createContracts(100,accounts,quotes);
        insert contracts;
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
            
            Contract contract = UM002_TestDataFactory.createContract(acc.id,quote.id,opp.id,Date.Today().addmonths(3));
            Insert contract;
            
            LPCR_ModificationEntrante__c modif = UM002_TestDataFactory.createModificationsEntrante('Validation Contrat Directrice',acc.id,cont.id,contract.id,Date.today(),10);
            insert modif;
            Test.startTest();
            List<SBQQ__Quote__c> quotes = [SELECT Id, SBQQ__Status__c FROM SBQQ__Quote__c];
            List<Contract> contracts = [SELECT Id, SBQQ__Quote__c FROM Contract];
            List<LPCR_ModificationEntrante__c> modificationsEntrantes = UM002_TestDataFactory.createModificationsEntrantes(100,quotes,contracts,'Validation Contrat Directrice');
            insert modificationsEntrantes;
            List<SBQQ__Quote__c> quotesValides = [SELECT Id, SBQQ__Status__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Validé Directrice'];
            System.assertEquals(100, quotesValides.size(), 'Error in SM021_ModificationEntranteServices_Test : problem in updating quotesValides');

            Test.stopTest();
        }
    }
    
    @isTest 
    public static void sendAgreementFromModifEntrantesReglementCreche_Test(){
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
            
            LPCR_RessourceFamille__c ressourceFamille = UM002_TestDataFactory.createRessourceFamille(firstDayOfCurrentMonthDate,acc.id,cont.id,'Test');
            insert ressourceFamille;
            
            Contract contract = UM002_TestDataFactory.createContract(acc.id,quote.id,opp.id,Date.Today().addmonths(3));
            Insert contract;
            
            LPCR_ModificationEntrante__c modif = UM002_TestDataFactory.createModificationsEntrante('Traitement jour férié',acc.id,cont.id,contract.id,Date.today(),10);
            insert modif;           
            
            LPCR_ModificationEntrante__c modif2 = UM002_TestDataFactory.createModificationsEntrante('Validation Contrat Directrice',acc.id,cont.id,contract.id,Date.today(),10);
            insert modif2;
            Test.startTest();
            List<SBQQ__Quote__c> quotesValides = [SELECT Id, SBQQ__Status__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Validé Directrice'];
            System.assertEquals(1, quotesValides.size(), 'Error in SM021_ModificationEntranteServices_Test : problem in updating quotesValides');
            
            Test.setMock(HttpCalloutMock.class, new MCK001_LPCRHttpCalloutMockImpl());
 		    modif.LPCR_EtatTraitement__c = true;
            update modif;      
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
            
            LPCR_RessourceFamille__c ressourceFamille = UM002_TestDataFactory.createRessourceFamille(firstDayOfCurrentMonthDate,acc.id,cont.id,'Test');
            insert ressourceFamille;
            
            Contract contract = UM002_TestDataFactory.createContract(acc.id,quote.id,opp.id,Date.Today().addmonths(3));
            Insert contract;
            
            LPCR_ModificationEntrante__c modif = UM002_TestDataFactory.createModificationsEntrante('Date Fin Contrat',acc.id,cont.id,contract.id,Date.today(),10);
            insert modif;           
            
            Test.startTest();
 		    modif.LPCR_EtatTraitement__c = true;
            update modif;      
            Test.stopTest();
            
        }
    }
	
	@isTest
    public static void updateQuotesFromModifEntrantesBatch_1_Test(){
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
            
            LPCR_RessourceFamille__c ressourceFamille = UM002_TestDataFactory.createRessourceFamille(firstDayOfCurrentMonthDate,acc.id,cont.id,'Test');
            insert ressourceFamille;
            
            Contract contract = UM002_TestDataFactory.createContract(acc.id,quote.id,opp.id,Date.Today().addmonths(3));
            Insert contract;
            
            LPCR_ModificationEntrante__c modif = UM002_TestDataFactory.createModificationsEntrante('Modification Situation Handicapé Enfant Fratrie',acc.id,cont.id,contract.id,Date.today(),10);
            insert modif;
            
            Test.startTest();
            
            APB007_TraitementModificationEntrante ss = new APB007_TraitementModificationEntrante();
            DataBase.executeBatch(ss);

            Test.stopTest();
            LPCR_ModificationEntrante__c modifChk = [select id,LPCR_EtatTraitement__c from LPCR_ModificationEntrante__c where id =: modif.id];
            System.assertEquals(true, modifChk.LPCR_EtatTraitement__c, 'Error in SM021_ModificationEntranteServices_Test : ModificationEntrante not updated');
        }
    }

    @isTest
    public static void updateQuotesFromModifEntrantesBatch_2_Test(){
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

            LPCR_RessourceFamille__c ressourceFamille = UM002_TestDataFactory.createRessourceFamille(firstDayOfCurrentMonthDate,acc.id,cont.id,'Test');
            insert ressourceFamille;

            Contract contract = UM002_TestDataFactory.createContract(acc.id,quote.id,opp.id,Date.Today().addmonths(3));
            Insert contract;

            LPCR_ModificationEntrante__c modif = UM002_TestDataFactory.createModificationsEntrante('Modification Type Planning',acc.id,cont.id,contract.id,Date.today(),10);
			modif.LPCR_TypePlanning__c = 'Planning Classique';
            insert modif;

            Time debutTime = Time.newInstance(08, 30, 2, 20);
            Time finTime = Time.newInstance(16, 30, 2, 20);
            LPCR_DetailModificationPlanning__c detailModifPlan = new LPCR_DetailModificationPlanning__c(LPCR_HeureDebutJeudi__c = debutTime, LPCR_HeureDebutLundi__c = debutTime, LPCR_HeureDebutMardi__c = debutTime, LPCR_HeureDebutMercredi__c = debutTime, LPCR_HeureDebutVendredi__c =debutTime, LPCR_HeureFinJeudi__c = finTime, LPCR_HeureFinLundi__c = finTime, LPCR_HeureFinMardi__c = finTime, LPCR_HeureFinMercredi__c = finTime, LPCR_HeureFinVendredi__c = finTime);
            detailModifPlan.LPCR_ModificationEntrante__c = modif.id;
            insert detailModifPlan;

            Test.startTest();

            APB007_TraitementModificationEntrante ss = new APB007_TraitementModificationEntrante();
            DataBase.executeBatch(ss);

            Test.stopTest();
            LPCR_ModificationEntrante__c modifChk = [select id,LPCR_EtatTraitement__c from LPCR_ModificationEntrante__c where id =: modif.id];
            System.assertEquals(true, modifChk.LPCR_EtatTraitement__c, 'Error in SM021_ModificationEntranteServices_Test : ModificationEntrante not updated');
        }
    }

    @isTest
    public static void updateQuotesFromModifEntrantesBatch_3_Test(){
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

            LPCR_RessourceFamille__c ressourceFamille = UM002_TestDataFactory.createRessourceFamille(firstDayOfCurrentMonthDate,acc.id,cont.id,'Test');
            insert ressourceFamille;

            Contract contract = UM002_TestDataFactory.createContract(acc.id,quote.id,opp.id,Date.Today().addmonths(3));
            Insert contract;

            LPCR_ModificationEntrante__c modif = UM002_TestDataFactory.createModificationsEntrante('Modification Nombre Jour Congé',acc.id,cont.id,contract.id,Date.today(),10);
            insert modif;

            Test.startTest();

            APB007_TraitementModificationEntrante ss = new APB007_TraitementModificationEntrante();
            DataBase.executeBatch(ss);

            Test.stopTest();
            LPCR_ModificationEntrante__c modifChk = [select id,LPCR_EtatTraitement__c from LPCR_ModificationEntrante__c where id =: modif.id];
            System.assertEquals(true, modifChk.LPCR_EtatTraitement__c, 'Error in SM021_ModificationEntranteServices_Test : ModificationEntrante not updated');
        }
    }

    @isTest
    public static void updateQuotesFromModifEntrantesBatch_4_Test(){
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

            LPCR_RessourceFamille__c ressourceFamille = UM002_TestDataFactory.createRessourceFamille(firstDayOfCurrentMonthDate,acc.id,cont.id,'Test');
            insert ressourceFamille;

            Contract contract = UM002_TestDataFactory.createContract(acc.id,quote.id,opp.id,Date.Today().addmonths(3));
            Insert contract;

            LPCR_ModificationEntrante__c modif = UM002_TestDataFactory.createModificationsEntrante('Date Fin Contrat',acc.id,cont.id,contract.id,Date.today(),10);
            insert modif;

            Test.startTest();

            APB007_TraitementModificationEntrante ss = new APB007_TraitementModificationEntrante();
            DataBase.executeBatch(ss);

            Test.stopTest();
            LPCR_ModificationEntrante__c modifChk = [select id,LPCR_EtatTraitement__c from LPCR_ModificationEntrante__c where id =: modif.id];
            System.assertEquals(true, modifChk.LPCR_EtatTraitement__c, 'Error in SM021_ModificationEntranteServices_Test : ModificationEntrante not updated');
        }
    }

    @isTest
    public static void updateQuotesFromModifEntrantesBatch_5_Test(){
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

            LPCR_RessourceFamille__c ressourceFamille = UM002_TestDataFactory.createRessourceFamille(firstDayOfCurrentMonthDate,acc.id,cont.id,'Test');
            insert ressourceFamille;

            Contract contract = UM002_TestDataFactory.createContract(acc.id,quote.id,opp.id,Date.Today().addmonths(3));
            Insert contract;

            LPCR_ModificationEntrante__c modif = UM002_TestDataFactory.createModificationsEntrante('Modification Type Accueil',acc.id,cont.id,contract.id,Date.today(),10);
            modif.LPCR_TypeAccueil__c = 'Normal';
            insert modif;

            Test.startTest();

            APB007_TraitementModificationEntrante ss = new APB007_TraitementModificationEntrante();
            DataBase.executeBatch(ss);

            Test.stopTest();
            LPCR_ModificationEntrante__c modifChk = [select id,LPCR_EtatTraitement__c from LPCR_ModificationEntrante__c where id =: modif.id];
            System.assertEquals(true, modifChk.LPCR_EtatTraitement__c, 'Error in SM021_ModificationEntranteServices_Test : ModificationEntrante not updated');
        }
    }

    @isTest
    public static void updateQuotesFromModifEntrantesBatch_6_Test(){
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

            LPCR_RessourceFamille__c ressourceFamille = UM002_TestDataFactory.createRessourceFamille(firstDayOfCurrentMonthDate,acc.id,cont.id,'Test');
            insert ressourceFamille;

            Contract contract = UM002_TestDataFactory.createContract(acc.id,quote.id,opp.id,Date.Today().addmonths(3));
            Insert contract;

            LPCR_ModificationEntrante__c modif = UM002_TestDataFactory.createModificationsEntrante('Modification Adresse Contact Parent',acc.id,cont.id,contract.id,Date.today(),10);
            modif.LPCR_Rue__c = 'test';
            modif.LPCR_Ville__c = 'test';
            modif.LPCR_Pays__c = 'test';
            modif.LPCR_CodePostal__c = 'AAAA77';

            insert modif;

            Test.startTest();

            APB007_TraitementModificationEntrante ss = new APB007_TraitementModificationEntrante();
            DataBase.executeBatch(ss);

            Test.stopTest();
            LPCR_ModificationEntrante__c modifChk = [select id,LPCR_EtatTraitement__c from LPCR_ModificationEntrante__c where id =: modif.id];
            System.assertEquals(true, modifChk.LPCR_EtatTraitement__c, 'Error in SM021_ModificationEntranteServices_Test : ModificationEntrante not updated');
        }
    }

    @isTest
    public static void updateQuotesFromModifEntrantesBatch_7_Test(){
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

            LPCR_RessourceFamille__c ressourceFamille = UM002_TestDataFactory.createRessourceFamille(firstDayOfCurrentMonthDate,acc.id,cont.id,'Test');
            insert ressourceFamille;

            Contract contract = UM002_TestDataFactory.createContract(acc.id,quote.id,opp.id,Date.Today().addmonths(3));
            Insert contract;

            LPCR_ModificationEntrante__c modif = UM002_TestDataFactory.createModificationsEntrante('Modification Autorité Parentale',acc.id,cont.id,contract.id,Date.today(),10);
            modif.LPCR_OuiNon__c = true;

            insert modif;

            Test.startTest();

            APB007_TraitementModificationEntrante ss = new APB007_TraitementModificationEntrante();
            DataBase.executeBatch(ss);

            Test.stopTest();
            LPCR_ModificationEntrante__c modifChk = [select id,LPCR_EtatTraitement__c from LPCR_ModificationEntrante__c where id =: modif.id];
            System.assertEquals(true, modifChk.LPCR_EtatTraitement__c, 'Error in SM021_ModificationEntranteServices_Test : ModificationEntrante not updated');
        }
    }

    @isTest
    public static void updateQuotesFromModifEntrantesBatch_8_Test(){
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

            LPCR_RessourceFamille__c ressourceFamille = UM002_TestDataFactory.createRessourceFamille(firstDayOfCurrentMonthDate,acc.id,cont.id,'Test');
            insert ressourceFamille;

            Contract contract = UM002_TestDataFactory.createContract(acc.id,quote.id,opp.id,Date.Today().addmonths(3));
            Insert contract;

            LPCR_ModificationEntrante__c modif = UM002_TestDataFactory.createModificationsEntrante('Modification Numéro Allocataire',acc.id,cont.id,contract.id,Date.today(),10);
            modif.LPCR_IDUnique__c = 'test';

            insert modif;

            Test.startTest();

            APB007_TraitementModificationEntrante ss = new APB007_TraitementModificationEntrante();
            DataBase.executeBatch(ss);

            Test.stopTest();
            LPCR_ModificationEntrante__c modifChk = [select id,LPCR_EtatTraitement__c from LPCR_ModificationEntrante__c where id =: modif.id];
            System.assertEquals(true, modifChk.LPCR_EtatTraitement__c, 'Error in SM021_ModificationEntranteServices_Test : ModificationEntrante not updated');
        }
    }

    @isTest
    public static void updateQuotesFromModifEntrantesBatch_9_Test(){
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

            LPCR_RessourceFamille__c ressourceFamille = UM002_TestDataFactory.createRessourceFamille(firstDayOfCurrentMonthDate,acc.id,cont.id,'Test');
            insert ressourceFamille;

            Contract contract = UM002_TestDataFactory.createContract(acc.id,quote.id,opp.id,Date.Today().addmonths(3));
            Insert contract;

            LPCR_ModificationEntrante__c modif = UM002_TestDataFactory.createModificationsEntrante('Date Naissance Enfant',acc.id,cont.id,contract.id,Date.today(),10);
            modif.LPCR_Date__c = Date.newInstance(1992, 01, 01);

            insert modif;

            Test.startTest();

            APB007_TraitementModificationEntrante ss = new APB007_TraitementModificationEntrante();
            DataBase.executeBatch(ss);

            Test.stopTest();
            LPCR_ModificationEntrante__c modifChk = [select id,LPCR_EtatTraitement__c from LPCR_ModificationEntrante__c where id =: modif.id];
            System.assertEquals(true, modifChk.LPCR_EtatTraitement__c, 'Error in SM021_ModificationEntranteServices_Test : ModificationEntrante not updated');
        }
    }

    @isTest
    public static void updateQuotesFromModifEntrantesBatch_10_Test(){
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

            LPCR_RessourceFamille__c ressourceFamille = UM002_TestDataFactory.createRessourceFamille(firstDayOfCurrentMonthDate,acc.id,cont.id,'Test');
            insert ressourceFamille;

            Contract contract = UM002_TestDataFactory.createContract(acc.id,quote.id,opp.id,Date.Today().addmonths(3));
            Insert contract;

            Test.startTest();
            
            LPCR_ModificationEntrante__c modif = UM002_TestDataFactory.createModificationsEntrante('Modification Section',acc.id,cont.id,contract.id,Date.today(),10);
            modif.LPCR_Section__c = 'Grands';

            insert modif;           

            APB007_TraitementModificationEntrante ss = new APB007_TraitementModificationEntrante();
            DataBase.executeBatch(ss);

            Test.stopTest();
            LPCR_ModificationEntrante__c modifChk = [select id,LPCR_EtatTraitement__c from LPCR_ModificationEntrante__c where id =: modif.id];
            System.assertEquals(true, modifChk.LPCR_EtatTraitement__c, 'Error in SM021_ModificationEntranteServices_Test : ModificationEntrante not updated');
        }
    }

    @isTest
    public static void updateQuotesFromModifEntrantesBatch_11_Test(){
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

            LPCR_RessourceFamille__c ressourceFamille = UM002_TestDataFactory.createRessourceFamille(firstDayOfCurrentMonthDate,acc.id,cont.id,'Test');
            insert ressourceFamille;

            Contract contract = UM002_TestDataFactory.createContract(acc.id,quote.id,opp.id,Date.Today().addmonths(3));
            Insert contract;

            Test.startTest();

            LPCR_ModificationEntrante__c modif = UM002_TestDataFactory.createModificationsEntrante('Modification Mode Garde',acc.id,cont.id,contract.id,Date.today(),10);
            modif.LPCR_SituationFamiliale__c = 'Divorcé';
            modif.LPCR_Garde__c = 'Autorité parentale conjointe';

            insert modif;           

            APB007_TraitementModificationEntrante ss = new APB007_TraitementModificationEntrante();
            DataBase.executeBatch(ss);

            Test.stopTest();
            LPCR_ModificationEntrante__c modifChk = [select id,LPCR_EtatTraitement__c from LPCR_ModificationEntrante__c where id =: modif.id];
            System.assertEquals(true, modifChk.LPCR_EtatTraitement__c, 'Error in SM021_ModificationEntranteServices_Test : ModificationEntrante not updated');
        }
    }
    @isTest
    public static void updateQuotesFromModifEntrantesBatch_12_Test(){
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

            LPCR_RessourceFamille__c ressourceFamille = UM002_TestDataFactory.createRessourceFamille(firstDayOfCurrentMonthDate,acc.id,cont.id,'Test');
            insert ressourceFamille;

            Contract contract = UM002_TestDataFactory.createContract(acc.id,quote.id,opp.id,Date.Today().addmonths(3));
            Insert contract;

            Test.startTest();

            LPCR_ModificationEntrante__c modif = UM002_TestDataFactory.createModificationsEntrante('Modification Situation Familiale',acc.id,cont.id,contract.id,Date.today(),10);
            modif.LPCR_SituationFamiliale__c = 'En couple';

            insert modif;            

            APB007_TraitementModificationEntrante ss = new APB007_TraitementModificationEntrante();
            DataBase.executeBatch(ss);

            Test.stopTest();
            LPCR_ModificationEntrante__c modifChk = [select id,LPCR_EtatTraitement__c from LPCR_ModificationEntrante__c where id =: modif.id];
            System.assertEquals(true, modifChk.LPCR_EtatTraitement__c, 'Error in SM021_ModificationEntranteServices_Test : ModificationEntrante not updated');
        }
    }

    @isTest
    public static void updateQuotesFromModifEntrantesBatch_13_Test(){
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

            LPCR_RessourceFamille__c ressourceFamille = UM002_TestDataFactory.createRessourceFamille(firstDayOfCurrentMonthDate,acc.id,cont.id,'Test');
            insert ressourceFamille;

            Contract contract = UM002_TestDataFactory.createContract(acc.id,quote.id,opp.id,Date.Today().addmonths(3));
            Insert contract;

            Test.startTest();

            LPCR_ModificationEntrante__c modif = UM002_TestDataFactory.createModificationsEntrante('Modification Heure Supplémentaire MAC',acc.id,cont.id,contract.id,Date.today(),10);
            modif.LPCR_HeureDateDebut__c = Datetime.newInstance(Date.today().Year(), Date.today().month() ,1);
            modif.LPCR_HeureDateFin__c = Datetime.newInstance(Date.today().Year(), Date.today().month() , Date.daysInMonth(Date.today().year(), Date.today().month()));

            insert modif;           

            APB007_TraitementModificationEntrante ss = new APB007_TraitementModificationEntrante();
            DataBase.executeBatch(ss);

            Test.stopTest();
            LPCR_ModificationEntrante__c modifChk = [select id,LPCR_EtatTraitement__c from LPCR_ModificationEntrante__c where id =: modif.id];
            System.assertEquals(true, modifChk.LPCR_EtatTraitement__c, 'Error in SM021_ModificationEntranteServices_Test : ModificationEntrante not updated');
        }
    }

    @isTest
    public static void updateQuotesFromModifEntrantesBatch_14_Test(){
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

            LPCR_RessourceFamille__c ressourceFamille = UM002_TestDataFactory.createRessourceFamille(firstDayOfCurrentMonthDate,acc.id,cont.id,'Test');
            insert ressourceFamille;

            Contract contract = UM002_TestDataFactory.createContract(acc.id,quote.id,opp.id,Date.Today().addmonths(3));
            Insert contract;

            Test.startTest();

            LPCR_ModificationEntrante__c modif = UM002_TestDataFactory.createModificationsEntrante('Modification Heure Occasionnel MAC',acc.id,cont.id,contract.id,Date.today(),10);
            modif.LPCR_HeureDateDebut__c = Datetime.newInstance(Date.today().Year(), Date.today().month() ,1);
            modif.LPCR_HeureDateFin__c = Datetime.newInstance(Date.today().Year(), Date.today().month() , Date.daysInMonth(Date.today().year(), Date.today().month()));

            insert modif;            

            APB007_TraitementModificationEntrante ss = new APB007_TraitementModificationEntrante();
            DataBase.executeBatch(ss);

            Test.stopTest();
            LPCR_ModificationEntrante__c modifChk = [select id,LPCR_EtatTraitement__c from LPCR_ModificationEntrante__c where id =: modif.id];
            System.assertEquals(true, modifChk.LPCR_EtatTraitement__c, 'Error in SM021_ModificationEntranteServices_Test : ModificationEntrante not updated');
        }
    }

    @isTest
    public static void updateQuotesFromModifEntrantesBatch_15_Test(){
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

            LPCR_RessourceFamille__c ressourceFamille = UM002_TestDataFactory.createRessourceFamille(firstDayOfCurrentMonthDate,acc.id,cont.id,'Test');
            insert ressourceFamille;

            Contract contract = UM002_TestDataFactory.createContract(acc.id,quote.id,opp.id,Date.Today().addmonths(3));
            Insert contract;

            Test.startTest();

            LPCR_ModificationEntrante__c modif = UM002_TestDataFactory.createModificationsEntrante('Modification Heure Déduite MAC',acc.id,cont.id,contract.id,Date.today(),10);
            modif.LPCR_HeureDateDebut__c = Datetime.newInstance(Date.today().Year(), Date.today().month() ,1);
            modif.LPCR_HeureDateFin__c = Datetime.newInstance(Date.today().Year(), Date.today().month() , Date.daysInMonth(Date.today().year(), Date.today().month()));

            insert modif;           

            APB007_TraitementModificationEntrante ss = new APB007_TraitementModificationEntrante();
            DataBase.executeBatch(ss);

            Test.stopTest();
            LPCR_ModificationEntrante__c modifChk = [select id,LPCR_EtatTraitement__c from LPCR_ModificationEntrante__c where id =: modif.id];
            System.assertEquals(true, modifChk.LPCR_EtatTraitement__c, 'Error in SM021_ModificationEntranteServices_Test : ModificationEntrante not updated');
        }
    }
   @isTest
    public static void updateQuotesFromModifEntrantesBatch_16_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Date firstDayOfCurrentMonthDate = Date.newInstance(Date.today().Year(), Date.today().month() ,1) ;
            Date lastDayOfCurrentMonthDate=Date.newInstance(Date.today().Year(), Date.today().month() , Date.daysInMonth(Date.today().year(), Date.today().month())) ;

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
            quote.SBQQ__Primary__c = true;
            quote.RecordTypeId = QUOTE_CONTRAT_ACCUEIL_RT_ID;
            update quote;

            List<SBQQ__QuoteLine__c> qlines = new List<SBQQ__QuoteLine__c> ();
            qlines.add(UM002_TestDataFactory.createQuoteLine(prod.Id, quote.Id, pbEntry.Id, 200, 1));
            insert qlines;

            LPCR_RessourceFamille__c ressourceFamille = UM002_TestDataFactory.createRessourceFamille(firstDayOfCurrentMonthDate,acc.id,cont.id,'Test');
            insert ressourceFamille;

            Contract contract = UM002_TestDataFactory.createContract(acc.id,quote.id,opp.id,Date.Today().addmonths(3));
            contract.Status = 'Draft';
            Insert contract;

            contract.Status = 'Activated';
            update contract;

            Order order = UM002_TestDataFactory.createOrder(acc.Id, contract.id,date.today(),'test','Draft','1');
            order.Pricebook2Id = standardPricebookId;
            order.SBQQ__Quote__c = quote.id;
            order.RecordTypeId = ORDER_CONTRAT_ACCUEIL_RT_ID;
            insert order;

            OrderItem orderItem = UM002_TestDataFactory.createOrderProduct(pbEntry.id, order.Id, prod.id, 'Recurring','Monthly', 100);
            orderItem.SBQQ__QuoteLine__c = qlines.get(0).id;
            orderItem.SBQQ__Activated__c = false;
            insert orderItem;
            orderItem.SBQQ__Activated__c = true;
            update orderItem;
            order.status ='Activated';
            update order;
            order.blng__BillNow__c = true;
            update order;

            Test.startTest();

            blng__Invoice__c invoice = new blng__Invoice__c();
            invoice.blng__Account__c = acc.Id;
            invoice.blng__BillToContact__c = cont.id;
            invoice.blng__InvoiceDate__c = Date.today();
            invoice.blng__DueDate__c = Date.today();
            invoice.blng__Order__c = order.id;
            invoice.blng__PaymentBatch__c = 'Batch 1';
            insert invoice;

            LPCR_ModificationEntrante__c modif = UM002_TestDataFactory.createModificationsEntrante('NB Heures réalisées',acc.id,cont.id,contract.id,Date.today(),10);
            modif.LPCR_HeureDateDebut__c = Datetime.newInstance(Date.today().Year(), Date.today().month() ,1);
            modif.LPCR_HeureDateFin__c = Datetime.newInstance(Date.today().Year(), Date.today().month() , Date.daysInMonth(Date.today().year(), Date.today().month()));
            modif.LPCR_Invoice__c = invoice.id;
            insert modif;            

            APB007_TraitementModificationEntrante ss = new APB007_TraitementModificationEntrante();
            DataBase.executeBatch(ss);

            Test.stopTest();
            LPCR_ModificationEntrante__c modifChk = [select id,LPCR_EtatTraitement__c from LPCR_ModificationEntrante__c where id =: modif.id];
            System.assertEquals(true, modifChk.LPCR_EtatTraitement__c, 'Error in SM021_ModificationEntranteServices_Test : ModificationEntrante not updated');
        }
    }

    @isTest
    public static void updateQuotesFromModifEntrantesBatch_17_Test(){
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

            LPCR_RessourceFamille__c ressourceFamille = UM002_TestDataFactory.createRessourceFamille(firstDayOfCurrentMonthDate,acc.id,cont.id,'Test');
            insert ressourceFamille;

            Contract contract = UM002_TestDataFactory.createContract(acc.id,quote.id,opp.id,Date.Today().addmonths(3));
            Insert contract;

            Test.startTest();

            LPCR_ModificationEntrante__c modif = UM002_TestDataFactory.createModificationsEntrante('Validation Contrat Directrice',acc.id,cont.id,contract.id,Date.today(),10);
            insert modif;            

            APB007_TraitementModificationEntrante ss = new APB007_TraitementModificationEntrante();
            DataBase.executeBatch(ss);

            Test.stopTest();
            LPCR_ModificationEntrante__c modifChk = [select id,LPCR_EtatTraitement__c from LPCR_ModificationEntrante__c where id =: modif.id];
            System.assertEquals(true, modifChk.LPCR_EtatTraitement__c, 'Error in SM021_ModificationEntranteServices_Test : ModificationEntrante not updated');
        }
    }
    @isTest
    public static void updateQuotesFromModifEntrantesBatch_18_Test(){
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

            LPCR_RessourceFamille__c ressourceFamille = UM002_TestDataFactory.createRessourceFamille(firstDayOfCurrentMonthDate,acc.id,cont.id,'Test');
            insert ressourceFamille;

            Contract contract = UM002_TestDataFactory.createContract(acc.id,quote.id,opp.id,Date.Today().addmonths(3));
            Insert contract;

            Test.startTest();

            LPCR_ModificationEntrante__c modif = UM002_TestDataFactory.createModificationsEntrante('Abscence',acc.id,cont.id,contract.id,Date.today(),10);
            modif.LPCR_HeureDateDebut__c = Datetime.newInstance(Date.today().Year(), Date.today().month() ,1);
            modif.LPCR_HeureDateFin__c = Datetime.newInstance(Date.today().Year(), Date.today().month() , Date.daysInMonth(Date.today().year(), Date.today().month()));

            insert modif;            

            APB007_TraitementModificationEntrante ss = new APB007_TraitementModificationEntrante();
            DataBase.executeBatch(ss);

            Test.stopTest();
            LPCR_ModificationEntrante__c modifChk = [select id,LPCR_EtatTraitement__c from LPCR_ModificationEntrante__c where id =: modif.id];
            System.assertEquals(true, modifChk.LPCR_EtatTraitement__c, 'Error in SM021_ModificationEntranteServices_Test : ModificationEntrante not updated');
        }
    }
    @isTest
    public static void updateQuotesFromModifEntrantesBatch_19_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Date firstDayOfCurrentMonthDate = Date.newInstance(Date.today().Year(), Date.today().month() ,1) ;
            Date lastDayOfCurrentMonthDate=Date.newInstance(Date.today().Year(), Date.today().month() , Date.daysInMonth(Date.today().year(), Date.today().month())) ;

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
            quote.SBQQ__Primary__c = true;
            quote.RecordTypeId = QUOTE_CONTRAT_ACCUEIL_RT_ID;
            update quote;

            List<SBQQ__QuoteLine__c> qlines = new List<SBQQ__QuoteLine__c> ();
            qlines.add(UM002_TestDataFactory.createQuoteLine(prod.Id, quote.Id, pbEntry.Id, 200, 1));
            insert qlines;

            LPCR_RessourceFamille__c ressourceFamille = UM002_TestDataFactory.createRessourceFamille(firstDayOfCurrentMonthDate,acc.id,cont.id,'Test');
            insert ressourceFamille;

            Contract contract = UM002_TestDataFactory.createContract(acc.id,quote.id,opp.id,Date.Today().addmonths(3));
            contract.Status = 'Draft';
            Insert contract;

            contract.Status = 'Activated';
            update contract;

            Order order = UM002_TestDataFactory.createOrder(acc.Id, contract.id,date.today(),'test','Draft','1');
            order.Pricebook2Id = standardPricebookId;
            order.SBQQ__Quote__c = quote.id;
            order.RecordTypeId = ORDER_CONTRAT_ACCUEIL_RT_ID;
            insert order;

            OrderItem orderItem = UM002_TestDataFactory.createOrderProduct(pbEntry.id, order.Id, prod.id, 'Recurring','Monthly', 100);
            orderItem.SBQQ__QuoteLine__c = qlines.get(0).id;
            orderItem.SBQQ__Activated__c = false;
            insert orderItem;
            orderItem.SBQQ__Activated__c = true;
            update orderItem;
            order.status ='Activated';
            update order;
            order.blng__BillNow__c = true;
            update order;

            Test.startTest();

            blng__Invoice__c invoice = new blng__Invoice__c();
            invoice.blng__Account__c = acc.Id;
            invoice.blng__BillToContact__c = cont.id;
            invoice.blng__InvoiceDate__c = Date.today();
            invoice.blng__DueDate__c = Date.today();
            invoice.blng__Order__c = order.id;
            invoice.blng__PaymentBatch__c = 'Batch 1';
            insert invoice;

            LPCR_ModificationEntrante__c modif = UM002_TestDataFactory.createModificationsEntrante('Commentaire individuel facture',acc.id,cont.id,contract.id,Date.today(),10);
            modif.LPCR_HeureDateDebut__c = Datetime.newInstance(Date.today().Year(), Date.today().month() ,1);
            modif.LPCR_HeureDateFin__c = Datetime.newInstance(Date.today().Year(), Date.today().month() , Date.daysInMonth(Date.today().year(), Date.today().month()));
            modif.LPCR_Invoice__c = invoice.id;
            modif.LPCR_Commentaire__c = 'Test';
            insert modif;           

            APB007_TraitementModificationEntrante ss = new APB007_TraitementModificationEntrante();
            DataBase.executeBatch(ss);

            Test.stopTest();
            LPCR_ModificationEntrante__c modifChk = [select id,LPCR_EtatTraitement__c from LPCR_ModificationEntrante__c where id =: modif.id];
            System.assertEquals(true, modifChk.LPCR_EtatTraitement__c, 'Error in SM021_ModificationEntranteServices_Test : ModificationEntrante not updated');
        }
    }
    @isTest
    public static void updateQuotesFromModifEntrantesBatch_20_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Date firstDayOfCurrentMonthDate = Date.newInstance(Date.today().Year(), Date.today().month() ,1) ;
            Date lastDayOfCurrentMonthDate=Date.newInstance(Date.today().Year(), Date.today().month() , Date.daysInMonth(Date.today().year(), Date.today().month())) ;

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
            quote.SBQQ__Primary__c = true;
            quote.RecordTypeId = QUOTE_CONTRAT_ACCUEIL_RT_ID;
            update quote;

            List<SBQQ__QuoteLine__c> qlines = new List<SBQQ__QuoteLine__c> ();
            qlines.add(UM002_TestDataFactory.createQuoteLine(prod.Id, quote.Id, pbEntry.Id, 200, 1));
            insert qlines;

            LPCR_RessourceFamille__c ressourceFamille = UM002_TestDataFactory.createRessourceFamille(firstDayOfCurrentMonthDate,acc.id,cont.id,'Test');
            insert ressourceFamille;

            Contract contract = UM002_TestDataFactory.createContract(acc.id,quote.id,opp.id,Date.Today().addmonths(3));
            contract.Status = 'Draft';
            Insert contract;

            contract.Status = 'Activated';
            update contract;

            Order order = UM002_TestDataFactory.createOrder(acc.Id, contract.id,date.today(),'test','Draft','1');
            order.Pricebook2Id = standardPricebookId;
            order.SBQQ__Quote__c = quote.id;
            order.RecordTypeId = ORDER_CONTRAT_ACCUEIL_RT_ID;
            insert order;

            OrderItem orderItem = UM002_TestDataFactory.createOrderProduct(pbEntry.id, order.Id, prod.id, 'Recurring','Monthly', 100);
            orderItem.SBQQ__QuoteLine__c = qlines.get(0).id;
            orderItem.SBQQ__Activated__c = false;
            insert orderItem;
            orderItem.SBQQ__Activated__c = true;
            update orderItem;
            order.status ='Activated';
            update order;
            order.blng__BillNow__c = true;
            update order;

            Test.startTest();

            blng__Invoice__c invoice = new blng__Invoice__c();
            invoice.blng__Account__c = acc.Id;
            invoice.blng__BillToContact__c = cont.id;
            invoice.blng__InvoiceDate__c = Date.today();
            invoice.blng__DueDate__c = Date.today();
            invoice.blng__Order__c = order.id;
            invoice.blng__PaymentBatch__c = 'Batch 1';
            insert invoice;

            LPCR_ModificationEntrante__c modif = UM002_TestDataFactory.createModificationsEntrante('Commentaire global facture',acc.id,cont.id,contract.id,Date.today(),10);
            modif.LPCR_HeureDateDebut__c = Datetime.newInstance(Date.today().Year(), Date.today().month() ,1);
            modif.LPCR_HeureDateFin__c = Datetime.newInstance(Date.today().Year(), Date.today().month() , Date.daysInMonth(Date.today().year(), Date.today().month()));
            modif.LPCR_Invoice__c = invoice.id;
            modif.LPCR_Commentaire__c = 'Test';
            insert modif;           

            APB007_TraitementModificationEntrante ss = new APB007_TraitementModificationEntrante();
            DataBase.executeBatch(ss);

            Test.stopTest();
            LPCR_ModificationEntrante__c modifChk = [select id,LPCR_EtatTraitement__c from LPCR_ModificationEntrante__c where id =: modif.id];
            System.assertEquals(true, modifChk.LPCR_EtatTraitement__c, 'Error in SM021_ModificationEntranteServices_Test : ModificationEntrante not updated');
        }
    }
    @isTest
    public static void updateQuotesFromModifEntrantesBatch_21_Test(){
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

            LPCR_RessourceFamille__c ressourceFamille = UM002_TestDataFactory.createRessourceFamille(firstDayOfCurrentMonthDate,acc.id,cont.id,'Test');
            insert ressourceFamille;

            Test.startTest();

            Contract contract = UM002_TestDataFactory.createContract(acc.id,quote.id,opp.id,Date.Today().addmonths(3));
            Insert contract;

            LPCR_ModificationEntrante__c modif = UM002_TestDataFactory.createModificationsEntrante('Nombre de repas',acc.id,cont.id,contract.id,Date.today(),10);
            modif.LPCR_HeureDateDebut__c = Datetime.newInstance(Date.today().Year(), Date.today().month() ,1);
            modif.LPCR_HeureDateFin__c = Datetime.newInstance(Date.today().Year(), Date.today().month() , Date.daysInMonth(Date.today().year(), Date.today().month()));

            insert modif;            

            APB007_TraitementModificationEntrante ss = new APB007_TraitementModificationEntrante();
            DataBase.executeBatch(ss);

            Test.stopTest();
            LPCR_ModificationEntrante__c modifChk = [select id,LPCR_EtatTraitement__c from LPCR_ModificationEntrante__c where id =: modif.id];
            System.assertEquals(true, modifChk.LPCR_EtatTraitement__c, 'Error in SM021_ModificationEntranteServices_Test : ModificationEntrante not updated');
        }
    }
    @isTest
    public static void updateQuotesFromModifEntrantesBatch_22_Test(){
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
            
            LPCR_RessourceFamille__c ressourceFamille = UM002_TestDataFactory.createRessourceFamille(firstDayOfCurrentMonthDate,acc.id,cont.id,'Test');
            insert ressourceFamille;
            
            Contract contract = UM002_TestDataFactory.createContract(acc.id,quote.id,opp.id,Date.Today().addmonths(3));
            Insert contract;
            
            LPCR_ModificationEntrante__c modif = UM002_TestDataFactory.createModificationsEntrante('Modification Nombre Enfant Fratrie',acc.id,cont.id,contract.id,Date.today(),10);
            insert modif;
            
            Test.startTest();
            
            APB007_TraitementModificationEntrante ss = new APB007_TraitementModificationEntrante();
            DataBase.executeBatch(ss);

            Test.stopTest();
            LPCR_ModificationEntrante__c modifChk = [select id,LPCR_EtatTraitement__c from LPCR_ModificationEntrante__c where id =: modif.id];
            System.assertEquals(true, modifChk.LPCR_EtatTraitement__c, 'Error in SM021_ModificationEntranteServices_Test : ModificationEntrante not updated');
        }
    }
    @isTest
    public static void updateQuotesFromModifEntrantesBatch_23_Test(){
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
            
            LPCR_RessourceFamille__c ressourceFamille = UM002_TestDataFactory.createRessourceFamille(firstDayOfCurrentMonthDate,acc.id,cont.id,'Test');
            insert ressourceFamille;
            
            Contract contract = UM002_TestDataFactory.createContract(acc.id,quote.id,opp.id,Date.Today().addmonths(3));
            Insert contract;
            
            LPCR_ModificationEntrante__c modif = UM002_TestDataFactory.createModificationsEntrante('Modification Montant Ressource',acc.id,cont.id,contract.id,Date.today(),10);
            insert modif;
            
            Test.startTest();
            
            APB007_TraitementModificationEntrante ss = new APB007_TraitementModificationEntrante();
            DataBase.executeBatch(ss);

            Test.stopTest();
            LPCR_ModificationEntrante__c modifChk = [select id,LPCR_EtatTraitement__c from LPCR_ModificationEntrante__c where id =: modif.id];
            System.assertEquals(true, modifChk.LPCR_EtatTraitement__c, 'Error in SM021_ModificationEntranteServices_Test : ModificationEntrante not updated');
        }
    }
    @isTest
    public static void updateQuotesFromModifEntrantesBatch_24_Test(){
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

            LPCR_RessourceFamille__c ressourceFamille = UM002_TestDataFactory.createRessourceFamille(firstDayOfCurrentMonthDate,acc.id,cont.id,'Test');
            insert ressourceFamille;

            Test.startTest();

            Contract contract = UM002_TestDataFactory.createContract(acc.id,quote.id,opp.id,Date.Today().addmonths(3));
            Insert contract;

            LPCR_ModificationEntrante__c modif = UM002_TestDataFactory.createModificationsEntrante('Regularisation',acc.id,cont.id,contract.id,Date.today(),10);
            modif.LPCR_HeureDateDebut__c = Datetime.newInstance(Date.today().Year(), Date.today().month() ,1);
            modif.LPCR_HeureDateFin__c = Datetime.newInstance(Date.today().Year(), Date.today().month() , Date.daysInMonth(Date.today().year(), Date.today().month()));

            insert modif;            

            APB007_TraitementModificationEntrante ss = new APB007_TraitementModificationEntrante();
            DataBase.executeBatch(ss);

            Test.stopTest();
            LPCR_ModificationEntrante__c modifChk = [select id,LPCR_EtatTraitement__c from LPCR_ModificationEntrante__c where id =: modif.id];
            System.assertEquals(true, modifChk.LPCR_EtatTraitement__c, 'Error in SM021_ModificationEntranteServices_Test : ModificationEntrante not updated');
        }
    }
}