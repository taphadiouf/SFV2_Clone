@isTest
public with sharing class APC011_GenererAvoir_Test {
    private static final Id B2C_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Famille);
    private static final Id CRECHE_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Creche);
    private static final Id OPPT_FAMILE_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Opportunity, Label.LPCR_Famille);
    private static final Id QUOTE_CONTRAT_ACCUEIL_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote, Label.LPCR_ContratA);
    private static final Id standardPricebookId = Test.getStandardPricebookId();
    private static final Id CONTACT_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contact, Label.LPCR_Famille);
   
    @testSetup 
    static void  testSetup() {
        User userFamille;
        User userResp;
        System.runAs(UM002_TestDataFactory.createUser()){
        List<UserRole > lstRole =[SELECT Id,developername, Name FROM UserRole where developername  IN ('LPCR_ChargeRelationFamillesInscriptions','LPCR_ResponsableADV')];
         userFamille=UM002_TestDataFactory.createUser(lstRole[0].Id);
             userResp=UM002_TestDataFactory.createUser(lstRole[1].Id);
        }
        Account acc = UM002_TestDataFactory.createAccounts(1, 'test').get(0);
        insert acc;
        LPCR_Avoir__c avoir= new LPCR_Avoir__c(LPCR_CompteClient__c=acc.id, LPCR_Montant__c=-80, LPCR_Description__c='test', LPCR_DateFacture__c=System.today(), LPCR_NomSociete__c =acc.id);
        insert avoir;
        ///start
        UM002_TestDataFactory.insertBillingCustomSettings();
        blng__LegalEntity__c billingLegalEntity = UM002_TestDataFactory.setupLegalEntity();
        blng__RevenueRecognitionRule__c revRecRule = UM002_TestDataFactory.setupRevRec(billingLegalEntity.Id);
        blng__BillingRule__c billingRule = UM002_TestDataFactory.setupBillingRule(billingLegalEntity.Id);
        blng__TaxRule__c taxRule = UM002_TestDataFactory.setupTaxRule(billingLegalEntity.Id);
        
        Map<String, Object> defaultVal = new Map<String, Object> {
            'RecordTypeId' => B2C_RT_ID,
                'Name' => 'Test-B2C',
                'SBQQ__RenewalModel__c' => 'Contract Based'
                };
                    Account account =(Account) UM002_TestDataFactory.createSObject('Account', defaultVal);
        account.RecordTypeId = B2C_RT_ID;
        account.LPCR_ResponsableServiceFamille__c=userFamille.id;
            account.LPCR_ResponsableADV__c=userResp.id;
        insert account;
        
        defaultVal = new Map<String, Object> {
            'Name' => 'prod-test',
                'isActive' => true,
                'blng__BillingRule__c' => billingRule.Id,
                'blng__RevenueRecognitionRule__c' => revRecRule.Id,
                'blng__TaxRule__c' => taxRule.Id,
                'SBQQ__SubscriptionPricing__c' => 'Fixed Price',
                'SBQQ__ChargeType__c' => 'One-Time',
                'SBQQ__SubscriptionType__c' => 'Renewable',
                'SBQQ__SubscriptionTerm__c' => 12,
                'ProductCode' => Label.LPCR_RegistrationFeeMac
                };
                    
                    Product2 prod = (Product2) UM002_TestDataFactory.createSObject('Product2', defaultVal);
        insert prod;
        
        defaultVal = new Map<String, Object> {
            'isActive' => true,
                'UnitPrice' => 100,
                'Product2Id' => prod.Id,
                'Pricebook2Id' => standardPricebookId
                
                };
                    
                    PricebookEntry priceBookEntry = (PricebookEntry) UM002_TestDataFactory.createSObject('PricebookEntry', defaultVal);
        insert priceBookEntry;
        
        defaultVal = new Map<String, Object> {
            'RecordTypeId' => OPPT_FAMILE_RT_ID,
                'AccountId' => account.Id,
                'Name' => 'test-oppt',
                'StageName' => 'Signée',
                'CloseDate' => System.today(),
                'Pricebook2Id' => standardPricebookId,
                'Type' => 'New Business'
                };
                    
                    Opportunity opp = (Opportunity) UM002_TestDataFactory.createSObject('Opportunity', defaultVal);
        insert opp;
        
        defaultVal = new Map<String, Object> {
            'RecordTypeId' => QUOTE_CONTRAT_ACCUEIL_RT_ID,
                'SBQQ__Account__c' => account.Id,
                'SBQQ__SubscriptionTerm__c' => 12,
                'SBQQ__Status__c' => 'Draft',
                'SBQQ__BillingFrequency__c' => 'Monthly',
                'LPCR_TypeFacturation__c' => 'Advance',
                'LPCR_IndexationConvenue__c' => 'Oui',
                'SBQQ__StartDate__c' => System.today(),
                'SBQQ__PricebookId__c' => standardPricebookId,
                'SBQQ__PriceBook__c' => standardPricebookId,
                'SBQQ__Type__c' => 'Quote',
                'SBQQ__QuoteLanguage__c' => 'English',
                'SBQQ__BillingCity__c' => 'Paris',
                'SBQQ__Primary__c' => true,
                'LPCR_TypeCreche__c' => 'MAC',
                'SBQQ__Opportunity2__c' => opp.Id,
                'SBQQ__RenewalUpliftRate__c' => 10
                };
                    
        SBQQ__Quote__c quote = (SBQQ__Quote__c) UM002_TestDataFactory.createSObject('SBQQ__Quote__c', defaultVal);
        quote.LPCR_Creation_conforme__c = true;
        insert quote;
        
        Integer price = 200;
        defaultVal = new Map<String, Object> {
            'Name' => 'prod-test',
                'SBQQ__StartDate__c' => System.Today(),
                'SBQQ__Product__c' => prod.Id,
                'SBQQ__Quantity__c' => 1,
                'SBQQ__ListPrice__c' => price,
                'SBQQ__CustomerPrice__c' => price,
                'SBQQ__NetPrice__c' => price,
                'SBQQ__SpecialPrice__c' => price,
                'SBQQ__Quote__c' => quote.Id,
                'SBQQ__PricebookEntryId__c' => priceBookEntry.Id,
                'SBQQ__PricingMethod__c' => 'List',
                'SBQQ__ChargeType__c' => 'Recurring',
                'SBQQ__BillingType__c' => 'Advance',
                'SBQQ__BillingFrequency__c' => 'Monthly',
                'LPCR_Region__c' => 'Paris',
                'LPCR_EntiteJuridique__c' => UM002_TestDataFactory.setupLegalEntity().Id
                };
                    
                    SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c) UM002_TestDataFactory.createSObject('SBQQ__QuoteLine__c', defaultVal);
        insert quoteLine;
        
       

        defaultVal = new Map<String, Object> {
            'RecordTypeId' => CRECHE_RT_ID,
                'Name' => 'Creche',
                'LPCR_TypeCreche__c' => 'MAC',
                'LPCR_Region__c' => 'Paris',
                'LPCR_TypeMensualisation__c' => 11 
                };
                    
       /** Account crecheAccount = (Account) UM002_TestDataFactory.createSObject('Account', defaultVal);
        crecheAccount.LPCR_TypeCreche__c = 'MICRO';
        crecheAccount.LPCR_ResponsableServiceFamille__c=userFamille.id;
            crecheAccount.LPCR_ResponsableADV__c=userResp.id;
        insert crecheAccount;**/
        
        Id standardPricebookId = Test.getStandardPricebookId();
        
        Order order = UM002_TestDataFactory.createOrder(account.id,null,date.today(),'test','Draft','1');
        order.Pricebook2Id = standardPricebookId;
        insert order;
        
        OrderItem orderItem = UM002_TestDataFactory.createOrderProduct(priceBookEntry.id, order.Id, prod.id, 'Recurring','Monthly', 300);
        insert orderItem;
        
        Contract contract = UM002_TestDataFactory.createContract(account.Id,order.Id);
        insert contract;        
        
        List<blng__InvoiceRun__c> invoiceRunsList = UM002_TestDataFactory.createInvoiceRuns(1,'Execution de Facture',date.newInstance(System.Today().year(), 10, 02));
        insert invoiceRunsList;
        
        blng__InvoiceRun__c invoiceRun = invoiceRunsList.get(0);
        
      Test.startTest();
        List<blng__Invoice__c> invoicesList = UM002_TestDataFactory.createInvoices(1,account.id,invoiceRun.id,'Draft','A Envoyer' );
        insert invoicesList;
       
        
        blng__Invoice__c invoice = invoicesList.get(0);
               
        blng__InvoiceLine__c invoiceLineList = UM002_TestDataFactory.createInvoiceLine(invoice.id,orderItem.Id);
        invoiceLineList.blng__InvoiceLineStatus__c = 'Draft';
        invoiceLineList.blng__UnitPrice__c = 150;
        invoiceLineList.blng__Quantity__c =3;
        invoiceLineList.blng__Product__c = prod.id;
        invoiceLineList.blng__StartDate__c = System.today();
        invoiceLineList.blng__ChargeType__c = 'Recurring';
        invoiceLineList.blng__BillingFrequency__c = 'Annual';
        invoiceLineList.blng__Subtotal__c = 200;
        insert invoiceLineList;
        test.stopTest();
    }
    @isTest
    public static void testMethod1(){
        LPCR_Avoir__c avoir=[SELECT Id, LPCR_CompteClient__c, LPCR_Montant__c, LPCR_Description__c, LPCR_DateFacture__c, LPCR_NomSociete__c FROM LPCR_Avoir__c limit 1 ];
        ApexPages.StandardController sc = new ApexPages.standardController(avoir);

        APC011_GenererAvoir controller = new APC011_GenererAvoir(sc);
        Test.startTest();
        APC011_GenererAvoir.GenererAvoir(avoir.ID,'test');
        Test.stopTest();
    }
    @isTest
    public static void testMethod2(){
        APC012_CreateAvoir.getPicklistvalues();
        blng__Invoice__c invoice = [SELECT Id, blng__order__c FROM blng__Invoice__c LIMIT 1];
        blng__InvoiceLine__c ligneFacture=[SELECT Id,Name, LPCR_MontantAvoirLigneFacture__c,blng__Invoice__r.LPCR_SocieteFacturante__c,blng__Invoice__r.blng__Account__r.LPCR_IDSage__c,blng__Invoice__r.blng__Order__r.SBQQ__Quote__r.LPCR_SocieteFacturante__r.Name, blng__EndDate__c, blng__StartDate__c,blng__TotalAmount__c,LPCR_Creche__r.Name,blng__Quantity__c from blng__InvoiceLine__c limit 1 ];
        List<LigneFactureWrapper> lstfac=new List<LigneFactureWrapper>();
        String datedebut=System.now().format('dd-MM-YYYY');
            String datefin=System.now().format('dd-MM-YYYY');
        lstfac.add(new LigneFactureWrapper(ligneFacture.Id,
                ligneFacture.Name,    
                ligneFacture.blng__TotalAmount__c ,ligneFacture.blng__Invoice__r.blng__Order__r.SBQQ__Quote__r.LPCR_SocieteFacturante__r.Name,ligneFacture.blng__Invoice__r.blng__Account__r.LPCR_IDSage__c,ligneFacture.LPCR_Creche__r.Name,datedebut,datefin,ligneFacture.blng__Quantity__c));
        Map<String,Object> mapObjectStr=new Map<String,Object>{'TypeAvoir' => 'Avoir partiel','invoiceID'=>invoice.id,'LineList'=>lstfac,'descavoir'=>'test','avoirmontant'=>'-10','checkboxApplyAll'=>false};
Test.startTest();
            APC012_CreateAvoir.saveAvoir(JSON.serialize(mapObjectStr));
        Test.stopTest();
         
            
        APC012_CreateAvoir.getLigneFacture(invoice.id);
    }
     @isTest
    public static void testMethod3(){
           blng__Invoice__c invoice = [SELECT Id, blng__order__c FROM blng__Invoice__c LIMIT 1];
        blng__InvoiceLine__c ligneFacture=[SELECT Id,Name, LPCR_MontantAvoirLigneFacture__c,blng__Invoice__r.LPCR_SocieteFacturante__c,blng__Invoice__r.blng__Account__r.LPCR_IDSage__c,blng__Invoice__r.blng__Order__r.SBQQ__Quote__r.LPCR_SocieteFacturante__r.Name, blng__EndDate__c, blng__StartDate__c,blng__TotalAmount__c,LPCR_Creche__r.Name,blng__Quantity__c from blng__InvoiceLine__c limit 1 ];
        List<LigneFactureWrapper> lstfac=new List<LigneFactureWrapper>();
        String datedebut=System.now().format('dd-MM-YYYY');
            String datefin=System.now().format('dd-MM-YYYY');
        lstfac.add(new LigneFactureWrapper(ligneFacture.Id,
                ligneFacture.Name,    
                ligneFacture.blng__TotalAmount__c ,ligneFacture.blng__Invoice__r.blng__Order__r.SBQQ__Quote__r.LPCR_SocieteFacturante__r.Name,ligneFacture.blng__Invoice__r.blng__Account__r.LPCR_IDSage__c,ligneFacture.LPCR_Creche__r.Name,datedebut,datefin,ligneFacture.blng__Quantity__c));
        Map<String,Object> mapObjectStr=new Map<String,Object>{'TypeAvoir' => 'Avoir total','invoiceID'=>invoice.id,'LineList'=>lstfac,'descavoir'=>'test','avoirmontant'=>'-10','checkboxApplyAll'=>false};
Test.startTest();
            APC012_CreateAvoir.saveAvoir(JSON.serialize(mapObjectStr));Test.stopTest();
    }
        @isTest
    public static void testMethod4(){
           blng__Invoice__c invoice = [SELECT Id, blng__order__c FROM blng__Invoice__c LIMIT 1];
        blng__InvoiceLine__c ligneFacture=[SELECT Id,Name, LPCR_MontantAvoirLigneFacture__c,blng__Invoice__r.LPCR_SocieteFacturante__c,blng__Invoice__r.blng__Account__r.LPCR_IDSage__c,blng__Invoice__r.blng__Order__r.SBQQ__Quote__r.LPCR_SocieteFacturante__r.Name, blng__EndDate__c, blng__StartDate__c,blng__TotalAmount__c,LPCR_Creche__r.Name,blng__Quantity__c from blng__InvoiceLine__c limit 1 ];
        List<LigneFactureWrapper> lstfac=new List<LigneFactureWrapper>();
        String datedebut=System.now().format('dd-MM-YYYY');
            String datefin=System.now().format('dd-MM-YYYY');
        lstfac.add(new LigneFactureWrapper(ligneFacture.Id,
                ligneFacture.Name,    
                ligneFacture.blng__TotalAmount__c ,ligneFacture.blng__Invoice__r.blng__Order__r.SBQQ__Quote__r.LPCR_SocieteFacturante__r.Name,ligneFacture.blng__Invoice__r.blng__Account__r.LPCR_IDSage__c,ligneFacture.LPCR_Creche__r.Name,datedebut,datefin,ligneFacture.blng__Quantity__c));
        Map<String,Object> mapObjectStr=new Map<String,Object>{'TypeAvoir' => 'Avoir partiel','invoiceID'=>invoice.id,'LineList'=>lstfac,'descavoir'=>'test','avoirmontant'=>'-10','checkboxApplyAll'=>true};
Test.startTest();
            APC012_CreateAvoir.saveAvoir(JSON.serialize(mapObjectStr));Test.stopTest();
    }
    public class LigneFactureWrapper{
        private String recId;
        private String name;
        private Decimal Montant;
        private String socfac;
        private String ctNum;
        private String Creche;
        private String datedebut;
        private String datefin;
        private Decimal qty;
        

       
        LigneFactureWrapper(String recId,String name, Decimal Montant,String socfac,String ctNum,String Creche,String datedebut,String datefin,Decimal qty){
          this.recId = recId;
          this.name = name;
          this.Montant = Montant;
          this.socfac=socfac;
          this.ctNum=ctNum;
          this.Creche=Creche;
          this.datedebut=datedebut;
          this.datefin=datefin;
          this.qty=qty;

        }
    }
}