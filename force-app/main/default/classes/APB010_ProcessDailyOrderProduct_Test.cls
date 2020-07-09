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
        List<Account> accounts = UM002_TestDataFactory.createAccounts(100, 'testAccount');
        List<Opportunity> opps = UM002_TestDataFactory.createOpportunities(100, 'testOpp', 'Prospecting');
        insert accounts;
        insert opps;
        List<SBQQ__Quote__c> quotes = UM002_TestDataFactory.createQuotes(100, accounts, opps);
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
              Test.startTest();
            Product2 prod = [SELECT Id FROM Product2 WHERE Name =: 'test' LIMIT 1];
            PricebookEntry pbEntry = [SELECT Id FROM PricebookEntry WHERE Product2Id =: prod.id LIMIT 1];
            Product2 prod1 = [SELECT Id FROM Product2 WHERE Name =: 'test1' LIMIT 1];
            PricebookEntry pbEntry1 = [SELECT Id FROM PricebookEntry WHERE Product2Id =: prod1.id LIMIT 1];
            
            Account acc = [SELECT Id,SBQQ__RenewalModel__c,RecordTypeId FROM Account WHERE Name =: 'testAccount' LIMIT 1];
            acc.SBQQ__RenewalModel__c = 'Contract Based';
            acc.RecordTypeId = B2C_RT_ID;
            acc.LPCR_ResponsableServiceFamille__c = UserInfo.getUserId();
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
            qlines.add(UM002_TestDataFactory.createQuoteLine(prod1.Id, quote.Id, pbEntry1.Id, 200, 1));
            insert qlines;
            
            Contract contract = UM002_TestDataFactory.createContract(acc.id,quote.id,opp.id,Date.Today().addmonths(3));
            contract.Status = 'Draft';
            contract.LPCR_DateFin__c = Date.Today().addmonths(12);
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
            orderItem.EndDate = System.today().addMonths(10);
            orderItem.blng__NextChargeDate__c = System.today().addMonths(1);
            orderItem.SBQQ__Contract__c = contract.id;
            insert orderItem;
            
            orderItem.SBQQ__Activated__c = true;
            update orderItem;
            
            OrderItem orderItem1 = UM002_TestDataFactory.createOrderProduct(pbEntry1.id, order.Id, prod1.id, 'Recurring','Invoice Plan', 100);
            orderItem1.SBQQ__QuoteLine__c = qlines.get(1).id;
            orderItem1.SBQQ__Activated__c = false;
            orderItem1.EndDate = System.today().addMonths(10);
            orderItem1.blng__NextChargeDate__c = System.today().addMonths(1);
            orderItem1.SBQQ__Contract__c = contract.id;
            insert orderItem1;
            
            orderItem1.SBQQ__Activated__c = true;
            update orderItem1;
            
            order.status ='Activated';
            update order;
          
            blng__BillingSchedule__c billingSchedule = new blng__BillingSchedule__c();
            billingSchedule.blng__OrderProduct__c = orderItem1.id;
            billingSchedule.name = 'Test';
            billingSchedule.blng__Amount__c = 100;
            try{
                insert billingSchedule;
            }catch(Exception ex){
                PAD.log('APB010_ProcessDailyOrderProduct_Test', 'APB010_ProcessDailyOrderProduct_Test', '**** Exception : '+ ex.getMessage());
            }            
            
            blng__BillingTransaction__c billingTrans = new blng__BillingTransaction__c();
            billingTrans.blng__BillingTargetDate__c = Date.today().addDays(30);
            billingTrans.blng__BillingSchedule__c = billingSchedule.Id;
            billingTrans.Name = 'Test';
            billingTrans.blng__Amount__c = 100;
            billingTrans.blng__Status__c = 'Pending';            
            try{
                insert billingTrans;
            }catch(Exception ex){
                PAD.log('APB010_ProcessDailyOrderProduct_Test', 'APB010_ProcessDailyOrderProduct_Test', '**** Exception : '+ ex.getMessage());
            }

            APB010_ProcessDailyOrderProduct ss = new APB010_ProcessDailyOrderProduct();
            DataBase.executeBatch(ss);
            ss.execute(null);
            
            Test.stopTest();
            List<LPCR_PlanFacturation__c> billingPlanCheck = new List<LPCR_PlanFacturation__c>();
            billingPlanCheck = [select id,LPCR_OrderItem__c from LPCR_PlanFacturation__c where LPCR_OrderItem__c =: orderItem.id];
            System.assertEquals(1, billingPlanCheck.size(), 'Error in APB010_ProcessDailyOrderProduct : problem in inserting Billing Plan');
        }
    }
    
}