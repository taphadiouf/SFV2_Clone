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
        
    }
    
    @isTest
    public static void createPaymentAndPaymentAllocation_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
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
            update invoice;
            List<blng__InvoiceLine__c> listInvoiceLine = [SELECT Id,blng__Balance__c from blng__InvoiceLine__c];
            
            List<blng__Payment__c> listPayment = [SELECT Id, blng__Invoice__c FROM blng__Payment__c ];
            System.assertNotEquals(0,listPayment.size(), 'Error in SM015_InvoiceServices_Test : blng__Payment__c not created');
            
            List<blng__PaymentAllocationInvoiceLine__c> listAllocationInvoiceLine = [SELECT Id, blng__InvoiceLine__c FROM blng__PaymentAllocationInvoiceLine__c ];
            System.assertNotEquals(0,listAllocationInvoiceLine.size(), 'Error in SM015_InvoiceServices_Test : blng__PaymentAllocationInvoiceLine__c not created');
         
            Test.stopTest();
            
        }
    }
    //commented in the context IS-1422
    /*@isTest
    public static void setStatutFacture_Test(){
        
        Test.startTest();
        Opportunity opp = [SELECT Id,AccountId FROM Opportunity   LIMIT 1];
        
        Account acc = [SELECT Id,SBQQ__RenewalModel__c,RecordTypeId FROM Account   LIMIT 1];
        Contact cont = UM002_TestDataFactory.createContacts(1, CONTACT_RT_ID, 'test_lastname', 'test_address').get(0);
        insert cont;
        
        SBQQ__Quote__c quote = [SELECT Id,SBQQ__Type__c,SBQQ__SubscriptionTerm__c,SBQQ__StartDate__c FROM SBQQ__Quote__c LIMIT 1];
        quote.SBQQ__Type__c='Quote';
        quote.SBQQ__StartDate__c = System.today();
        quote.SBQQ__SubscriptionTerm__c = 12;
        quote.SBQQ__Primary__c = true;
        update quote;
        
        Contract contract = UM002_TestDataFactory.createContract(acc.id,quote.id,opp.id,Date.Today().addmonths(3));
        contract.Status = 'Draft';
        Insert contract;
        
        Order order = UM002_TestDataFactory.createOrder(acc.Id, contract.id,Date.today(),'test','Draft','1');
        order.Pricebook2Id = standardPricebookId;
        order.SBQQ__Quote__c = quote.id;
        insert order;
        
        blng__Invoice__c invoice = new blng__Invoice__c();
        invoice.blng__Account__c = acc.Id;
        invoice.blng__BillToContact__c = cont.id;
        invoice.blng__InvoiceDate__c = Date.today();
        invoice.blng__DueDate__c = Date.today();
        invoice.blng__Order__c = order.id;
        invoice.blng__PaymentBatch__c = 'Batch 1';
        insert invoice;
        
        List<blng__Invoice__c> invoicesLst = [SELECT Id,blng__InvoiceStatus__c,LPCR_StatutFacture__c FROM blng__Invoice__c];
        System.debug('invoicesLst  => ' + invoicesLst);
        for(Integer i = 0; i< invoicesLst.size(); i++){
            blng__Invoice__c eachInvoice = invoicesLst.get(i);
            eachInvoice.blng__InvoiceStatus__c = 'Posted';
        }
        update invoicesLst;
        List<blng__Invoice__c> newInvoices = [SELECT Id,blng__InvoiceStatus__c,LPCR_StatutFacture__c FROM blng__Invoice__c
                                              WHERE LPCR_StatutFacture__c = 'Prêt à valider'];
        System.assertEquals(invoicesLst.size(), newInvoices.size());
        Test.stopTest();
        
    }   */ 
}