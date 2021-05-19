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
        Contact contactPartner=UM002_TestDataFactory.createContact('testchild',contactPatner);
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
        //create quote resa
        SBQQ__Quote__c quote = UM002_TestDataFactory.createQuote('test',opp.Id, lstAcc[0].Id, standardPricebookId, 'Quote');
        quote.SBQQ__Primary__c =true;
        //quote.recordtypeid=QUOTE_Referencement_RT_ID;
        SBQQ__Quote__c quote2 = UM002_TestDataFactory.createQuote('test2',opp2.Id, lstAcc[0].Id, standardPricebookId, 'Quote');
        quote2.SBQQ__Primary__c =true;
        //quote2.recordtypeid=QUOTE_Referencement_RT_ID;
        lstQuote=new List<SBQQ__Quote__c>{quote,quote2};
        insert lstQuote;
        //QLI
        SBQQ__QuoteLine__c quoteLine = UM002_TestDataFactory.createQuoteLine(prod.Id, lstQuote[0].Id, priceBookEntry1.Id, 200,1);
        quoteLine.SBQQ__SubscriptionPricing__c='Fixed Price';
        //quoteLine.LPCR_ContactEnfant__c=contactEnfant.ID;
       // quoteLine.LPCR_Creche__c =compteCreche.Id;
        //quoteLine.LPCR_CompteFamille__c=lstAcc[2].Id;
        SBQQ__QuoteLine__c quoteLine2 = UM002_TestDataFactory.createQuoteLine(prod.Id, lstQuote[1].Id, priceBookEntry1.Id, 150,1);
        quoteLine2.SBQQ__SubscriptionPricing__c='Fixed Price';
        quoteLine2.LPCR_ContactEnfant__c=contactEnfant.ID;
        quoteLine2.LPCR_Creche__c =compteCreche.Id;
        quoteLine2.LPCR_CompteFamille__c=lstAcc[2].Id;
        lstQli=new List<SBQQ__QuoteLine__c>{quoteLine,quoteLine2};
        insert lstQli;
        System.debug('##pdo this is qli '+lstQli[0].LPCR_ContactEnfant__c);
        System.debug('##pdo this is qli '+lstQli[1].LPCR_ContactEnfant__c);
        //generate order
        lstQuote[0].SBQQ__Ordered__c  = true; 
        lstQuote[0].LPCR_IndexationConvenue__c='non';
        lstQuote[0].LPCR_TypeFacturation__c='Arrears';
        lstQuote[0].SBQQ__BillingFrequency__c='Quarterly';
        lstQuote[0].LPCR_DateDebut__c = Date.today();
        lstQuote[0].LPCR_DateFin__c = Date.today() + 100;
        lstQuote[0].LPCR_ChiffreAffaire__c = 100;
        lstQuote[0].SBQQ__RenewalUpliftRate__c = 2; 
        lstQuote[0].LPCR_BatchCommande__c = 'Batch 2';
        lstQuote[0].LPCR_TypeCreche__c = 'MICRO';
        lstQuote[1].SBQQ__Ordered__c  = true; 
        lstQuote[1].LPCR_IndexationConvenue__c='non';
        lstQuote[1].LPCR_TypeFacturation__c='Arrears';
        lstQuote[1].SBQQ__BillingFrequency__c='Quarterly';
        lstQuote[1].LPCR_DateDebut__c = Date.today();
        lstQuote[1].LPCR_DateFin__c = Date.today() + 111;
        lstQuote[1].LPCR_ChiffreAffaire__c = 111;
        lstQuote[1].SBQQ__RenewalUpliftRate__c = 2; 
        lstQuote[1].LPCR_BatchCommande__c = 'Batch 2';
        lstQuote[1].LPCR_TypeCreche__c = 'MICRO';
        update lstQuote;
        Set<Id> quotesIds = new Set<Id>{lstQuote[1].Id,lstQuote[0].Id};
        List<Order> orders = Database.query('SELECT Id ,SBQQ__Contracted__c , Status ,OpportunityId,EffectiveDate FROM Order WHERE SBQQ__Quote__c  in :quotesIds');
        for(Order order: orders)
        {
            order.status ='Activated';
            order.LPCR_NumeroContrat__c = '4';
            order.LPCR_ContactEnfant__c=contactEnfant.ID;
        }
        update orders;
        //create bda
        LPCR_ContratPartenaire__c contratPartenaire=new LPCR_ContratPartenaire__c (LPCR_Opportunite__c=oppPartenaire.ID,LPCR_CDDCDI__c='CDD', LPCR_Compte__c=comptePartner.ID,LPCR_ContactPartenaire__c=contactPartner.Id);
        insert contratPartenaire;
        LPCR_BonAchatPartenaire__c bda = new LPCR_BonAchatPartenaire__c(LPCR_ContratPartenaire__c =contratPartenaire.id,LPCR_ComptePartenaire__c=comptePartner.ID,LPCR_ContactEnfant__c=contactEnfant.Id,LPCR_Creche__c=compteCreche.ID);
        insert bda;
        
        
        
    }
    @isTest
    private static void testContratReservataire() {
      //  System.runAs(UM002_TestDataFactory.createUser()){
            
            Date lastMonth=Date.newInstance(System.today().Year(), System.today().month() - 1, System.today().day()+1) ;
            Test.startTest();
            Contact contactEnfant=[Select id from Contact where name='testchild' limit 1];
            Product2 Berceautest=[select id from Product2 where name='Berceautest' limit 1  ];
            Account acc = [SELECT Id, name from Account where name ='test' limit 1 ];
            Account accreche = [SELECT Id, name from Account where name ='testcreche' limit 1 ];
            acc.RecordTypeId = ACCOUNT_ENTREPRISE_RT_ID;
            update acc;
            Contract contract2 = new Contract(
            AccountId = acc.Id, 
            SBQQ__PreserveBundleStructureUponRenewals__c = true, 
            ContractTerm = 12,
            StartDate = Date.today());
        insert contract2;
        SBQQ__Subscription__c subs = new SBQQ__Subscription__c(
            SBQQ__Contract__c = contract2.Id, 
            SBQQ__Product__c = Berceautest.ID, 
            SBQQ__Quantity__c = 10, 
            SBQQ__Account__c = acc.Id,
            SBQQ__NetPrice__c = 2000,
            SBQQ__SubscriptionEndDate__c = Date.today()+100,LPCR_Creche__c=accreche.id,LPCR_ContactEnfant__c=contactEnfant.ID
        );
        insert subs;
            //Contact contactEnfant=[Select id from Contact where name='testchild' limit 1];
            
             blng__InvoicePlan__c invoicePlan =   new blng__InvoicePlan__c(blng__BillingScheduleCreation__c='Manual',blng__Active__c =true);
            insert    invoicePlan;
            SBQQ__Quote__c quote = Database.query('SELECT Id,LPCR_DureeContratJour__c,SBQQ__SalesRep__c, LPCR_ResponsableADV__c, LPCR_ResponsableServiceFamille__c,LPCR_IndexationConvenue__c,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c,LPCR_MasterDevis__c ,LPCR_DateDebut__c,LPCR_DateFin__c,LPCR_ChiffreAffaire__c, LPCR_MethodeRenouvellement__c,SBQQ__RenewalUpliftRate__c,LPCR_TypeEntreprise__c,LPCR_PlanningEnfant__c FROM SBQQ__Quote__c WHERE SBQQ__BillingCity__c = \'test2\'');
            Order order = [SELECT Id ,LPCR_NouveauPlanFacture__c, LPCR_RenouvellementPlanFacture__c,Status ,SBQQ__Contracted__c FROM Order WHERE SBQQ__Quote__c  = :quote.Id];       
           
            order.SBQQ__Contracted__c=true; 
            order.LPCR_NouveauPlanFacture__c=invoicePlan.Id;
            order.LPCR_RenouvellementPlanFacture__c=invoicePlan.Id;
            //order.LPCR_ContactEnfant__c=contactEnfant.ID;
            update order;

             Contract contract =null; 
            try{
                contract = [SELECT Id,RecordTypeId,LPCR_NouveauPlanFacture__c,LPCR_RenouvellementPlanFacture__c,SBQQ__Order__c, LPCR_Sales_Rep__c ,LPCR_ResponsableADV__c, LPCR_ResponsableServiceFamille__c, LPCR_BillingFrequency__c,LPCR_TypeFacturation__c,Status,StartDate,ContractTerm,LPCR_DateRenouvellement__c,LPCR_RenouvellementAutomatique__c, SBQQ__RenewalQuoted__c,LPCR_JoursAvance__c, LPCR_PlanningEnfant__c FROM Contract 

                            WHERE SBQQ__Order__c =:order.Id ]; 
            }catch(Exception e){
                PAD.log('SM010_ContractServices_Test','setContractFieldsTest','Error , Contract not get generated');
                contract = UM002_TestDataFactory.createContract(acc.Id,quote.Id,order.Id);
                //contract.LPCR_ContactEnfant__c=contactEnfant.ID;
            }
            
			 Test.stopTest();
            
            
      //  }
       
    }
    

    
}
