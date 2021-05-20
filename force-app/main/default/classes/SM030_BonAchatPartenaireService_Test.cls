@isTest
public  class SM030_BonAchatPartenaireService_Test {
    //contrat reservataire 
    private static final Id ContratReservataireID=EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract, Label.LPCR_Reservataire);
    private static final Id ContratRefID=EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract, Label.LPCR_Referencement);
    private static final Id ACCOUNT_ENTREPRISE_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account,Label.LPCR_Entreprise);
    private static final Id CONTRACT_Referencement_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract, Label.LPCR_Referencement);
    private static final Id QUOTE_Referencement_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote, Label.LPCR_Referencement);
    private static final Id ACCOUNT_CRECHE_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account,Label.LPCR_Creche);
    //opp
    private static final Id OPP_ENT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Opportunity,Label.LPCR_Entreprise);
    private static final Id OPP_PART = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Opportunity,Label.LPCR_Partenaire);
    private static final Id ACCOUNT_PARTENAIRE=EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account,Label.LPCR_Partenaire);
    //qli
    
    @testsetup
    static void setup(){
        
        Id standardPricebookId = Test.getStandardPricebookId();
        List<Account> lstAcc;
        List<Opportunity> lstOpp;
        List<Contact> lstCon=new List<Contact> ();
        List<SBQQ__Quote__c> lstQuote;
        List<SBQQ__QuoteLine__c> lstQli;
        UM002_TestDataFactory.insertBillingCustomSettings();
        
        blng__LegalEntity__c billingLegalEntity = UM002_TestDataFactory.setupLegalEntity();
        
        blng__RevenueRecognitionRule__c revRecRule = UM002_TestDataFactory.setupRevRec(billingLegalEntity.Id);
        
        blng__BillingRule__c billingRule = UM002_TestDataFactory.setupBillingRule(billingLegalEntity.Id);
        
        blng__TaxRule__c taxRule = UM002_TestDataFactory.setupTaxRule(billingLegalEntity.Id);
        Product2 prod = UM002_TestDataFactory.createProduct('Berceautest', billingRule.Id, revRecRule.Id,taxRule.Id );
       prod.SBQQ__SubscriptionPricing__c ='Fixed Price';
      
        insert prod;
      
        
        PricebookEntry priceBookEntry1 = UM002_TestDataFactory.createPricebookEntry(standardPricebookId,prod.Id);
        insert priceBookEntry1;
        //create accoun famille
        Id accountFamilleRTId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Famille);
         Account accFamille = UM002_TestDataFactory.createAccounts(1,accountFamilleRTId,'testFamil').get(0);
        //create account entreprise
        Account acc = UM002_TestDataFactory.createAccounts(1,ACCOUNT_ENTREPRISE_RT_ID,'test').get(0);
        acc.SBQQ__RenewalModel__c ='Contract Based';
        acc.LPCR_PasDeSIRET__c = true;
        //create account creche
        Account compteCreche=UM002_TestDataFactory.createAccounts(1,ACCOUNT_CRECHE_RT_ID,'testcreche').get(0);
        compteCreche.LPCR_TypeCreche__c='MICRO';
        Account comptePartner=UM002_TestDataFactory.createAccounts(1,ACCOUNT_PARTENAIRE,'testpartenaire').get(0);
        comptePartner.LPCR_TypeCreche__c='MICRO';
        lstAcc= new List<Account>{acc,compteCreche,accFamille,comptePartner};
        insert lstAcc;
        Id contactEnfantRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contact, Label.LPCR_Enfant);
        Id contactRepRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contact, Label.LPCR_Parent);
        Id contactPatner = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contact, Label.LPCR_Partenaire);
        Contact contactRep1=UM002_TestDataFactory.createContact('tesRep',contactRepRT);
        contactRep1.AccountId=lstAcc[2].Id;
        insert contactRep1;
        
        Contact contactEnfant=UM002_TestDataFactory.createContact('testchild',contactEnfantRT);
        contactEnfant.AccountId=lstAcc[2].Id;
        contactEnfant.LPCR_Representant1__c=contactRep1.Id;
        contactEnfant.Birthdate=Date.today()-100;
            contactEnfant.LPCR_DateEntreeCrecheSouhaitee__c=Date.today()+100;
        insert contactEnfant;
        Contact contactPartner=UM002_TestDataFactory.createContact('testchild1',contactPatner);
        contactPartner.AccountId=lstAcc[3].Id;
        insert contactPartner;
        
        System.debug('cont ne '+contactEnfant);
        //opportunities
        Opportunity opp = UM002_TestDataFactory.createOpportunities(1, 'test', 'Prospecting').get(0);
        //opp.recordtypeid=OPP_ENT;
        Opportunity opp2 = UM002_TestDataFactory.createOpportunities(1, 'test2', 'Prospecting').get(0);
        Opportunity oppPartenaire = UM002_TestDataFactory.createOpportunities(1, 'testPartenaire', 'Prospecting').get(0);
        oppPartenaire.recordtypeid=OPP_PART;
        //opp2.recordtypeid=OPP_ENT;
        lstOpp=new List<Opportunity>{opp,opp2,oppPartenaire};
        insert lstOpp;
        
            Date lastMonth=Date.newInstance(System.today().Year(), System.today().month() - 1, System.today().day()+1) ;
            
           // Contact contactEnfant=[Select id from Contact where name='testchild' limit 1];
            Product2 Berceautest=[select id from Product2 where name='Berceautest' limit 1  ];
            //Account acc = [SELECT Id, name from Account where name ='test' limit 1 ];
            Account accreche = [SELECT Id, name from Account where name ='testcreche' limit 1 ];
            acc.RecordTypeId = ACCOUNT_ENTREPRISE_RT_ID;
            update acc;
            Contract contract2 = new Contract(
            AccountId = lstAcc[0].Id, 
            SBQQ__PreserveBundleStructureUponRenewals__c = true, 
            ContractTerm = 12,
            StartDate = Date.today(),recordtypeid=ContratRefID);
        insert contract2;
        SBQQ__Subscription__c subs = new SBQQ__Subscription__c(
            SBQQ__Contract__c = contract2.Id, LPCR_BonDachatPartenaire__c=null,
            SBQQ__Product__c = Berceautest.ID, 
            SBQQ__Quantity__c = 10, 
            SBQQ__Account__c = acc.Id,
            SBQQ__NetPrice__c = 2000,
            SBQQ__SubscriptionEndDate__c = Date.today()+100,LPCR_Creche__c=accreche.id,LPCR_ContactEnfant__c=contactEnfant.ID
        );
        insert subs;
        
        //create bda
        LPCR_ContratPartenaire__c contratPartenaire=new LPCR_ContratPartenaire__c (LPCR_Opportunite__c=oppPartenaire.ID,LPCR_CDDCDI__c='CDD', LPCR_Compte__c=comptePartner.ID,LPCR_ContactPartenaire__c=contactPartner.Id);
        insert contratPartenaire;
        
        LPCR_BonAchatPartenaire__c bda = new LPCR_BonAchatPartenaire__c(Name='testbda',LPCR_ContratPartenaire__c =contratPartenaire.id,LPCR_ComptePartenaire__c=comptePartner.ID,LPCR_ContactEnfant__c=contactEnfant.Id,LPCR_Creche__c=accreche.ID);
        insert bda;
        
    }
    @isTest
    private static void testContratReservataire() {
      
        Test.startTest();
        Test.stopTest();
        LPCR_BonAchatPartenaire__c bda =[Select LPCR_ContratReservataire__c,Name from LPCR_BonAchatPartenaire__c ];
        System.assertNotEquals(bda.LPCR_ContratReservataire__c, null);
        
            
            
    
       
    }
    

    
}