/**
 * @description       :
 * @author            : Widaad Papauretty
 * @group             :
 * @last modified on  : 10-28-2021
 * @last modified by  : Widaad Papauretty
 **/
@isTest
public class APC013_UpliftNow_TEST {
  
    @testSetup
    static void setup() {
        Id standardPricebookId = Test.getStandardPricebookId();
        //billing
        UM002_TestDataFactory.insertBillingCustomSettings();

        blng__LegalEntity__c billingLegalEntity = UM002_TestDataFactory.setupLegalEntity();

        blng__RevenueRecognitionRule__c revRecRule = UM002_TestDataFactory.setupRevRec(billingLegalEntity.Id);

        System.debug('billingLegalEntity:' + billingLegalEntity);
        blng__BillingRule__c billingRule = UM002_TestDataFactory.setupBillingRule(billingLegalEntity.Id);

        blng__TaxRule__c taxRule = UM002_TestDataFactory.setupTaxRule(billingLegalEntity.Id);

        //create account
        Account acc = UM002_TestDataFactory.createAccounts(1, 'test').get(0);
        insert acc;

        //create creche
        List<RecordType> AllRts = [SELECT sobjecttype,developername,id FROM recordtype];
        Map<String,Id> RTNameIdAccount = new Map<String,Id>();
        for(RecordType rt : AllRts){
            switch on rt.sobjecttype {
                when 'Account' {		
                    RTNameIdAccount.put(rt.developername,rt.id);
                }
            }
        }
        id recTypeId = RTNameIdAccount.get('Creche');
        Account accCreche = UM002_TestDataFactory.createAccountWithRecType(1, 'Les petits diables', recTypeId, '').get(0);
        insert accCreche;

        //create product
        Product2 prod = UM002_TestDataFactory.createProduct('test', billingRule.Id, revRecRule.Id, taxRule.Id);
        prod.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        insert prod;

        //get pricebookentry
        PricebookEntry priceBookEntry = UM002_TestDataFactory.createPricebookEntry(standardPricebookId, prod.Id);
        insert priceBookEntry;

        SBQQ.TriggerControl.disable();
        try {
            //create opportunity
            Opportunity opp = UM002_TestDataFactory.createOpportunities(10, 'testOpp', 'Client').get(0);
            insert opp;

            //create quote
            SBQQ__Quote__c quote = UM002_TestDataFactory.createQuote('testCity', opp.id, acc.id, standardPricebookId, 'Quote');
            quote.LPCR_Creche__c = accCreche.id;
            quote.SBQQ__Primary__c = true;
            insert quote;

            SBQQ__Quote__c quote2 = UM002_TestDataFactory.createQuote('testCity2', opp.id, acc.id, standardPricebookId, 'Quote');
            quote2.LPCR_Creche__c = accCreche.id;
            quote2.SBQQ__Primary__c = true;
            insert quote2;

            //insert quote line
            SBQQ__QuoteLine__c quoteLine = UM002_TestDataFactory.createQuoteLine(prod.Id, quote.Id, priceBookEntry.Id, 200, 1);
            quoteLine.LPCR_Creche__c = accCreche.id;
            insert quoteLine;

            SBQQ__QuoteLine__c quoteLine2 = UM002_TestDataFactory.createQuoteLine(prod.Id, quote2.Id, priceBookEntry.Id, 200, 1);
            quoteLine2.LPCR_Creche__c = accCreche.id;
            insert quoteLine2;

            opp.SBQQ__PrimaryQuote__c = quote.Id;
            update opp;

            //create contract
            Date myDate = Date.today();
          

            //create order
            Order order = UM002_TestDataFactory.createOrder(acc.id, null,myDate, 'Order Test' ,'Draft',null);
            insert order;
            
            Order order2 = UM002_TestDataFactory.createOrder(acc.id, null,myDate, 'Order Test2' ,'Draft',null);
            insert order2;

            myDate.addYears(2);
            Contract contract = UM002_TestDataFactory.createContract(acc.id,quote.id, opp.id, myDate);
            insert contract;

            Contract contract2 = UM002_TestDataFactory.createContract(acc.id,quote2.id, opp.id, myDate);
            insert contract2;

            contract.SBQQ__RenewalUpliftRate__c = 3;
            contract.LPCR_DateRevisionPrix__c = myDate;
            contract.LPCR_UpliftNow__c = true;
            contract.LPCR_IndexationConvenue__c = 'Non';
            update contract;

        } finally {
            SBQQ.TriggerControl.enable();
        }
    }
    @isTest
    public static void doUpliftPositiveTest() {
        //start test
        test.startTest();
        Account acc = [SELECT Id, name from Account where name ='test' LIMIT 1];
        SBQQ__Quote__c quote = [SELECT Id, name FROM SBQQ__Quote__c WHERE 	SBQQ__Account__c =: acc.id ORDER BY Id ASC LIMIT 1];
       
        //Fetch contract
        Contract con = Database.query('SELECT AccountId, LPCR_Creche__c , SBQQ__Opportunity__c, SBQQ__Quote__c FROM Contract WHERE AccountId  = \'' + acc.id + '\' AND SBQQ__Quote__c = \''+quote.id+'\'');
        APC013_UpliftNow.doUplift(con.id);
        test.stopTest();

    }
    @isTest
    public static void doUpliftNegativeTest(){
        //start test
        test.startTest();
        Account acc = [SELECT Id, name from Account where name ='test' LIMIT 1];
        SBQQ__Quote__c quote = [SELECT Id, name FROM SBQQ__Quote__c WHERE 	SBQQ__Account__c =: acc.id ORDER BY Id DESC LIMIT 1];
        //Fetch contract
        Contract con = Database.query('SELECT AccountId, LPCR_Creche__c , SBQQ__Opportunity__c, SBQQ__Quote__c FROM Contract WHERE AccountId  = \'' + acc.id + '\' AND SBQQ__Quote__c = \''+quote.id+'\'');
        try{
            
            APC013_UpliftNow.doUplift(con.id);
            
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
        test.stopTest();
    }
}
