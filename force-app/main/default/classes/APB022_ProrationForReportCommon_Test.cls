/**
 * @description       :
 * @author            : Widaad Papauretty
 * @group             :
 * @last modified on  : 11-18-2021
 * @last modified by  : Widaad Papauretty
 **/
@isTest
public class APB022_ProrationForReportCommon_Test {
    private static final Id B2C_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Famille);
    private static final Id OPP_ENTREPRISE_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Opportunity, Label.LPCR_Entreprise);
    private static final Id ACCOUNT_CRECHE_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Creche);
    private static final Id CONTACT_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contact, Label.LPCR_Parent);
    private static final Id QUOTE_CONTRAT_ACCUEIL_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote, Label.LPCR_ContratA);
    private static final Id ORDER_CONTRAT_ACCUEIL_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Order, Label.LPCR_ContratA);
    private static final Id standardPricebookId = Test.getStandardPricebookId();

    @testSetup
    static void testSetup() {
        System.runAs(UM002_TestDataFactory.createUser()) {
            User userFamille = UM002_TestDataFactory.createServiceFamilleUser();
            User userADV = UM002_TestDataFactory.createADVUser();

            List<Account> accounts = UM002_TestDataFactory.createAccounts(2, 'testAccount');
            accounts.get(0).RecordTypeId = B2C_RT_ID;
            accounts.get(0).LPCR_ResponsableServiceFamille__c = userFamille.id;
            accounts.get(0).LPCR_ResponsableADV__c = userADV.id;
            accounts.get(0).SBQQ__RenewalModel__c = 'Contract Based';
            accounts.get(0).LPCR_ProcessRevenuCascade__c = true;

            accounts.get(1).RecordTypeId = ACCOUNT_CRECHE_ID;
            accounts.get(1).SBQQ__RenewalModel__c = 'Contract Based';
            accounts.get(1).Name = 'Creche';
            accounts.get(1).LPCR_ResponsableServiceFamille__c = userFamille.id;
            accounts.get(1).LPCR_ResponsableADV__c = userADV.id;

            List<Opportunity> opps = UM002_TestDataFactory.createOpportunities(1, 'testOpp', 'Prospecting');
            opps.get(0).recordTypeId = OPP_ENTREPRISE_RT_ID;
            opps.get(0).AccountId = accounts.get(0).id;

            insert accounts;
            insert opps;
            SBQQ__Quote__c quote = UM002_TestDataFactory.createQuotes(1, accounts, opps).get(0);
            quote.SBQQ__Type__c = 'Quote';
            quote.SBQQ__StartDate__c = System.today();
            quote.SBQQ__SubscriptionTerm__c = 12;
            quote.SBQQ__Primary__c = true;
            quote.RecordTypeId = QUOTE_CONTRAT_ACCUEIL_RT_ID;
            insert quote;

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

            Product2 prod1 = UM002_TestDataFactory.createFixedPriceProduct('test1', billingRule.Id, revRecRule.Id, taxRule.Id);
            prod1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            prod1.SBQQ__BillingType__c = 'Advance';
            prod1.SBQQ__ChargeType__c = 'Recurring';
            prod1.SBQQ__SubscriptionTerm__c = 12;
            prod1.SBQQ__SubscriptionType__c = 'Renewable';
            insert prod1;

            PricebookEntry priceBookEntry1 = UM002_TestDataFactory.createPricebookEntry(standardPricebookId, prod.Id);
            insert priceBookEntry1;
            PricebookEntry priceBookEntry2 = UM002_TestDataFactory.createPricebookEntry(standardPricebookId, prod1.Id);
            insert priceBookEntry2;

            Contact cont = UM002_TestDataFactory.createContacts(1, CONTACT_RT_ID, 'test_lastname', 'test_address').get(0);
            insert cont;

            LPCR_RessourceFamille__c ressourceFamille = UM002_TestDataFactory.createRessourceFamille(
                Date.newInstance(Date.today().Year(), Date.today().month(), 1),
                accounts.get(0).id,
                cont.id
            );
            insert ressourceFamille;
        }
    }

    /*
    // Reminder of APB022_ProrationForReportCommonFreq goal : 
     Input : blng__RevenueTransaction__c with LPCR_Amount__c empty
     Output : Populate and adjust the LPCR_Amount__c field on the Revenue Transaction accordingly to what LPCR wants
    */

    @isTest
    static void batchAPB022Test() {
        System.runAs(UM002_TestDataFactory.createUser()) {
            Date firstDayOfMonthDate = Date.newInstance(Date.today().Year(), Date.today().month(), 1);
            Date lastDayOfCurrentMonthDate = Date.newInstance(Date.today().Year(), Date.today().month(), Date.daysInMonth(Date.today().year(), Date.today().month()));

            Product2 prod = [SELECT Id FROM Product2 WHERE Name = :'test' LIMIT 1];
            PricebookEntry pbEntry = [SELECT Id FROM PricebookEntry WHERE Product2Id = :prod.id LIMIT 1];

            Account acc = [SELECT Id, SBQQ__RenewalModel__c, RecordTypeId FROM Account WHERE Name = :'testAccount' LIMIT 1];

            Account accCreche = [SELECT Id, SBQQ__RenewalModel__c, RecordTypeId FROM Account WHERE Name = :'Creche' LIMIT 1];

            Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE Name = :'testOpp' LIMIT 1];

            SBQQ__Quote__c quote = [SELECT Id, SBQQ__Type__c, SBQQ__SubscriptionTerm__c, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :opp.Id LIMIT 1];

            SBQQ__QuoteLine__c qline = UM002_TestDataFactory.createQuoteLine(prod.Id, quote.Id, pbEntry.Id, 200, 1);
            qline.LPCR_Creche__c = accCreche.id;
            insert qline;

            Test.startTest();
            Contract contract = UM002_TestDataFactory.createContract(acc.id, quote.id, opp.id, Date.Today().addmonths(3));
            contract.Status = 'Draft';
            insert contract;

            contract.Status = 'Activated';
            update contract;

            Order order = UM002_TestDataFactory.createOrder(acc.Id, contract.id, date.today(), 'test', 'Draft', '1');
            order.Pricebook2Id = standardPricebookId;
            order.SBQQ__Quote__c = quote.id;
            order.RecordTypeId = ORDER_CONTRAT_ACCUEIL_RT_ID;
            order.LPCR_InitAutoAvecDateDebut__c = false;
            insert order;

            OrderItem orderItem = UM002_TestDataFactory.createOrderProduct(pbEntry.id, order.Id, prod.id, 'Recurring', 'Monthly', 100);
            orderItem.SBQQ__QuoteLine__c = qline.id;
            orderItem.ServiceDate = System.today();
            orderItem.SBQQ__Contract__c = contract.id;
            orderItem.blng__BillableUnitPrice__c = 100;
            orderItem.EndDate = System.today();
            orderItem.LPCR_FirstInvoiceEndDate__c = System.today().addMonths(1);
            orderItem.LPCR_Creche__c = accCreche.Id;
            orderItem.SBQQ__Activated__c = true;
            orderItem.blng__GroupId__c = acc.id + '' + contract.id + '' + accCreche.Id;
            orderItem.blng__InvoiceGroupId__c = acc.id + '' + contract.id + '' + accCreche.Id;

            OrderItem orderItem1 = UM002_TestDataFactory.createOrderProduct(pbEntry.id, order.Id, prod.id, 'Recurring', 'Quarterly', 100);
            orderItem1.SBQQ__QuoteLine__c = qline.id;
            orderItem1.ServiceDate = System.today();
            orderItem1.SBQQ__Contract__c = contract.id;
            orderItem1.blng__BillableUnitPrice__c = 100;
            orderItem1.EndDate = System.today();
            orderItem1.LPCR_FirstInvoiceEndDate__c = System.today().addMonths(-1);
            orderItem1.LPCR_Creche__c = accCreche.Id;
            orderItem1.SBQQ__Activated__c = true;
            orderItem1.blng__GroupId__c = acc.id + '' + contract.id + '' + accCreche.Id;
            orderItem1.blng__InvoiceGroupId__c = acc.id + '' + contract.id + '' + accCreche.Id;

            OrderItem orderItem2 = UM002_TestDataFactory.createOrderProduct(pbEntry.id, order.Id, prod.id, 'Recurring', 'Semiannual', 100);
            orderItem2.SBQQ__QuoteLine__c = qline.id;
            orderItem2.ServiceDate = firstDayOfMonthDate.addMonths(1);
            orderItem2.SBQQ__Contract__c = contract.id;
            orderItem2.blng__BillableUnitPrice__c = 100;
            orderItem2.EndDate = System.today().addMonths(2);
            orderItem2.LPCR_FirstInvoiceEndDate__c = System.today().addMonths(2);
            orderItem2.LPCR_Creche__c = accCreche.Id;
            orderItem2.SBQQ__Activated__c = true;
            orderItem2.blng__GroupId__c = acc.id + '' + contract.id + '' + accCreche.Id;
            orderItem2.blng__InvoiceGroupId__c = acc.id + '' + contract.id + '' + accCreche.Id;

            OrderItem orderItem3 = UM002_TestDataFactory.createOrderProduct(pbEntry.id, order.Id, prod.id, 'Recurring', 'Annual', 100);
            orderItem3.SBQQ__QuoteLine__c = qline.id;
            orderItem3.ServiceDate = System.today().addYears(1).addMonths(-1);
            orderItem3.SBQQ__Contract__c = contract.id;
            orderItem3.blng__BillableUnitPrice__c = 100;
            orderItem3.EndDate = System.today().addYears(1);
            orderItem3.LPCR_FirstInvoiceEndDate__c = System.today().addMonths(-1);
            orderItem3.LPCR_Creche__c = accCreche.Id;
            orderItem3.SBQQ__Activated__c = true;
            orderItem3.blng__GroupId__c = acc.id + '' + contract.id + '' + accCreche.Id;
            orderItem3.blng__InvoiceGroupId__c = acc.id + '' + contract.id + '' + accCreche.Id;

            OrderItem orderItem4 = UM002_TestDataFactory.createOrderProduct(pbEntry.id, order.Id, prod.id, 'Recurring', 'Invoice Plan', 100);
            orderItem4.SBQQ__QuoteLine__c = qline.id;
            orderItem4.ServiceDate = System.today();
            orderItem4.SBQQ__Contract__c = contract.id;
            orderItem4.blng__BillableUnitPrice__c = 100;
            orderItem4.EndDate = System.today();
            orderItem4.LPCR_FirstInvoiceEndDate__c = System.today().addMonths(-1);
            orderItem4.LPCR_Creche__c = accCreche.Id;
            orderItem4.SBQQ__Activated__c = true;
            orderItem4.blng__GroupId__c = acc.id + '' + contract.id + '' + accCreche.Id;
            orderItem4.blng__InvoiceGroupId__c = acc.id + '' + contract.id + '' + accCreche.Id;

            insert new List<OrderItem>{ orderItem, orderItem1, orderItem2, orderItem3, orderItem4 };

            order.status = 'Activated';
            order.blng__BillNow__c = true;
            update order;

            // get Revenue Recognition Rule
            blng__RevenueRecognitionRule__c revRecogRule = [SELECT id FROM blng__RevenueRecognitionRule__c LIMIT 1];

            // crate GL Rule
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
            revRecogTreat.blng__RevenueRecognitionRule__c = revRecogRule.id;
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

            // create blng__FinancePeriod__c
            blng__FinancePeriod__c financePeriod = new blng__FinancePeriod__c();
            financePeriod.blng__PeriodStartDate__c = firstDayOfMonthDate;
            financePeriod.blng__PeriodEndDate__c = lastDayOfCurrentMonthDate;
            financePeriod.blng__FinanceBook__c = financeBook.id;
            financePeriod.blng__PeriodStatus__c = 'Open';
            financePeriod.Name = '08';

            insert financePeriod;

            // create blng__RevenueTransaction__c
            blng__RevenueTransaction__c revTrans = new blng__RevenueTransaction__c();
            revTrans.blng__OrderProduct__c = orderItem.id;
            revTrans.blng__Account__c = acc.id;
            revTrans.blng__Contract__c = contract.id;
            revTrans.blng__SystemPeriodStartDate__c = System.today().addYears(1);
            revTrans.blng__RevenueAmount__c = 100;
            revTrans.blng__RevenueFinancePeriod__c = financePeriod.id;
            revTrans.blng__RevenueSchedule__c = revSchedule.id;
            revTrans.LPCR_Amount__c = null;

            // create blng__RevenueTransaction__c for credit note
            blng__RevenueTransaction__c revTransCreditNote = new blng__RevenueTransaction__c();
            revTransCreditNote.blng__OrderProduct__c = orderItem1.id;
            revTransCreditNote.blng__Account__c = acc.id;
            revTransCreditNote.blng__Contract__c = contract.id;
            revTransCreditNote.blng__SystemPeriodStartDate__c = System.today().addYears(2);
            revTransCreditNote.blng__RevenueAmount__c = 100;
            revTransCreditNote.blng__RevenueFinancePeriod__c = financePeriod.id;
            revTransCreditNote.blng__RevenueSchedule__c = revSchedule.id;

            // create blng__RevenueTransaction__c
            blng__RevenueTransaction__c revTrans1 = new blng__RevenueTransaction__c();
            revTrans1.blng__OrderProduct__c = orderItem2.id;
            revTrans1.blng__Account__c = acc.id;
            revTrans1.blng__Contract__c = contract.id;
            revTrans1.blng__SystemPeriodStartDate__c = System.today();
            revTrans1.blng__RevenueAmount__c = 100;
            revTrans1.blng__RevenueFinancePeriod__c = financePeriod.id;
            revTrans1.blng__RevenueSchedule__c = revSchedule.id;
            revTrans1.LPCR_Amount__c = null;

            // create blng__RevenueTransaction__c
            blng__RevenueTransaction__c revTrans2 = new blng__RevenueTransaction__c();
            revTrans2.blng__OrderProduct__c = orderItem3.id;
            revTrans2.blng__Account__c = acc.id;
            revTrans2.blng__Contract__c = contract.id;
            revTrans2.blng__SystemPeriodStartDate__c = System.today();
            revTrans2.blng__RevenueAmount__c = 100;
            revTrans2.blng__RevenueFinancePeriod__c = financePeriod.id;
            revTrans2.blng__RevenueSchedule__c = revSchedule.id;
            revTrans2.LPCR_Amount__c = null;

            // create blng__RevenueTransaction__c
            blng__RevenueTransaction__c revTrans3 = new blng__RevenueTransaction__c();
            revTrans3.blng__OrderProduct__c = orderItem4.id;
            revTrans3.blng__Account__c = acc.id;
            revTrans3.blng__Contract__c = contract.id;
            revTrans3.blng__SystemPeriodStartDate__c = System.today();
            revTrans3.blng__RevenueAmount__c = 100;
            revTrans3.blng__RevenueFinancePeriod__c = financePeriod.id;
            revTrans3.blng__RevenueSchedule__c = revSchedule.id;
            revTrans3.LPCR_Amount__c = null;

            insert new List<blng__RevenueTransaction__c>{ revTrans, revTransCreditNote, revTrans1, revTrans2, revTrans3 };

            APB022_ProrationForReportCommonFreq ss = new APB022_ProrationForReportCommonFreq();
            DataBase.executeBatch(ss);

            Test.stopTest();
            ss.execute(null);

            List<blng__RevenueTransaction__c> listRevTrans = new List<blng__RevenueTransaction__c>([SELECT Id, LPCR_Amount__c FROM blng__RevenueTransaction__c]);
            PAD.log('APB022_ProrationForReportCommon_Test', 'batchAPB022Test', 'listRevTrans.size():' + listRevTrans.size());
            PAD.log('APB022_ProrationForReportCommon_Test', 'batchAPB022Test', 'listRevTrans:' + listRevTrans);

            // TODO
            // SOQL to cehck result of batch
            //+ ASSERT : System.assertEquals(1, revCascadeList.size(),'batchAPB022Test : RevenueTransaction upsert fail');
        }

    }

    @isTest
    static void batchAPB022Test3() {
        System.runAs(UM002_TestDataFactory.createUser()) {
            Date firstDayOfMonthDate = Date.newInstance(Date.today().Year(), Date.today().month(), 1);
            Date lastDayOfCurrentMonthDate = Date.newInstance(Date.today().Year(), Date.today().month(), Date.daysInMonth(Date.today().year(), Date.today().month()));

            Product2 prod = [SELECT Id FROM Product2 WHERE Name = :'test' LIMIT 1];
            PricebookEntry pbEntry = [SELECT Id FROM PricebookEntry WHERE Product2Id = :prod.id LIMIT 1];

            Account acc = [SELECT Id, SBQQ__RenewalModel__c, RecordTypeId FROM Account WHERE Name = :'testAccount' LIMIT 1];

            Account accCreche = [SELECT Id, SBQQ__RenewalModel__c, RecordTypeId FROM Account WHERE Name = :'Creche' LIMIT 1];

            Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE Name = :'testOpp' LIMIT 1];

            SBQQ__Quote__c quote = [SELECT Id, SBQQ__Type__c, SBQQ__SubscriptionTerm__c, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :opp.Id LIMIT 1];

            SBQQ__QuoteLine__c qline = UM002_TestDataFactory.createQuoteLine(prod.Id, quote.Id, pbEntry.Id, 200, 1);
            qline.LPCR_Creche__c = accCreche.id;
            insert qline;

            Test.startTest();
            Contract contract = UM002_TestDataFactory.createContract(acc.id, quote.id, opp.id, Date.Today().addmonths(3));
            contract.Status = 'Draft';
            insert contract;

            contract.Status = 'Activated';
            update contract;

            Order order = UM002_TestDataFactory.createOrder(acc.Id, contract.id, date.today(), 'test', 'Draft', '1');
            order.Pricebook2Id = standardPricebookId;
            order.SBQQ__Quote__c = quote.id;
            order.RecordTypeId = ORDER_CONTRAT_ACCUEIL_RT_ID;
            order.LPCR_InitAutoAvecDateDebut__c = false;
            insert order;

            OrderItem orderItem = UM002_TestDataFactory.createOrderProduct(pbEntry.id, order.Id, prod.id, 'Recurring', 'Monthly', 100);
            orderItem.SBQQ__QuoteLine__c = qline.id;
            orderItem.ServiceDate = System.today();
            orderItem.SBQQ__Contract__c = contract.id;
            orderItem.blng__BillableUnitPrice__c = 500;
            orderItem.EndDate = System.today();
            orderItem.LPCR_FirstInvoiceEndDate__c = System.today().addMonths(1);
            orderItem.LPCR_Creche__c = accCreche.Id;
            orderItem.SBQQ__Activated__c = true;
            orderItem.blng__GroupId__c = acc.id + '' + contract.id + '' + accCreche.Id;
            orderItem.blng__InvoiceGroupId__c = acc.id + '' + contract.id + '' + accCreche.Id;

            OrderItem orderItem1 = UM002_TestDataFactory.createOrderProduct(pbEntry.id, order.Id, prod.id, 'Recurring', 'Quarterly', 100);
            orderItem1.SBQQ__QuoteLine__c = qline.id;
            orderItem1.ServiceDate = System.today();
            orderItem1.SBQQ__Contract__c = contract.id;
            orderItem1.blng__BillableUnitPrice__c = 500;
            orderItem1.EndDate = System.today();
            orderItem1.LPCR_FirstInvoiceEndDate__c = System.today().addMonths(-1);
            orderItem1.LPCR_Creche__c = accCreche.Id;
            orderItem1.SBQQ__Activated__c = true;
            orderItem1.blng__GroupId__c = acc.id + '' + contract.id + '' + accCreche.Id;
            orderItem1.blng__InvoiceGroupId__c = acc.id + '' + contract.id + '' + accCreche.Id;

            OrderItem orderItem2 = UM002_TestDataFactory.createOrderProduct(pbEntry.id, order.Id, prod.id, 'Recurring', 'Semiannual', 100);
            orderItem2.SBQQ__QuoteLine__c = qline.id;
            orderItem2.ServiceDate = firstDayOfMonthDate.addMonths(1);
            orderItem2.SBQQ__Contract__c = contract.id;
            orderItem2.blng__BillableUnitPrice__c = 500;
            orderItem2.EndDate = System.today().addMonths(2);
            orderItem2.LPCR_FirstInvoiceEndDate__c = System.today().addMonths(2);
            orderItem2.LPCR_Creche__c = accCreche.Id;
            orderItem2.EndDate = System.today().addYears(1);
            orderItem2.SBQQ__Activated__c = true;
            orderItem2.blng__GroupId__c = acc.id + '' + contract.id + '' + accCreche.Id;
            orderItem2.blng__InvoiceGroupId__c = acc.id + '' + contract.id + '' + accCreche.Id;

            OrderItem orderItem3 = UM002_TestDataFactory.createOrderProduct(pbEntry.id, order.Id, prod.id, 'Recurring', 'Annual', 100);
            orderItem3.SBQQ__QuoteLine__c = qline.id;
            orderItem3.ServiceDate = System.today();
            orderItem3.SBQQ__Contract__c = contract.id;
            orderItem3.blng__BillableUnitPrice__c = 500;
            orderItem3.EndDate = System.today().addYears(1);
            orderItem3.LPCR_FirstInvoiceEndDate__c = System.today();
            orderItem3.LPCR_Creche__c = accCreche.Id;
            orderItem3.SBQQ__Activated__c = true;
            orderItem3.blng__GroupId__c = acc.id + '' + contract.id + '' + accCreche.Id;
            orderItem3.blng__InvoiceGroupId__c = acc.id + '' + contract.id + '' + accCreche.Id;

            OrderItem orderItem4 = UM002_TestDataFactory.createOrderProduct(pbEntry.id, order.Id, prod.id, 'Recurring', 'Invoice Plan', 100);
            orderItem4.SBQQ__QuoteLine__c = qline.id;
            orderItem4.ServiceDate = System.today();
            orderItem4.SBQQ__Contract__c = contract.id;
            orderItem4.blng__BillableUnitPrice__c = 500;
            orderItem4.EndDate = System.today();
            orderItem4.LPCR_FirstInvoiceEndDate__c = System.today();
            orderItem4.LPCR_Creche__c = accCreche.Id;
            orderItem4.SBQQ__Activated__c = true;
            orderItem4.blng__GroupId__c = acc.id + '' + contract.id + '' + accCreche.Id;
            orderItem4.blng__InvoiceGroupId__c = acc.id + '' + contract.id + '' + accCreche.Id;

            insert new List<OrderItem>{orderItem, orderItem1, orderItem2, orderItem3, orderItem4};

            order.status = 'Activated';
            order.blng__BillNow__c = true;
            update order;

            // get Revenue Recognition Rule
            blng__RevenueRecognitionRule__c revRecogRule = [SELECT id FROM blng__RevenueRecognitionRule__c LIMIT 1];

            // crate GL Rule
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
            revRecogTreat.blng__RevenueRecognitionRule__c = revRecogRule.id;
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

            // create blng__FinancePeriod__c
            blng__FinancePeriod__c financePeriod = new blng__FinancePeriod__c();
            financePeriod.blng__PeriodStartDate__c = firstDayOfMonthDate;
            financePeriod.blng__PeriodEndDate__c = lastDayOfCurrentMonthDate;
            financePeriod.blng__FinanceBook__c = financeBook.id;
            financePeriod.blng__PeriodStatus__c = 'Open';
            financePeriod.Name = '08';

            insert financePeriod;

            // create blng__RevenueTransaction__c
            blng__RevenueTransaction__c revTrans = new blng__RevenueTransaction__c();
            revTrans.blng__OrderProduct__c = orderItem2.id;
            revTrans.blng__Account__c = acc.id;
            revTrans.blng__Contract__c = contract.id;
            revTrans.blng__SystemPeriodStartDate__c = System.today().addYears(2);
            revTrans.blng__RevenueAmount__c = 100;
            revTrans.blng__RevenueFinancePeriod__c = financePeriod.id;
            revTrans.blng__RevenueSchedule__c = revSchedule.id;
            revTrans.LPCR_Amount__c = null; 

            blng__RevenueTransaction__c revTransCreditNote = new blng__RevenueTransaction__c();
            revTransCreditNote.blng__OrderProduct__c = orderItem2.id;
            revTransCreditNote.blng__Account__c = acc.id;
            revTransCreditNote.blng__SystemPeriodStartDate__c = System.today();
            revTransCreditNote.blng__Contract__c = contract.id;
            revTransCreditNote.blng__RevenueAmount__c = 100;
            revTransCreditNote.blng__RevenueFinancePeriod__c = financePeriod.id;
            revTransCreditNote.blng__RevenueSchedule__c = revSchedule.id;

            // create blng__RevenueTransaction__c
            blng__RevenueTransaction__c revTrans3 = new blng__RevenueTransaction__c();
            revTrans3.blng__OrderProduct__c = orderItem2.id;
            revTrans3.blng__Account__c = acc.id;
            revTrans3.blng__Contract__c = contract.id;
            revTrans3.blng__SystemPeriodStartDate__c = System.today().addYears(1);
            revTrans3.blng__RevenueAmount__c = 100;
            revTrans3.blng__RevenueFinancePeriod__c = financePeriod.id;
            revTrans3.blng__RevenueSchedule__c = revSchedule.id;
            revTrans3.LPCR_Amount__c = null;

            insert new List<blng__RevenueTransaction__c>{ revTrans,revTrans3,revTransCreditNote};

            APB022_ProrationForReportCommonFreq ss = new APB022_ProrationForReportCommonFreq();
            DataBase.executeBatch(ss);

            Test.stopTest();
            ss.execute(null);

            List<blng__RevenueTransaction__c> listRevTrans = new List<blng__RevenueTransaction__c>([SELECT Id, LPCR_Amount__c FROM blng__RevenueTransaction__c]);
            PAD.log('APB022_ProrationForReportCommon_Test', 'batchAPB022Test', 'listRevTrans.size():' + listRevTrans.size());
            PAD.log('APB022_ProrationForReportCommon_Test', 'batchAPB022Test', 'listRevTrans:' + listRevTrans);

            // TODO
            // SOQL to cehck result of batch
            //+ ASSERT : System.assertEquals(1, revCascadeList.size(),'batchAPB022Test : RevenueTransaction upsert fail');
        }

    }

    @isTest
    static void batchAPB022Test2() {
        System.runAs(UM002_TestDataFactory.createUser()) {
            Date firstDayOfCurrentMonthDate = Date.newInstance(Date.today().Year(), Date.today().month(), 1);
            Date lastDayOfCurrentMonthDate = Date.newInstance(Date.today().Year(), Date.today().month(), Date.daysInMonth(Date.today().year(), Date.today().month()));

            Product2 prod = [SELECT Id FROM Product2 WHERE Name = :'test1' LIMIT 1];
            PricebookEntry pbEntry = [SELECT Id FROM PricebookEntry WHERE Product2Id = :prod.id LIMIT 1];

            Account acc = [SELECT Id, SBQQ__RenewalModel__c, RecordTypeId FROM Account WHERE Name = :'testAccount' LIMIT 1];

            Account accCreche = [SELECT Id, SBQQ__RenewalModel__c, RecordTypeId FROM Account WHERE Name = :'Creche' LIMIT 1];

            Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE Name = :'testOpp' LIMIT 1];

            SBQQ__Quote__c quote = [SELECT Id, SBQQ__Type__c, SBQQ__SubscriptionTerm__c, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :opp.Id LIMIT 1];

            SBQQ__QuoteLine__c qline = UM002_TestDataFactory.createQuoteLine(prod.Id, quote.Id, pbEntry.Id, 200, 1);
            qline.LPCR_Creche__c = accCreche.id;
            insert qline;

            Test.startTest();
            Contract contract = UM002_TestDataFactory.createContract(acc.id, quote.id, opp.id, Date.Today().addmonths(3));
            contract.Status = 'Draft';
            insert contract;

            contract.Status = 'Activated';
            update contract;

            Order order = UM002_TestDataFactory.createOrder(acc.Id, contract.id, date.today(), 'test', 'Draft', '1');
            order.Pricebook2Id = standardPricebookId;
            order.SBQQ__Quote__c = quote.id;
            order.RecordTypeId = ORDER_CONTRAT_ACCUEIL_RT_ID;
            order.LPCR_InitAutoAvecDateDebut__c = false;
            insert order;

            OrderItem orderItem = UM002_TestDataFactory.createOrderProduct(pbEntry.id, order.Id, prod.id, 'One-Time', 100);
            orderItem.SBQQ__QuoteLine__c = qline.id;
            orderItem.SBQQ__Contract__c = contract.id;
            orderItem.ServiceDate = System.today();
            orderItem.EndDate = System.today().addMonths(1);
            orderItem.LPCR_FirstInvoiceEndDate__c = null;
            orderItem.LPCR_Creche__c = acc.Id;
            orderItem.Quantity = 2;
            orderItem.SBQQ__Activated__c = true;
            orderItem.blng__GroupId__c = acc.id + '' + contract.id + '' + accCreche.Id;
            orderItem.blng__InvoiceGroupId__c = acc.id + '' + contract.id + '' + accCreche.Id;
            insert orderItem;

            order.status = 'Activated';
            order.blng__BillNow__c = true;
            update order;

            // get Revenue Recognition Rule
            blng__RevenueRecognitionRule__c revRecogRule = [SELECT id FROM blng__RevenueRecognitionRule__c LIMIT 1];

            // crate GL Rule
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
            revRecogTreat.blng__RevenueRecognitionRule__c = revRecogRule.id;
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

            // create blng__FinancePeriod__c
            blng__FinancePeriod__c financePeriod = new blng__FinancePeriod__c();
            financePeriod.blng__PeriodStartDate__c = firstDayOfCurrentMonthDate;
            financePeriod.blng__PeriodEndDate__c = lastDayOfCurrentMonthDate;
            financePeriod.blng__FinanceBook__c = financeBook.id;
            financePeriod.blng__PeriodStatus__c = 'Open';
            financePeriod.Name = '08';

            insert financePeriod;

            // create blng__RevenueTransaction__c
            blng__RevenueTransaction__c revTrans = new blng__RevenueTransaction__c();
            revTrans.blng__OrderProduct__c = orderItem.id;
            revTrans.blng__Account__c = acc.id;
            revTrans.blng__Contract__c = contract.id;
            revTrans.blng__RevenueAmount__c = 100;
            revTrans.blng__RevenueFinancePeriod__c = financePeriod.id;
            revTrans.blng__RevenueSchedule__c = revSchedule.id;
            revTrans.blng__SystemPeriodStartDate__c = System.today();
            revTrans.LPCR_Amount__c = null;
            insert revTrans;

            // create blng__RevenueTransaction__c for credit note
            blng__RevenueTransaction__c revTransCreditNote = new blng__RevenueTransaction__c();
            revTransCreditNote.blng__OrderProduct__c = orderItem.id;
            revTransCreditNote.blng__Account__c = acc.id;
            revTransCreditNote.blng__SystemPeriodStartDate__c = System.today();
            revTransCreditNote.blng__Contract__c = contract.id;
            revTransCreditNote.blng__RevenueAmount__c = 100;
            revTransCreditNote.blng__RevenueFinancePeriod__c = financePeriod.id;
            revTransCreditNote.blng__RevenueSchedule__c = revSchedule.id;
            insert revTransCreditNote;

            APB022_ProrationForReportCommonFreq ss = new APB022_ProrationForReportCommonFreq();
            DataBase.executeBatch(ss);

            Test.stopTest();
            ss.execute(null);

            List<blng__RevenueTransaction__c> listRevTrans = new List<blng__RevenueTransaction__c>([SELECT Id, LPCR_Amount__c FROM blng__RevenueTransaction__c]);
            PAD.log('APB022_ProrationForReportCommon_Test', 'batchAPB022Test', 'listRevTrans.size():' + listRevTrans.size());
            PAD.log('APB022_ProrationForReportCommon_Test', 'batchAPB022Test', 'listRevTrans:' + listRevTrans);
        }

    }
}
