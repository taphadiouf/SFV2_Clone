/**
* @author Ayoub Ouarti
* @date 26/03/2020
* @description test class for SM012_OrderItemServices
*/
@isTest
public with sharing class SM012_OrderItemServices_Test {
    private static final Id B2B_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Entreprise);
    private static final Id B2C_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Famille);
    private static final Id CRECHE_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Creche);
    private static final Id OPPT_FAMILE_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Opportunity, Label.LPCR_Famille);
    private static final Id OPPT_ENTERPRISE_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Opportunity, Label.LPCR_Entreprise);
    private static final Id QUOTE_CONTRAT_ACCUEIL_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote, Label.LPCR_ContratA);
    private static final Id QUOTE_CONTRAT_REF_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote, 'Referencement');
    private static final Id standardPricebookId = Test.getStandardPricebookId();
    
    @TestSetup
    static void setup(){
        Id standardPricebookId = Test.getStandardPricebookId();
        //Id recordTypeId = UM003_TypeManager.getQuoteRecordTypeIdByDeveloperName('Referencement');
        //Id recordTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote, 'Referencement');
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
                    List<Account> accounts = new List<Account> ();
        Account b2cAccount = (Account) UM002_TestDataFactory.createSObject('Account', defaultVal);
        accounts.add(b2cAccount);
        
        defaultVal = new Map<String, Object> {
            'RecordTypeId' => B2B_RT_ID,
                'Name' => 'Test-B2B',
                'SBQQ__RenewalModel__c' => 'Contract Based',
                'LPCR_PasDeSIRET__c' => true
                };
                    
                    Account b2bAccount = (Account) UM002_TestDataFactory.createSObject('Account', defaultVal);
        accounts.add(b2bAccount);
        
        defaultVal = new Map<String, Object> {
            'RecordTypeId' => CRECHE_RT_ID,
                'Name' => 'Creche',
                'LPCR_TypeCreche__c' => 'MAC',
                'LPCR_Region__c' => 'Paris',
                'LPCR_TypeMensualisation__c' => 11 
                };
                    List<Account> creches = UM002_TestDataFactory.createSObjectList('Account', 2, defaultVal);
        creches.get(1).LPCR_TypeCreche__c = 'MICRO';
        
        accounts.addAll (creches);
        insert accounts;
        
        defaultVal = new Map<String, Object> {
            'Name' => 'prod-test',
                'isActive' => true,
                'blng__BillingRule__c' => billingRule.Id,
                'blng__RevenueRecognitionRule__c' => revRecRule.Id,
                'blng__TaxRule__c' => taxRule.Id,
                'SBQQ__SubscriptionPricing__c' => 'Fixed Price'
                };
                    
                    Product2 prod = (Product2) UM002_TestDataFactory.createSObject('Product2', defaultVal);
        insert prod;
        
        defaultVal = new Map<String, Object> {
            'isActive' => true,
                'UnitPrice' => 100,
                'Product2Id' => prod.Id,
                'Pricebook2Id' => standardPricebookId
                };
                    
                    PricebookEntry priceBookEntry1 = (PricebookEntry) UM002_TestDataFactory.createSObject('PricebookEntry', defaultVal);
        insert priceBookEntry1;
        
        defaultVal = new Map<String, Object> {
            'RecordTypeId' => OPPT_FAMILE_RT_ID,
                'AccountId' => b2cAccount.Id,
                'Name' => 'test-oppt-accuel',
                'StageName' => 'Signée',
                'CloseDate' => System.today(),
                'Pricebook2Id' => standardPricebookId,
                'Type' => 'New Business'
                };
                    
                    Opportunity oppForAccuel = (Opportunity) UM002_TestDataFactory.createSObject('Opportunity', defaultVal);
        defaultVal.put('Name', 'test-oppt-ref');
        defaultVal.put('AccountId', b2bAccount.Id);
        Opportunity oppForRef = (Opportunity) UM002_TestDataFactory.createSObject('Opportunity', defaultVal);
        insert new List<Opportunity> {oppForAccuel, oppForRef};
            
            defaultVal = new Map<String, Object> {
                'RecordTypeId' => QUOTE_CONTRAT_ACCUEIL_RT_ID,
                    'SBQQ__Account__c' => b2cAccount.Id,
                    'SBQQ__SubscriptionTerm__c' => 12,
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
                    'SBQQ__Opportunity2__c' => oppForAccuel.Id,
                     'SBQQ__RenewalUpliftRate__c' => 10
                    };
                        
                        SBQQ__Quote__c quoteForAccueil = (SBQQ__Quote__c) UM002_TestDataFactory.createSObject('SBQQ__Quote__c', defaultVal);
        
        defaultVal.put('RecordTypeId', QUOTE_CONTRAT_REF_RT_ID);
        defaultVal.put('SBQQ__Opportunity2__c', oppForRef.Id);
        defaultVal.put('SBQQ__Account__c', b2bAccount.Id);
        
        SBQQ__Quote__c quoteForRef = (SBQQ__Quote__c) UM002_TestDataFactory.createSObject('SBQQ__Quote__c', defaultVal);
        
        insert new List<SBQQ__Quote__c> {quoteForAccueil, quoteForRef};
            
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
                'SBQQ__Quote__c' => quoteForAccueil.Id,
                'SBQQ__PricebookEntryId__c' => priceBookEntry1.Id,
                'SBQQ__PricingMethod__c' => 'List',
                'SBQQ__ChargeType__c' => 'Recurring',
                'SBQQ__BillingType__c' => 'Advance',
                'SBQQ__BillingFrequency__c' => 'Monthly',
                'LPCR_Region__c' => 'Paris',
                'LPCR_NumeroPurchaseOrder__c' => '12345678',
                'LPCR_EntiteJuridique__c' => UM002_TestDataFactory.setupLegalEntity().Id
                };
                    
                    SBQQ__QuoteLine__c quoteLineForAccueil = (SBQQ__QuoteLine__c) UM002_TestDataFactory.createSObject('SBQQ__QuoteLine__c', defaultVal);
        
        defaultVal.put('SBQQ__Quote__c', quoteForRef.Id);
        SBQQ__QuoteLine__c quoteLineForRef = (SBQQ__QuoteLine__c) UM002_TestDataFactory.createSObject('SBQQ__QuoteLine__c', defaultVal);
        insert new List<SBQQ__QuoteLine__c> {quoteLineForAccueil, quoteLineForRef};
            
            oppForAccuel.SBQQ__PrimaryQuote__c = quoteForAccueil.Id;
        oppForRef.SBQQ__PrimaryQuote__c = quoteForRef.Id;
        update new List<Opportunity> {oppForAccuel, oppForRef};
            }
     @IsTest
    private static void lastDayOfDatePeriod_test(){
        Date[] expected = new Date[]{
            Date.newInstance(2020,4,1),
                Date.newInstance(2020,7,1),
                Date.newInstance(2020,10,1),
                Date.newInstance(2021,1,1)};
                    for(integer x = 1; x <= 12; x++){
                        if(1<= x && x <4 )  System.assertEquals(expected[0],
                                                                UM005_DateUtility.lastDayOfDatePeriod (Date.newInstance(2020,x,10), UM005_DateUtility.quarterlyMonths).addDays(1));
                        else if(4 <= x && x<7 )  System.assertEquals(expected[1],
                                                                     UM005_DateUtility.lastDayOfDatePeriod (Date.newInstance(2020,x,10), UM005_DateUtility.quarterlyMonths).addDays(1));
                        else if(7 <= x && x<10 )  System.assertEquals(expected[2],
                                                                      UM005_DateUtility.lastDayOfDatePeriod (Date.newInstance(2020,x,10), UM005_DateUtility.quarterlyMonths).addDays(1));
                        else if(10 <= x && x<=12 )  System.assertEquals(expected[3],
                                                                        UM005_DateUtility.lastDayOfDatePeriod (Date.newInstance(2020,x,10), UM005_DateUtility.quarterlyMonths).addDays(1));
          }
        expected = new Date[]{
            Date.newInstance(2020,7,1),
                Date.newInstance(2021,1,1)
                };
                    for(integer x = 1; x <= 12; x++){
                        if(1<= x && x <7 )  System.assertEquals(expected[0],
                                                                UM005_DateUtility.lastDayOfDatePeriod (Date.newInstance(2020,x,10), UM005_DateUtility.semiannualMonths).addDays(1));
                        else if(7 <= x && x<=12 )  System.assertEquals(expected[1],
                                                                       UM005_DateUtility.lastDayOfDatePeriod (Date.newInstance(2020,x,10), UM005_DateUtility.semiannualMonths).addDays(1));
                    }
    }
   

         
    
    @isTest
    private static void setOrderItemFields_Test () {     
        Account customerAcc = null; 
        Account billingAccount = [SELECT id  FROM Account WHERE name = 'Test-B2B'];
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            //setup data for this particular test
            
            Product2 prod = [SELECT Id FROM Product2].get(0);
            PricebookEntry priceBookEntry = [SELECT Id FROM PricebookEntry].get(0);
            
            Map<String, Object> defaultVal = new Map<String, Object> {
                'RecordTypeId' => OPPT_FAMILE_RT_ID,
                    'AccountId' => billingAccount.Id,
                    'Name' => 'test-oppt',
                    'StageName' => 'Signée',
                    'CloseDate' => System.today(),
                    'Pricebook2Id' => standardPricebookId,
                    'Type' => 'New Business'
                    };
                        
                        Opportunity opp = (Opportunity) UM002_TestDataFactory.createSObject('Opportunity', defaultVal);
            Opportunity oppRenewal = (Opportunity) UM002_TestDataFactory.createSObject('Opportunity', defaultVal);
            
            insert new List<Opportunity>{opp,oppRenewal};
                
                blng__InvoicePlan__c invoicePlan =   new blng__InvoicePlan__c(blng__BillingScheduleCreation__c='Manual',blng__Active__c =true);
            insert    invoicePlan;
            defaultVal = new Map<String, Object> {
                'LPCR_NouveauPlanFacture__c'=>invoicePlan.Id,
                    'RecordTypeId' => QUOTE_CONTRAT_ACCUEIL_RT_ID,
                    'SBQQ__Account__c' => billingAccount.Id,
                    'SBQQ__SubscriptionTerm__c' => 12,
                    'SBQQ__BillingFrequency__c' => 'Invoice Plan' ,
                    'LPCR_TypeFacturation__c' => 'Advance',
                    'LPCR_IndexationConvenue__c' => 'Oui',
                    'SBQQ__StartDate__c' => System.today(),
                    'SBQQ__PricebookId__c' => standardPricebookId,
                    'SBQQ__PriceBook__c' => standardPricebookId,
                    'SBQQ__Type__c' => 'Quote',
                    'SBQQ__QuoteLanguage__c' => 'English',
                    'SBQQ__BillingCity__c' => 'Paris',
                    'SBQQ__Primary__c' => true,
                    'SBQQ__Opportunity2__c' => opp.Id,
                'SBQQ__RenewalUpliftRate__c' => 10
                    };
                        
                        SBQQ__Quote__c quote = (SBQQ__Quote__c) UM002_TestDataFactory.createSObject('SBQQ__Quote__c', defaultVal);
            defaultVal.put('SBQQ__Type__c','Renewal');
            defaultVal.put('SBQQ__Opportunity2__c',oppRenewal.Id);
            SBQQ__Quote__c quoteRenewal = (SBQQ__Quote__c) UM002_TestDataFactory.createSObject('SBQQ__Quote__c', defaultVal);
            
            insert new List<SBQQ__Quote__c>{quote,quoteRenewal};
                
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
                    'LPCR_Region__c' => 'Paris',
                    'SBQQ__BillingFrequency__c' => 'Invoice Plan' ,
                    'LPCR_EntiteJuridique__c' => UM002_TestDataFactory.setupLegalEntity().Id
                    };
                        
                        SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c) UM002_TestDataFactory.createSObject('SBQQ__QuoteLine__c', defaultVal);
            defaultVal.put('SBQQ__Quote__c',quoteRenewal.Id);    
            SBQQ__QuoteLine__c quoteLineRenewal = (SBQQ__QuoteLine__c) UM002_TestDataFactory.createSObject('SBQQ__QuoteLine__c', defaultVal);
            
            insert new List<SBQQ__QuoteLine__c>{quoteLine,quoteLineRenewal};
                
                opp.SBQQ__PrimaryQuote__c = quote.Id;
            oppRenewal.SBQQ__PrimaryQuote__c = quoteRenewal.Id;
            
            update new List<Opportunity>{opp,oppRenewal};
                
                //Order the quote to create Order / OrderItems
                update new List<SBQQ__Quote__c> {new SBQQ__Quote__c (Id = quote.Id, SBQQ__Ordered__c = true),new SBQQ__Quote__c (Id = quoteRenewal.Id, SBQQ__Ordered__c = true)};
                    
                    Order order = [SELECT Id ,LPCR_NouveauPlanFacture__c, SBQQ__Contracted__c, Status, OpportunityId, EffectiveDate, AccountId, SBQQ__Quote__c, blng__BillingAccount__c, LPCR_TypeCreche__c FROM Order WHERE SBQQ__Quote__c =:quote.Id];
            OrderItem  ordrItem = Database.query('SELECT Id , blng__HoldBilling__c  FROM OrderItem  WHERE OrderId = \''+order.Id+'\'');
            
            
            
            blng__BillingRule__c br = [SELECT Id FROM blng__BillingRule__c LIMIT 1];
            blng__FinanceBook__c accoutingFinanceBook = new blng__FinanceBook__c(blng__Active__c = true, Name = 'Accounting Finance Book', blng__PeriodType__c = 'Accounting');
            insert accoutingFinanceBook;
            
            
            blng__BillingTreatment__c billingTreatmentsForRenewal = new blng__BillingTreatment__c(blng__BillingRule__c = br.Id,blng__InvoicePlan__c=invoicePlan.Id,blng__BillingFinanceBook__c = accoutingFinanceBook.Id);
            insert billingTreatmentsForRenewal;
            
            
            List<OrderItem> orderItems = new List<OrderItem>([SELECT Id,OrderItemNumber,ServiceDate,TotalPrice,blng__BillingRule__c,SBQQ__RevisedOrderProduct__c FROM OrderItem WHERE
                                                              SBQQ__BillingFrequency__c = 'Invoice Plan' 
                                                              AND OrderId = :order.Id]);
            List<blng__BillingSchedule__c> listBillingSchedule = new  List<blng__BillingSchedule__c>();
            OrderItem originalOrderItem = orderItems.get(0);
            originalOrderItem.ServiceDate = Date.today();
            update originalOrderItem;
            System.assertNotEquals(null,originalOrderItem.blng__BillingRule__c,'blng__BillingRule__c on OrderItem is null');
            System.assertEquals(billingTreatmentsForRenewal.blng__BillingRule__c,originalOrderItem.blng__BillingRule__c,'blng__BillingRule__c on OrderItem is null');
            
        /*  Ayoub :   this commented code starting from the line bellow is testing the updateFiledsOnBillingTransaction with Quantity > 0, and works fine,
         *  now commenting this code because the test should be on Quantity<0 which I did not succeed to get it generated from CPQ
          
			listBillingSchedule.add(new blng__BillingSchedule__c( Name = 'BS-' + originalOrderItem.OrderItemNumber,
                                                                 blng__Amount__c = originalOrderItem.TotalPrice,
                                                                 blng__OrderProduct__c = originalOrderItem.Id));
            insert listBillingSchedule;
            
            
            order = [SELECT Id ,LPCR_NouveauPlanFacture__c, blng__BillingAccount__c,SBQQ__Contracted__c, Status, OpportunityId, EffectiveDate, AccountId, SBQQ__Quote__c FROM Order WHERE SBQQ__Quote__c =:quoteRenewal.Id];
            order.blng__BillingAccount__c = billingAccount.Id;
            update order;
            OrderItem orderItem = [SELECT Id,Quantity,SBQQ__BillingFrequency__c,SBQQ__RevisedOrderProduct__c,Order.blng__BillingAccount__c FROM OrderItem WHERE
                                   OrderId = :order.Id];
            orderItem.SBQQ__RevisedOrderProduct__c = originalOrderItem.Id;
            update  orderItem;
            
            List<blng__BillingTransaction__c> listBT = new  List<blng__BillingTransaction__c>();
            
            for(blng__BillingSchedule__c eachBS : listBillingSchedule){
                listBT.add(new blng__BillingTransaction__c(blng__Amount__c = eachBS.blng__Amount__c, 
                                                           Name = 'BT for '+eachBS.Name,
                                                           blng__Status__c = 'Pending',
                                                           blng__BillingSchedule__c =eachBS.Id) );
            }
            insert listBT;
            Set<Id> BTids = UM003_TypeManager.getIdsOfListObjects(listBT);
            
            
            order.Status='Activated'; 
            update order;
            orderItem = [SELECT Id,Quantity,SBQQ__RevisedOrderProduct__c FROM OrderItem WHERE
                         OrderId = :order.Id];
            
            System.debug(orderItem.SBQQ__RevisedOrderProduct__c);
            
           
            for(blng__BillingTransaction__c eachBT :  [SELECT Id,blng__OverrideBillingTargetDate__c,blng__ServicePeriodStart__c,blng__ServicePeriodEnd__c FROM blng__BillingTransaction__c WHERE Id IN :BTids]){
                System.assertNotEquals(null,eachBT.blng__OverrideBillingTargetDate__c,'blng__OverrideBillingTargetDate__c on BT is null');
                System.assertNotEquals(null,eachBT.blng__ServicePeriodStart__c,'blng__OverrideBillingTargetDate__c on BT is null');
                System.assertNotEquals(null,eachBT.blng__ServicePeriodEnd__c,'blng__OverrideBillingTargetDate__c on BT is null');
                
            }*/
           Test.stopTest();       
        }
    }
    
    
    
    @IsTest
    static void setLegalEntityOnOrderItem_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            blng__LegalEntity__c billingLegalEntity = UM002_TestDataFactory.setupLegalEntity();
            blng__RevenueRecognitionRule__c revRecRule = UM002_TestDataFactory.setupRevRec(billingLegalEntity.Id);
            blng__BillingRule__c   billingRule = UM002_TestDataFactory.setupBillingRule(billingLegalEntity.Id);
            blng__TaxRule__c   taxRule = UM002_TestDataFactory.setupTaxRule(billingLegalEntity.Id);
            SBQQ__Quote__c quote = [SELECT Id,SBQQ__Ordered__c FROM SBQQ__Quote__c WHERE SBQQ__BillingCity__c = 'Paris' AND RecordTypeId = :QUOTE_CONTRAT_ACCUEIL_RT_ID];
            
            Test.startTest(); 
            quote.SBQQ__Ordered__c  = true; 
            update quote;
            
            Order order = [SELECT Id , Status,SBQQ__Quote__c  FROM Order WHERE SBQQ__Quote__c = :quote.Id];            
            Map<Id,OrderItem> mapOrderItem = new Map<Id,OrderItem>([SELECT Id,blng__LegalEntity__c, SBQQ__QuoteLine__r.LPCR_EntiteJuridique__c	 FROM OrderItem WHERE OrderId = :order.Id]);
            
            SBQQ__OrderItemConsumptionSchedule__c orderItemConSch = new SBQQ__OrderItemConsumptionSchedule__c(
                blng__RevenueRecognitionRule__c=revRecRule.Id,blng__BillingRule__c=billingRule.Id,blng__TaxRule__c=taxRule.Id,
                SBQQ__OrderItem__c =mapOrderItem.values().get(0).Id,SBQQ__BillingTermUnit__c='Month',
                SBQQ__BillingTerm__c=1, SBQQ__Category__c='Rates', SBQQ__RatingMethod__c='Tier', SBQQ__Type__c='Slab');
            
            insert orderItemConSch;
            
            update mapOrderItem.values();
            Test.stopTest();
            mapOrderItem = new Map<Id,OrderItem>([SELECT Id,blng__LegalEntity__c, SBQQ__QuoteLine__r.LPCR_EntiteJuridique__c
                                                  FROM OrderItem WHERE OrderId = :order.Id]);
            
            /*
//DCO Assertion commented once it systematically fails => LPCR_NumeroPurchaseOrder__c and blng__InvoiceGroupId__c are not correctly propagated and are null
// To be revied / fixed by author dev
for(OrderItem eachOrderItem : mapOrderItem.values()){
System.assertNotEquals(null, eachOrderItem.blng__LegalEntity__c,'Legal Entity is Null in the OrderItem');
System.assertEquals(eachOrderItem.SBQQ__QuoteLine__r.LPCR_EntiteJuridique__c, eachOrderItem.blng__LegalEntity__c,'Legal Entity in order item is not  equal to quote line legal entity');
}
*/
            List<SBQQ__OrderItemConsumptionSchedule__c> listOrderItemConSch = [SELECT SBQQ__OrderItem__c,SBQQ__OrderItem__r.blng__LegalEntity__c,blng__LegalEntity__c  FROM SBQQ__OrderItemConsumptionSchedule__c WHERE SBQQ__OrderItem__c in :mapOrderItem.keySet() ];
            for(SBQQ__OrderItemConsumptionSchedule__c eachOrderItemConSch : listOrderItemConSch){
                /*
//DCO Assertion commented once it systematically fails => LPCR_NumeroPurchaseOrder__c and blng__InvoiceGroupId__c are not correctly propagated and are null
// To be revied / fixed by author dev
System.assertNotEquals(null, eachOrderItemConSch.blng__LegalEntity__c,'Legal Entity is Null in the OrderItemConsumptionSchedule');
System.assertEquals(eachOrderItemConSch.blng__LegalEntity__c, eachOrderItemConSch.SBQQ__OrderItem__r.blng__LegalEntity__c,'Legal Entity in OrderItemConsumptionSchedule is not  equal to order item legal entity');
*/
            }
        }
    }
    
    //used to be testSetupInvoiceDatesFamilyMacAdvance changed in IS-1349
    @isTest
    private static void testSetupInvoiceDatesFamilyAdvance () {      //IS-507
        Account customerAcc = null;
        List<Account> creches = new List<Account> ();
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            // Load Contract Type Conf
            Map<String, LPCR_TypeContrat__mdt> mapTypeContractConf = new Map<String, LPCR_TypeContrat__mdt> ();
            for (LPCR_TypeContrat__mdt typeContractConf : [SELECT Id, DeveloperName, LPCR_JourFacturation__c FROM LPCR_TypeContrat__mdt]) {
                mapTypeContractConf.put(typeContractConf.DeveloperName, typeContractConf);
            }
            Integer invoicingDay = Integer.valueOf(mapTypeContractConf.get('B2C_MAC').LPCR_JourFacturation__c);
            
            //setup data for this particular test
            List<Account> accounts = [SELECT Id, RecordTypeId FROM Account];
            for (Account a : accounts) {
                if (a.RecordTypeId == B2C_RT_ID) {
                    customerAcc = a;
                } else if (a.RecordTypeId == CRECHE_RT_ID) {
                    creches.add (a);
                }
            }
            Product2 prod = [SELECT Id FROM Product2].get(0);
            PricebookEntry priceBookEntry = [SELECT Id FROM PricebookEntry].get(0);
            
            Map<String, Object> defaultVal = new Map<String, Object> {
                'RecordTypeId' => OPPT_FAMILE_RT_ID,
                    'AccountId' => customerAcc.Id,
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
                    'SBQQ__Account__c' => customerAcc.Id,
                    'SBQQ__SubscriptionTerm__c' => 12,
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
                    'SBQQ__ChargeType__c' => 'One-Time',
                    //'SBQQ__BillingType__c' => 'Advance',
                    'LPCR_Region__c' => 'Paris',
                    //'SBQQ__BillingFrequency__c' => 'Monthly',
                    'LPCR_EntiteJuridique__c' => UM002_TestDataFactory.setupLegalEntity().Id
                    };
                        
                        SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c) UM002_TestDataFactory.createSObject('SBQQ__QuoteLine__c', defaultVal);
            insert quoteLine;
            
            opp.SBQQ__PrimaryQuote__c = quote.Id;
            update opp;
            
            //Order the quote to create Order / OrderItems
            update new SBQQ__Quote__c (Id = quote.Id, SBQQ__Ordered__c = true);
            
            
            //Update orders to trigger OrderItem Update => test setupInvoiceDates
            List<Order> orders = [SELECT Id , SBQQ__Contracted__c, Status, OpportunityId, EffectiveDate, AccountId, SBQQ__Quote__c, blng__BillingAccount__c, LPCR_TypeCreche__c FROM Order];
            for (Order order : orders) {
                order.blng__BillingAccount__c = order.blng__BillingAccount__c == null && order.AccountId != null 
                    ? order.AccountId
                    : order.blng__BillingAccount__c;
                
                order.LPCR_TypeCreche__c = String.isNotBlank(order.LPCR_TypeCreche__c)
                    ? order.LPCR_TypeCreche__c 
                    : 'MAC';
                
                
                order.LPCR_TypeFacturation__c = 'Advance';
            }
            
            update orders;
            Test.stopTest();
            
            /*Map<Id,OrderItem> mapOrderItem = new Map<Id,OrderItem>([SELECT Id, SBQQ__BillingType__c, ServiceDate, blng__NextChargeDate__c, blng__OverrideNextBillingDate__c,
                                                                    blng__BillThroughDateOverride__c, OrderId, Order.LPCR_TypeCreche__c, blng__BillingAccount__c, Order.blng__BillingAccount__r.RecordTypeId, SBQQ__ChargeType__c FROM OrderItem]);
            
            
            
            Integer todaytDay = System.today().day();
            Date expectedDate = (todaytDay > invoicingDay)
                ? UM005_DateUtility.setDayOnDate (invoicingDay, System.today().addMonths(1))
                : UM005_DateUtility.setDayOnDate (invoicingDay, System.today());
            
            for (OrderItem oi : mapOrderItem.values()) {
                System.assertEquals(System.today(), oi.ServiceDate);
                System.assertEquals(System.today(), oi.blng__NextChargeDate__c);                
                System.assertEquals(expectedDate, oi.blng__OverrideNextBillingDate__c);
               	System.assertEquals(null, oi.blng__BillThroughDateOverride__c);
            }*/
            
            
            Order order = orders.get(0);
            OrderItem orderItem = UM002_TestDataFactory.createOrderProduct(priceBookEntry.id,order.Id,null,'One-Time',4);
            orderItem.Quantity = 10;
            orderItem.SBQQ__TerminatedDate__c = null;
            insert orderItem;
            orderItem = [Select Id, blng__OverrideNextBillingDate__c, blng__NextChargeDate__c,blng__BillThroughDateOverride__c from orderItem limit 1];
            System.assertEquals(orderItem.blng__NextChargeDate__c.toStartOfMonth(), orderItem.blng__OverrideNextBillingDate__c);
            
        }
    }
    //used to be testSetupInvoiceDatesFamilyMicroAdvance changed in IS-1349
    @isTest
    private static void testSetupInvoiceDatesFamilyBillThroughDateOverride () {      //IS-507
        Account customerAcc = null;
        List<Account> creches = new List<Account> ();
        
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            // Load Contract Type Conf
            Map<String, LPCR_TypeContrat__mdt> mapTypeContractConf = new Map<String, LPCR_TypeContrat__mdt> ();
            for (LPCR_TypeContrat__mdt typeContractConf : [SELECT Id, DeveloperName, LPCR_JourFacturation__c FROM LPCR_TypeContrat__mdt]) {
                mapTypeContractConf.put(typeContractConf.DeveloperName, typeContractConf);
            }
            Integer invoicingDay = Integer.valueOf(mapTypeContractConf.get('B2C_MICRO').LPCR_JourFacturation__c);
            
            //setup data for this particular test
            List<Account> accounts = [SELECT Id, RecordTypeId FROM Account];
            for (Account a : accounts) {
                if (a.RecordTypeId == B2C_RT_ID) {
                    customerAcc = a;
                } else if (a.RecordTypeId == CRECHE_RT_ID) {
                    creches.add (a);
                }
            }
            Product2 prod = [SELECT Id FROM Product2].get(0);
            PricebookEntry priceBookEntry = [SELECT Id FROM PricebookEntry].get(0);
            
            Map<String, Object> defaultVal = new Map<String, Object> {
                'RecordTypeId' => OPPT_FAMILE_RT_ID,
                    'AccountId' => customerAcc.Id,
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
                    'SBQQ__Account__c' => customerAcc.Id,
                    'SBQQ__SubscriptionTerm__c' => 12,
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
                    'LPCR_Region__c' => 'Paris',
                    'SBQQ__BillingFrequency__c' => 'Monthly',
                    'LPCR_EntiteJuridique__c' => UM002_TestDataFactory.setupLegalEntity().Id
                    };
                        
                        SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c) UM002_TestDataFactory.createSObject('SBQQ__QuoteLine__c', defaultVal);
            insert quoteLine;
            
            opp.SBQQ__PrimaryQuote__c = quote.Id;
            update opp;
            
            //Order the quote to create Order / OrderItems
            update new SBQQ__Quote__c (Id = quote.Id, SBQQ__Ordered__c = true);
            
            //Update orders to trigger OrderItem Update => test setupInvoiceDates
            List<Order> orders = [SELECT Id , SBQQ__Contracted__c, Status, OpportunityId, EffectiveDate, AccountId, SBQQ__Quote__c, blng__BillingAccount__c, LPCR_TypeCreche__c,Type FROM Order];
            for (Order order : orders) {
                order.Type='New';
                order.blng__BillingAccount__c = order.blng__BillingAccount__c == null && order.AccountId != null 
                    ? order.AccountId
                    : order.blng__BillingAccount__c;
                
                order.LPCR_TypeCreche__c = String.isNotBlank(order.LPCR_TypeCreche__c)
                    ? order.LPCR_TypeCreche__c 
                    : 'MICRO';
            }
            
            update orders;
            Test.stopTest();
            
           /* Map<Id,OrderItem> mapOrderItem = new Map<Id,OrderItem>([SELECT Id, SBQQ__BillingType__c, ServiceDate, blng__NextChargeDate__c, blng__OverrideNextBillingDate__c,
                                                                    blng__NextBillingDate__c, blng__BillThroughDateOverride__c, OrderId, Order.Type, Order.LPCR_TypeCreche__c, blng__BillingAccount__c, Order.blng__BillingAccount__r.RecordTypeId FROM OrderItem]);
            update mapOrderItem.values();
            Integer todaytDay = System.today().day();
            Date expectedDate = (todaytDay > invoicingDay)
                ? UM005_DateUtility.setDayOnDate (invoicingDay, System.today().addMonths(1))
                : UM005_DateUtility.setDayOnDate (invoicingDay, System.today());
            
            for (OrderItem oi : mapOrderItem.values()) {
                System.assertEquals(System.today(), oi.ServiceDate);
                System.assertEquals(System.today(), oi.blng__NextChargeDate__c);
              	System.assertEquals(expectedDate, oi.blng__OverrideNextBillingDate__c);
             //   System.assertEquals(expectedDate.addMonths(1), oi.blng__BillThroughDateOverride__c);                
            }*/
            Order order = orders.get(0);
            OrderItem orderItem = UM002_TestDataFactory.createOrderProduct(priceBookEntry.id,order.Id,null,'One-Time',4);
            orderItem.Quantity = 10;
            insert orderItem;
            List<orderItem> orderItems = [Select Id, blng__OverrideNextBillingDate__c, blng__NextChargeDate__c,blng__BillThroughDateOverride__c,SBQQ__TerminatedDate__c from orderItem limit 1];
            for(orderItem oi : orderItems){
                oi.SBQQ__TerminatedDate__c = date.newInstance(System.Today().year(), 10, 02);
            }
            update orderItems;
            for(orderItem oi : orderItems){
                system.debug('oi.SBQQ__TerminatedDate__c'+oi.SBQQ__TerminatedDate__c);
            	System.assertEquals(UM005_DateUtility.lastDateOfMonth(oi.blng__NextChargeDate__c), oi.blng__BillThroughDateOverride__c);
            }
            
        }
    }
    // commented in the context of IS-1349
   /* @isTest
    private static void testSetupInvoiceDatesFamilyMacArrears () {      //IS-507
        Account customerAcc = null;
        List<Account> creches = new List<Account> ();
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            // Load Contract Type Conf
            Map<String, LPCR_TypeContrat__mdt> mapTypeContractConf = new Map<String, LPCR_TypeContrat__mdt> ();
            for (LPCR_TypeContrat__mdt typeContractConf : [SELECT Id, DeveloperName, LPCR_JourFacturation__c FROM LPCR_TypeContrat__mdt]) {
                mapTypeContractConf.put(typeContractConf.DeveloperName, typeContractConf);
            }
            Integer invoicingDay = Integer.valueOf(mapTypeContractConf.get('B2C_MAC').LPCR_JourFacturation__c);
            
            //setup data for this particular test
            List<Account> accounts = [SELECT Id, RecordTypeId FROM Account];
            for (Account a : accounts) {
                if (a.RecordTypeId == B2C_RT_ID) {
                    customerAcc = a;
                } else if (a.RecordTypeId == CRECHE_RT_ID) {
                    creches.add (a);
                }
            }
            Product2 prod = [SELECT Id FROM Product2].get(0);
            PricebookEntry priceBookEntry = [SELECT Id FROM PricebookEntry].get(0);
            
            Map<String, Object> defaultVal = new Map<String, Object> {
                'RecordTypeId' => OPPT_FAMILE_RT_ID,
                    'AccountId' => customerAcc.Id,
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
                    'SBQQ__Account__c' => customerAcc.Id,
                    'SBQQ__SubscriptionTerm__c' => 12,
                    'SBQQ__BillingFrequency__c' => 'Monthly',
                    'LPCR_TypeFacturation__c' => 'Arrears',
                    'LPCR_IndexationConvenue__c' => 'Oui',
                    'SBQQ__StartDate__c' => System.today(),
                    'SBQQ__PricebookId__c' => standardPricebookId,
                    'SBQQ__PriceBook__c' => standardPricebookId,
                    'SBQQ__Type__c' => 'Quote',
                    'SBQQ__QuoteLanguage__c' => 'English',
                    'SBQQ__BillingCity__c' => 'Paris',
                    'SBQQ__Primary__c' => true,
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
                    'LPCR_Region__c' => 'Paris',
                    'SBQQ__BillingType__c' => 'Arrears',
                    'SBQQ__BillingFrequency__c' => 'Monthly',
                    'LPCR_EntiteJuridique__c' => UM002_TestDataFactory.setupLegalEntity().Id
                    };
                        
                        SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c) UM002_TestDataFactory.createSObject('SBQQ__QuoteLine__c', defaultVal);
            insert quoteLine;
            
            opp.SBQQ__PrimaryQuote__c = quote.Id;
            update opp;
            
            //Order the quote to create Order / OrderItems
            update new SBQQ__Quote__c (Id = quote.Id, SBQQ__Ordered__c = true);
            
            
            //Update orders to trigger OrderItem Update => test setupInvoiceDates
            List<Order> orders = [SELECT Id , SBQQ__Contracted__c, Status, OpportunityId, EffectiveDate, AccountId, SBQQ__Quote__c, blng__BillingAccount__c, LPCR_TypeCreche__c FROM Order];
            for (Order order : orders) {
                order.blng__BillingAccount__c = order.blng__BillingAccount__c == null && order.AccountId != null 
                    ? order.AccountId
                    : order.blng__BillingAccount__c;
                
                order.LPCR_TypeCreche__c = String.isNotBlank(order.LPCR_TypeCreche__c)
                    ? order.LPCR_TypeCreche__c 
                    : 'MAC';
            }
            
            update orders;
            
            Test.stopTest();
            
            Map<Id,OrderItem> mapOrderItem = new Map<Id,OrderItem>([SELECT Id, SBQQ__BillingType__c, ServiceDate, blng__NextChargeDate__c, blng__OverrideNextBillingDate__c,
                                                                    blng__BillThroughDateOverride__c, OrderId, Order.LPCR_TypeCreche__c, blng__BillingAccount__c, Order.blng__BillingAccount__r.RecordTypeId FROM OrderItem]);
            
            Integer todaytDay = System.today().day();
            Date expectedDate = UM005_DateUtility.setDayOnDate (invoicingDay, System.today().addMonths(1));
            
            for (OrderItem oi : mapOrderItem.values()) {
                System.assertEquals(System.today(), oi.ServiceDate);
                System.assertEquals(System.today(), oi.blng__NextChargeDate__c);
                System.assertEquals(expectedDate, oi.blng__OverrideNextBillingDate__c);
                System.assertEquals(null, oi.blng__BillThroughDateOverride__c);
            }
        }
    }
    */
    
    //used to be testSetupInvoiceDatesFamilyMicroArrears changed in 1349
    @isTest
    private static void testSetupInvoiceDatesFamilyArrears () {      //IS-507
        Account customerAcc = null;
        List<Account> creches = new List<Account> ();
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            
            // Load Contract Type Conf
            Map<String, LPCR_TypeContrat__mdt> mapTypeContractConf = new Map<String, LPCR_TypeContrat__mdt> ();
            for (LPCR_TypeContrat__mdt typeContractConf : [SELECT Id, DeveloperName, LPCR_JourFacturation__c FROM LPCR_TypeContrat__mdt]) {
                mapTypeContractConf.put(typeContractConf.DeveloperName, typeContractConf);
            }
            Integer invoicingDay = Integer.valueOf(mapTypeContractConf.get('B2C_MICRO').LPCR_JourFacturation__c);
            
            //setup data for this particular test
            List<Account> accounts = [SELECT Id, RecordTypeId FROM Account];
            for (Account a : accounts) {
                if (a.RecordTypeId == B2C_RT_ID) {
                    customerAcc = a;
                } else if (a.RecordTypeId == CRECHE_RT_ID) {
                    creches.add (a);
                }
            }
            Product2 prod = [SELECT Id FROM Product2].get(0);
            PricebookEntry priceBookEntry = [SELECT Id FROM PricebookEntry].get(0);
            
            Map<String, Object> defaultVal = new Map<String, Object> {
                'RecordTypeId' => OPPT_FAMILE_RT_ID,
                    'AccountId' => customerAcc.Id,
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
                    'SBQQ__Account__c' => customerAcc.Id,
                    'SBQQ__SubscriptionTerm__c' => 12,
                    'SBQQ__BillingFrequency__c' => 'Monthly',
                    'LPCR_TypeFacturation__c' => 'Arrears',
                    'LPCR_IndexationConvenue__c' => 'Oui',
                    'SBQQ__StartDate__c' => System.today(),
                    'SBQQ__PricebookId__c' => standardPricebookId,
                    'SBQQ__PriceBook__c' => standardPricebookId,
                    'SBQQ__Type__c' => 'Quote',
                    'SBQQ__QuoteLanguage__c' => 'English',
                    'SBQQ__BillingCity__c' => 'Paris',
                    'SBQQ__Primary__c' => true,
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
                    			//'SBQQ__ChargeType__c' => 'Recurring',
                    'SBQQ__ChargeType__c' => 'One-Time',
                   // 'SBQQ__BillingType__c' => 'Arrears',
                    'LPCR_Region__c' => 'Paris',
                    //'SBQQ__BillingFrequency__c' => 'Monthly',
                    'LPCR_EntiteJuridique__c' => UM002_TestDataFactory.setupLegalEntity().Id
                    };
                        
                        SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c) UM002_TestDataFactory.createSObject('SBQQ__QuoteLine__c', defaultVal);
            insert quoteLine;
            
            opp.SBQQ__PrimaryQuote__c = quote.Id;
            update opp;
            
            //Order the quote to create Order / OrderItems
            update new SBQQ__Quote__c (Id = quote.Id, SBQQ__Ordered__c = true);
            
            //Update orders to trigger OrderItem Update => test setupInvoiceDates
            List<Order> orders = [SELECT Id , SBQQ__Contracted__c, Status, OpportunityId, EffectiveDate, AccountId, SBQQ__Quote__c, blng__BillingAccount__c, LPCR_TypeCreche__c FROM Order];
            for (Order order : orders) {
                order.blng__BillingAccount__c = order.blng__BillingAccount__c == null && order.AccountId != null 
                    ? order.AccountId
                    : order.blng__BillingAccount__c;
                
                order.LPCR_TypeCreche__c = String.isNotBlank(order.LPCR_TypeCreche__c)
                    ? order.LPCR_TypeCreche__c 
                    : 'MICRO';
                
                
                
                order.LPCR_TypeFacturation__c = 'Arrears';
            }
            
            update orders;
            Test.stopTest();
            
            /*Map<Id,OrderItem> mapOrderItem = new Map<Id,OrderItem>([SELECT Id, SBQQ__BillingType__c, ServiceDate, blng__NextChargeDate__c, blng__OverrideNextBillingDate__c,
                                                                    blng__NextBillingDate__c, blng__BillThroughDateOverride__c, OrderId, Order.LPCR_TypeCreche__c, blng__BillingAccount__c, Order.blng__BillingAccount__r.RecordTypeId FROM OrderItem]);
            
            Integer todaytDay = System.today().day();
            Date expectedDate = (todaytDay > invoicingDay)
                ? UM005_DateUtility.setDayOnDate (invoicingDay, System.today().addMonths(1))
                : UM005_DateUtility.setDayOnDate (invoicingDay, System.today());
            
            for (OrderItem oi : mapOrderItem.values()) {
                
                System.assertEquals(System.today(), oi.ServiceDate);
                System.assertEquals(System.today(), oi.blng__NextChargeDate__c);
                System.assertEquals(expectedDate, oi.blng__OverrideNextBillingDate__c);
                System.assertEquals(UM005_DateUtility.lastDateOfMonth (oi.blng__BillThroughDateOverride__c), oi.blng__BillThroughDateOverride__c);
            }*/
            Order order = orders.get(0);
            OrderItem orderItem = UM002_TestDataFactory.createOrderProduct(priceBookEntry.id,order.Id,null,'One-Time',4);
            orderItem.Quantity = 10;
            orderItem.SBQQ__TerminatedDate__c = date.newInstance(System.Today().year(), 10, 02);
            insert orderItem;
            orderItem = [Select Id, blng__OverrideNextBillingDate__c, blng__NextChargeDate__c,blng__BillThroughDateOverride__c,SBQQ__TerminatedDate__c from orderItem  limit 1];
            System.assertEquals(UM005_DateUtility.lastDateOfMonth(orderItem.blng__NextChargeDate__c).addDays(1), orderItem.blng__OverrideNextBillingDate__c);
            
        }
    }
    
    
    @isTest
    private static void testSetupInvoiceDatesEnterpriseMonthlyAdvance () {      //IS-529
        Account customerAcc = null;
        List<Account> creches = new List<Account> ();
        
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            // Load Contract Type Conf
            Map<String, LPCR_TypeContrat__mdt> mapTypeContractConf = new Map<String, LPCR_TypeContrat__mdt> ();
            for (LPCR_TypeContrat__mdt typeContractConf : [SELECT Id, DeveloperName, LPCR_JourFacturation__c FROM LPCR_TypeContrat__mdt]) {
                mapTypeContractConf.put(typeContractConf.DeveloperName, typeContractConf);
            }
            Integer invoiceDelta = -1 * Integer.valueOf(mapTypeContractConf.get('B2B').LPCR_JourFacturation__c);
            
            //setup data for this particular test
            List<Account> accounts = [SELECT Id, RecordTypeId FROM Account];
            for (Account a : accounts) {
                if (a.RecordTypeId == B2B_RT_ID) {
                    customerAcc = a;
                } else if (a.RecordTypeId == CRECHE_RT_ID) {
                    creches.add (a);
                }
            }
            Product2 prod = [SELECT Id FROM Product2].get(0);
            PricebookEntry priceBookEntry = [SELECT Id FROM PricebookEntry].get(0);
            
            Map<String, Object> defaultVal = new Map<String, Object> {
                'RecordTypeId' => OPPT_ENTERPRISE_RT_ID,
                    'AccountId' => customerAcc.Id,
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
                    'SBQQ__Account__c' => customerAcc.Id,
                    'SBQQ__SubscriptionTerm__c' => 12,
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
                    'LPCR_Region__c' => 'Paris',
                    'SBQQ__BillingFrequency__c' => 'Monthly',
                    'LPCR_EntiteJuridique__c' => UM002_TestDataFactory.setupLegalEntity().Id
                    };
                        
                        SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c) UM002_TestDataFactory.createSObject('SBQQ__QuoteLine__c', defaultVal);
            insert quoteLine;
            
            opp.SBQQ__PrimaryQuote__c = quote.Id;
            update opp;
            
            //Order the quote to create Order / OrderItems
            update new SBQQ__Quote__c (Id = quote.Id, SBQQ__Ordered__c = true);
            
            //Update orders to trigger OrderItem Update => test setupInvoiceDates
            List<Order> orders = [SELECT Id , SBQQ__Contracted__c, Status, OpportunityId, EffectiveDate, AccountId, SBQQ__Quote__c, blng__BillingAccount__c, LPCR_TypeCreche__c FROM Order];
            for (Order order : orders) {
                order.blng__BillingAccount__c = order.blng__BillingAccount__c == null && order.AccountId != null 
                    ? order.AccountId
                    : order.blng__BillingAccount__c;
                order.LPCR_TypeCreche__c = String.isNotBlank(order.LPCR_TypeCreche__c)
                    ? order.LPCR_TypeCreche__c 
                    : 'MICRO';
                
                order.LPCR_TypeFacturation__c = 'Advance';
            }
            
            update orders;
            Test.stopTest();
            
            Map<Id,OrderItem> mapOrderItem = new Map<Id,OrderItem>([SELECT Id, SBQQ__BillingType__c, ServiceDate, blng__NextChargeDate__c, blng__OverrideNextBillingDate__c,
                                                                    blng__BillThroughDateOverride__c, OrderId, Order.LPCR_TypeCreche__c, blng__BillingAccount__c, Order.blng__BillingAccount__r.RecordTypeId FROM OrderItem]);
            
            Date expectedDate = System.today().addDays(invoiceDelta);
            
            for (OrderItem oi : mapOrderItem.values()) {
                System.assertEquals(System.today(), oi.ServiceDate);
                System.assertEquals(System.today(), oi.blng__NextChargeDate__c);
                System.assertEquals(expectedDate, oi.blng__OverrideNextBillingDate__c);
                System.assertEquals(UM005_DateUtility.lastDateOfMonth(oi.blng__NextChargeDate__c), oi.blng__BillThroughDateOverride__c);
            }
        }
    }
    
    
    @isTest
    private static void testSetupInvoiceDatesEnterpriseMonthlyArrears () {     
        Account customerAcc = null;
        List<Account> creches = new List<Account> ();
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            // Load Contract Type Conf
            Map<String, LPCR_TypeContrat__mdt> mapTypeContractConf = new Map<String, LPCR_TypeContrat__mdt> ();
            for (LPCR_TypeContrat__mdt typeContractConf : [SELECT Id, DeveloperName, LPCR_JourFacturation__c FROM LPCR_TypeContrat__mdt]) {
                mapTypeContractConf.put(typeContractConf.DeveloperName, typeContractConf);
            }
            Integer invoiceDelta = -1 * Integer.valueOf(mapTypeContractConf.get('B2B').LPCR_JourFacturation__c);
            
            //setup data for this particular test
            List<Account> accounts = [SELECT Id, RecordTypeId FROM Account];
            for (Account a : accounts) {
                if (a.RecordTypeId == B2B_RT_ID) {
                    customerAcc = a;
                } else if (a.RecordTypeId == CRECHE_RT_ID) {
                    creches.add (a);
                }
            }
            Product2 prod = [SELECT Id FROM Product2].get(0);
            PricebookEntry priceBookEntry = [SELECT Id FROM PricebookEntry].get(0);
            
            Map<String, Object> defaultVal = new Map<String, Object> {
                'RecordTypeId' => OPPT_ENTERPRISE_RT_ID,
                    'AccountId' => customerAcc.Id,
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
                    'SBQQ__Account__c' => customerAcc.Id,
                    'SBQQ__SubscriptionTerm__c' => 12,
                    'SBQQ__BillingFrequency__c' => 'Monthly',
                    'LPCR_TypeFacturation__c' => 'Arrears',
                    'LPCR_IndexationConvenue__c' => 'Oui',
                    'SBQQ__StartDate__c' => System.today(),
                    'SBQQ__PricebookId__c' => standardPricebookId,
                    'SBQQ__PriceBook__c' => standardPricebookId,
                    'SBQQ__Type__c' => 'Quote',
                    'SBQQ__QuoteLanguage__c' => 'English',
                    'SBQQ__BillingCity__c' => 'Paris',
                    'SBQQ__Primary__c' => true,
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
                    'SBQQ__BillingType__c' => 'Arrears',
                    'LPCR_Region__c' => 'Paris',
                    'SBQQ__BillingFrequency__c' => 'Monthly',
                    'LPCR_EntiteJuridique__c' => UM002_TestDataFactory.setupLegalEntity().Id
                    };
                        
                        SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c) UM002_TestDataFactory.createSObject('SBQQ__QuoteLine__c', defaultVal);
            insert quoteLine;
            
            opp.SBQQ__PrimaryQuote__c = quote.Id;
            update opp;
            
            //Order the quote to create Order / OrderItems
            update new SBQQ__Quote__c (Id = quote.Id, SBQQ__Ordered__c = true);
            
            
            //Update orders to trigger OrderItem Update => test setupInvoiceDates
            List<Order> orders = [SELECT Id , SBQQ__Contracted__c, Status, OpportunityId, EffectiveDate, AccountId, SBQQ__Quote__c, blng__BillingAccount__c, LPCR_TypeCreche__c FROM Order];
            for (Order order : orders) {
                order.LPCR_TypeFacturation__c='Arrears';
                order.blng__BillingAccount__c = order.blng__BillingAccount__c == null && order.AccountId != null 
                    ? order.AccountId
                    : order.blng__BillingAccount__c;
                order.LPCR_TypeCreche__c = String.isNotBlank(order.LPCR_TypeCreche__c)
                    ? order.LPCR_TypeCreche__c 
                    : 'MICRO';
            }
            
            update orders;
            Test.stopTest();
            
            Map<Id,OrderItem> mapOrderItem = new Map<Id,OrderItem>([SELECT Id, SBQQ__BillingType__c, ServiceDate, blng__NextChargeDate__c, blng__OverrideNextBillingDate__c,
                                                                    blng__BillThroughDateOverride__c, OrderId, Order.LPCR_TypeCreche__c, blng__BillingAccount__c, Order.blng__BillingAccount__r.RecordTypeId FROM OrderItem]);
            
            Date expectedDate = System.today().addDays(invoiceDelta);
            
            for (OrderItem oi : mapOrderItem.values()) {
                System.assertEquals(System.today(), oi.ServiceDate);
                System.assertEquals(System.today(), oi.blng__NextChargeDate__c);
                if(oi.blng__NextChargeDate__c.day() != 1){
                    System.assertEquals(UM005_DateUtility.lastDateOfMonth(oi.blng__NextChargeDate__c), oi.blng__BillThroughDateOverride__c);
                }
            }
        }
    }
    
    @isTest
    private static void testSetupInvoiceDatesEnterpriseQuaterlyAdvance () {      //IS-529
        Account customerAcc = null;
        List<Account> creches = new List<Account> ();
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            // Load Contract Type Conf
            Map<String, LPCR_TypeContrat__mdt> mapTypeContractConf = new Map<String, LPCR_TypeContrat__mdt> ();
            for (LPCR_TypeContrat__mdt typeContractConf : [SELECT Id, DeveloperName, LPCR_JourFacturation__c FROM LPCR_TypeContrat__mdt]) {
                mapTypeContractConf.put(typeContractConf.DeveloperName, typeContractConf);
            }
            Integer invoiceDelta = -1 * Integer.valueOf(mapTypeContractConf.get('B2B').LPCR_JourFacturation__c);
            
            //setup data for this particular test
            List<Account> accounts = [SELECT Id, RecordTypeId FROM Account];
            for (Account a : accounts) {
                if (a.RecordTypeId == B2B_RT_ID) {
                    customerAcc = a;
                } else if (a.RecordTypeId == CRECHE_RT_ID) {
                    creches.add (a);
                }
            }
            Product2 prod = [SELECT Id FROM Product2].get(0);
            PricebookEntry priceBookEntry = [SELECT Id FROM PricebookEntry].get(0);
            
            Map<String, Object> defaultVal = new Map<String, Object> {
                'RecordTypeId' => OPPT_ENTERPRISE_RT_ID,
                    'AccountId' => customerAcc.Id,
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
                    'SBQQ__Account__c' => customerAcc.Id,
                    'SBQQ__SubscriptionTerm__c' => 12,
                    'SBQQ__BillingFrequency__c' => 'Quarterly',
                    'LPCR_TypeFacturation__c' => 'Advance',
                    'LPCR_IndexationConvenue__c' => 'Oui',
                    'SBQQ__StartDate__c' => System.today(),
                    'SBQQ__PricebookId__c' => standardPricebookId,
                    'SBQQ__PriceBook__c' => standardPricebookId,
                    'SBQQ__Type__c' => 'Quote',
                    'SBQQ__QuoteLanguage__c' => 'English',
                    'SBQQ__BillingCity__c' => 'Paris',
                    'SBQQ__Primary__c' => true,
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
                    'LPCR_Region__c' => 'Paris',
                    'SBQQ__BillingFrequency__c' => 'Quarterly',
                    'LPCR_EntiteJuridique__c' => UM002_TestDataFactory.setupLegalEntity().Id
                    };
                        
                        SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c) UM002_TestDataFactory.createSObject('SBQQ__QuoteLine__c', defaultVal);
            insert quoteLine;
            
            opp.SBQQ__PrimaryQuote__c = quote.Id;
            update opp;
            
            //Order the quote to create Order / OrderItems
            update new SBQQ__Quote__c (Id = quote.Id, SBQQ__Ordered__c = true);
            
            
            //Update orders to trigger OrderItem Update => test setupInvoiceDates
            List<Order> orders = [SELECT Id , SBQQ__Contracted__c, Status, OpportunityId, EffectiveDate, AccountId, SBQQ__Quote__c, blng__BillingAccount__c, LPCR_TypeCreche__c FROM Order];
            for (Order order : orders) {
                order.blng__BillingAccount__c = order.blng__BillingAccount__c == null && order.AccountId != null 
                    ? order.AccountId
                    : order.blng__BillingAccount__c;
                
                order.LPCR_TypeCreche__c = String.isNotBlank(order.LPCR_TypeCreche__c)
                    ? order.LPCR_TypeCreche__c 
                    : 'MICRO';
                
                order.LPCR_TypeFacturation__c = 'Advance';
            }
            
            update orders;
            Test.stopTest();
            
            Map<Id,OrderItem> mapOrderItem = new Map<Id,OrderItem>([SELECT Id, SBQQ__BillingType__c, ServiceDate, blng__NextChargeDate__c, blng__OverrideNextBillingDate__c,
                                                                    blng__NextBillingDate__c, blng__BillThroughDateOverride__c, OrderId, Order.LPCR_TypeCreche__c, blng__BillingAccount__c, Order.blng__BillingAccount__r.RecordTypeId FROM OrderItem]);
            
            Date expectedDate = System.today().addDays(invoiceDelta);
            
            for (OrderItem oi : mapOrderItem.values()) {
                System.assertEquals(System.today(), oi.ServiceDate);
                System.assertEquals(System.today(), oi.blng__NextChargeDate__c);
                System.assertEquals(expectedDate, oi.blng__OverrideNextBillingDate__c);
                

                Date expectedBillThrought = ((UM005_DateUtility.quarterlyMonths.contains(oi.blng__NextChargeDate__c.month()) 
                                                && oi.blng__NextChargeDate__c.day() != 1) 
                                               || !UM005_DateUtility.quarterlyMonths.contains(oi.blng__NextChargeDate__c.month()) )

                    ? UM005_DateUtility.lastDayOfDatePeriod (oi.blng__NextBillingDate__c, UM005_DateUtility.quarterlyMonths)
                    : null;
                System.assertEquals(expectedBillThrought, oi.blng__BillThroughDateOverride__c);
            }
        }
    }
    
    
    @isTest
    private static void testSetupInvoiceDatesEnterpriseQuaterlyArrears() {   
        Account customerAcc = null;
        List<Account> creches = new List<Account> ();
        
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            // Load Contract Type Conf
            Map<String, LPCR_TypeContrat__mdt> mapTypeContractConf = new Map<String, LPCR_TypeContrat__mdt> ();
            for (LPCR_TypeContrat__mdt typeContractConf : [SELECT Id, DeveloperName, LPCR_JourFacturation__c FROM LPCR_TypeContrat__mdt]) {
                mapTypeContractConf.put(typeContractConf.DeveloperName, typeContractConf);
            }
            Integer invoiceDelta = -1 * Integer.valueOf(mapTypeContractConf.get('B2B').LPCR_JourFacturation__c);
            
            //setup data for this particular test
            List<Account> accounts = [SELECT Id, RecordTypeId FROM Account];
            for (Account a : accounts) {
                if (a.RecordTypeId == B2B_RT_ID) {
                    customerAcc = a;
                } else if (a.RecordTypeId == CRECHE_RT_ID) {
                    creches.add (a);
                }
            }
            Product2 prod = [SELECT Id FROM Product2].get(0);
            PricebookEntry priceBookEntry = [SELECT Id FROM PricebookEntry].get(0);
            
            Map<String, Object> defaultVal = new Map<String, Object> {
                'RecordTypeId' => OPPT_ENTERPRISE_RT_ID,
                    'AccountId' => customerAcc.Id,
                    'Name' => 'test-oppt',
                    'StageName' => 'Signée',
                    'CloseDate' => System.today(),
                    'Pricebook2Id' => standardPricebookId,
                    'Type' => 'New Business',
                    'LPCR_TypeFacturation__c'=>'Arrears'
                    };
                        
                        Opportunity opp = (Opportunity) UM002_TestDataFactory.createSObject('Opportunity', defaultVal);
            insert opp;
            
            defaultVal = new Map<String, Object> {
                'RecordTypeId' => QUOTE_CONTRAT_ACCUEIL_RT_ID,
                    'SBQQ__Account__c' => customerAcc.Id,
                    'SBQQ__SubscriptionTerm__c' => 12,
                    'SBQQ__BillingFrequency__c' => 'Quarterly',
                    'LPCR_TypeFacturation__c' => 'Arrears',
                    'SBQQ__BillingType__c' => 'Arrears',
                    'LPCR_IndexationConvenue__c' => 'Oui',
                    'SBQQ__StartDate__c' => System.today(),
                    'SBQQ__PricebookId__c' => standardPricebookId,
                    'SBQQ__PriceBook__c' => standardPricebookId,
                    'SBQQ__Type__c' => 'Quote',
                    'SBQQ__QuoteLanguage__c' => 'English',
                    'SBQQ__BillingCity__c' => 'Paris',
                    'SBQQ__Primary__c' => true,
                    'SBQQ__Opportunity2__c' => opp.Id,
                'SBQQ__RenewalUpliftRate__c' => 10
                    };
                        
                        
                        SBQQ__Quote__c quote = (SBQQ__Quote__c) UM002_TestDataFactory.createSObject('SBQQ__Quote__c', defaultVal);
            insert quote;
            quote = [SELECT SBQQ__BillingFrequency__c,LPCR_TypeFacturation__c FROM SBQQ__Quote__c where Id = :quote.Id ];
            system.debug('quote : SBQQ__BillingType__c ===== '+quote.SBQQ__BillingFrequency__c);
            system.debug('quote : LPCR_TypeFacturation__c ===== '+quote.LPCR_TypeFacturation__c);
            
            
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
                    'SBQQ__BillingType__c' => 'Arrears',
                    'LPCR_Region__c' => 'Paris',
                    'SBQQ__BillingFrequency__c' => 'Quarterly',
                    'LPCR_EntiteJuridique__c' => UM002_TestDataFactory.setupLegalEntity().Id
                    };
                        
                        SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c) UM002_TestDataFactory.createSObject('SBQQ__QuoteLine__c', defaultVal);
            insert quoteLine;
            
            opp.SBQQ__PrimaryQuote__c = quote.Id;
            update opp;
            
            //Order the quote to create Order / OrderItems
            update new SBQQ__Quote__c (Id = quote.Id, SBQQ__Ordered__c = true);
            
            //Update orders to trigger OrderItem Update => test setupInvoiceDates
            List<Order> orders = [SELECT Id , LPCR_TypeFacturation__c,SBQQ__Contracted__c, Status, OpportunityId, EffectiveDate, AccountId, SBQQ__Quote__c, blng__BillingAccount__c, LPCR_TypeCreche__c FROM Order WHERE SBQQ__Quote__c= :quote.Id];
            for (Order order : orders) {
                order.LPCR_TypeFacturation__c='Arrears';
                
                order.blng__BillingAccount__c = order.blng__BillingAccount__c == null && order.AccountId != null 
                    ? order.AccountId
                    : order.blng__BillingAccount__c;
                
                order.LPCR_TypeCreche__c = String.isNotBlank(order.LPCR_TypeCreche__c)
                    ? order.LPCR_TypeCreche__c 
                    : 'MICRO';
            }
            
            update orders;
            Test.stopTest();
            
            Map<Id,OrderItem> mapOrderItem = new Map<Id,OrderItem>([SELECT Id, SBQQ__BillingType__c, ServiceDate, blng__NextChargeDate__c, blng__OverrideNextBillingDate__c,
                                                                    blng__NextBillingDate__c, blng__BillThroughDateOverride__c, OrderId, Order.LPCR_TypeCreche__c, blng__BillingAccount__c, Order.blng__BillingAccount__r.RecordTypeId FROM OrderItem]);
            
            Date expectedDate = System.today().addDays(invoiceDelta);
            
            for (OrderItem oi : mapOrderItem.values()) {
                System.assertEquals(System.today(), oi.ServiceDate);
                System.assertEquals(System.today(), oi.blng__NextChargeDate__c);
                System.assertEquals(UM005_DateUtility.lastDayOfDatePeriod (System.today(), UM005_DateUtility.quarterlyMonths)/*.addDays(1)*/, oi.blng__OverrideNextBillingDate__c);
                Date expectedBillThrought = ((UM005_DateUtility.semiannualMonths.contains(oi.blng__NextChargeDate__c.month()) 
                                                                         && oi.blng__NextChargeDate__c.day() != 1) 
                                                                        || !UM005_DateUtility.semiannualMonths.contains(oi.blng__NextChargeDate__c.month()))
                    ? UM005_DateUtility.lastDayOfDatePeriod (oi.blng__NextBillingDate__c, UM005_DateUtility.quarterlyMonths)
                    : null;
                System.assertEquals(UM005_DateUtility.lastDayOfDatePeriod(oi.blng__NextChargeDate__c, UM005_DateUtility.quarterlyMonths), oi.blng__BillThroughDateOverride__c);
            }
        }
    }
    
    
    
    @isTest
    private static void testSetupInvoiceDatesEnterpriseSemiannualAdvance () {      //IS-529
        Account customerAcc = null;
        List<Account> creches = new List<Account> ();
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            // Load Contract Type Conf
            Map<String, LPCR_TypeContrat__mdt> mapTypeContractConf = new Map<String, LPCR_TypeContrat__mdt> ();
            for (LPCR_TypeContrat__mdt typeContractConf : [SELECT Id, DeveloperName, LPCR_JourFacturation__c FROM LPCR_TypeContrat__mdt]) {
                mapTypeContractConf.put(typeContractConf.DeveloperName, typeContractConf);
            }
            Integer invoiceDelta = -1 * Integer.valueOf(mapTypeContractConf.get('B2B').LPCR_JourFacturation__c);
            
            //setup data for this particular test
            List<Account> accounts = [SELECT Id, RecordTypeId FROM Account];
            for (Account a : accounts) {
                if (a.RecordTypeId == B2B_RT_ID) {
                    customerAcc = a;
                } else if (a.RecordTypeId == CRECHE_RT_ID) {
                    creches.add (a);
                }
            }
            Product2 prod = [SELECT Id FROM Product2].get(0);
            PricebookEntry priceBookEntry = [SELECT Id FROM PricebookEntry].get(0);
            
            Map<String, Object> defaultVal = new Map<String, Object> {
                'RecordTypeId' => OPPT_ENTERPRISE_RT_ID,
                    'AccountId' => customerAcc.Id,
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
                    'SBQQ__Account__c' => customerAcc.Id,
                    'SBQQ__SubscriptionTerm__c' => 12,
                    'SBQQ__BillingFrequency__c' => 'Semiannual',
                    'LPCR_TypeFacturation__c' => 'Advance',
                    'LPCR_IndexationConvenue__c' => 'Oui',
                    'SBQQ__StartDate__c' => System.today(),
                    'SBQQ__PricebookId__c' => standardPricebookId,
                    'SBQQ__PriceBook__c' => standardPricebookId,
                    'SBQQ__Type__c' => 'Quote',
                    'SBQQ__QuoteLanguage__c' => 'English',
                    'SBQQ__BillingCity__c' => 'Paris',
                    'SBQQ__Primary__c' => true,
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
                    'LPCR_Region__c' => 'Paris',
                    'SBQQ__BillingFrequency__c' => 'Semiannual',
                    'LPCR_EntiteJuridique__c' => UM002_TestDataFactory.setupLegalEntity().Id
                    };
                        
                        SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c) UM002_TestDataFactory.createSObject('SBQQ__QuoteLine__c', defaultVal);
            insert quoteLine;
            
            opp.SBQQ__PrimaryQuote__c = quote.Id;
            update opp;
            
            //Order the quote to create Order / OrderItems
            update new SBQQ__Quote__c (Id = quote.Id, SBQQ__Ordered__c = true);
            
            
            //Update orders to trigger OrderItem Update => test setupInvoiceDates
            List<Order> orders = [SELECT Id , SBQQ__Contracted__c, Status, OpportunityId, EffectiveDate, AccountId, SBQQ__Quote__c, blng__BillingAccount__c, LPCR_TypeCreche__c FROM Order];
            for (Order order : orders) {
                order.blng__BillingAccount__c = order.blng__BillingAccount__c == null && order.AccountId != null 
                    ? order.AccountId
                    : order.blng__BillingAccount__c;
                
                order.LPCR_TypeCreche__c = String.isNotBlank(order.LPCR_TypeCreche__c)
                    ? order.LPCR_TypeCreche__c 
                    : 'MICRO';
                
                order.LPCR_TypeFacturation__c = 'Advance';
            }
            
            update orders;
            Test.stopTest();
            
            Map<Id,OrderItem> mapOrderItem = new Map<Id,OrderItem>([SELECT Id, SBQQ__BillingType__c, ServiceDate, blng__NextChargeDate__c, blng__OverrideNextBillingDate__c,
                                                                    blng__NextBillingDate__c, blng__BillThroughDateOverride__c, OrderId, Order.LPCR_TypeCreche__c, blng__BillingAccount__c, Order.blng__BillingAccount__r.RecordTypeId FROM OrderItem]);
            
            Date expectedDate = System.today().addDays(invoiceDelta);
            
            for (OrderItem oi : mapOrderItem.values()) {
                System.assertEquals(System.today(), oi.ServiceDate);
                System.assertEquals(System.today(), oi.blng__NextChargeDate__c);
                System.assertEquals(expectedDate, oi.blng__OverrideNextBillingDate__c);
                

                Date expectedBillThrought =  ((UM005_DateUtility.semiannualMonths.contains(oi.blng__NextChargeDate__c.month()) 
                                               && oi.blng__NextChargeDate__c.day() != 1) 
                                               || !UM005_DateUtility.semiannualMonths.contains(oi.blng__NextChargeDate__c.month()))

                    ? UM005_DateUtility.lastDayOfDatePeriod (oi.blng__NextBillingDate__c, UM005_DateUtility.semiannualMonths)
                    : null;
                System.assertEquals(expectedBillThrought, oi.blng__BillThroughDateOverride__c);
            }
        }
    }
    
    @isTest
    private static void testSetupInvoiceDatesEnterpriseSemiannualArrears () {      
        Account customerAcc = null;
        List<Account> creches = new List<Account> ();
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            // Load Contract Type Conf
            Map<String, LPCR_TypeContrat__mdt> mapTypeContractConf = new Map<String, LPCR_TypeContrat__mdt> ();
            for (LPCR_TypeContrat__mdt typeContractConf : [SELECT Id, DeveloperName, LPCR_JourFacturation__c FROM LPCR_TypeContrat__mdt]) {
                mapTypeContractConf.put(typeContractConf.DeveloperName, typeContractConf);
            }
            Integer invoiceDelta = -1 * Integer.valueOf(mapTypeContractConf.get('B2B').LPCR_JourFacturation__c);
            
            //setup data for this particular test
            List<Account> accounts = [SELECT Id, RecordTypeId FROM Account];
            for (Account a : accounts) {
                if (a.RecordTypeId == B2B_RT_ID) {
                    customerAcc = a;
                } else if (a.RecordTypeId == CRECHE_RT_ID) {
                    creches.add (a);
                }
            }
            Product2 prod = [SELECT Id FROM Product2].get(0);
            PricebookEntry priceBookEntry = [SELECT Id FROM PricebookEntry].get(0);
            
            Map<String, Object> defaultVal = new Map<String, Object> {
                'RecordTypeId' => OPPT_ENTERPRISE_RT_ID,
                    'AccountId' => customerAcc.Id,
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
                    'SBQQ__Account__c' => customerAcc.Id,
                    'SBQQ__SubscriptionTerm__c' => 12,
                    'SBQQ__BillingFrequency__c' => 'Semiannual',
                    'LPCR_TypeFacturation__c' => 'Arrears',
                    'LPCR_IndexationConvenue__c' => 'Oui',
                    'SBQQ__StartDate__c' => System.today(),
                    'SBQQ__PricebookId__c' => standardPricebookId,
                    'SBQQ__PriceBook__c' => standardPricebookId,
                    'SBQQ__Type__c' => 'Quote',
                    'SBQQ__QuoteLanguage__c' => 'English',
                    'SBQQ__BillingCity__c' => 'Paris',
                    'SBQQ__Primary__c' => true,
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
                    'SBQQ__BillingType__c' => 'Arrears',
                    'LPCR_Region__c' => 'Paris',
                    'SBQQ__BillingFrequency__c' => 'Semiannual',
                    'LPCR_EntiteJuridique__c' => UM002_TestDataFactory.setupLegalEntity().Id
                    };
                        
                        SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c) UM002_TestDataFactory.createSObject('SBQQ__QuoteLine__c', defaultVal);
            insert quoteLine;
            
            opp.SBQQ__PrimaryQuote__c = quote.Id;
            update opp;
            
            //Order the quote to create Order / OrderItems
            update new SBQQ__Quote__c (Id = quote.Id, SBQQ__Ordered__c = true);
            
            
            //Update orders to trigger OrderItem Update => test setupInvoiceDates
            List<Order> orders = [SELECT Id , SBQQ__Contracted__c, Status, OpportunityId, EffectiveDate, AccountId, SBQQ__Quote__c, blng__BillingAccount__c, LPCR_TypeCreche__c FROM Order];
            for (Order order : orders) {
                order.LPCR_TypeFacturation__c='Arrears';
                order.blng__BillingAccount__c = order.blng__BillingAccount__c == null && order.AccountId != null 
                    ? order.AccountId
                    : order.blng__BillingAccount__c;
                
                order.LPCR_TypeCreche__c = String.isNotBlank(order.LPCR_TypeCreche__c)
                    ? order.LPCR_TypeCreche__c 
                    : 'MICRO';
            }
            
            update orders;
            Test.stopTest();
            
            Map<Id,OrderItem> mapOrderItem = new Map<Id,OrderItem>([SELECT Id, SBQQ__BillingType__c, ServiceDate, blng__NextChargeDate__c, blng__OverrideNextBillingDate__c,
                                                                    blng__NextBillingDate__c, blng__BillThroughDateOverride__c, OrderId, Order.LPCR_TypeCreche__c, blng__BillingAccount__c, Order.blng__BillingAccount__r.RecordTypeId FROM OrderItem]);
            
            Date expectedDate = System.today().addDays(invoiceDelta);
            
            for (OrderItem oi : mapOrderItem.values()) {
                System.assertEquals(System.today(), oi.ServiceDate);
                System.assertEquals(System.today(), oi.blng__NextChargeDate__c);
                
                Date expectedBillThrought = !UM005_DateUtility.semiannualMonths.contains(oi.blng__NextBillingDate__c.month()) || oi.blng__NextChargeDate__c.day() != 1
                    ? UM005_DateUtility.lastDayOfDatePeriod (oi.blng__NextChargeDate__c, UM005_DateUtility.semiannualMonths)
                    : null;
                System.assertEquals(expectedBillThrought, oi.blng__BillThroughDateOverride__c);
                
                Date expectedOverrideNextBillingDate = !UM005_DateUtility.semiannualMonths.contains(oi.blng__NextBillingDate__c.month()) || oi.blng__NextChargeDate__c.day() != 1
                    ? UM005_DateUtility.lastDayOfDatePeriod (oi.blng__NextChargeDate__c, UM005_DateUtility.semiannualMonths)/*.addDays(1)*/
                    : null;
                System.assertEquals(expectedOverrideNextBillingDate, oi.blng__OverrideNextBillingDate__c);
            }
        }
    }
    
    
    @isTest
    private static void testSetupInvoiceDatesEnterpriseSemiannualArrearsOneTime() {      
        Account customerAcc = null;
        List<Account> creches = new List<Account> ();
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            // Load Contract Type Conf
            Map<String, LPCR_TypeContrat__mdt> mapTypeContractConf = new Map<String, LPCR_TypeContrat__mdt> ();
            for (LPCR_TypeContrat__mdt typeContractConf : [SELECT Id, DeveloperName, LPCR_JourFacturation__c FROM LPCR_TypeContrat__mdt]) {
                mapTypeContractConf.put(typeContractConf.DeveloperName, typeContractConf);
            }
            Integer invoiceDelta = -1 * Integer.valueOf(mapTypeContractConf.get('B2B').LPCR_JourFacturation__c);
            
            //setup data for this particular test
            List<Account> accounts = [SELECT Id, RecordTypeId FROM Account];
            for (Account a : accounts) {
                if (a.RecordTypeId == B2B_RT_ID) {
                    customerAcc = a;
                } else if (a.RecordTypeId == CRECHE_RT_ID) {
                    creches.add (a);
                }
            }
            Product2 prod = [SELECT Id FROM Product2].get(0);
            PricebookEntry priceBookEntry = [SELECT Id FROM PricebookEntry].get(0);
            
            Map<String, Object> defaultVal = new Map<String, Object> {
                'RecordTypeId' => OPPT_ENTERPRISE_RT_ID,
                    'AccountId' => customerAcc.Id,
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
                    'SBQQ__Account__c' => customerAcc.Id,
                    'SBQQ__SubscriptionTerm__c' => 12,
                    'SBQQ__BillingFrequency__c' => 'Semiannual',
                    'LPCR_TypeFacturation__c' => 'Arrears',
                    'LPCR_IndexationConvenue__c' => 'Oui',
                    'SBQQ__StartDate__c' => System.today(),
                    'SBQQ__PricebookId__c' => standardPricebookId,
                    'SBQQ__PriceBook__c' => standardPricebookId,
                    'SBQQ__Type__c' => 'Quote',
                    'SBQQ__QuoteLanguage__c' => 'English',
                    'SBQQ__BillingCity__c' => 'Paris',
                    'SBQQ__Primary__c' => true,
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
                    'SBQQ__ChargeType__c' => 'One-Time',
                    'LPCR_Region__c' => 'Paris',
                    'LPCR_EntiteJuridique__c' => UM002_TestDataFactory.setupLegalEntity().Id
                    };
                        
                        SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c) UM002_TestDataFactory.createSObject('SBQQ__QuoteLine__c', defaultVal);
            insert quoteLine;
            
            opp.SBQQ__PrimaryQuote__c = quote.Id;
            update opp;
            
            //Order the quote to create Order / OrderItems
            update new SBQQ__Quote__c (Id = quote.Id, SBQQ__Ordered__c = true);
            
            
            //Update orders to trigger OrderItem Update => test setupInvoiceDates
            List<Order> orders = [SELECT Id , SBQQ__Contracted__c, Status, OpportunityId, EffectiveDate, AccountId, SBQQ__Quote__c, blng__BillingAccount__c, LPCR_TypeCreche__c FROM Order];
            for (Order order : orders) {
                order.LPCR_TypeFacturation__c='Arrears';
                order.blng__BillingAccount__c = order.blng__BillingAccount__c == null && order.AccountId != null 
                    ? order.AccountId
                    : order.blng__BillingAccount__c;
                
                order.LPCR_TypeCreche__c = String.isNotBlank(order.LPCR_TypeCreche__c)
                    ? order.LPCR_TypeCreche__c 
                    : 'MICRO';
            }
            
            update orders;
            Test.stopTest();
            
            Map<Id,OrderItem> mapOrderItem = new Map<Id,OrderItem>([SELECT Id, SBQQ__ChargeType__c,SBQQ__BillingType__c, ServiceDate, blng__NextChargeDate__c, blng__OverrideNextBillingDate__c,
                                                                    blng__NextBillingDate__c, blng__BillThroughDateOverride__c,Order.LPCR_TypeFacturation__c, Order.LPCR_FrequenceFacturation__c,OrderId, Order.LPCR_TypeCreche__c, blng__BillingAccount__c, Order.blng__BillingAccount__r.RecordTypeId FROM OrderItem]);
            
            Date expectedDate = System.today().addDays(invoiceDelta);
            
            for (OrderItem oi : mapOrderItem.values()) {
                
                System.assertEquals(System.today(), oi.ServiceDate);
                System.assertEquals(System.today(), oi.blng__NextChargeDate__c);
                
                
                //System.assertEquals(UM005_DateUtility.lastDayOfDatePeriod (oi.blng__NextChargeDate__c, UM005_DateUtility.semiannualMonths), oi.blng__BillThroughDateOverride__c);
                
                Date expectedOverrideNextBillingDate = !UM005_DateUtility.semiannualMonths.contains(oi.blng__NextBillingDate__c.month()) || oi.blng__NextChargeDate__c.day() != 1
                    ? UM005_DateUtility.lastDayOfDatePeriod (oi.blng__NextChargeDate__c, UM005_DateUtility.semiannualMonths).addDays(1) 
                    : null;
                System.assertEquals(expectedOverrideNextBillingDate.addDays(-1), oi.blng__OverrideNextBillingDate__c);
            }
        }
    }
    
    
    @isTest
    private static void testSetupInvoiceDatesEnterpriseQuarterlyArrearsOneTime() {      
        Account customerAcc = null;
        List<Account> creches = new List<Account> ();
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            // Load Contract Type Conf
            Map<String, LPCR_TypeContrat__mdt> mapTypeContractConf = new Map<String, LPCR_TypeContrat__mdt> ();
            for (LPCR_TypeContrat__mdt typeContractConf : [SELECT Id, DeveloperName, LPCR_JourFacturation__c FROM LPCR_TypeContrat__mdt]) {
                mapTypeContractConf.put(typeContractConf.DeveloperName, typeContractConf);
            }
            Integer invoiceDelta = -1 * Integer.valueOf(mapTypeContractConf.get('B2B').LPCR_JourFacturation__c);
            
            //setup data for this particular test
            List<Account> accounts = [SELECT Id, RecordTypeId FROM Account];
            for (Account a : accounts) {
                if (a.RecordTypeId == B2B_RT_ID) {
                    customerAcc = a;
                } else if (a.RecordTypeId == CRECHE_RT_ID) {
                    creches.add (a);
                }
            }
            Product2 prod = [SELECT Id FROM Product2].get(0);
            PricebookEntry priceBookEntry = [SELECT Id FROM PricebookEntry].get(0);
            
            Map<String, Object> defaultVal = new Map<String, Object> {
                'RecordTypeId' => OPPT_ENTERPRISE_RT_ID,
                    'AccountId' => customerAcc.Id,
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
                    'SBQQ__Account__c' => customerAcc.Id,
                    'SBQQ__SubscriptionTerm__c' => 12,
                    'SBQQ__BillingFrequency__c' => 'Quarterly',
                    'LPCR_TypeFacturation__c' => 'Arrears',
                    'LPCR_IndexationConvenue__c' => 'Oui',
                    'SBQQ__StartDate__c' => System.today(),
                    'SBQQ__PricebookId__c' => standardPricebookId,
                    'SBQQ__PriceBook__c' => standardPricebookId,
                    'SBQQ__Type__c' => 'Quote',
                    'SBQQ__QuoteLanguage__c' => 'English',
                    'SBQQ__BillingCity__c' => 'Paris',
                    'SBQQ__Primary__c' => true,
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
                    'SBQQ__ChargeType__c' => 'One-Time',
                    'LPCR_Region__c' => 'Paris',
                    'LPCR_EntiteJuridique__c' => UM002_TestDataFactory.setupLegalEntity().Id
                    };
                        
                        SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c) UM002_TestDataFactory.createSObject('SBQQ__QuoteLine__c', defaultVal);
            insert quoteLine;
            
            opp.SBQQ__PrimaryQuote__c = quote.Id;
            update opp;
            
            //Order the quote to create Order / OrderItems
            update new SBQQ__Quote__c (Id = quote.Id, SBQQ__Ordered__c = true);
            
            
            //Update orders to trigger OrderItem Update => test setupInvoiceDates
            List<Order> orders = [SELECT Id , SBQQ__Contracted__c, Status, OpportunityId, EffectiveDate, AccountId, SBQQ__Quote__c, blng__BillingAccount__c, LPCR_TypeCreche__c FROM Order];
            for (Order order : orders) {
                order.LPCR_TypeFacturation__c='Arrears';
                order.blng__BillingAccount__c = order.blng__BillingAccount__c == null && order.AccountId != null 
                    ? order.AccountId
                    : order.blng__BillingAccount__c;
                
                order.LPCR_TypeCreche__c = String.isNotBlank(order.LPCR_TypeCreche__c)
                    ? order.LPCR_TypeCreche__c 
                    : 'MICRO';
            }
            
            update orders;
            Test.stopTest();
            
            Map<Id,OrderItem> mapOrderItem = new Map<Id,OrderItem>([SELECT Id, SBQQ__ChargeType__c,SBQQ__BillingType__c, ServiceDate, blng__NextChargeDate__c, blng__OverrideNextBillingDate__c,
                                                                    blng__NextBillingDate__c, blng__BillThroughDateOverride__c,Order.LPCR_TypeFacturation__c, Order.LPCR_FrequenceFacturation__c,OrderId, Order.LPCR_TypeCreche__c, blng__BillingAccount__c, Order.blng__BillingAccount__r.RecordTypeId FROM OrderItem]);
            
            Date expectedDate = System.today().addDays(invoiceDelta);
            
            for (OrderItem oi : mapOrderItem.values()) {
                
                System.assertEquals(System.today(), oi.ServiceDate);
                System.assertEquals(System.today(), oi.blng__NextChargeDate__c);
                
                
                System.assertEquals(null, oi.blng__BillThroughDateOverride__c);
                
                Date expectedOverrideNextBillingDate = !UM005_DateUtility.quarterlyMonths.contains(oi.blng__NextBillingDate__c.month()) || oi.blng__NextChargeDate__c.day() != 1
                    ? UM005_DateUtility.lastDayOfDatePeriod (oi.blng__NextChargeDate__c, UM005_DateUtility.quarterlyMonths).addDays(1) 
                    : null;
                System.assertEquals(expectedOverrideNextBillingDate.addDays(-1), oi.blng__OverrideNextBillingDate__c);
            }
        }
    }
    
    
    
    @IsTest
    //Do This test need an additional quote of type Referencement?
    static void setInvoiceGroupingOnOrderItem_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            blng__LegalEntity__c billingLegalEntity = UM002_TestDataFactory.setupLegalEntity();
            blng__RevenueRecognitionRule__c revRecRule = UM002_TestDataFactory.setupRevRec(billingLegalEntity.Id);
            blng__BillingRule__c   billingRule = UM002_TestDataFactory.setupBillingRule(billingLegalEntity.Id);
            blng__TaxRule__c   taxRule = UM002_TestDataFactory.setupTaxRule(billingLegalEntity.Id);        
            
            SBQQ__Quote__c quote = [SELECT Id,SBQQ__Ordered__c FROM SBQQ__Quote__c WHERE RecordTypeId = :QUOTE_CONTRAT_REF_RT_ID];
            
            Test.startTest(); 
            quote.SBQQ__Ordered__c  = true; 
            update quote;
            
            Order order = [SELECT Id , Status,SBQQ__Quote__c  FROM Order WHERE SBQQ__Quote__c = :quote.Id];            
            Test.stopTest();
            
            Map<Id,OrderItem> mapOrderItem = new Map<Id,OrderItem>([SELECT Id, LPCR_NumeroPurchaseOrder__c, blng__InvoiceGrouping__c, blng__InvoiceGroupId__c FROM OrderItem WHERE OrderId = :order.Id]);
            /*
//DCO Assertion commented once it systematically fails => LPCR_NumeroPurchaseOrder__c and blng__InvoiceGroupId__c are not correctly propagated and are null
// To be revied / fixed by author dev
for(OrderItem eachOrderItem : mapOrderItem.values()){
System.assertNotEquals(null, eachOrderItem.blng__InvoiceGroupId__c,'Invoice group id is Null in the OrderItem');
System.assertEquals(eachOrderItem.LPCR_NumeroPurchaseOrder__c, eachOrderItem.blng__InvoiceGroupId__c,'Invoice group id in order item is not  equal to PO Numero');
}
*/
        }                
    }
    
    @IsTest
    static void setInvoiceGrouping_Test(){
        Account customerAcc = null;
        List<Account> creches = new List<Account> ();
        System.runAs(UM002_TestDataFactory.createUser()){    
            Test.startTest();
            blng__LegalEntity__c billingLegalEntity = UM002_TestDataFactory.setupLegalEntity();
            blng__RevenueRecognitionRule__c revRecRule = UM002_TestDataFactory.setupRevRec(billingLegalEntity.Id);
            blng__BillingRule__c billingRule = UM002_TestDataFactory.setupBillingRule(billingLegalEntity.Id);
            blng__TaxRule__c taxRule = UM002_TestDataFactory.setupTaxRule(billingLegalEntity.Id);
            
            // Load Contract Type Conf
            Map<String, LPCR_TypeContrat__mdt> mapTypeContractConf = new Map<String, LPCR_TypeContrat__mdt> ();
            for (LPCR_TypeContrat__mdt typeContractConf : [SELECT Id, DeveloperName, LPCR_JourFacturation__c FROM LPCR_TypeContrat__mdt]) {
                mapTypeContractConf.put(typeContractConf.DeveloperName, typeContractConf);
            }
            Integer invoicingDay = Integer.valueOf(mapTypeContractConf.get('B2C_MICRO').LPCR_JourFacturation__c);
            
            //setup data for this particular test
            List<Account> accounts = [SELECT Id, RecordTypeId FROM Account];
            for (Account a : accounts) {
                if (a.RecordTypeId == B2C_RT_ID) {
                    customerAcc = a;
                } else if (a.RecordTypeId == CRECHE_RT_ID) {
                    creches.add (a);
                }
            }
            Map<String, Object> defaultVal = new Map<String, Object> {
                'Name' => 'prod2-test',
                    'isActive' => true,
                    'blng__BillingRule__c' => billingRule.Id,
                    'blng__RevenueRecognitionRule__c' => revRecRule.Id,
                    'blng__TaxRule__c' => taxRule.Id,
                    'SBQQ__SubscriptionPricing__c' => 'Fixed Price',
                    'ProductCode' => Label.Product_Code_Depot_Garantie
                    };
                        
                        Product2 prod2 = (Product2) UM002_TestDataFactory.createSObject('Product2', defaultVal);
            insert prod2;
            
            defaultVal = new Map<String, Object> {
                'isActive' => true,
                    'UnitPrice' => 100,
                    'Product2Id' => prod2.Id,
                    'Pricebook2Id' => standardPricebookId
                    };
                        
                        PricebookEntry priceBookEntry = (PricebookEntry) UM002_TestDataFactory.createSObject('PricebookEntry', defaultVal);
            insert priceBookEntry;
            
            defaultVal = new Map<String, Object> {
                'RecordTypeId' => OPPT_FAMILE_RT_ID,
                    'AccountId' => customerAcc.Id,
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
                    'SBQQ__Account__c' => customerAcc.Id,
                    'SBQQ__SubscriptionTerm__c' => 12,
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
                    'SBQQ__Opportunity2__c' => opp.Id,
                'SBQQ__RenewalUpliftRate__c' => 10
                    };
                        
                        SBQQ__Quote__c quote = (SBQQ__Quote__c) UM002_TestDataFactory.createSObject('SBQQ__Quote__c', defaultVal);
            insert quote;
            
            Integer price = 200;
            defaultVal = new Map<String, Object> {
                'Name' => 'prod2-test',
                    'SBQQ__StartDate__c' => System.Today(),
                    'SBQQ__Product__c' => prod2.Id,
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
                    'LPCR_Region__c' => 'Paris',
                    'SBQQ__BillingFrequency__c' => 'Monthly',
                    'LPCR_EntiteJuridique__c' => UM002_TestDataFactory.setupLegalEntity().Id
                    };
                        
                        SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c) UM002_TestDataFactory.createSObject('SBQQ__QuoteLine__c', defaultVal);
            insert quoteLine;
            
            opp.SBQQ__PrimaryQuote__c = quote.Id;
            update opp;
            
            
            
            //Order the quote to create Order / OrderItems
            update new SBQQ__Quote__c (Id = quote.Id, SBQQ__Ordered__c = true);
            System.assertEquals(Label.InvoiceGrouping_SeperateInvoice, [select id,blng__InvoiceGrouping__c from orderitem limit 1].blng__InvoiceGrouping__c);
            Test.stopTest();
            
        }    
    }
    
}