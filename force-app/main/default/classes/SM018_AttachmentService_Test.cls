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
    private static final Id CRECHE_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Creche);

    @testSetup
    static void testSetup() {
        System.runAs(UM002_TestDataFactory.createUser()) {
            User userFamille = UM002_TestDataFactory.createServiceFamilleUser();
            User userADV = UM002_TestDataFactory.createADVUser();

            List<Account> accounts = UM002_TestDataFactory.createAccounts(2, 'testAccount');
            Account acc = accounts.get(0);
            acc.LPCR_ResponsableServiceFamille__c = userFamille.id;
            acc.LPCR_ResponsableADV__c = userADV.id;

            Account accCreche = accounts.get(1);
            accCreche.LPCR_ResponsableServiceFamille__c = userFamille.id;
            accCreche.LPCR_ResponsableADV__c = userADV.id;
            accCreche.RecordTypeId = CRECHE_RT_ID;
            accCreche.LPCR_TypeCreche__c = 'MAC';
            accCreche.LPCR_TypeMensualisation__c = 11;
            accCreche.Name = 'Creche';

            insert accounts;

            List<Opportunity> opps = UM002_TestDataFactory.createOpportunities(1, 'testOpp', 'Prospecting');
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

            Product2 prod = UM002_TestDataFactory.createFixedPriceProduct('test', billingRule.Id, revRecRule.Id, taxRule.Id);
            prod.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            prod.SBQQ__BillingFrequency__c = 'Monthly';
            prod.SBQQ__BillingType__c = 'Advance';
            prod.SBQQ__ChargeType__c = 'Recurring';
            prod.SBQQ__SubscriptionTerm__c = 12;
            prod.SBQQ__SubscriptionType__c = 'Renewable';
            insert prod;

            PricebookEntry priceBookEntry1 = UM002_TestDataFactory.createPricebookEntry(standardPricebookId, prod.Id);
            insert priceBookEntry1;

            SBQQ__Quote__c quote = quotes.get(0);
            quote.SBQQ__Primary__c=true;
            update quotes; 

            Opportunity opp = opps.get(0);
            opp.SBQQ__PrimaryQuote__c = quote.id;
            update opps;

            SBQQ__QuoteLine__c qline = UM002_TestDataFactory.createQuoteLine(prod.Id, quote.Id, priceBookEntry1.Id, 200, 1);
            qline.LPCR_Creche__c = accCreche.id;

            insert qline;

            Contract contract = UM002_TestDataFactory.createContract(acc.id, quote.id, opp.id, Date.Today().addmonths(3));
            contract.Status = 'Draft';
            insert contract;

            contract.Status = 'Activated';
            update contract;

            SBQQ.TriggerControl.disable();
            
            Order order = UM002_TestDataFactory.createOrder(acc.Id, contract.id, date.today(), 'test', 'Draft', '1');
            order.Pricebook2Id = standardPricebookId;
            order.SBQQ__Quote__c = quote.id;
            insert order;


            OrderItem orderItem = UM002_TestDataFactory.createOrderProduct(priceBookEntry1.id, order.Id, prod.id, 'Recurring', 'Monthly', 100);
            orderItem.SBQQ__QuoteLine__c = qline.id;
            orderItem.SBQQ__Activated__c = false;
            orderItem.blng__RevenueRecognitionRule__c = revRecRule.id;
            orderItem.blng__BillingRule__c = billingRule.id;
            orderItem.blng__TaxRule__c = taxRule.id;
            insert orderItem;

            orderItem.SBQQ__Activated__c = true;
            update orderItem;

            SBQQ.TriggerControl.enable();
        }
    }
    @isTest
    static void sendLPCRDocumentByCallout_Test() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MCK001_LPCRHttpCalloutMockImpl());

        Account acc = UM002_TestDataFactory.createAccounts(1, 'testAccount').get(0);
        acc.Email__c = 'test@test.com';
        insert acc;

        blng__Invoice__c invoice = new blng__Invoice__c();
        invoice.blng__Account__c = acc.Id;
        //invoice.blng__BillToContact__c = cont.id;
        invoice.blng__InvoiceDate__c = Date.today();
        invoice.blng__DueDate__c = Date.today();
        //invoice.blng__Order__c = order.id;
        invoice.blng__PaymentBatch__c = 'Batch 1';
        //invoice.CreatedById = UM002_TestDataFactory.createUser();
        invoice.LPCR_StatutFacture__c = 'Brouillon';
        insert invoice;

        List<Attachment> attachmentList = new List<Attachment>();
        Attachment attach1 = UM002_TestDataFactory.createAttachement('Attach1', 'Testing Body', invoice.Id, 'Facture');
        Attachment attach2 = UM002_TestDataFactory.createAttachement('Attach2', 'Testing Body', invoice.Id, 'Contrat');
        Attachment attach3 = UM002_TestDataFactory.createAttachement('Attach2', 'Testing Body', invoice.Id, 'Test');
        attachmentList.add(attach1);
        attachmentList.add(attach2);
        attachmentList.add(attach3);

        insert attachmentList;

        Set<String> parentIds = UM003_TypeManager.getFieldsOfListObjects(attachmentList, 'ParentId');

        Test.stopTest();
        List<LPCR_Log__c> successLogList = [SELECT Id, Name, LPCR_TargetObject__c, LPCR_Result__c FROM LPCR_Log__c WHERE LPCR_Result__c = 'Success'];
        List<LPCR_Log__c> errorLogList = [SELECT Id, Name, LPCR_TargetObject__c, LPCR_Result__c FROM LPCR_Log__c WHERE LPCR_Result__c = 'Error'];
        List<blng__Invoice__c> invoiceList = [SELECT id, blng__Account__r.Email__c, CreatedBy.Name, LPCR_StatutFacture__c FROM blng__Invoice__c WHERE id IN :parentIds];
        blng__Invoice__c invoice1 = invoiceList.get(0);
        //System.assertEquals(9, successLogList.size(), 'sendLPCRDocumentByCallout_Test success log failed');
        //System.assertEquals(0, errorLogList.size(), 'sendLPCRDocumentByCallout_Test error log failed');
        System.assertEquals('Envoyée', invoice1.LPCR_StatutFacture__c, 'update failed');
    }
    @isTest
    static void sendLPCRDocumentByCallout1_Test() {
        System.runAs(UM002_TestDataFactory.createUser()) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MCK001_LPCRHttpCalloutMockImpl());

            Product2 prod = [SELECT Id FROM Product2 WHERE Name = :'test' LIMIT 1];
            PricebookEntry pbEntry = [SELECT Id FROM PricebookEntry WHERE Product2Id = :prod.id LIMIT 1];

            Account acc = [SELECT Id, SBQQ__RenewalModel__c, RecordTypeId FROM Account WHERE Name = :'testAccount' LIMIT 1];
            acc.SBQQ__RenewalModel__c = 'Contract Based';
            acc.RecordTypeId = B2C_RT_ID;
            acc.Email__c = 'test@mail.com';
            update acc;

            Account accCreche = [SELECT Id FROM Account WHERE Name = :'Creche' LIMIT 1];

            Contact cont = UM002_TestDataFactory.createContacts(1, CONTACT_RT_ID, 'test_lastname', 'test_address').get(0);
            insert cont;

            Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE Name = :'testOpp' LIMIT 1];
            opp.AccountId = acc.id;
            update opp;

            SBQQ__Quote__c quote = [SELECT Id, SBQQ__Type__c, SBQQ__SubscriptionTerm__c, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :opp.Id LIMIT 1];
            quote.SBQQ__Type__c = 'Quote';
            quote.SBQQ__StartDate__c = System.today();
            quote.SBQQ__SubscriptionTerm__c = 12;
            quote.SBQQ__Primary__c = true;
            update quote;

            Order order = [SELECT Id FROM Order WHERE SBQQ__Quote__c =: quote.id LIMIT 1];

            // SBQQ__QuoteLine__c qline = UM002_TestDataFactory.createQuoteLine(prod.Id, quote.Id, pbEntry.Id, 200, 1);
            // qline.LPCR_Creche__c = accCreche.id;

            // insert qline;

            // Contract contract = UM002_TestDataFactory.createContract(acc.id, quote.id, opp.id, Date.Today().addmonths(3));
            // contract.Status = 'Draft';
            // insert contract;

            // contract.Status = 'Activated';
            // update contract;

            // Order order = UM002_TestDataFactory.createOrder(acc.Id, contract.id, date.today(), 'test', 'Draft', '1');
            // order.Pricebook2Id = standardPricebookId;
            // order.SBQQ__Quote__c = quote.id;
            // insert order;

            // /SBQQ.TriggerControl.disable();

            // OrderItem orderItem = UM002_TestDataFactory.createOrderProduct(pbEntry.id, order.Id, prod.id, 'Recurring', 'Monthly', 100);
            // orderItem.SBQQ__QuoteLine__c = qline.id;
            // orderItem.SBQQ__Activated__c = false;
            // orderItem.blng__RevenueRecognitionRule__c = revRecRule.id;
            // orderItem.blng__BillingRule__c = billingRule.id;
            // orderItem.blng__TaxRule__c = taxRule.id;
            // insert orderItem;

            // orderItem.SBQQ__Activated__c = true;
            // update orderItem;

            // SBQQ.TriggerControl.enable();
            order.status = 'Activated';
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

            List<Attachment> attachmentList = new List<Attachment>();
            Attachment attach1 = UM002_TestDataFactory.createAttachement('Facture Famille', 'Testing Body', invoice.Id, 'Facture');
            attachmentList.add(attach1);
            //insert attachmentList;
            Attachment attach2 = UM002_TestDataFactory.createAttachement('Contrat Famille', 'Testing Body', invoice.Id, 'Contrat');
            insert attach2;
            Test.stopTest();
        }
    }
}
