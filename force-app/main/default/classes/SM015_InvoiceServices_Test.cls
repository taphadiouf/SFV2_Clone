/**
* @author Saurabh
* @date 19/05/2020
* @description Test class for Service class LPCR_ModificationEntrante__c
*/
@isTest
public class SM015_InvoiceServices_Test {
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
    
    }
    
    @isTest
    public static void createPaymentAndPaymentAllocation_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            
            Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
            PricebookEntry pbEntry = [SELECT Id FROM PricebookEntry WHERE Product2Id =: prod.id LIMIT 1];
            
            SBQQ__Quote__c  quote = [SELECT Id,SBQQ__Ordered__c From SBQQ__Quote__c LIMIT 1];
            SBQQ__QuoteLine__c quoteLine = [SELECT Id From SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quote.Id];
            Test.startTest();
            quote.SBQQ__Ordered__c  = true;     
            update quote; 
            
            
            
            Order order = Database.query('SELECT Id , Status FROM Order WHERE SBQQ__Quote__c  = \''+quote.Id+'\'');            
            List<OrderItem> orderItems = [SELECT Id,SBQQ__DefaultSubscriptionTerm__c  FROM OrderItem WHERE OrderID = :order.Id];
            for(OrderItem eachOrderItem : orderItems){
                eachOrderItem.SBQQ__DefaultSubscriptionTerm__c=1;
                eachOrderItem.blng__LegalEntity__c=UM002_TestDataFactory.setupLegalEntity().Id;
            }
            update orderItems;
            order.Status='Activated';
            update order;
            
            order.SBQQ__Contracted__c =true;
            update order;
            order.blng__BillNow__c=true;
            update order;
            
            blng__Invoice__c invoice = [SELECT Id, blng__order__c FROM blng__Invoice__c WHERE blng__order__c = :order.Id LIMIT 1];
            invoice.LPCR_StatutPaiement__c = true;
            update invoice;
            List<blng__InvoiceLine__c> listInvoiceLine = [SELECT Id,blng__Balance__c from blng__InvoiceLine__c];
 
            Test.stopTest();

            List<blng__Payment__c> listPayment = [SELECT Id, blng__Invoice__c FROM blng__Payment__c ];
            System.assertNotEquals(0,listPayment.size(), 'Error in SM015_InvoiceServices_Test : blng__Payment__c not created');
            
            List<blng__PaymentAllocationInvoiceLine__c> listAllocationInvoiceLine = [SELECT Id, blng__InvoiceLine__c FROM blng__PaymentAllocationInvoiceLine__c ];
            System.assertNotEquals(0,listAllocationInvoiceLine.size(), 'Error in SM015_InvoiceServices_Test : blng__PaymentAllocationInvoiceLine__c not created');
            
            
        }
    }

    @isTest
    public static void setCongePrisPeriode_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            Account account = [Select Id, Name, RecordTypeId From Account where Name ='Test-B2C' AND RecordTypeId =: B2C_RT_ID LIMIT 1 ];
            LPCR_ModificationEntrante__c modificationEntrante = [Select Id, LPCR_Quantite__c, LPCR_Contract__c From LPCR_ModificationEntrante__c].get(0);
            blng__Invoice__c invoiceList = [Select Id,LPCR_CongesPrisPeriode__c,blng__Account__r.recordTypeId,LPCR_StatutFacture__c from blng__Invoice__c WHERE blng__Account__c =: account.id];
            invoiceList.LPCR_Commentaire__c   ='test' ;            
            update invoiceList;
            blng__Invoice__c updatedInvoiceList = [Select Id,LPCR_CongesPrisPeriode__c from blng__Invoice__c WHERE LPCR_Commentaire__c ='test' LIMIT 1];
            Decimal updatedInvoice = updatedInvoiceList.LPCR_CongesPrisPeriode__c;
            system.assertEquals(modificationEntrante.LPCR_Quantite__c, updatedInvoice,'Error');
            Test.stopTest();
            
        }
    }
    
    @isTest
    public static void setFieldsOnInvoicee_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            Account creche = [Select Id from Account Where recordTypeId =: CRECHE_RT_ID Limit 1];
            
            Contact cont = UM002_TestDataFactory.createContacts(1, CONTACT_RT_ID, 'test_lastname', 'test_address').get(0);
            insert cont;
            
            Order order = [Select Id,LPCR_ContactEnfant__c,LPCR_Creche__c From Order Limit 1];
            order.LPCR_ContactEnfant__c = cont.Id;
            order.LPCR_Creche__c = creche.id;
            Update Order;
            
            blng__Invoice__c invoice = [Select Id,LPCR_Commentaire__c from blng__Invoice__c Limit 1];

            invoice.LPCR_Commentaire__c   ='test' ;            
            update invoice;
           
            blng__Invoice__c updatedInvoiceList = [Select Id,LPCR_ContactEnfant__c,LPCR_Creche__c from blng__Invoice__c Limit 1];
            system.assertEquals(cont.id, updatedInvoiceList.LPCR_ContactEnfant__c,'Error');
            system.assertEquals(creche.id, updatedInvoiceList.LPCR_Creche__c,'Error');
            Test.stopTest();           
        }
    }
    
    @isTest
    public static void afterUpdateCreateCreditNoteAllocation_Test(){

        User user = UM002_TestDataFactory.createUser();

        System.runAs(user){
            
            Account acc = [SELECT Id,SBQQ__RenewalModel__c,RecordTypeId FROM Account   LIMIT 1];
            
            Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
            PricebookEntry pbEntry = [SELECT Id FROM PricebookEntry WHERE Product2Id =: prod.id LIMIT 1];
            
            SBQQ__Quote__c  quote = [SELECT Id,SBQQ__Ordered__c,SBQQ__Account__c,SBQQ__Opportunity2__c From SBQQ__Quote__c LIMIT 1];
            SBQQ__QuoteLine__c quoteLine = [SELECT Id From SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quote.Id];
            Test.startTest();
            quote.SBQQ__Ordered__c  = true;     
            update quote; 
            
           
            
            Order order = [SELECT Id , Status FROM Order WHERE SBQQ__Quote__c  =: quote.Id LIMIT 1];            
            List<OrderItem> orderItems = [SELECT Id,SBQQ__DefaultSubscriptionTerm__c  FROM OrderItem WHERE OrderID = :order.Id];
            
            for(OrderItem eachOrderItem : orderItems){
                eachOrderItem.SBQQ__DefaultSubscriptionTerm__c=1;
                eachOrderItem.blng__LegalEntity__c=UM002_TestDataFactory.setupLegalEntity().Id;
            }
            
            update orderItems;
            order.Status='Activated';
            update order;           
            
            Contract contract = UM002_TestDataFactory.createContract(quote.SBQQ__Account__c,order.Id);
            insert contract;
            
            LPCR_ModificationEntrante__c modificationEntrante = UM002_TestDataFactory.createModificationsEntrante('EVT_NOMBRE_JOUR_CONGE',quote.SBQQ__Account__c,null,contract.id,null);
            modificationEntrante.LPCR_Quantite__c = 10;
            insert modificationEntrante;
            
            List<blng__InvoiceRun__c> invoiceRunsList = UM002_TestDataFactory.createInvoiceRuns(1,'Execution de Facture',date.newInstance(System.Today().year(), 10, 02));
            insert invoiceRunsList;
            
            blng__InvoiceRun__c invoiceRun = invoiceRunsList.get(0);
            
            List<blng__Invoice__c> invoicesList = UM002_TestDataFactory.createInvoices(1,quote.SBQQ__Account__c,invoiceRun.id,'Draft','A Envoyer' );
            insert invoicesList;
            
            blng__Invoice__c invoice = invoicesList.get(0);           
            
            blng__InvoiceLine__c invoiceLineList = UM002_TestDataFactory.createInvoiceLine(invoice.id,orderItems.get(0).Id);
            invoiceLineList.blng__InvoiceLineStatus__c = 'Draft';
            invoiceLineList.blng__UnitPrice__c = 150;
            invoiceLineList.blng__Quantity__c =3;
            invoiceLineList.blng__Product__c = prod.id;
            invoiceLineList.blng__StartDate__c = System.today();
            invoiceLineList.blng__ChargeType__c = 'Recurring';
            invoiceLineList.blng__BillingFrequency__c = 'Annual';
            invoiceLineList.blng__Subtotal__c = 200;
            insert invoiceLineList;  
            
            invoice.blng__InvoiceStatus__c = 'Posted';
            update invoice;
            blng__CreditNote__c cn = [select id,blng__Account__c,blng__Status__c,blng__TaxErrorMessage__c from blng__CreditNote__c limit 1];
            cn.blng__Status__c = 'Posted';
            Update cn;
            
            Test.stopTest();
            blng__CreditNote__c postedCN = [select id,blng__Account__c,blng__Status__c,blng__TaxErrorMessage__c from blng__CreditNote__c limit 1];
            blng__Invoice__c postedInvoice = [select id,blng__InvoiceStatus__c from blng__Invoice__c where id =: invoice.id limit 1];
            System.assertEquals('Posted', postedCN.blng__Status__c,'SM015_InvoiceServices_Test : Credit Note not posted.');
            System.assertEquals('Posted', postedInvoice.blng__InvoiceStatus__c,'SM015_InvoiceServices_Test : Invoice not posted.');
        }
    }
    
}