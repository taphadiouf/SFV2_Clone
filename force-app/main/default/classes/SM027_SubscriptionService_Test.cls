@isTest
public class SM027_SubscriptionService_Test {
    //contrat reservataire 
    private static final Id ContratReservataireID=EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract, Label.LPCR_Reservataire);
    private static final Id ContratRefID=EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract, Label.LPCR_Referencement);
    private static final Id ACCOUNT_ENTREPRISE_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account,Label.LPCR_Entreprise);
     private static final Id CONTRACT_CONTRAT_ACCUEIL_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract, Label.LPCR_ContratA);
    private static final Id QUOTE_CONTRAT_ACCUEIL_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote, Label.LPCR_ContratA);
    private static final Id CONTRACT_Referencement_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract, Label.LPCR_Referencement);
    private static final Id QUOTE_Referencement_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote, Label.LPCR_Referencement);
    private static final Id Order_Referencement_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Order, Label.LPCR_Referencement);
    
    @testsetup
    static void setup(){
        Id standardPricebookId = Test.getStandardPricebookId();
        
        UM002_TestDataFactory.insertBillingCustomSettings();
        
        blng__LegalEntity__c billingLegalEntity = UM002_TestDataFactory.setupLegalEntity();
        
        blng__RevenueRecognitionRule__c revRecRule = UM002_TestDataFactory.setupRevRec(billingLegalEntity.Id);
        
        blng__BillingRule__c billingRule = UM002_TestDataFactory.setupBillingRule(billingLegalEntity.Id);
        
        blng__TaxRule__c taxRule = UM002_TestDataFactory.setupTaxRule(billingLegalEntity.Id);
        
        Id familleAccountRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Famille);
        Account acc = UM002_TestDataFactory.createAccounts(1,familleAccountRT,'test').get(0);
        acc.SBQQ__RenewalModel__c ='Contract Based';
        acc.LPCR_PasDeSIRET__c = true;
        insert acc;
        
        Opportunity opp = UM002_TestDataFactory.createOpportunities(1, 'test', 'Prospecting').get(0);
        insert opp;
        Opportunity opp2 = UM002_TestDataFactory.createOpportunities(1, 'test2', 'Prospecting').get(0);
        insert opp2;
        
        SBQQ__Quote__c quote = UM002_TestDataFactory.createQuote('test',opp.Id, acc.Id, standardPricebookId, 'Quote');
        quote.SBQQ__Primary__c =true;
        insert quote;
        
        SBQQ__Quote__c quote2 = UM002_TestDataFactory.createQuote('test2',opp2.Id, acc.Id, standardPricebookId, 'Quote');
        quote2.SBQQ__Primary__c =true;
        insert quote2;
        
        Product2 prod = UM002_TestDataFactory.createProduct('Berceautest', billingRule.Id, revRecRule.Id,taxRule.Id );
       prod.SBQQ__SubscriptionPricing__c ='Fixed Price';
      
        insert prod;
      
        
        PricebookEntry priceBookEntry1 = UM002_TestDataFactory.createPricebookEntry(standardPricebookId,prod.Id);
        insert priceBookEntry1;
        
        SBQQ__QuoteLine__c quoteLine = UM002_TestDataFactory.createQuoteLine(prod.Id, quote.Id, priceBookEntry1.Id, 200,1);
        quoteLine.SBQQ__SubscriptionPricing__c='Fixed Price';
        insert quoteLine;
       
        opp.SBQQ__PrimaryQuote__c =quote.Id;
        
        
        
        SBQQ__QuoteLine__c quoteLine2 = UM002_TestDataFactory.createQuoteLine(prod.Id, quote2.Id, priceBookEntry1.Id, 150,1);
        quoteLine2.SBQQ__SubscriptionPricing__c='Fixed Price';
        insert quoteLine2;
        opp2.SBQQ__PrimaryQuote__c =quote2.Id;
        
        
        update new List<Opportunity>{opp,opp2};
        Test.startTest();    
        LPCR_Planning__c planningEnfant = new LPCR_Planning__c();
        insert planningEnfant;
        quote.RecordTypeId=QUOTE_CONTRAT_ACCUEIL_RT_ID;
        quote.SBQQ__Ordered__c  = true; 
        quote.LPCR_IndexationConvenue__c='Oui';
        quote.LPCR_TypeFacturation__c='Arrears';
        quote.SBQQ__BillingFrequency__c='Invoice Plan';
        quote.LPCR_DateDebut__c = Date.today();
        quote.LPCR_DateFin__c = Date.today() + 10;
        quote.LPCR_ChiffreAffaire__c = 1000;
        quote.SBQQ__RenewalUpliftRate__c = 2; 
        quote.LPCR_PlanningEnfant__c = planningEnfant.id;
        quote.LPCR_BatchCommande__c = 'Batch 2';
        quote.LPCR_ResponsableADV__c = UserInfo.getUserId();
        quote.SBQQ__SalesRep__c = UserInfo.getUserId();
        quote.LPCR_ResponsableServiceFamille__c = UserInfo.getUserId();
        quote.LPCR_TypeCreche__c = 'MAC';
        
        quote2.SBQQ__Ordered__c  = true; 
        quote2.LPCR_IndexationConvenue__c='non';
        quote2.LPCR_TypeFacturation__c='Arrears';
        quote2.SBQQ__BillingFrequency__c='Invoice Plan';
        quote2.LPCR_DateDebut__c = Date.today();
        quote2.LPCR_DateFin__c = Date.today() + 100;
        quote2.LPCR_ChiffreAffaire__c = 100;
        quote2.SBQQ__RenewalUpliftRate__c = 2; 
        quote2.LPCR_PlanningEnfant__c = planningEnfant.id;
        quote2.LPCR_BatchCommande__c = 'Batch 2';
        

        update new List<SBQQ__Quote__c>{quote,quote2};
        Test.stopTest();    
            Set<Id> quotesIds = new Set<Id>{quote2.Id,quote.Id};
                List<Order> orders = Database.query('SELECT Id ,SBQQ__Contracted__c , Status ,OpportunityId,EffectiveDate FROM Order WHERE SBQQ__Quote__c  in :quotesIds');
        for(Order order: orders)
        {
            order.status ='Activated';
            order.LPCR_NumeroContrat__c = '4';
        }
        update orders;
        
        
    }
    @isTest
    private static void testContratReservataire() {
        System.runAs(UM002_TestDataFactory.createUser()){
            
            Date lastMonth=Date.newInstance(System.today().Year(), System.today().month() - 1, System.today().day()+1) ;
            Test.startTest();
            
            Account acc = [SELECT Id, name from Account where name ='test' ];
            acc.RecordTypeId = ACCOUNT_ENTREPRISE_RT_ID;
            update acc;
             blng__InvoicePlan__c invoicePlan =   new blng__InvoicePlan__c(blng__BillingScheduleCreation__c='Manual',blng__Active__c =true);
            insert    invoicePlan;
            SBQQ__Quote__c quote = Database.query('SELECT Id,LPCR_DureeContratJour__c,SBQQ__SalesRep__c, LPCR_ResponsableADV__c, LPCR_ResponsableServiceFamille__c,LPCR_IndexationConvenue__c,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c,LPCR_MasterDevis__c ,LPCR_DateDebut__c,LPCR_DateFin__c,LPCR_ChiffreAffaire__c, LPCR_MethodeRenouvellement__c,SBQQ__RenewalUpliftRate__c,LPCR_TypeEntreprise__c,LPCR_PlanningEnfant__c FROM SBQQ__Quote__c WHERE SBQQ__BillingCity__c = \'test\'');
            Order order = [SELECT Id ,LPCR_NouveauPlanFacture__c, LPCR_RenouvellementPlanFacture__c,Status ,SBQQ__Contracted__c FROM Order WHERE SBQQ__Quote__c  = :quote.Id];       
           
            order.SBQQ__Contracted__c=true; 
            order.LPCR_NouveauPlanFacture__c=invoicePlan.Id;
            order.LPCR_RenouvellementPlanFacture__c=invoicePlan.Id;
            update order;

             Contract contract =null; 
            try{
                contract = [SELECT Id,RecordTypeId,LPCR_NouveauPlanFacture__c,LPCR_RenouvellementPlanFacture__c,SBQQ__Order__c, LPCR_Sales_Rep__c ,LPCR_ResponsableADV__c, LPCR_ResponsableServiceFamille__c, LPCR_BillingFrequency__c,LPCR_TypeFacturation__c,Status,StartDate,ContractTerm,LPCR_DateRenouvellement__c,LPCR_RenouvellementAutomatique__c, SBQQ__RenewalQuoted__c,LPCR_JoursAvance__c, LPCR_PlanningEnfant__c FROM Contract 

                            WHERE SBQQ__Order__c =:order.Id ]; 
            }catch(Exception e){
                PAD.log('SM010_ContractServices_Test','setContractFieldsTest','Error , Contract not get generated');
                contract = UM002_TestDataFactory.createContract(acc.Id,quote.Id,order.Id);
            }
			 Test.stopTest();
            contract = [SELECT Id,LPCR_BatchCommande__c	,LPCR_NombreDeBerceaux__c FROM Contract
                        WHERE SBQQ__Order__c =:order.Id]; 
           
           System.assertEquals(1,contract.LPCR_NombreDeBerceaux__c,'Berceau nbr not same');
        }
        
    }
     

}