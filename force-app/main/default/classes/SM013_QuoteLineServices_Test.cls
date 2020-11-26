/**
* @author Dario Correnti
* @date 20/05/2020
* @description test class for SM013_QuoteLineServices
*/
@isTest
public with sharing class SM013_QuoteLineServices_Test {
    private static final Id B2C_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Famille);
    private static final Id CRECHE_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Creche);
    private static final Id OPPT_FAMILE_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Opportunity, Label.LPCR_Famille);
    private static final Id QUOTE_CONTRAT_ACCUEIL_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote, Label.LPCR_ContratA);
    private static final Id standardPricebookId = Test.getStandardPricebookId();

    @TestSetup
    static void setup () {
        
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
        accounts.add((Account) UM002_TestDataFactory.createSObject('Account', defaultVal));
        
        defaultVal = new Map<String, Object> {
            'RecordTypeId' => CRECHE_RT_ID,
            'Name' => 'Creche',
            'LPCR_TypeCreche__c' => 'MAC',
            'LPCR_Region__c' => 'Paris',
            'LPCR_TypeMensualisation__c' => 11 
        };
        Account creche = (Account) UM002_TestDataFactory.createSObject('Account', defaultVal);
        accounts.add (creche);
        insert accounts;
        
        defaultVal = new Map<String, Object> {
            'Name' => 'prod-test',
            'isActive' => true,
            'blng__BillingRule__c' => billingRule.Id,
            'blng__RevenueRecognitionRule__c' => revRecRule.Id,
            'blng__TaxRule__c' => taxRule.Id,
            'SBQQ__SubscriptionPricing__c' => 'Fixed Price',
            'SBQQ__SubscriptionTerm__c' => 12,
            'ProductCode' => Label.LPCR_RegistrationFeeMac
        };
        
        Product2 prod = (Product2) UM002_TestDataFactory.createSObject('Product2', defaultVal);
        insert prod;
        
        defaultVal = new Map<String, Object> {
            'isActive' => true,
            'UnitPrice' => 100,
            'Product2Id' => prod.Id,
            'Pricebook2Id' => standardPricebookId
        };
        
        PricebookEntry priceBookEntry = (PricebookEntry) UM002_TestDataFactory.createSObject('PricebookEntry', defaultVal);
        insert priceBookEntry;

        defaultVal = new Map<String, Object> {
            'RecordTypeId' => OPPT_FAMILE_RT_ID,
            'AccountId' => accounts.get(0).Id,
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
            'SBQQ__Account__c' => accounts.get(0).Id,
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
            'LPCR_TypeCreche__c' => 'MAC',
            'SBQQ__Primary__c' => true,
            'LPCR_Creche__c' => creche.Id,
            'SBQQ__Opportunity2__c' => opp.Id,
            'SBQQ__RenewalUpliftRate__c' => 10,
             'LPCR_Creation_conforme__c' => true
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
            'SBQQ__BillingFrequency__c' => 'Monthly',
            'LPCR_Region__c' => 'Paris',
            'LPCR_Creche__c' => creche.Id,
            'LPCR_EntiteJuridique__c' => UM002_TestDataFactory.setupLegalEntity().Id
        };

        SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c) UM002_TestDataFactory.createSObject('SBQQ__QuoteLine__c', defaultVal);
        insert quoteLine;
        
        opp.SBQQ__PrimaryQuote__c = quote.Id;
        update opp;

        //Order the quote to create Order / OrderItems
        try {
            update new SBQQ__Quote__c (Id = quote.Id, SBQQ__Ordered__c = true);
        } catch (Exception e ) {
            system.debug('*** SM013_QuoteLineServices_Test setup method exception :' + e.getMessage());
        }
        List<Order> orders = [SELECT Id , SBQQ__Contracted__c, Status, OpportunityId, EffectiveDate, AccountId, SBQQ__Quote__c, blng__BillingAccount__c, LPCR_TypeCreche__c FROM Order];
        for (Order order : orders) {
            order.blng__BillingAccount__c = order.blng__BillingAccount__c == null && order.AccountId != null 
                ? order.AccountId
                : order.blng__BillingAccount__c;

            order.LPCR_TypeCreche__c = String.isNotBlank(order.LPCR_TypeCreche__c)
                ? order.LPCR_TypeCreche__c 
                : 'MAC';

            //order.status = 'Activated';
        }
        update orders;

        /*List<Contract> contracts = new List<Contract>();
        for (Order order : orders) {
            defaultVal = new Map<String, Object> {
                'AccountId' => order.AccountId,
                'SBQQ__Quote__c' => order.SBQQ__Quote__c,
                'SBQQ__Order__c' => order.Id,
                'LPCR_RenouvellementAutomatique__c' => true,
                'StartDate' => System.today().addMonths(-1),
                'SBQQ__RenewalQuoted__c' => false,
                'ContractTerm' => 1,
                'LPCR_Creche__c' => creche.Id,
                'Status'=>'Draft'
            };

            contracts.add((Contract) UM002_TestDataFactory.createSObject('Contract', defaultVal));
            //tmpContract.Status='Activated';
        }
        insert contracts;

        // adjust contract data & Activate
        contracts = [SELECT Id, LPCR_JoursAvance__c, EndDate FROM Contract];
        for (Contract c : contracts) {
            Integer diffEndDate = c.EndDate.daysBetween(System.today());
            c.LPCR_JoursAvance__c = c.EndDate < System.today()
                ? diffEndDate
                : -1 * diffEndDate;
        }

        update contracts;

        for (Contract c : contracts) {
            c.Status='Activated';
        }
        update contracts;*/

        defaultVal = new Map<String, Object> {
            'Name' => 'Asset-MAC',
            'AccountId' => accounts.get(0).Id,
            'Product2Id' => prod.Id,
            'ProductCode' => Label.LPCR_RegistrationFeeMac,
            'SBQQ__QuoteLine__c' => quoteLine.Id
        };

        Asset asset = (Asset) UM002_TestDataFactory.createSObject('Asset', defaultVal);
        insert Asset;
    }
    
    @IsTest
    static void testCheckExistingRegistrationFee () {
        Product2 prod = [SELECT Id FROM Product2].get(0);
        PricebookEntry priceBookEntry = [SELECT Id FROM PricebookEntry].get(0);
        List<Account> customer = [SELECT Id FROM Account WHERE RecordTypeId = :B2C_RT_ID];
        List<Account> creche = [SELECT Id FROM Account WHERE RecordTypeId = :CRECHE_RT_ID];

        Boolean excepThrowed = false;
        String excepMessage = '';
        System.runAs(UM002_TestDataFactory.createUser()){
            // Create new quote with QL for Registration Fee for the same customer /creche
            Test.startTest();
            Map<String, Object> defaultVal = new Map<String, Object> {
                'RecordTypeId' => OPPT_FAMILE_RT_ID,
                'AccountId' => customer.get(0).Id,
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
                'SBQQ__Account__c' => customer.get(0).Id,
                'SBQQ__SubscriptionTerm__c' => 12,
                'SBQQ__Status__c' => 'Draft',
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
                'LPCR_TypeCreche__c' => 'MAC',
                'LPCR_Creche__c' => creche.get(0).Id,
                'SBQQ__Opportunity2__c' => opp.Id,
                'SBQQ__RenewalUpliftRate__c' => 10,
                'LPCR_Creation_conforme__c' => true
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
                'SBQQ__BillingFrequency__c' => 'Monthly',
                'LPCR_Region__c' => 'Paris',
                'LPCR_Creche__c' => creche.get(0).Id,
                'LPCR_EntiteJuridique__c' => UM002_TestDataFactory.setupLegalEntity().Id
            };

            SBQQ__QuoteLine__c quoteLine = (SBQQ__QuoteLine__c) UM002_TestDataFactory.createSObject('SBQQ__QuoteLine__c', defaultVal);
            try {
                insert quoteLine;
            } catch (Exception e) {
                excepThrowed = true;
                excepMessage = e.getMessage();
            }
            Test.stopTest();
			/* Comment this Code commited In 
			 * 28461176b768c7b283abaade1e6a479c2daa279f
			 * 8b47cdfc4d90437377e331f189a4f042bd3fa371 
			 * 43d522a33ece43a0ff883ebea0764bbab7b7bb45 
			 * And restore the original code by Dario
			 * c20b8170d55624a4b58153bf132d3e529a25192d 
            System.assertEquals(false, excepThrowed);
            System.assert(String.isBlank(excepMessage));
            System.assert(!excepMessage.contains(Label.LPCR_RegistrationFeeErrorMessage));*/
            
            System.assert( excepThrowed);
            System.assert(String.isNotBlank(excepMessage));
            System.assert(excepMessage.contains(Label.LPCR_RegistrationFeeErrorMessage));
        }
    }
}