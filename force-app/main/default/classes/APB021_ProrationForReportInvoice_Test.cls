/**
 * @description       :
 * @author            : Widaad Papauretty
 * @group             :
 * @last modified on  : 11-17-2021
 * @last modified by  : Widaad Papauretty
 **/
@isTest
public class APB021_ProrationForReportInvoice_Test {
    private static final Id B2C_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Famille);
    private static final Id CONTACT_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contact, Label.LPCR_Parent);
    private static final Id standardPricebookId = Test.getStandardPricebookId();
    private static final Id CRECHE_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Creche);

    @testSetup
    static void testSetup() {
        System.runAs(UM002_TestDataFactory.createUser()) {
            User userFamille = UM002_TestDataFactory.createServiceFamilleUser();
            User userADV = UM002_TestDataFactory.createADVUser();

            List<Account> accounts = UM002_TestDataFactory.createAccounts(3, 'testAccount');
            List<Opportunity> opps = UM002_TestDataFactory.createOpportunities(3, 'testOpp', 'Prospecting');

            accounts.get(0).LPCR_ResponsableServiceFamille__c = userFamille.id;
            accounts.get(0).LPCR_ResponsableADV__c = userADV.id;

            accounts.get(1).LPCR_ResponsableServiceFamille__c = userFamille.id;
            accounts.get(1).LPCR_ResponsableADV__c = userADV.id;
            accounts.get(1).RecordTypeId = CRECHE_RT_ID;
            accounts.get(1).Name = 'Creche';
            accounts.get(1).LPCR_TypeMensualisation__c = 11;
            accounts.get(1).LPCR_TypeCreche__c = 'MAC';

            insert accounts;

            opps.get(0).AccountId = accounts.get(0).id;
            //opps.get(1).AccountId =  accounts.get(0).id;
            insert opps;

            List<SBQQ__Quote__c> quotes = UM002_TestDataFactory.createQuotes(3, accounts, opps);
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
            prod.SBQQ__SubscriptionTerm__c = 1;
            prod.SBQQ__SubscriptionType__c = 'Renewable';

            Product2 prod1 = UM002_TestDataFactory.createFixedPriceProduct('test1', billingRule.Id, revRecRule.Id, taxRule.Id);
            prod1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            prod1.SBQQ__BillingFrequency__c = 'Invoice Plan';
            prod1.SBQQ__BillingType__c = 'Advance';
            prod1.SBQQ__ChargeType__c = 'Recurring';
            prod1.SBQQ__SubscriptionTerm__c = 12;
            prod1.SBQQ__SubscriptionType__c = 'Renewable';

            insert new List<Product2>{ prod, prod1 };
        }
    }

    /*
    // Reminder of APB021_ProrationForReportInvoicePlanFreq goal : 
        * Only For Invoice Plan
        * Input : blng__BillingTransaction__c with blng__BillingSchedule__r.blng__OrderProduct__c != null AND LPCR_ProcessProrate__c = false
        * Output : Populate and adjust the LPCR_Amount__c field on the Revenue Transaction accordingly to what LPCR wants
    */

    @isTest
    static void batchAPB021Test() {
        System.runAs(UM002_TestDataFactory.createUser()) {
            Test.startTest();
            blng__LegalEntity__c billingLegalEntity = UM002_TestDataFactory.setupLegalEntity();
            blng__RevenueRecognitionRule__c revRecRule = UM002_TestDataFactory.setupRevRec(billingLegalEntity.Id);
            blng__BillingRule__c billingRule = UM002_TestDataFactory.setupBillingRule(billingLegalEntity.Id);
            blng__TaxRule__c taxRule = UM002_TestDataFactory.setupTaxRule(billingLegalEntity.Id);

            Product2 prod1 = [SELECT Id FROM Product2 WHERE Name = :'test1' LIMIT 1];

            PricebookEntry pbEntry1 = UM002_TestDataFactory.createPricebookEntry(standardPricebookId, prod1.Id);
            pbEntry1.UnitPrice = 0;
            insert pbEntry1;

            Account acc = [SELECT Id, SBQQ__RenewalModel__c, RecordTypeId FROM Account WHERE Name = :'testAccount' LIMIT 1];
            acc.SBQQ__RenewalModel__c = 'Contract Based';
            acc.RecordTypeId = B2C_RT_ID;
            acc.SBQQ__RenewalPricingMethod__c = 'List';
            update acc;

            Account accCreche = [SELECT Id FROM Account WHERE Name = 'Creche' LIMIT 1];

            Contact cont = UM002_TestDataFactory.createContacts(1, CONTACT_RT_ID, 'test_lastname', 'test_address').get(0);
            insert cont;

            Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE Name = :'testOpp' LIMIT 1];

            SBQQ__Quote__c quote = [SELECT Id, SBQQ__Type__c, SBQQ__SubscriptionTerm__c, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :opp.Id LIMIT 1];
            quote.SBQQ__Type__c = 'Quote';
            quote.SBQQ__StartDate__c = System.today();
            quote.SBQQ__SubscriptionTerm__c = 36;
            quote.SBQQ__Primary__c = true;

            List<Opportunity> oppList = [SELECT Id, AccountId FROM Opportunity WHERE Name = :'testOpp' LIMIT 3];
            Opportunity opp1 = oppList.get(1);

            Contract contract = UM002_TestDataFactory.createContract(acc.id, quote.id, opp.id, Date.Today().addmonths(36));
            contract.Status = 'Draft';
            contract.SBQQ__RenewalUpliftRate__c = 2;
            contract.LPCR_DateFin__c = Date.Today().addmonths(36);
            insert contract;

            contract.Status = 'Activated';
            update contract;

            SBQQ.TriggerControl.disable();
            SBQQ__Quote__c quote1 = [SELECT Id, SBQQ__Type__c, SBQQ__SubscriptionTerm__c, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :opp1.Id LIMIT 1];
            quote1.SBQQ__Type__c = 'Amendment';
            quote1.SBQQ__StartDate__c = System.today();
            quote1.SBQQ__SubscriptionTerm__c = 36;
            quote1.SBQQ__Primary__c = true;
            quote1.SBQQ__RenewalUpliftRate__c = 2;
            quote1.SBQQ__MasterContract__c = contract.id;
            update new List<SBQQ__Quote__c>{ quote, quote1 };

            // create quote line record
            SBQQ__QuoteLine__c qline = UM002_TestDataFactory.createQuoteLine(prod1.Id, quote.Id, pbEntry1.Id, 100, 1);
            qline.LPCR_Creche__c = accCreche.id;

            List<SBQQ__QuoteLine__c> qlines1 = new List<SBQQ__QuoteLine__c>();
            qlines1.add(UM002_TestDataFactory.createQuoteLine(prod1.Id, quote1.Id, pbEntry1.Id, 100, 1));
            qlines1.add(UM002_TestDataFactory.createQuoteLine(prod1.Id, quote1.Id, pbEntry1.Id, 0, -1));

            qlines1.get(0).LPCR_Creche__c = accCreche.id;
            qlines1.get(1).LPCR_Creche__c = accCreche.id;

            qlines1.add(qline);
            insert qlines1;

            // create Contract record
            Contract contract1 = UM002_TestDataFactory.createContract(acc.id, quote1.id, opp1.id, Date.Today().addmonths(36));
            contract1.Status = 'Draft';
            contract1.SBQQ__RenewalUpliftRate__c = 2;
            contract1.LPCR_DateFin__c = Date.Today().addmonths(36);
            insert contract1;

            contract1.Status = 'Activated';
            update contract1;

            Order order = UM002_TestDataFactory.createOrder(acc.Id, contract.id, date.today(), 'test', 'Draft', '1');
            order.Pricebook2Id = standardPricebookId;
            order.SBQQ__Quote__c = quote.id;

            // Create new order with order item
            Order order1 = UM002_TestDataFactory.createOrder(acc.Id, contract1.id, date.today(), 'test', 'Draft', '1');
            order1.Pricebook2Id = standardPricebookId;
            order1.SBQQ__Quote__c = quote1.id;
            insert new List<Order>{ order, order1 };

            OrderItem orderItem1 = UM002_TestDataFactory.createOrderProduct(pbEntry1.id, order.Id, prod1.id, 'Recurring', 'Invoice Plan', 100);
            orderItem1.SBQQ__QuoteLine__c = qline.id;
            orderItem1.SBQQ__Activated__c = true;
            orderItem1.EndDate = System.today(); //.addMonths(36);
            orderItem1.SBQQ__TerminatedDate__c = System.today().addDays(-5);
            orderItem1.blng__NextChargeDate__c = System.today();
            orderItem1.SBQQ__Contract__c = contract.id;
            orderItem1.LPCR_BillingPlanProcessment__c = true;
            orderItem1.blng__RevenueRecognitionRule__c = revRecRule.id;
            orderItem1.blng__BillingRule__c = billingRule.id;
            orderItem1.blng__TaxRule__c = taxRule.id;

            OrderItem orderItem2 = UM002_TestDataFactory.createOrderProduct(pbEntry1.id, order1.Id, prod1.id, 'Recurring', 'Invoice Plan', 100);
            orderItem2.SBQQ__QuoteLine__c = qlines1.get(0).id;
            orderItem2.SBQQ__Activated__c = true;
            orderItem2.EndDate = System.today().addMonths(36);
            orderItem2.SBQQ__TerminatedDate__c = System.today().addDays(5);
            orderItem2.blng__NextChargeDate__c = null; //System.today();
            orderItem2.SBQQ__Contract__c = contract1.id;
            orderItem2.LPCR_BillingPlanProcessment__c = false;
            orderItem2.SBQQ__RevisedOrderProduct__c = orderItem1.Id;
            orderItem2.SBQQ__PricingMethod__c = 'Custom';
            orderItem2.Quantity = 1;
            orderItem2.blng__RevenueRecognitionRule__c = revRecRule.id;
            orderItem2.blng__BillingRule__c = billingRule.id;
            orderItem2.blng__TaxRule__c = taxRule.id;

            insert new List<OrderItem>{ orderItem1, orderItem2 };

            order.status = 'Activated';
            order1.status = 'Activated';
            update new List<Order>{ order, order1 };

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

            insert billingScheduleList;

            // Billing Transaction records
            List<blng__BillingTransaction__c> billingTransList = new List<blng__BillingTransaction__c>();

            blng__BillingTransaction__c billingTrans = new blng__BillingTransaction__c();
            billingTrans.blng__BillingTargetDate__c = Date.today();
            billingTrans.blng__BillingSchedule__c = billingSchedule.Id;
            billingTrans.Name = 'Test';
            billingTrans.blng__Amount__c = 100;
            billingTrans.blng__Status__c = 'Pending';
            billingTrans.LPCR_ProcessProrate__c = false;
            billingTransList.add(billingTrans);

            blng__BillingTransaction__c billingTrans1 = new blng__BillingTransaction__c();
            billingTrans1.blng__BillingTargetDate__c = Date.today();
            billingTrans1.blng__BillingSchedule__c = billingSchedule1.Id;
            billingTrans1.Name = 'Test';
            billingTrans1.blng__Amount__c = 100;
            billingTrans1.blng__Status__c = 'Pending';
            billingTrans1.LPCR_ProcessProrate__c = false;
            billingTransList.add(billingTrans1);

            insert billingTransList;

            // create GL Rule
            blng__GLRule__c glRule = new blng__GLRule__c();
            glRule.Name = 'Test GL Rule';
            glRule.blng__Active__c = true;
            insert glRule;

            // create Finance Book
            blng__FinanceBook__c financeBook = new blng__FinanceBook__c();
            financeBook.Name = 'Test Book';
            financeBook.blng__Active__c = true;
            financeBook.blng__FinancePeriodDuration__c = 'Monthly';
            financeBook.blng__PeriodType__c = 'Revenue';
            insert financeBook;

            // create Revenue Distribution Method
            blng__RevenueDistributionMethod__c revDistributionMethod = new blng__RevenueDistributionMethod__c();
            revDistributionMethod.blng__Active__c = true;
            revDistributionMethod.blng__DistributionMethod__c = 'Monthly';
            revDistributionMethod.blng__RevenueScheduleTermStartDate__c = 'Order Product Start Date';
            revDistributionMethod.blng__RevenueScheduleTermEndDate__c = 'Order Product End Date';
            revDistributionMethod.blng__MonthlyRecognitionProration__c = 'Number of Days';
            revDistributionMethod.blng__RevenueTransactionCreationProcess__c = 'Automatic';
            revDistributionMethod.blng__Type__c = 'Order';
            revDistributionMethod.Name = 'Test Rev Distribution Method';
            insert revDistributionMethod;

            //New Revenue Recognition Treatment
            blng__RevenueRecognitionTreatment__c revRecogTreat = new blng__RevenueRecognitionTreatment__c();
            revRecogTreat.Name = 'Test revRecogTreat';
            revRecogTreat.blng__Active__c = true;
            revRecogTreat.blng__ProcessingOrder__c = 1;
            revRecogTreat.blng__RevenueDistributionMethod__c = revDistributionMethod.id;
            revRecogTreat.blng__RevenueFinanceBook__c = financeBook.id;
            revRecogTreat.blng__RevenueRecognitionRule__c = revRecRule.id;
            revRecogTreat.blng__RevenueScheduleCreationAction__c = 'Order Activation';
            revRecogTreat.blng__RevenueScheduleAmount__c = 'Transaction Amount';
            revRecogTreat.blng__RevenueGLRule__c = glRule.id;
            revRecogTreat.blng__Type__c = 'Flat Amount';
            revRecogTreat.blng__FlatAmount__c = 100;
            insert revRecogTreat;

            // create Revenue Schedule
            blng__RevenueSchedule__c revSchedule = new blng__RevenueSchedule__c();
            revSchedule.blng__TotalRevenueAmount__c = 100;
            revSchedule.blng__RevenueRecognitionTreatment__c = revRecogTreat.id;
            insert revSchedule;

            Date firstDayOfCurrentMonthDate = Date.newInstance(Date.today().Year(), Date.today().month(), 1);
            Date lastDayOfCurrentMonthDate = Date.newInstance(Date.today().Year(), Date.today().month(), Date.daysInMonth(Date.today().year(), Date.today().month()));

            // create blng__FinancePeriod__c
            blng__FinancePeriod__c financePeriod = new blng__FinancePeriod__c();
            financePeriod.blng__PeriodStartDate__c = firstDayOfCurrentMonthDate;
            financePeriod.blng__PeriodEndDate__c = lastDayOfCurrentMonthDate;
            financePeriod.blng__FinanceBook__c = financeBook.id;
            financePeriod.blng__PeriodStatus__c = 'Open';
            financePeriod.Name = '08';

            insert financePeriod;
            //blng__RevenueTransaction__c records
            blng__RevenueTransaction__c revTrans = new blng__RevenueTransaction__c();
            revTrans.blng__OrderProduct__c = orderItem1.id;
            revTrans.blng__Account__c = acc.id;
            revTrans.blng__Contract__c = contract.id;
            revTrans.blng__RevenueFinancePeriod__c = financePeriod.id;
            revTrans.blng__RevenueSchedule__c = revSchedule.id;
            insert revTrans;

            SBQQ.TriggerControl.enable();

            // call batch class
            APB021_ProrationForReportInvoicePlanFreq ss = new APB021_ProrationForReportInvoicePlanFreq();
            DataBase.executeBatch(ss);
            Test.stopTest();
            ss.execute(null);

            // SOQL CHECK
            // ASSERT
        }
    }

    @isTest
    static void batchAPB021Test2() {
        System.runAs(UM002_TestDataFactory.createUser()) {
            Test.startTest();
            blng__LegalEntity__c billingLegalEntity = UM002_TestDataFactory.setupLegalEntity();
            blng__RevenueRecognitionRule__c revRecRule = UM002_TestDataFactory.setupRevRec(billingLegalEntity.Id);
            blng__BillingRule__c billingRule = UM002_TestDataFactory.setupBillingRule(billingLegalEntity.Id);
            blng__TaxRule__c taxRule = UM002_TestDataFactory.setupTaxRule(billingLegalEntity.Id);

            Product2 prod1 = [SELECT Id FROM Product2 WHERE Name = :'test1' LIMIT 1];

            PricebookEntry pbEntry1 = UM002_TestDataFactory.createPricebookEntry(standardPricebookId, prod1.Id);
            pbEntry1.UnitPrice = 0;
            insert pbEntry1;

            Account acc = [SELECT Id, SBQQ__RenewalModel__c, RecordTypeId FROM Account WHERE Name = :'testAccount' LIMIT 1];
            acc.SBQQ__RenewalModel__c = 'Contract Based';
            acc.RecordTypeId = B2C_RT_ID;
            acc.SBQQ__RenewalPricingMethod__c = 'List';
            update acc;

            Account accCreche = [SELECT Id FROM Account WHERE Name = 'Creche' LIMIT 1];

            Contact cont = UM002_TestDataFactory.createContacts(1, CONTACT_RT_ID, 'test_lastname', 'test_address').get(0);
            insert cont;

            Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE Name = :'testOpp' LIMIT 1];

            SBQQ__Quote__c quote = [SELECT Id, SBQQ__Type__c, SBQQ__SubscriptionTerm__c, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :opp.Id LIMIT 1];
            quote.SBQQ__Type__c = 'Quote';
            quote.SBQQ__StartDate__c = System.today();
            quote.SBQQ__SubscriptionTerm__c = 36;
            quote.SBQQ__Primary__c = true;

            List<Opportunity> oppList = [SELECT Id, AccountId FROM Opportunity WHERE Name = :'testOpp' LIMIT 3];
            Opportunity opp1 = oppList.get(1);

            Contract contract = UM002_TestDataFactory.createContract(acc.id, quote.id, opp.id, Date.Today().addmonths(36));
            contract.Status = 'Draft';
            contract.SBQQ__RenewalUpliftRate__c = 2;
            contract.LPCR_DateFin__c = Date.Today().addmonths(36);
            insert contract;

            contract.Status = 'Activated';
            update contract;

            SBQQ.TriggerControl.disable();
            SBQQ__Quote__c quote1 = [SELECT Id, SBQQ__Type__c, SBQQ__SubscriptionTerm__c, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :opp1.Id LIMIT 1];
            quote1.SBQQ__Type__c = 'Amendment';
            quote1.SBQQ__StartDate__c = System.today();
            quote1.SBQQ__SubscriptionTerm__c = 36;
            quote1.SBQQ__Primary__c = true;
            quote1.SBQQ__RenewalUpliftRate__c = 2;
            quote1.SBQQ__MasterContract__c = contract.id;
            update new List<SBQQ__Quote__c>{ quote, quote1 };

            // create quote line record
            SBQQ__QuoteLine__c qline = UM002_TestDataFactory.createQuoteLine(prod1.Id, quote.Id, pbEntry1.Id, 100, 1);
            qline.LPCR_Creche__c = accCreche.id;

            List<SBQQ__QuoteLine__c> qlines1 = new List<SBQQ__QuoteLine__c>();
            qlines1.add(UM002_TestDataFactory.createQuoteLine(prod1.Id, quote1.Id, pbEntry1.Id, 100, 1));
            qlines1.add(UM002_TestDataFactory.createQuoteLine(prod1.Id, quote1.Id, pbEntry1.Id, 0, -1));

            qlines1.get(0).LPCR_Creche__c = accCreche.id;
            qlines1.get(1).LPCR_Creche__c = accCreche.id;

            qlines1.add(qline);
            insert qlines1;

            // create Contract record
            Contract contract1 = UM002_TestDataFactory.createContract(acc.id, quote1.id, opp1.id, Date.Today().addmonths(36));
            contract1.Status = 'Draft';
            contract1.SBQQ__RenewalUpliftRate__c = 2;
            contract1.LPCR_DateFin__c = Date.Today().addmonths(36);
            insert contract1;

            contract1.Status = 'Activated';
            update contract1;

            Order order = UM002_TestDataFactory.createOrder(acc.Id, contract.id, date.today(), 'test', 'Draft', '1');
            order.Pricebook2Id = standardPricebookId;
            order.SBQQ__Quote__c = quote.id;

            // Create new order with order item
            Order order1 = UM002_TestDataFactory.createOrder(acc.Id, contract1.id, date.today(), 'test', 'Draft', '1');
            order1.Pricebook2Id = standardPricebookId;
            order1.SBQQ__Quote__c = quote1.id;
            insert new List<Order>{ order, order1 };

            OrderItem orderItem1 = UM002_TestDataFactory.createOrderProduct(pbEntry1.id, order.Id, prod1.id, 'Recurring', 'Invoice Plan', 100);
            orderItem1.SBQQ__QuoteLine__c = qline.id;
            orderItem1.SBQQ__Activated__c = true;
            orderItem1.EndDate = System.today(); //.addMonths(36);
            orderItem1.SBQQ__TerminatedDate__c = System.today().addDays(-5);
            orderItem1.blng__NextChargeDate__c = System.today();
            orderItem1.SBQQ__Contract__c = contract.id;
            orderItem1.LPCR_BillingPlanProcessment__c = true;
            orderItem1.blng__RevenueRecognitionRule__c = revRecRule.id;
            orderItem1.blng__BillingRule__c = billingRule.id;
            orderItem1.blng__TaxRule__c = taxRule.id;

            OrderItem orderItem2 = UM002_TestDataFactory.createOrderProduct(pbEntry1.id, order1.Id, prod1.id, 'Recurring', 'Invoice Plan', 100);
            orderItem2.SBQQ__QuoteLine__c = qlines1.get(0).id;
            orderItem2.SBQQ__Activated__c = true;
            orderItem2.EndDate = System.today().addMonths(36);
            orderItem2.SBQQ__TerminatedDate__c = System.today().addDays(5);
            orderItem2.blng__NextChargeDate__c = null; //System.today();
            orderItem2.SBQQ__Contract__c = contract1.id;
            orderItem2.LPCR_BillingPlanProcessment__c = false;
            orderItem2.SBQQ__RevisedOrderProduct__c = orderItem1.Id;
            orderItem2.SBQQ__PricingMethod__c = 'Custom';
            orderItem2.Quantity = 1;
            orderItem2.blng__RevenueRecognitionRule__c = revRecRule.id;
            orderItem2.blng__BillingRule__c = billingRule.id;
            orderItem2.blng__TaxRule__c = taxRule.id;

            insert new List<OrderItem>{ orderItem1, orderItem2 };

            order.status = 'Activated';
            order1.status = 'Activated';
            update new List<Order>{ order, order1 };

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

            insert billingScheduleList;

            // Billing Transaction records
            List<blng__BillingTransaction__c> billingTransList = new List<blng__BillingTransaction__c>();

            blng__BillingTransaction__c billingTrans = new blng__BillingTransaction__c();
            billingTrans.blng__BillingTargetDate__c = System.today();
            billingTrans.blng__OverrideBillingTargetDate__c = Date.today();
            billingTrans.blng__BillingSchedule__c = billingSchedule.Id;
            billingTrans.Name = 'Test';
            billingTrans.blng__Amount__c = 100;
            billingTrans.blng__Status__c = 'Pending';
            billingTrans.LPCR_ProcessProrate__c = false;
            billingTransList.add(billingTrans);

            blng__BillingTransaction__c billingTrans1 = new blng__BillingTransaction__c();
            billingTrans1.blng__BillingTargetDate__c = Date.today();
            billingTrans1.blng__BillingSchedule__c = billingSchedule1.Id;
            billingTrans1.Name = 'Test';
            billingTrans1.blng__Amount__c = 100;
            billingTrans1.blng__Status__c = 'Pending';
            billingTrans1.LPCR_ProcessProrate__c = false;
            billingTransList.add(billingTrans1);

            insert billingTransList;

            // create GL Rule
            blng__GLRule__c glRule = new blng__GLRule__c();
            glRule.Name = 'Test GL Rule';
            glRule.blng__Active__c = true;
            insert glRule;

            // create Finance Book
            blng__FinanceBook__c financeBook = new blng__FinanceBook__c();
            financeBook.Name = 'Test Book';
            financeBook.blng__Active__c = true;
            financeBook.blng__FinancePeriodDuration__c = 'Monthly';
            financeBook.blng__PeriodType__c = 'Revenue';
            insert financeBook;

            // create Revenue Distribution Method
            blng__RevenueDistributionMethod__c revDistributionMethod = new blng__RevenueDistributionMethod__c();
            revDistributionMethod.blng__Active__c = true;
            revDistributionMethod.blng__DistributionMethod__c = 'Monthly';
            revDistributionMethod.blng__RevenueScheduleTermStartDate__c = 'Order Product Start Date';
            revDistributionMethod.blng__RevenueScheduleTermEndDate__c = 'Order Product End Date';
            revDistributionMethod.blng__MonthlyRecognitionProration__c = 'Number of Days';
            revDistributionMethod.blng__RevenueTransactionCreationProcess__c = 'Automatic';
            revDistributionMethod.blng__Type__c = 'Order';
            revDistributionMethod.Name = 'Test Rev Distribution Method';
            insert revDistributionMethod;

            //New Revenue Recognition Treatment
            blng__RevenueRecognitionTreatment__c revRecogTreat = new blng__RevenueRecognitionTreatment__c();
            revRecogTreat.Name = 'Test revRecogTreat';
            revRecogTreat.blng__Active__c = true;
            revRecogTreat.blng__ProcessingOrder__c = 1;
            revRecogTreat.blng__RevenueDistributionMethod__c = revDistributionMethod.id;
            revRecogTreat.blng__RevenueFinanceBook__c = financeBook.id;
            revRecogTreat.blng__RevenueRecognitionRule__c = revRecRule.id;
            revRecogTreat.blng__RevenueScheduleCreationAction__c = 'Order Activation';
            revRecogTreat.blng__RevenueScheduleAmount__c = 'Transaction Amount';
            revRecogTreat.blng__RevenueGLRule__c = glRule.id;
            revRecogTreat.blng__Type__c = 'Flat Amount';
            revRecogTreat.blng__FlatAmount__c = 100;
            insert revRecogTreat;

            // create Revenue Schedule
            blng__RevenueSchedule__c revSchedule = new blng__RevenueSchedule__c();
            revSchedule.blng__TotalRevenueAmount__c = 100;
            revSchedule.blng__RevenueRecognitionTreatment__c = revRecogTreat.id;
            insert revSchedule;

            Date firstDayOfCurrentMonthDate = Date.newInstance(Date.today().Year(), Date.today().month(), 1);
            Date lastDayOfCurrentMonthDate = Date.newInstance(Date.today().Year(), Date.today().month(), Date.daysInMonth(Date.today().year(), Date.today().month()));

            // create blng__FinancePeriod__c
            blng__FinancePeriod__c financePeriod = new blng__FinancePeriod__c();
            financePeriod.blng__PeriodStartDate__c = firstDayOfCurrentMonthDate.addMonths(2);
            financePeriod.blng__PeriodEndDate__c = lastDayOfCurrentMonthDate;
            financePeriod.blng__FinanceBook__c = financeBook.id;
            financePeriod.blng__PeriodStatus__c = 'Open';
            financePeriod.Name = '08';

            insert financePeriod;
            //blng__RevenueTransaction__c records
            blng__RevenueTransaction__c revTrans = new blng__RevenueTransaction__c();
            revTrans.blng__OrderProduct__c = orderItem1.id;
            revTrans.blng__Account__c = acc.id;
            revTrans.blng__Contract__c = contract.id;
            revTrans.blng__RevenueFinancePeriod__c = financePeriod.id;
            revTrans.blng__RevenueSchedule__c = revSchedule.id;
            insert revTrans;

            SBQQ.TriggerControl.enable();

            // call batch class
            APB021_ProrationForReportInvoicePlanFreq ss = new APB021_ProrationForReportInvoicePlanFreq();
            DataBase.executeBatch(ss);
            Test.stopTest();
            ss.execute(null);

        }
    }
}
