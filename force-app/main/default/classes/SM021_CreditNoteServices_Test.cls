/**
* @author Ayoub Ouarti
* @created 15/07/2020
* @description Test class for SM021_CreditNoteServices 
*/
@isTest
public class SM021_CreditNoteServices_Test {
    private static final Id B2B_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Entreprise);
    
    private static final Id B2C_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Famille);
    private static final Id CRECHE_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Creche);
    private static final Id OPPT_FAMILE_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Opportunity, Label.LPCR_Famille);
    private static final Id QUOTE_CONTRAT_ACCUEIL_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote, Label.LPCR_ContratA);
    private static final Id standardPricebookId = Test.getStandardPricebookId();
    private static final Id CONTACT_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contact, Label.LPCR_Famille);
    private static final Id COMPTE_Famille = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Famille);
    
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
        insert account;
        
        defaultVal = new Map<String, Object> {
            'Name' => 'prod-test',
                'isActive' => true,
                'blng__BillingRule__c' => billingRule.Id,
                'blng__RevenueRecognitionRule__c' => revRecRule.Id,
                'blng__TaxRule__c' => taxRule.Id,
                'SBQQ__SubscriptionPricing__c' => 'Fixed Price',
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
        // Forced to update to bypass validation rule. This didn't work in the method above
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
        
        Map<String, Object> defaultVals = new Map<String, Object> {
            'RecordTypeId' => COMPTE_Famille,
                'Name' => 'Test-B2C',
                'SBQQ__RenewalModel__c' => 'Contract Based'
                };
                    Account accountFamille =(Account) UM002_TestDataFactory.createSObject('Account', defaultVals);
        insert accountFamille;
        
        
        
        Id standardPricebookId = Test.getStandardPricebookId();
        
        Order order = UM002_TestDataFactory.createOrder(accountFamille.id,null,date.today(),'test','Draft','1');
        order.Pricebook2Id = standardPricebookId;
        order.EndDate = date.today().addDays(60);
        insert order;
        
        OrderItem orderItem = UM002_TestDataFactory.createOrderProduct(priceBookEntry.id, order.Id, prod.id, 'Recurring','Monthly', 100);
        insert orderItem;
        
        Contract contract = UM002_TestDataFactory.createContract(accountFamille.Id,order.Id);
        insert contract;
        
        
        
        List<blng__InvoiceRun__c> invoiceRunsList = UM002_TestDataFactory.createInvoiceRuns(1,'Execution de Facture',date.newInstance(System.Today().year(), 10, 02));
        insert invoiceRunsList;
        
        blng__InvoiceRun__c invoiceRun = invoiceRunsList.get(0);
        
        
        LPCR_ModificationEntrante__c modificationEntrante = UM002_TestDataFactory.createModificationsEntrante('Conges_Pris_Periode',accountFamille.Id,null,contract.id,null);
        modificationEntrante.LPCR_Quantite__c = 10;
        insert modificationEntrante;
        
        List<blng__Invoice__c> invoicesList = UM002_TestDataFactory.createInvoices(1,accountFamille.id,invoiceRun.id,'Posted','A Envoyer' );
        system.debug('invoicesListaaaa'+invoicesList);
        insert invoicesList;
        
        blng__Invoice__c invoice = invoicesList.get(0);
        
        
        blng__InvoiceLine__c invoiceLineList = UM002_TestDataFactory.createInvoiceLine(invoice.id,orderItem.Id);
        invoiceLineList.blng__InvoiceLineStatus__c = 'Posted';
        invoiceLineList.blng__UnitPrice__c = 100;
        invoiceLineList.blng__Quantity__c =3;
        invoiceLineList.blng__Product__c = prod.id;
        invoiceLineList.blng__StartDate__c = System.today();
        invoiceLineList.blng__ChargeType__c = 'Recurring';
        invoiceLineList.blng__BillingFrequency__c = 'Monthly';
        invoiceLineList.blng__NegativeLineConversion__c = 10;
        insert invoiceLineList;
               
    }
    
    @isTest
    private static void setContractFieldsTest(){        
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();  
            Map<String, Object> defaultVal = new Map<String, Object> {
                'RecordTypeId' => B2B_RT_ID,
                    'Name' => 'Test-B2B',
                    'SBQQ__RenewalModel__c' => 'Contract Based'
                    };
                        Account b2bAccount = (Account) UM002_TestDataFactory.createSObject('Account', defaultVal);
            insert b2bAccount;
            
            defaultVal = new Map<String, Object> {
                'blng__Account__c' => b2bAccount.Id};
                    blng__CreditNote__c b2bCreditNote = (blng__CreditNote__c) UM002_TestDataFactory.createSObject('blng__CreditNote__c', defaultVal);
            insert b2bCreditNote;
            
            Test.stopTest();
            b2bAccount = [SELECT Id,LPCR_ProcessRevenuCascade__c from Account where name ='Test-B2B' ];
            
            System.assertEquals(true, b2bAccount.LPCR_ProcessRevenuCascade__c ,'Account.LPCR_ProcessRevenuCascade__c is false');
            
            
        }
    }
    
    @isTest
    public static void afterUpdateCreateCreditNoteAllocation_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            
            Account acc = [SELECT Id,SBQQ__RenewalModel__c,RecordTypeId FROM Account   LIMIT 1];
            
            Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
            PricebookEntry pbEntry = [SELECT Id FROM PricebookEntry WHERE Product2Id =: prod.id LIMIT 1];
            
            SBQQ__Quote__c  quote = [SELECT Id,SBQQ__Ordered__c From SBQQ__Quote__c LIMIT 1];
            SBQQ__QuoteLine__c quoteLine = [SELECT Id From SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quote.Id];
            
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
            invoice.blng__InvoiceStatus__c = 'Posted';
            update invoice;
            
            List<blng__InvoiceLine__c> listInvoiceLine = [SELECT Id,blng__Balance__c from blng__InvoiceLine__c];
            
            blng__CreditNote__c creditNote = new blng__CreditNote__c();
            creditNote.blng__Account__c = acc.id;
            creditNote.blng__Status__c = 'Draft';
            creditNote.blng__CreditNoteSourceAction__c = 'Negative Lines Conversion';
            creditNote.blng__EffectiveTaxDate__c = System.today();
            creditNote.blng__CreditNoteDate__c = date.today();
            creditNote.blng__RelatedInvoice__c = invoice.id;       
            insert creditNote;
            
            blng__CreditNoteLine__c cnLine = new blng__CreditNoteLine__c();
            cnLine.blng__CreditNote__c = creditNote.id;
            cnLine.blng__Status__c = 'Draft';
            cnLine.blng__InvoiceLine__c = listInvoiceLine.get(0).Id;
            cnLine.blng__Product__c = prod.Id;
            cnLine.blng__Subtotal__c = 100;
            
            insert cnLine;
            
            cnLine.blng__Status__c = 'Posted';
            update cnLine;
                        
            creditNote.blng__Status__c = 'Posted';
            update creditNote;
                                    
            Test.stopTest();
            
            List<blng__CreditNoteAllocation__c> cnAllocationList = [select id from blng__CreditNoteAllocation__c];
            System.assertEquals(0, cnAllocationList.size(),'SM021_CreditNoteServices_Test : CreditNoteAllocation record not created. ');
        }
    }
    
    
}