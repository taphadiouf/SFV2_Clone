@isTest
public class APB021_ProrationForReportInvoice_Test {

    private static final Id B2C_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Famille);
    private static final Id CONTACT_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contact, Label.LPCR_Parent);
    private static final Id standardPricebookId = Test.getStandardPricebookId();

    @testSetup
    static void testSetup(){
        List<Account> accounts = UM002_TestDataFactory.createAccounts(3, 'testAccount');
        List<Opportunity> opps = UM002_TestDataFactory.createOpportunities(3, 'testOpp', 'Prospecting');
        insert accounts;
        insert opps;
        List<SBQQ__Quote__c> quotes = UM002_TestDataFactory.createQuotes(3, accounts, opps);
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
        prod.SBQQ__SubscriptionTerm__c = 1;
        prod.SBQQ__SubscriptionType__c = 'Renewable';
        insert prod;
        
        Product2 prod1 = UM002_TestDataFactory.createFixedPriceProduct('test1', billingRule.Id, revRecRule.Id,taxRule.Id );
        prod1.SBQQ__SubscriptionPricing__c ='Fixed Price';
        prod1.SBQQ__BillingFrequency__c = 'Invoice Plan';
        prod1.SBQQ__BillingType__c = 'Advance';
        prod1.SBQQ__ChargeType__c = 'Recurring';
        prod1.SBQQ__SubscriptionTerm__c = 12;
        prod1.SBQQ__SubscriptionType__c = 'Renewable';
        insert prod1;
        
        PricebookEntry priceBookEntry1 = UM002_TestDataFactory.createPricebookEntry(standardPricebookId,prod.Id);
        priceBookEntry1.UnitPrice = 0;
        insert priceBookEntry1;
        PricebookEntry priceBookEntry2 = UM002_TestDataFactory.createPricebookEntry(standardPricebookId,prod1.Id);
        insert priceBookEntry2;
        
    }

     /*
    // Reminder of APB021_ProrationForReportInvoicePlanFreq goal : 
        * Only For Invoice Plan
        * Input : blng__BillingTransaction__c with blng__BillingSchedule__r.blng__OrderProduct__c != null AND LPCR_ProcessProrate__c = false
        * Output : Populate and adjust the LPCR_Amount__c field on the Revenue Transaction accordingly to what LPCR wants
    */

    @isTest
    static void batchAPB021Test() {

        System.runAs(UM002_TestDataFactory.createUser()){
            
            
            blng__LegalEntity__c billingLegalEntity = UM002_TestDataFactory.setupLegalEntity();
            blng__RevenueRecognitionRule__c revRecRule = UM002_TestDataFactory.setupRevRec(billingLegalEntity.Id);
            blng__BillingRule__c billingRule = UM002_TestDataFactory.setupBillingRule(billingLegalEntity.Id);
            blng__TaxRule__c taxRule = UM002_TestDataFactory.setupTaxRule(billingLegalEntity.Id);
            
            Product2 prod1 = UM002_TestDataFactory.createFixedPriceProduct('test1', billingRule.Id, revRecRule.Id,taxRule.Id );
            prod1.SBQQ__SubscriptionPricing__c ='Fixed Price';
            prod1.SBQQ__BillingFrequency__c = 'Invoice Plan';
            prod1.SBQQ__BillingType__c = 'Advance';
            prod1.SBQQ__ChargeType__c = 'Recurring';
            prod1.SBQQ__SubscriptionTerm__c = 12;
            prod1.SBQQ__SubscriptionType__c = 'Renewable';
            insert prod1;

            PricebookEntry pbEntry1 = UM002_TestDataFactory.createPricebookEntry(standardPricebookId,prod1.Id);
            pbEntry1.UnitPrice = 0;
            insert pbEntry1;


            Account acc = [SELECT Id,SBQQ__RenewalModel__c,RecordTypeId FROM Account WHERE Name =: 'testAccount' LIMIT 1];
            acc.SBQQ__RenewalModel__c = 'Contract Based';
            acc.RecordTypeId = B2C_RT_ID;
            acc.LPCR_ResponsableServiceFamille__c = UserInfo.getUserId();
            acc.SBQQ__RenewalPricingMethod__c = 'List';
            update acc;
            
            Contact cont = UM002_TestDataFactory.createContacts(1, CONTACT_RT_ID, 'test_lastname', 'test_address').get(0);
            insert cont;
            
            Opportunity opp = [SELECT Id,AccountId FROM Opportunity WHERE Name =: 'testOpp' LIMIT 1];
            opp.AccountId = acc.id;
            update opp;
            
            SBQQ__Quote__c quote = [SELECT Id,SBQQ__Type__c,SBQQ__SubscriptionTerm__c,SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c =: opp.Id LIMIT 1];
            quote.SBQQ__Type__c='Quote';
            quote.SBQQ__StartDate__c = System.today();
            quote.SBQQ__SubscriptionTerm__c = 36;
            quote.SBQQ__Primary__c = true;
            update quote;
            
            List<SBQQ__QuoteLine__c> qlines = new List<SBQQ__QuoteLine__c> ();
            qlines.add(UM002_TestDataFactory.createQuoteLine(prod1.Id, quote.Id, pbEntry1.Id, 100, 1));
            insert qlines;
            
            List<Opportunity> oppList = [SELECT Id,AccountId FROM Opportunity WHERE Name =: 'testOpp' LIMIT 3];
            Opportunity opp1 = oppList.get(1);
            opp1.AccountId = acc.id;
            update opp1;
            
            Contract contract = UM002_TestDataFactory.createContract(acc.id,quote.id,opp.id,Date.Today().addmonths(36));
            contract.Status = 'Draft';
            contract.SBQQ__RenewalUpliftRate__c = 2;
            contract.LPCR_DateFin__c = Date.Today().addmonths(36);
            Insert contract;
            
            contract.Status = 'Activated';
            update contract;
            
            // create quote record
            SBQQ__Quote__c quote1 = [SELECT Id,SBQQ__Type__c,SBQQ__SubscriptionTerm__c,SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c =: opp1.Id LIMIT 1];
            quote1.SBQQ__Type__c='Amendment';
            quote1.SBQQ__StartDate__c = System.today();
            quote1.SBQQ__SubscriptionTerm__c = 36;
            quote1.SBQQ__Primary__c = true;
            quote1.SBQQ__RenewalUpliftRate__c = 2;
            quote1.SBQQ__MasterContract__c = contract.id; 
            update quote1;
            
            // create quote line record
            List<SBQQ__QuoteLine__c> qlines1 = new List<SBQQ__QuoteLine__c> ();
            qlines1.add(UM002_TestDataFactory.createQuoteLine(prod1.Id, quote1.Id, pbEntry1.Id, 100, 1));
            qlines1.add(UM002_TestDataFactory.createQuoteLine(prod1.Id, quote1.Id, pbEntry1.Id, 0, -1));
            insert qlines1;
            
            // create Contract record
            Contract contract1 = UM002_TestDataFactory.createContract(acc.id,quote1.id,opp1.id,Date.Today().addmonths(36));
            contract1.Status = 'Draft';
            contract1.SBQQ__RenewalUpliftRate__c = 2;
            contract1.LPCR_DateFin__c = Date.Today().addmonths(36);
            Insert contract1;
            
            contract1.Status = 'Activated';
            update contract1;
            
            
            Order order = UM002_TestDataFactory.createOrder(acc.Id, contract.id,date.today(),'test','Draft','1');
            order.Pricebook2Id = standardPricebookId;
            order.SBQQ__Quote__c = quote.id;
            insert order;
            
            Test.startTest();
            
            OrderItem orderItem1 = UM002_TestDataFactory.createOrderProduct(pbEntry1.id, order.Id, prod1.id, 'Recurring','Invoice Plan', 100);
            orderItem1.SBQQ__QuoteLine__c = qlines.get(0).id;
            orderItem1.SBQQ__Activated__c = false;
            orderItem1.EndDate = System.today();//.addMonths(36);
            orderItem1.SBQQ__TerminatedDate__c = System.today().addDays(-5);
            orderItem1.blng__NextChargeDate__c = System.today();
            orderItem1.SBQQ__Contract__c = contract.id;
            orderItem1.LPCR_BillingPlanProcessment__c = true;
            insert orderItem1;
            
            orderItem1.SBQQ__Activated__c = true;
            update orderItem1;
            
            order.status ='Activated';
            update order;                       
            
                       
            // Create new order with order item
            Order order1 = UM002_TestDataFactory.createOrder(acc.Id, contract1.id,date.today(),'test','Draft','1');
            order1.Pricebook2Id = standardPricebookId;
            order1.SBQQ__Quote__c = quote1.id;
            insert order1;
            
            OrderItem orderItem2 = UM002_TestDataFactory.createOrderProduct(pbEntry1.id, order1.Id, prod1.id, 'Recurring','Invoice Plan', 100);
            orderItem2.SBQQ__QuoteLine__c = qlines1.get(0).id;
            orderItem2.SBQQ__Activated__c = false;
            orderItem2.EndDate = System.today().addMonths(36);
            orderItem2.SBQQ__TerminatedDate__c = System.today().addDays(5);
            orderItem2.blng__NextChargeDate__c = null;//System.today();
            orderItem2.SBQQ__Contract__c = contract1.id;
            orderItem2.LPCR_BillingPlanProcessment__c = false;
            orderItem2.SBQQ__RevisedOrderProduct__c = orderItem1.Id;
            orderItem2.SBQQ__PricingMethod__c = 'Custom';
            orderItem2.Quantity = 1;
            insert orderItem2;
            
            orderItem2.SBQQ__Activated__c = true;
            update orderItem2;
            
            order1.status ='Activated';
            update order1;                       
            
            // Billing Schedule records
            List<blng__BillingSchedule__c> billingScheduleList = new List<blng__BillingSchedule__c>();
            
            blng__BillingSchedule__c billingSchedule = new blng__BillingSchedule__c();
            billingSchedule.blng__OrderProduct__c = orderItem1.id;
            billingSchedule.name = 'Test';
            billingSchedule.blng__Amount__c = 100;
            billingScheduleList.add(billingSchedule);
            
            blng__BillingSchedule__c billingSchedule1 = new blng__BillingSchedule__c();
            billingSchedule1.blng__OrderProduct__c = orderItem2.id;
            billingSchedule1.name = 'Test';
            billingSchedule1.blng__Amount__c = 100;
            billingScheduleList.add(billingSchedule1);
            
            try{
                insert billingScheduleList;
            }catch(Exception ex){
                PAD.log('APB021_ProrationForReportInvoice_Test', 'billingPlanLinesForInvoicePlan_Test', '**** Exception : '+ ex.getMessage());
            }            
            
            // Billing Transaction records
            List<blng__BillingTransaction__c> billingTransList = new List<blng__BillingTransaction__c>();
            
            blng__BillingTransaction__c billingTrans = new blng__BillingTransaction__c();
            billingTrans.blng__BillingTargetDate__c = Date.today().addDays(30);
            billingTrans.blng__BillingSchedule__c = billingSchedule.Id;
            billingTrans.Name = 'Test';
            billingTrans.blng__Amount__c = 100;
            billingTrans.blng__Status__c = 'Pending'; 
            billingTrans.LPCR_ProcessProrate__c = false;
            billingTransList.add(billingTrans);
            
            blng__BillingTransaction__c billingTrans1 = new blng__BillingTransaction__c();
            billingTrans1.blng__BillingTargetDate__c = Date.today().addDays(30);
            billingTrans1.blng__BillingSchedule__c = billingSchedule1.Id;
            billingTrans1.Name = 'Test';
            billingTrans1.blng__Amount__c = 100;
            billingTrans1.blng__Status__c = 'Pending'; 
            billingTrans1.LPCR_ProcessProrate__c = false;
            billingTransList.add(billingTrans1);
            
            try{
                insert billingTransList;
            }catch(Exception ex){
                PAD.log('APB021_ProrationForReportInvoice_Test', 'billingPlanLinesForInvoicePlan_Test', '**** Exception : '+ ex.getMessage());
            }
            
            // call batch class
            APB021_ProrationForReportInvoicePlanFreq ss = new APB021_ProrationForReportInvoicePlanFreq();
            DataBase.executeBatch(ss);
            Test.stopTest();
            ss.execute(null);

            // SOQL CHECK
            // ASSERT
        }

    }
}
