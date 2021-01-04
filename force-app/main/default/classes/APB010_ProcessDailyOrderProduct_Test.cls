/**
* @author Saurabh
* @date 19/06/2020
* @Description Test class for APB010_ProcessDailyOrderProduct 
*/

@isTest
public class APB010_ProcessDailyOrderProduct_Test {
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
        prod.SBQQ__BillingFrequency__c = 'Quarterly';
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
        insert priceBookEntry1;
        PricebookEntry priceBookEntry2 = UM002_TestDataFactory.createPricebookEntry(standardPricebookId,prod1.Id);
        insert priceBookEntry2;
        
    }
    
    @isTest
    public static void APB010_ProcessDailyOrderProduct_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            
            Product2 prod = [SELECT Id FROM Product2 WHERE Name =: 'test' LIMIT 1];
            PricebookEntry pbEntry = [SELECT Id FROM PricebookEntry WHERE Product2Id =: prod.id LIMIT 1];
            Product2 prod1 = [SELECT Id FROM Product2 WHERE Name =: 'test1' LIMIT 1];
            PricebookEntry pbEntry1 = [SELECT Id FROM PricebookEntry WHERE Product2Id =: prod1.id LIMIT 1];
            
            Account acc = [SELECT Id,SBQQ__RenewalModel__c,RecordTypeId FROM Account WHERE Name =: 'testAccount' LIMIT 1];
            acc.SBQQ__RenewalModel__c = 'Contract Based';
            acc.RecordTypeId = B2C_RT_ID;
            acc.LPCR_ResponsableServiceFamille__c = UserInfo.getUserId();
            acc.SBQQ__RenewalPricingMethod__c = 'Uplift';
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
            quote.SBQQ__RenewalUpliftRate__c = 2;
            update quote;
            
            List<SBQQ__QuoteLine__c> qlines = new List<SBQQ__QuoteLine__c> ();
            qlines.add(UM002_TestDataFactory.createQuoteLine(prod.Id, quote.Id, pbEntry.Id, 100, 1));
            qlines.add(UM002_TestDataFactory.createQuoteLine(prod1.Id, quote.Id, pbEntry1.Id, 100, 1));
            insert qlines;
            
            Contract contract = UM002_TestDataFactory.createContract(acc.id,quote.id,opp.id,Date.Today().addmonths(36));
            contract.Status = 'Draft';
            contract.SBQQ__RenewalUpliftRate__c = 2;
            contract.LPCR_DateFin__c = Date.Today().addmonths(36);
            Insert contract;
            
            contract.Status = 'Activated';
            update contract;
            
            Test.startTest();

            Order order = UM002_TestDataFactory.createOrder(acc.Id, contract.id,date.today(),'test','Draft','1');
            order.Pricebook2Id = standardPricebookId;
            order.SBQQ__Quote__c = quote.id;
            order.type = 'New';
            insert order;
            
            //Causing error
            OrderItem orderItem = UM002_TestDataFactory.createOrderProduct(pbEntry.id, order.Id, prod.id, 'Recurring','Quarterly', 100);
            orderItem.SBQQ__QuoteLine__c = qlines.get(0).id;
            orderItem.SBQQ__Activated__c = false;
            orderItem.ServiceDate = date.today();
            orderItem.EndDate = System.today().addMonths(36);
            orderItem.blng__NextChargeDate__c = System.today();
            orderItem.SBQQ__Contract__c = contract.id;
            
            OrderItem orderItem2 = UM002_TestDataFactory.createOrderProduct(pbEntry1.id, order.Id, prod1.id, 'Recurring','Semiannual', 100);
            orderItem2.SBQQ__QuoteLine__c = qlines.get(1).id;
            orderItem2.SBQQ__Activated__c = false;
            orderItem2.ServiceDate = date.today();
            orderItem2.EndDate = System.today().addMonths(36);
            orderItem2.blng__NextChargeDate__c = System.today();
            orderItem2.SBQQ__Contract__c = contract.id;
            
            OrderItem orderItem3 = UM002_TestDataFactory.createOrderProduct(pbEntry1.id, order.Id, prod1.id, 'Recurring','Annual', 100);
            orderItem3.SBQQ__QuoteLine__c = qlines.get(1).id;
            orderItem3.SBQQ__Activated__c = false;
            orderItem3.ServiceDate = date.today();
            orderItem3.EndDate = System.today().addMonths(36);
            orderItem3.blng__NextChargeDate__c = System.today();
            orderItem3.SBQQ__Contract__c = contract.id;
            
            OrderItem orderItem1 = UM002_TestDataFactory.createOrderProduct(pbEntry1.id, order.Id, prod1.id, 'Recurring','Invoice Plan', 100);
            orderItem1.SBQQ__QuoteLine__c = qlines.get(1).id;
            orderItem1.SBQQ__Activated__c = false;
            orderItem1.ServiceDate = date.today();
            orderItem1.EndDate = System.today().addMonths(36);
            orderItem1.blng__NextChargeDate__c = System.today();
            orderItem1.SBQQ__Contract__c = contract.id;
            
            insert new List<OrderItem>{orderItem,orderItem1,orderItem2,orderItem3};

            orderItem.SBQQ__Activated__c = true;
            orderItem1.SBQQ__Activated__c = true;
            orderItem2.SBQQ__Activated__c = true;
            orderItem3.SBQQ__Activated__c = true;

            List<OrderItem> orderItems = new List<OrderItem>{orderItem,orderItem1,orderItem2,orderItem3};
            update orderItems;

            order.status ='Activated';
            update order;

            blng__InvoicePlan__c invoicePlan = new blng__InvoicePlan__c();
            invoicePlan.blng__BillingScheduleCreation__c = 'Manual';
            invoicePlan.Name = 'Test Invoice Plan';
            invoicePlan.blng__Active__c = true;
            insert invoicePlan;
            
            blng__InvoicePlanLine__c invPlanLine1 = new blng__InvoicePlanLine__c();
            invPlanLine1.blng__InvoicePlan__c = invoicePlan.id;
            invPlanLine1.blng__CommencementDateOffsetUnits__c = 'Months';
            invPlanLine1.blng__CommencementDateOffset__c = 1;
            invPlanLine1.blng__Percentage__c = 2;
            invPlanLine1.name = 'Test Invoice Plan Line';
            invPlanLine1.blng__ProcessingOrder__c = 1;
            invPlanLine1.blng__Type__c = 'Percent';
            insert invPlanLine1;
            
            order.LPCR_RenouvellementPlanFacture__c = invoicePlan.id;
            update order;


            List<blng__BillingSchedule__c> billingSchedules = new List<blng__BillingSchedule__c>();
            List<blng__BillingTransaction__c> billingTransactions = new List<blng__BillingTransaction__c>();
            for(OrderItem o : orderItems){
                blng__BillingSchedule__c billingSchedule = new blng__BillingSchedule__c();
                billingSchedule.blng__OrderProduct__c = o.id;
                billingSchedule.name = 'Test';
                billingSchedule.blng__Amount__c = 100;

                billingSchedules.add(billingSchedule);      
            }
            insert billingSchedules;

            for (blng__BillingSchedule__c sche : billingSchedules) {
                blng__BillingTransaction__c billingTrans = new blng__BillingTransaction__c();
                billingTrans.blng__BillingTargetDate__c = Date.today().addDays(30);
                billingTrans.blng__BillingSchedule__c = sche.Id;
                billingTrans.Name = 'Test';
                billingTrans.blng__Amount__c = 100;
                billingTrans.blng__Status__c = 'Pending';

                billingTransactions.add(billingTrans);          
            }
            insert billingTransactions;

            APB010_ProcessDailyOrderProduct ss = new APB010_ProcessDailyOrderProduct();
            DataBase.executeBatch(ss);
            
            Test.stopTest();


            List<LPCR_PlanFacturation__c> billingPlanCheck = new List<LPCR_PlanFacturation__c>();
            List<LPCR_PlanFacturation__c> billingPlanCheck2 = new List<LPCR_PlanFacturation__c>();
            List<LPCR_PlanFacturation__c> billingPlanCheck3 = new List<LPCR_PlanFacturation__c>();
            List<LPCR_LignePlanFacturation__c> billingPlanLineCheck = new List<LPCR_LignePlanFacturation__c>();

            billingPlanCheck = [SELECT id,LPCR_OrderItem__c FROM LPCR_PlanFacturation__c WHERE LPCR_OrderItem__c =: orderItem.id];
            billingPlanCheck2 = [SELECT id,LPCR_OrderItem__c FROM LPCR_PlanFacturation__c WHERE LPCR_OrderItem__c =: orderItem2.id];
            billingPlanCheck3 = [SELECT id,LPCR_OrderItem__c FROM LPCR_PlanFacturation__c WHERE LPCR_OrderItem__c =: orderItem3.id];

            billingPlanLineCheck = [SELECT Id, Name, LPCR_StartDate__c, LPCR_EndDate__c, LPCR_Amount__c, LPCR_PlanFacturation__c 
                                    FROM LPCR_LignePlanFacturation__c WHERE LPCR_PlanFacturation__c IN: billingPlanCheck];

            System.assertEquals(4, billingPlanCheck.size(), 'Error in APB010_ProcessDailyOrderProduct : problem in inserting Billing Plan');
            System.assertEquals(13, billingPlanLineCheck.size(), 'Error in APB010_ProcessDailyOrderProduct : problem in inserting Billing Plan Line');
            System.assertNotEquals(0, billingPlanCheck2.size());
            System.assertNotEquals(0, billingPlanCheck3.size());
        }
    }
    
}