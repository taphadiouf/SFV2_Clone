/**
* @author  PDO
* @created 09/04/2021
* @description Test class for Service class Invoice Line 
*/
@isTest
public class SM028_InvoiceLineService_Test {
    private static final Id B2C_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Famille);
    private static final Id CRECHE_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Creche);
    private static final Id OPPT_FAMILE_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Opportunity, Label.LPCR_Famille);
    private static final Id QUOTE_CONTRAT_ACCUEIL_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote, Label.LPCR_ContratA);
    private static final Id standardPricebookId = Test.getStandardPricebookId();
    private static final Id CONTACT_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contact, Label.LPCR_Famille);
    
    @testSetup
    static void testSetup(){
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
        
        blng__CreditNote__c creditNote = new blng__CreditNote__c();
        creditNote.blng__Account__c = account.Id;
        creditNote.blng__Status__c = 'Draft';
        creditNote.blng__CreditNoteSourceAction__c = 'Manual';
        creditNote.blng__EffectiveTaxDate__c = date.today();
        creditNote.blng__CreditNoteDate__c = date.today();
        insert creditNote;
        
        blng__CreditNoteLine__c cnLine = new blng__CreditNoteLine__c();
        cnLine.blng__CreditNote__c = creditNote.id;
        cnLine.blng__CreditNoteLineDate__c = date.today();
        cnLine.blng__Status__c = 'Draft';
        cnLine.blng__Product__c = prod.Id;
        cnLine.blng__Subtotal__c = 200;
        
        insert cnLine;

        defaultVal = new Map<String, Object> {
            'RecordTypeId' => CRECHE_RT_ID,
                'Name' => 'Creche',
                'LPCR_TypeCreche__c' => 'MAC',
                'LPCR_Region__c' => 'Paris',
                'LPCR_TypeMensualisation__c' => 11 
                };
                    
        Account crecheAccount = (Account) UM002_TestDataFactory.createSObject('Account', defaultVal);
        crecheAccount.LPCR_TypeCreche__c = 'MICRO';
        insert crecheAccount;
        
        Id standardPricebookId = Test.getStandardPricebookId();
        
        Order order = UM002_TestDataFactory.createOrder(account.id,null,date.today(),'test','Draft','1');
        order.Pricebook2Id = standardPricebookId;
        insert order;
        
        OrderItem orderItem = UM002_TestDataFactory.createOrderProduct(priceBookEntry.id, order.Id, prod.id, 'Recurring','Monthly', 300);
        orderItem.blng__BillableUnitPrice__c=90;
        insert orderItem;
        
        Contract contract = UM002_TestDataFactory.createContract(account.Id,order.Id);
        insert contract;        
        
        List<blng__InvoiceRun__c> invoiceRunsList = UM002_TestDataFactory.createInvoiceRuns(1,'Execution de Facture',date.newInstance(System.Today().year(), 10, 02));
        insert invoiceRunsList;
        
        blng__InvoiceRun__c invoiceRun = invoiceRunsList.get(0);
        
        LPCR_ModificationEntrante__c modificationEntrante = UM002_TestDataFactory.createModificationsEntrante('EVT_NOMBRE_JOUR_CONGE',account.Id,null,contract.id,null);
        modificationEntrante.LPCR_Quantite__c = 10;
        insert modificationEntrante;
       
             
        
            
        List<blng__Invoice__c> invoicesList = UM002_TestDataFactory.createInvoices(1,account.id,invoiceRun.id,'Draft','A Envoyer' );
        insert invoicesList;
		//create utilisation summary
        defaultVal = new Map<String, Object> {
        'Name' => 'test22',
            'blng__Account__c'=>account.ID,
            'blng__Invoice__c'=>invoicesList[0].ID,
            'blng__Order__c'=>order.Id,
            'blng__OrderProduct__c'=>orderItem.Id
         };
        blng__UsageSummary__c blngUsageSummary=(blng__UsageSummary__c)UM002_TestDataFactory.createSObject('blng__UsageSummary__c', defaultVal); 
        insert blngUsageSummary;     
        System.debug('##pdo id '+blngUsageSummary.Id);
         //create utilisation 
        defaultVal = new Map<String, Object> {
        'Name' => 'test',
            'blng__Account__c '=>account.ID,
            
            'blng__MatchingId__c '=>'test',
            'blng__Order__c'=>order.Id,
            'blng__OrderProduct__c'=>orderItem.Id,
            'blng__Status__c'=>'Processed'
            
         };
         blng__Usage__c blngUsage = (blng__Usage__c) UM002_TestDataFactory.createSObject('blng__Usage__c', defaultVal);  
        insert blngUsage;
        blngUsage.blng__UsageSummary__c=blngUsageSummary.Id;
        update blngUsage;
        blng__Invoice__c invoice = invoicesList.get(0);
        blng__InvoiceLine__c  invoiceLineList = UM002_TestDataFactory.createInvoiceLine(invoice.id,orderItem.Id);
        invoiceLineList.Name=Label.LPCR_NomProduitAccueilSupp;
        invoiceLineList.blng__InvoiceLineStatus__c = 'Draft';
        invoiceLineList.blng__UnitPrice__c = 150;
        invoiceLineList.blng__Quantity__c =3;
        invoiceLineList.blng__Product__c = prod.id;
        invoiceLineList.blng__StartDate__c = System.today();
        invoiceLineList.blng__ChargeType__c = 'Recurring';
        invoiceLineList.blng__BillingFrequency__c = 'Annual';
        invoiceLineList.blng__Subtotal__c = 200;
        invoiceLineList.blng__UsageSummary__c=blngUsageSummary.id;
        insert invoiceLineList;
        
    }
    @isTest
    public static void createInvoiceLine(){
        
        Test.startTest();
        blng__InvoiceLine__c invoiceLine=[Select id from blng__InvoiceLine__c limit 1];
        
        
        Test.stopTest();
        blng__Invoice__c invoice=[Select id ,LPCR_NombreJoursUtilisation__c from blng__Invoice__c limit 1];
        
        System.assertNotEquals(invoice.LPCR_NombreJoursUtilisation__c,null,'Error nombre de jour null');
        
        
    }
}