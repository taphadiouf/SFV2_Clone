/**
* @author Saurabh
* @date 30/06/2020
* @description Test class for SM018_AttachmentService
*/
@isTest
public class SM018_AttachmentService_Test {
    private static final Id B2C_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Famille);
    private static final Id CONTACT_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contact, Label.LPCR_Famille);
    private static final Id standardPricebookId = Test.getStandardPricebookId();
    
    @testSetup
    static void testSetup(){
        
        List<Account> accounts = UM002_TestDataFactory.createAccounts(1, 'testAccount');
        List<Opportunity> opps = UM002_TestDataFactory.createOpportunities(1, 'testOpp', 'Prospecting');
        insert accounts;
        insert opps;
        List<SBQQ__Quote__c> quotes = UM002_TestDataFactory.createQuotes(1, accounts, opps);
        quotes.get(0).SBQQ__StartDate__c = date.today();
        insert quotes;
        
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
    static void sendLPCRDocumentByCallout_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            
            Test.setMock(HttpCalloutMock.class, new MCK001_LPCRHttpCalloutMockImpl());
            
            Account acc = UM002_TestDataFactory.createAccounts(1, 'testAccount').get(0);
            insert acc;
            
            
            blng__Invoice__c invoice = new blng__Invoice__c();
            invoice.blng__Account__c = acc.Id;
            //invoice.blng__BillToContact__c = cont.id;
            invoice.blng__InvoiceDate__c = Date.today();
            invoice.blng__DueDate__c = Date.today();
            //invoice.blng__Order__c = order.id;
            invoice.blng__PaymentBatch__c = 'Batch 1';
            //invoice.CreatedById = UM002_TestDataFactory.createUser();
            insert invoice;
            
            List<Attachment> attachmentList = new List<Attachment>();
            Attachment attach1 = UM002_TestDataFactory.createAttachement('Attach1', 'Testing Body', invoice.Id, 'Facture');
            Attachment attach2 = UM002_TestDataFactory.createAttachement('Attach2', 'Testing Body', invoice.Id, 'Contrat');
            Attachment attach3 = UM002_TestDataFactory.createAttachement('Attach2', 'Testing Body', invoice.Id, 'Test');
            attachmentList.add(attach1);
            attachmentList.add(attach2);
            attachmentList.add(attach3);
            
            insert attachmentList;
            
            Test.stopTest();
            List<LPCR_Log__c> successLogList = [SELECT Id, Name, LPCR_TargetObject__c, LPCR_Result__c FROM LPCR_Log__c WHERE LPCR_Result__c = 'Success'];
            List<LPCR_Log__c> errorLogList = [SELECT Id, Name, LPCR_TargetObject__c, LPCR_Result__c FROM LPCR_Log__c WHERE LPCR_Result__c = 'Error'];
            
            System.assertEquals(3, successLogList.size(), 'sendLPCRDocumentByCallout_Test success log failed');
            System.assertEquals(0, errorLogList.size(), 'sendLPCRDocumentByCallout_Test error log failed');
        }
    }
    @isTest
    static void sendLPCRDocumentByCallout1_Test(){
        Test.setMock(HttpCalloutMock.class, new MCK001_LPCRHttpCalloutMockImpl());
        
        Product2 prod = [SELECT Id FROM Product2 WHERE Name =: 'test' LIMIT 1];
        PricebookEntry pbEntry = [SELECT Id FROM PricebookEntry WHERE Product2Id =: prod.id LIMIT 1];
        
        Account acc = [SELECT Id,SBQQ__RenewalModel__c,RecordTypeId FROM Account WHERE Name =: 'testAccount' LIMIT 1];
        acc.SBQQ__RenewalModel__c = 'Contract Based';
        acc.RecordTypeId = B2C_RT_ID;
        acc.LPCR_ResponsableServiceFamille__c = UserInfo.getUserId();
        acc.Email__c = 'test@mail.com';
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
        update quote;
        
        List<SBQQ__QuoteLine__c> qlines = new List<SBQQ__QuoteLine__c> ();
        qlines.add(UM002_TestDataFactory.createQuoteLine(prod.Id, quote.Id, pbEntry.Id, 200, 1));
        insert qlines;
        
        Contract contract = UM002_TestDataFactory.createContract(acc.id,quote.id,opp.id,Date.Today().addmonths(3));
        contract.Status = 'Draft';
        Insert contract;
        
        contract.Status = 'Activated';
        update contract;
        
        Order order = UM002_TestDataFactory.createOrder(acc.Id, contract.id,date.today(),'test','Draft','1');
        order.Pricebook2Id = standardPricebookId;
        order.SBQQ__Quote__c = quote.id;
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
        
        blng__Invoice__c invoice = new blng__Invoice__c();
        invoice.blng__Account__c = acc.Id;
        invoice.blng__BillToContact__c = cont.id;
        invoice.blng__InvoiceDate__c = Date.today();
        invoice.blng__DueDate__c = Date.today();
        invoice.blng__Order__c = order.id;
        invoice.blng__PaymentBatch__c = 'Batch 1';
        insert invoice;
        
        Test.startTest();
        List<Attachment> attachmentList = new List<Attachment>();
        Attachment attach1 = UM002_TestDataFactory.createAttachement('Facture Famille', 'Testing Body', invoice.Id, 'Facture');
        attachmentList.add(attach1);
        insert attachmentList;
        
        Test.stopTest();
        
    }
}