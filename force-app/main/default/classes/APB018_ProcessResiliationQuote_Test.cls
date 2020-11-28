/**
* @author Saurabh Singh
* @date 18/03/2020
* @Description Testt class for PB002_RenewalContract
*/

@isTest
public class APB018_ProcessResiliationQuote_Test {
    private static final Id ACC_B2B_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Entreprise);
    private static final Id ACC_B2C_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Famille);
    private static final Id ACC_CRECHE_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Creche);
    private static final Id CONTRACT_B2B_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract, Label.LPCR_Reservataire);
    private static final Id CONTRACT_ACCUEIL_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract, Label.LPCR_ContratA);
    private static final Id OPPT_FAMILE_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Opportunity, Label.LPCR_Famille);
    private static final Id OPPT_ENTERPRISE_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Opportunity, Label.LPCR_Entreprise);
    private static final Id STANDARD_PRICEBOOK_ID = Test.getStandardPricebookId();
    private static final Id QUOTE_CONTRAT_ACCUEIL_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote, Label.LPCR_ContratA);
    private static final Id QUOTE_CONTRAT_REF_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote, Label.LPCR_Referencement);
    
    private static final Date todayDate = Date.toDay();
    
    @testsetup
    static void setup() {
        UM002_TestDataFactory.insertBillingCustomSettings();
        
        blng__LegalEntity__c billingLegalEntity = UM002_TestDataFactory.setupLegalEntity();
        blng__RevenueRecognitionRule__c revRecRule = UM002_TestDataFactory.setupRevRec(billingLegalEntity.Id);
        blng__BillingRule__c billingRule = UM002_TestDataFactory.setupBillingRule(billingLegalEntity.Id);
        blng__TaxRule__c taxRule = UM002_TestDataFactory.setupTaxRule(billingLegalEntity.Id);
        
        Map<String, Object> defaultVal = new Map<String, Object> {
            'RecordTypeId' => ACC_B2B_RT_ID,
                'Name' => 'Test-B2B',
                'SBQQ__RenewalModel__c' => 'Contract Based',
                'LPCR_PasDeSIRET__c' => true
                };
                    
        List<Account> accounts = new List<Account>();
        Account B2BAccount = (Account) UM002_TestDataFactory.createSObject('Account', defaultVal);
        accounts.add(B2BAccount);
        defaultVal.put('RecordTypeId',ACC_B2C_RT_ID);
        defaultVal.put('Name','Test-B2C');
        Account B2CAccount = (Account) UM002_TestDataFactory.createSObject('Account', defaultVal);
        accounts.add(B2CAccount);
        defaultVal.put('RecordTypeId',ACC_CRECHE_RT_ID);
        defaultVal.put('Name','Test-Creche');
        Account crecheAccount = (Account) UM002_TestDataFactory.createSObject('Account', defaultVal);
        accounts.add(crecheAccount);
        insert accounts;
        
        
        defaultVal = new Map<String, Object> {
            'Name' => 'prod-test',
                'isActive' => true,
                'blng__BillingRule__c' => billingRule.Id,
                'blng__RevenueRecognitionRule__c' => revRecRule.Id,
                'blng__TaxRule__c' => taxRule.Id,
                'SBQQ__SubscriptionPricing__c' => 'Fixed Price',
                'SBQQ__SubscriptionTerm__c' => 1,
                'ProductCode' => 'BerceauXXX'
                };
                    
                    Product2 prod = (Product2) UM002_TestDataFactory.createSObject('Product2', defaultVal);
        insert prod;
        
        defaultVal = new Map<String, Object> {
            'isActive' => true,
                'UnitPrice' => 100,
                'Product2Id' => prod.Id,
                'Pricebook2Id' => STANDARD_PRICEBOOK_ID
                };
                    
                    PricebookEntry priceBookEntry1 = (PricebookEntry) UM002_TestDataFactory.createSObject('PricebookEntry', defaultVal);
        insert priceBookEntry1;
        
        defaultVal = new Map<String, Object> {
            'RecordTypeId' => OPPT_ENTERPRISE_RT_ID,
                'AccountId' => B2BAccount.Id,
                'Name' => 'test-oppt-accuel',
                'StageName' => 'Signée',
                'CloseDate' => System.today(),
                'Pricebook2Id' => STANDARD_PRICEBOOK_ID,
                'Type' => 'New Business'
                };
                    
                    Opportunity oppB2BInitial = (Opportunity) UM002_TestDataFactory.createSObject('Opportunity', defaultVal);
        insert oppB2BInitial;
        
        Integer price = 200;
        
        defaultVal = new Map<String, Object> {
            'RecordTypeId' => QUOTE_CONTRAT_REF_RT_ID,
                'SBQQ__Account__c' => B2BAccount.Id,
                'SBQQ__SubscriptionTerm__c' => 12,
                'SBQQ__BillingFrequency__c' => 'Monthly',
                'LPCR_TypeFacturation__c' => 'Advance',
                'LPCR_IndexationConvenue__c' => 'Oui',
                'SBQQ__StartDate__c' => System.today(),
                'SBQQ__PricebookId__c' => STANDARD_PRICEBOOK_ID,
                'SBQQ__PriceBook__c' => STANDARD_PRICEBOOK_ID,
                'SBQQ__Type__c' => 'Quote',
                'SBQQ__QuoteLanguage__c' => 'English',
                'SBQQ__BillingCity__c' => 'Paris',
                'SBQQ__Primary__c' => true,
                'SBQQ__Opportunity2__c' => oppB2BInitial.Id,
                'LPCR_DateDebut__c'=>todayDate,
                'LPCR_DateFin__c'=>todayDate.addDays(60),
                'SBQQ__RenewalUpliftRate__c' => 10
                
                };
                    
                    SBQQ__Quote__c quoteB2BInitial = (SBQQ__Quote__c) UM002_TestDataFactory.createSObject('SBQQ__Quote__c', defaultVal);
        quoteB2BInitial.LPCR_Creation_conforme__c = true;
        insert quoteB2BInitial;
        
        price = 200;
        defaultVal = new Map<String, Object> {
            'Name' => 'quoteLine-B2B',
                'LPCR_Creche__c '=>crecheAccount.Id,
                'SBQQ__StartDate__c' => System.Today(),
                'SBQQ__Product__c' => prod.Id,
                'SBQQ__Quantity__c' => 1,
                'SBQQ__ListPrice__c' => price,
                'SBQQ__CustomerPrice__c' => price,
                'SBQQ__NetPrice__c' => price,
                'SBQQ__SpecialPrice__c' => price,
                'SBQQ__Quote__c' => quoteB2BInitial.Id,
                'SBQQ__PricebookEntryId__c' => priceBookEntry1.Id,
                'SBQQ__PricingMethod__c' => 'List',
                'SBQQ__ChargeType__c' => 'Recurring',
                'SBQQ__BillingType__c' => 'Advance',
                'SBQQ__BillingFrequency__c' => 'Monthly',
                'LPCR_Region__c' => 'Paris',
                'LPCR_NumeroPurchaseOrder__c' => '12345678',
                'LPCR_EntiteJuridique__c' => UM002_TestDataFactory.setupLegalEntity().Id
                };
                    
                    SBQQ__QuoteLine__c quoteLineB2BInitial= (SBQQ__QuoteLine__c) UM002_TestDataFactory.createSObject('SBQQ__QuoteLine__c', defaultVal);
        defaultVal.put('Name','quoteLine-B2B-2');
        
        SBQQ__QuoteLine__c quoteLineB2B2Initial= (SBQQ__QuoteLine__c) UM002_TestDataFactory.createSObject('SBQQ__QuoteLine__c', defaultVal);
        insert new List<SBQQ__QuoteLine__c>{quoteLineB2BInitial,quoteLineB2B2Initial};
            
            oppB2BInitial.SBQQ__PrimaryQuote__c = quoteB2BInitial.Id;
        update oppB2BInitial;
        
        // Create B2B Contract
        defaultVal = new Map<String, Object> {
            'RecordTypeId'=>CONTRACT_B2B_RT_ID,
                'AccountId' => B2BAccount.Id,
                'LPCR_DureeContratJour__c'=>100,
                'SBQQ__Quote__c'=>quoteB2BInitial.Id,
                'Status'=>'Draft',
                'LPCR_Creche__c'=>crecheAccount.Id
                };
                    Contract contractB2BInitial = (Contract) UM002_TestDataFactory.createSObject('Contract', defaultVal);
        insert contractB2BInitial;
        
        defaultVal = new Map<String, Object> {
            'RecordTypeId' => OPPT_ENTERPRISE_RT_ID,
                'AccountId' => B2BAccount.Id,
                'Name' => 'test-oppt-accuel',
                'StageName' => 'Signée',
                'CloseDate' => System.today(),
                'Pricebook2Id' => STANDARD_PRICEBOOK_ID,
                'Type' => 'New Business',
                'SBQQ__AmendedContract__c' => contractB2BInitial.id
                };
                    
                    Opportunity oppB2B = (Opportunity) UM002_TestDataFactory.createSObject('Opportunity', defaultVal);
        insert oppB2B;
        
        price = 200;
        
        defaultVal = new Map<String, Object> {
            'RecordTypeId' => QUOTE_CONTRAT_REF_RT_ID,
                'SBQQ__Account__c' => B2BAccount.Id,
                'SBQQ__SubscriptionTerm__c' => 12,
                'SBQQ__BillingFrequency__c' => 'Monthly',
                'LPCR_TypeFacturation__c' => 'Advance',
                'LPCR_IndexationConvenue__c' => 'Oui',
                'SBQQ__StartDate__c' => System.today(),
                'SBQQ__PricebookId__c' => STANDARD_PRICEBOOK_ID,
                'SBQQ__PriceBook__c' => STANDARD_PRICEBOOK_ID,
                'SBQQ__QuoteLanguage__c' => 'English',
                'SBQQ__BillingCity__c' => 'Paris',
                'SBQQ__Primary__c' => true,
                'SBQQ__Opportunity2__c' => oppB2B.Id,
                'LPCR_DateDebut__c'=>todayDate,
                'LPCR_DateFin__c'=>todayDate.addDays(60),
                'SBQQ__RenewalUpliftRate__c' => 10,
                'SBQQ__Type__c' => 'Amendment',
                'SBQQ__MasterContract__c' => contractB2BInitial.id,
                'LPCR_TypeAvenant__c' => 'Résiliation'
                
                };
                    
                    SBQQ__Quote__c quoteB2B = (SBQQ__Quote__c) UM002_TestDataFactory.createSObject('SBQQ__Quote__c', defaultVal);
        quoteB2B.LPCR_Creation_conforme__c = true;
        insert quoteB2B;
        
        price = 200;
        defaultVal = new Map<String, Object> {
            'Name' => 'quoteLine-B2B',
                'LPCR_Creche__c '=>crecheAccount.Id,
                'SBQQ__StartDate__c' => System.Today(),
                'SBQQ__Product__c' => prod.Id,
                'SBQQ__Quantity__c' => 1,
                'SBQQ__ListPrice__c' => price,
                'SBQQ__CustomerPrice__c' => price,
                'SBQQ__NetPrice__c' => price,
                'SBQQ__SpecialPrice__c' => price,
                'SBQQ__Quote__c' => quoteB2B.Id,
                'SBQQ__PricebookEntryId__c' => priceBookEntry1.Id,
                'SBQQ__PricingMethod__c' => 'List',
                'SBQQ__ChargeType__c' => 'Recurring',
                'SBQQ__BillingType__c' => 'Advance',
                'SBQQ__BillingFrequency__c' => 'Monthly',
                'LPCR_Region__c' => 'Paris',
                'LPCR_NumeroPurchaseOrder__c' => '12345678',
                'LPCR_EntiteJuridique__c' => UM002_TestDataFactory.setupLegalEntity().Id
                };
                    test.startTest();         
        SBQQ__QuoteLine__c quoteLineB2B= (SBQQ__QuoteLine__c) UM002_TestDataFactory.createSObject('SBQQ__QuoteLine__c', defaultVal);
        defaultVal.put('Name','quoteLine-B2B-2');
        
        SBQQ__QuoteLine__c quoteLineB2B2= (SBQQ__QuoteLine__c) UM002_TestDataFactory.createSObject('SBQQ__QuoteLine__c', defaultVal);
        insert new List<SBQQ__QuoteLine__c>{quoteLineB2B,quoteLineB2B2};
            
            oppB2B.SBQQ__PrimaryQuote__c = quoteB2B.Id;
        update oppB2B;
        
        // Create B2B Contract
        defaultVal = new Map<String, Object> {
            'RecordTypeId'=>CONTRACT_B2B_RT_ID,
                'AccountId' => B2BAccount.Id,
                'LPCR_DureeContratJour__c'=>100,
                'SBQQ__Quote__c'=>quoteB2B.Id,
                'Status'=>'Draft',
                'LPCR_Creche__c'=>crecheAccount.Id
                };
                    Contract contractB2B = (Contract) UM002_TestDataFactory.createSObject('Contract', defaultVal);
        insert contractB2B;
       test.stopTest();
    }
    
    @isTest
    private static void APB018_ProcessResiliationQuote_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Account B2BAccount = new Account(); 
            Account B2CAccount = new Account(); 
            Account CrecheAccount = new Account(); 
            
            for(Account acc : [SELECT Id, name from Account]){
                if(acc.Name == 'Test-B2B')
                    B2BAccount = acc;
                else if(acc.Name == 'Test-B2C')
                    B2CAccount = acc;
                else if(acc.Name == 'Test-Creche')
                    CrecheAccount = acc;
            }
            
            Contract contractB2B = [SELECT Id FROM Contract Order By CreatedDate desc LIMIT 1];
            Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
            PricebookEntry priceBookEntry1 = [SELECT Id FROM PricebookEntry WHERE Product2Id =: prod.id LIMIT 1];
            
            test.startTest();
                       
            Map<String, Object> defaultVal = new Map<String, Object> {
                'RecordTypeId' => OPPT_ENTERPRISE_RT_ID,
                    'AccountId' => B2BAccount.Id,
                    'Name' => 'test-oppt-accuel',
                    'StageName' => 'Signée',
                    'CloseDate' => System.today(),
                    'Pricebook2Id' => STANDARD_PRICEBOOK_ID,
                    'Type' => 'New Business',
                    'SBQQ__AmendedContract__c' => contractB2B.id
                    };
                        
                        Opportunity oppB2BRenv = (Opportunity) UM002_TestDataFactory.createSObject('Opportunity', defaultVal);
            insert oppB2BRenv;
            
            Integer price = 200;
            
            defaultVal = new Map<String, Object> {
                'RecordTypeId' => QUOTE_CONTRAT_REF_RT_ID,
                    'SBQQ__Account__c' => B2BAccount.Id,
                    'SBQQ__SubscriptionTerm__c' => 12,
                    'SBQQ__BillingFrequency__c' => 'Monthly',
                    'LPCR_TypeFacturation__c' => 'Advance',
                    'LPCR_IndexationConvenue__c' => 'Oui',
                    'SBQQ__StartDate__c' => System.today(),
                    'SBQQ__PricebookId__c' => STANDARD_PRICEBOOK_ID,
                    'SBQQ__PriceBook__c' => STANDARD_PRICEBOOK_ID,
                    'SBQQ__QuoteLanguage__c' => 'English',
                    'SBQQ__BillingCity__c' => 'Paris',
                    'SBQQ__Primary__c' => true,
                    'SBQQ__Opportunity2__c' => oppB2BRenv.Id,
                    'LPCR_DateDebut__c'=>todayDate,
                    'LPCR_DateFin__c'=>todayDate.addDays(60),
                    'SBQQ__RenewalUpliftRate__c' => 10,
                    'SBQQ__Type__c' => 'Amendment',
                    'SBQQ__MasterContract__c' => contractB2B.id,
                    'LPCR_TypeAvenant__c' => 'Résiliation'
                    
                    };
                        
                        SBQQ__Quote__c quoteB2BRenv = (SBQQ__Quote__c) UM002_TestDataFactory.createSObject('SBQQ__Quote__c', defaultVal);
            insert quoteB2BRenv;
            price = 200;
            defaultVal = new Map<String, Object> {
                'Name' => 'quoteLine-B2B',
                    'LPCR_Creche__c '=>crecheAccount.Id,
                    'SBQQ__StartDate__c' => System.Today(),
                    'SBQQ__Product__c' => prod.Id,
                    'SBQQ__Quantity__c' => 1,
                    'SBQQ__ListPrice__c' => price,
                    'SBQQ__CustomerPrice__c' => price,
                    'SBQQ__NetPrice__c' => price,
                    'SBQQ__SpecialPrice__c' => price,
                    'SBQQ__Quote__c' => quoteB2BRenv.Id,
                    'SBQQ__PricebookEntryId__c' => priceBookEntry1.Id,
                    'SBQQ__PricingMethod__c' => 'List',
                    'SBQQ__ChargeType__c' => 'Recurring',
                    'SBQQ__BillingType__c' => 'Advance',
                    'SBQQ__BillingFrequency__c' => 'Monthly',
                    'LPCR_Region__c' => 'Paris',
                    'LPCR_NumeroPurchaseOrder__c' => '12345678',
                    'LPCR_EntiteJuridique__c' => UM002_TestDataFactory.setupLegalEntity().Id
                    };
                        
                        SBQQ__QuoteLine__c quoteLineB2BRenv= (SBQQ__QuoteLine__c) UM002_TestDataFactory.createSObject('SBQQ__QuoteLine__c', defaultVal);
            defaultVal.put('Name','quoteLine-B2B-2');
            
            SBQQ__QuoteLine__c quoteLineB2BRenv2= (SBQQ__QuoteLine__c) UM002_TestDataFactory.createSObject('SBQQ__QuoteLine__c', defaultVal);
            insert new List<SBQQ__QuoteLine__c>{quoteLineB2BRenv,quoteLineB2BRenv2};
                
                oppB2BRenv.SBQQ__PrimaryQuote__c = quoteB2BRenv.Id;
            update oppB2BRenv;
                       
            //Order the quote to create Order / OrderItems
            update new SBQQ__Quote__c (Id = quoteB2BRenv.Id, SBQQ__Ordered__c = true);    
            
            Order orderB2B= [SELECT ID, blng__BillNow__c ,Status FROM Order WHERE SBQQ__Quote__c = :quoteB2BRenv.Id];  
            List<OrderItem> orderItems = [SELECT Id,SBQQ__DefaultSubscriptionTerm__c  FROM OrderItem WHERE OrderID = :orderB2B.Id];
            for(OrderItem eachOrderItem : orderItems){
                eachOrderItem.SBQQ__DefaultSubscriptionTerm__c=1;
            }
            update orderItems;
            
            APB018_ProcessResiliationQuote batch = new APB018_ProcessResiliationQuote();
            batch.execute(null);            
            Test.stopTest();  
            
            Contract checkContractB2B = [SELECT Id,Status FROM Contract WHERE Id =: contractB2B.id LIMIT 1];
            System.assertEquals('Terminé',checkContractB2B.Status, 'APB018_ProcessResiliationQuote B2B Contract Status not updated');
        }
        
    }
    
}