/**
* @author Saurabh
* @date 29/07/2020
* @Description Test class for APB012_ProcessRevenuCascade 
*/

@isTest
public class APB012_ProcessRevenuCascade_Test {
 	private static final Id B2C_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Famille);
    private static final Id OPP_ENTREPRISE_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Opportunity, Label.LPCR_Entreprise);
    private static final Id ACCOUNT_CRECHE_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Creche);
    private static final Id CONTACT_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contact, Label.LPCR_Parent);
    private static final Id QUOTE_CONTRAT_ACCUEIL_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote, Label.LPCR_ContratA);
    private static final Id ORDER_CONTRAT_ACCUEIL_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Order, Label.LPCR_ContratA);
    private static final Id standardPricebookId = Test.getStandardPricebookId();
    
        
    @testSetup
    static void testSetup(){
        List<Account> accounts = UM002_TestDataFactory.createAccounts(1, 'testAccount');
        accounts.get(0).RecordTypeId = B2C_RT_ID;
        
        List<Opportunity> opps = UM002_TestDataFactory.createOpportunities(1, 'testOpp', 'Prospecting');
        opps.get(0).recordTypeId = OPP_ENTREPRISE_RT_ID;
        insert accounts;
        insert opps;
        List<SBQQ__Quote__c> quotes = UM002_TestDataFactory.createQuotes(1, accounts, opps);
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
    public static void APB012_ProcessRevenuCascade_Test(){
        User testUser = UM002_TestDataFactory.createUser();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'LPCR_Admin' limit 1];
        insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps.Id);
        System.runAs(testUser){
            Date firstDayOfCurrentMonthDate = Date.newInstance(Date.today().Year(), Date.today().month() ,1) ;
            Date lastDayOfCurrentMonthDate=Date.newInstance(Date.today().Year(), Date.today().month() , Date.daysInMonth(Date.today().year(), Date.today().month())) ;

            Product2 prod = [SELECT Id FROM Product2 WHERE Name =: 'test' LIMIT 1];
            PricebookEntry pbEntry = [SELECT Id FROM PricebookEntry WHERE Product2Id =: prod.id LIMIT 1];

            Account acc = [SELECT Id,SBQQ__RenewalModel__c,RecordTypeId FROM Account WHERE Name =: 'testAccount' LIMIT 1];
            acc.SBQQ__RenewalModel__c = 'Contract Based';
            acc.RecordTypeId = B2C_RT_ID;
            acc.LPCR_ResponsableServiceFamille__c = UserInfo.getUserId();
            acc.LPCR_ProcessRevenuCascade__c = true;
            update acc;
			
            Account accCreche = UM002_TestDataFactory.createAccounts(1, 'testAccount1').get(0);
            accCreche.RecordTypeId = ACCOUNT_CRECHE_ID;
            accCreche.SBQQ__RenewalModel__c = 'Contract Based';
            insert accCreche;
            
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
            quote.RecordTypeId = QUOTE_CONTRAT_ACCUEIL_RT_ID;
            update quote;

            List<SBQQ__QuoteLine__c> qlines = new List<SBQQ__QuoteLine__c> ();
            qlines.add(UM002_TestDataFactory.createQuoteLine(prod.Id, quote.Id, pbEntry.Id, 200, 1));
            insert qlines;

            LPCR_RessourceFamille__c ressourceFamille = UM002_TestDataFactory.createRessourceFamille(firstDayOfCurrentMonthDate,acc.id,cont.id);
            insert ressourceFamille;

            Contract contract = UM002_TestDataFactory.createContract(acc.id,quote.id,opp.id,Date.Today().addmonths(3));
            contract.Status = 'Draft';
            Insert contract;

            contract.Status = 'Activated';
            update contract;

            Order order = UM002_TestDataFactory.createOrder(acc.Id, contract.id,date.today(),'test','Draft','1');
            order.Pricebook2Id = standardPricebookId;
            order.SBQQ__Quote__c = quote.id;
            order.RecordTypeId = ORDER_CONTRAT_ACCUEIL_RT_ID;
            insert order;
			Test.startTest();
            OrderItem orderItem = UM002_TestDataFactory.createOrderProduct(pbEntry.id, order.Id, prod.id, 'Recurring','Monthly', 100);
            orderItem.SBQQ__QuoteLine__c = qlines.get(0).id;
            orderItem.SBQQ__Contract__c = contract.id;
            orderItem.LPCR_Creche__c = acc.Id; 
            orderItem.SBQQ__Activated__c = false;
            orderItem.blng__GroupId__c = acc.id+''+contract.id+''+accCreche.Id;
            orderItem.blng__InvoiceGroupId__c = acc.id+''+contract.id+''+accCreche.Id;
            insert orderItem;
            orderItem.SBQQ__Activated__c = true;
            update orderItem;
            order.status ='Activated';
            update order;
            order.blng__BillNow__c = true;
            update order;

            // create billing invoice
            blng__Invoice__c invoice = new blng__Invoice__c();
            invoice.blng__Account__c = acc.Id;
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
            binLine.blng__BillingFrequency__c = 'Annual';
            binLine.blng__UnitPrice__c = 150;
            binLine.blng__Quantity__c =3;
            binLine.blng__StartDate__c = System.today();
            binLine.blng__OrderProduct__c = orderItem.id;
            binLine.blng__InvoiceLineStatus__c = 'Posted';
            binLine.blng__Product__c = prod.id;
            
            Insert binLine;
            invoice.blng__InvoiceStatus__c = 'Posted';
            update invoice;
            
            blng__CreditNote__c cn = new blng__CreditNote__c();
            cn.blng__Account__c = acc.id;
            cn.blng__Status__c = 'Draft';
            cn.blng__CreditNoteSourceAction__c = 'Negative Lines Conversion';
            cn.blng__RelatedInvoice__c = invoice.id;
            cn.blng__EffectiveTaxDate__c = System.today();
            cn.blng__CreditNoteDate__c = System.today();        
            Insert cn;
            
            blng__CreditNoteLine__c creditNoteLine = new blng__CreditNoteLine__c();
            creditNoteLine.blng__CreditNote__c = cn.id; 
            creditNoteLine.blng__Product__c = prod.Id;
            creditNoteLine.blng__InvoiceLine__c = binLine.id;
            creditNoteLine.blng__Status__c = 'Draft';
            insert creditNoteLine;
            
            cn.blng__Status__c = 'Posted';
            try{
                update cn;                 
            }catch(Exception ex){
                System.debug('*** Exception : '+ex.getMessage());                
            }       
            
            System.debug('*** Credit Note Status : '+cn.blng__Status__c);
            
            // get Revenue Recognition Rule
            blng__RevenueRecognitionRule__c revRecogRule = [select id from blng__RevenueRecognitionRule__c limit 1];
            
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
            revTrans.blng__InvoiceLine__c = binLine.id;
            revTrans.blng__Contract__c = contract.id;
            revTrans.blng__RevenueAmount__c = 100;            
            revTrans.blng__RevenueFinancePeriod__c = financePeriod.id;
            revTrans.blng__RevenueSchedule__c =  revSchedule.id;                        
            insert revTrans;
            
            // create blng__RevenueTransaction__c for credit note
            blng__RevenueTransaction__c revTransCreditNote = new blng__RevenueTransaction__c();
            revTransCreditNote.blng__OrderProduct__c = orderItem.id;
            revTransCreditNote.blng__Account__c = acc.id;
            revTransCreditNote.blng__CreditNoteLine__c = creditNoteLine.id;
            revTransCreditNote.blng__Contract__c = contract.id;
            revTransCreditNote.blng__RevenueAmount__c = 100;            
            revTransCreditNote.blng__RevenueFinancePeriod__c = financePeriod.id;
            revTransCreditNote.blng__RevenueSchedule__c =  revSchedule.id;
            insert revTransCreditNote;
            
           
            APB012_ProcessRevenuCascade ss = new APB012_ProcessRevenuCascade();
            DataBase.executeBatch(ss);
            APB012_ProcessRevenuCascade ss1 = new APB012_ProcessRevenuCascade();
            
            Test.stopTest();
			ss.execute(null);
            List<LPCR_RevenueCascade__c> revCascadeList = [SELECT Id, Name, LPCR_Compte__c, LPCR_CreditNoteLineAggregation__c, LPCR_CreditNoteRevenue__c, LPCR_DateDebut__c, LPCR_MontantFacture__c, LPCR_OrderInvoiceRevenue__c, LPCR_OrderLineAggregation__c, LPCR_OrderLineGroup__c, LPCR_PCA__c FROM LPCR_RevenueCascade__c];
            System.assertEquals(1, revCascadeList.size(),'APB012_ProcessRevenuCascade_Test : RevenueTransaction upsert fail');
            
        }
    }
}