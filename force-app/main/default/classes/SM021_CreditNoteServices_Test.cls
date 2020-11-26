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
    
    
    @isTest
    private static void setContractFieldsTest(){        
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();  
            Map<String, Object> defaultVal = new Map<String, Object> {
                'RecordTypeId' => B2B_RT_ID,
                    'Name' => 'Test-B2B',
                    'LPCR_PasDeSIRET__c' => true,
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
        
        UM002_TestDataFactory.insertBillingCustomSettings();
        blng__LegalEntity__c billingLegalEntity = UM002_TestDataFactory.setupLegalEntity();
        blng__RevenueRecognitionRule__c revRecRule = UM002_TestDataFactory.setupRevRec(billingLegalEntity.Id);
        blng__BillingRule__c billingRule = UM002_TestDataFactory.setupBillingRule(billingLegalEntity.Id);
        blng__TaxRule__c taxRule = UM002_TestDataFactory.setupTaxRule(billingLegalEntity.Id);
        taxRule.blng__TaxableYesNo__c = 'No';
        update taxRule;
        
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
                'SBQQ__SubscriptionType__c' => 'Renewable',
                'SBQQ__BillingType__c' => 'Advance',
                'SBQQ__ChargeType__c' => 'Recurring',
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
        
        List<OrderItem> orderItems = [SELECT Id,SBQQ__DefaultSubscriptionTerm__c  FROM OrderItem WHERE OrderID = :order.Id];
        
        Test.startTest();
        
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
        
        Contact cont = UM002_TestDataFactory.createContacts(1, CONTACT_RT_ID, 'test_lastname', 'test_address').get(0);
        insert cont;
        
        // create billing invoice
        blng__Invoice__c invoice = new blng__Invoice__c();
        invoice.blng__Account__c = account.Id;
        invoice.blng__BillToContact__c = cont.id;
        invoice.blng__InvoiceDate__c = Date.today();
        invoice.blng__DueDate__c = Date.today();
        invoice.blng__Order__c = order.id;
        invoice.blng__PaymentBatch__c = 'Batch 1';
        insert invoice;
        
        // create billing invoice line
        blng__InvoiceLine__c binLine = new blng__InvoiceLine__c();
        binLine.blng__Invoice__c = invoice.id;
        binLine.blng__ChargeType__c = 'Recurring';
        binLine.blng__BillingFrequency__c = 'Monthly';
        binLine.blng__UnitPrice__c = 10;
        binLine.blng__Quantity__c =1;
        binLine.blng__StartDate__c = System.today();
        binLine.blng__OrderProduct__c = orderItem.id;
        binLine.blng__InvoiceLineStatus__c = 'Posted';
        binLine.blng__Product__c = prod.id;
        binLine.blng__Subtotal__c = 10;
        
        insert binLine;
        
        invoice.blng__InvoiceStatus__c = 'Posted';
        update invoice;
        
        // create Finance Book
        blng__FinanceBook__c financeBook = new blng__FinanceBook__c();
        financeBook.Name = 'Test Book';
        financeBook.blng__Active__c = true;
        financeBook.blng__FinancePeriodDuration__c = 'Monthly';
        financeBook.blng__PeriodType__c = 'Revenue';            
        insert financeBook;
        
        List<blng__InvoiceLine__c> listInvoiceLine = [SELECT Id,blng__Balance__c from blng__InvoiceLine__c];
        
        //Insert Credit Note
        blng__CreditNote__c creditNote = new blng__CreditNote__c();
        creditNote.blng__Account__c = account.id;
        creditNote.blng__Status__c = 'Draft';
        creditNote.blng__CreditNoteSourceAction__c = 'Negative Lines Conversion';
        creditNote.blng__EffectiveTaxDate__c = System.today();
        creditNote.blng__CreditNoteDate__c = date.today();
        creditNote.blng__RelatedInvoice__c = invoice.id;    
        
        insert creditNote;
        
        // Insert CreditNoteLine1
        blng__CreditNoteLine__c cnLine = new blng__CreditNoteLine__c();
        cnLine.blng__CreditNote__c = creditNote.id;
        cnLine.blng__Status__c = 'Draft';
        cnLine.blng__Product__c = prod.Id;
        cnLine.blng__Subtotal__c = 5;
        cnLine.blng__TotalAmount__c = 5;
        cnLine.blng__BillingFinanceBook__c = financeBook.id;
        cnLine.blng__LegalEntity__c = billingLegalEntity.id;
        cnLine.blng__BillingRule__c = billingRule.id;
        cnLine.blng__TaxRule__c = taxRule.id;
        cnLine.blng__CalculateTax__c = false;       
        insert cnLine;
        
        // Insert CreditNoteLine2
        blng__CreditNoteLine__c cnLine1 = new blng__CreditNoteLine__c();
        cnLine1.blng__CreditNote__c = creditNote.id;
        cnLine1.blng__Status__c = 'Draft';
        cnLine1.blng__Product__c = prod.Id;
        cnLine1.blng__Subtotal__c = 10;
        cnLine1.blng__TotalAmount__c = 10;
        cnLine1.blng__BillingFinanceBook__c = financeBook.id;
        cnLine1.blng__LegalEntity__c = billingLegalEntity.id;
        cnLine1.blng__BillingRule__c = billingRule.id;
        cnLine1.blng__TaxRule__c = taxRule.id;
        cnLine1.blng__CalculateTax__c = false;       
        insert cnLine1;
        
        creditNote.blng__Status__c = 'Posted';
        
        try{
            update creditNote;
        }catch(Exception ex){
            System.debug('SM021_CreditNoteServices_Test : Exception: '+ ex.getMessage()); 
        }
        
        Test.stopTest();
        
        List<blng__CreditNoteAllocation__c> cnAllocationList = [select id from blng__CreditNoteAllocation__c];
        System.assertEquals(2, cnAllocationList.size(),'SM021_CreditNoteServices_Test : CreditNoteAllocation record not created. ');
        
    }   
}