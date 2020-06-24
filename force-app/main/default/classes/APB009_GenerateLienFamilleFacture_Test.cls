/**
    * @author Ayoub Ouarti
    * @date 22/06/2020
    * @Description Test class for APB009_GenerateLienFamilleFacture
    */
    @isTest
    public class APB009_GenerateLienFamilleFacture_Test {
        private static final Id ACC_B2B_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Entreprise);
        private static final Id ACC_B2C_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Famille);
        private static final Id ACC_CRECHE_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Creche);
        private static final Id CONTRACT_B2B_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract, Label.LPCR_Contrat_B2B);
        private static final Id CONTRACT_B2C_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract, Label.LPCR_Contrat_B2C);
        private static final Id OPPT_FAMILE_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Opportunity, Label.LPCR_Famille);
        private static final Id OPPT_ENTERPRISE_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Opportunity, Label.LPCR_Entreprise);
        private static final Id STANDARD_PRICEBOOK_ID = Test.getStandardPricebookId();
        private static final Id QUOTE_CONTRAT_ACCUEIL_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote, Label.LPCR_ContratA);
        private static final Id QUOTE_CONTRAT_REF_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote, 'Referencement');
        
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
                    'SBQQ__RenewalModel__c' => 'Contract Based'
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
                'RecordTypeId' => OPPT_FAMILE_RT_ID,
                    'AccountId' => B2CAccount.Id,
                    'Name' => 'test-oppt-accuel',
                    'StageName' => 'Signée',
                    'CloseDate' => System.today(),
                    'Pricebook2Id' => STANDARD_PRICEBOOK_ID,
                    'Type' => 'New Business'
                    };
                        Opportunity oppB2C = (Opportunity) UM002_TestDataFactory.createSObject('Opportunity', defaultVal);
            insert oppB2C;
            
            defaultVal = new Map<String, Object> {
                'RecordTypeId' => OPPT_ENTERPRISE_RT_ID,
                    'AccountId' => B2BAccount.Id,
                    'Name' => 'test-oppt-accuel',
                    'StageName' => 'Signée',
                    'CloseDate' => System.today(),
                    'Pricebook2Id' => STANDARD_PRICEBOOK_ID,
                    'Type' => 'New Business'
                    };
                        
                        Opportunity oppB2B = (Opportunity) UM002_TestDataFactory.createSObject('Opportunity', defaultVal);
            insert oppB2B;
            
            defaultVal = new Map<String, Object> {
                'RecordTypeId' => QUOTE_CONTRAT_ACCUEIL_RT_ID,
                    'SBQQ__Account__c' => B2CAccount.Id,
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
                    'SBQQ__Opportunity2__c' => oppB2C.Id,
                    'LPCR_DateDebut__c'=>todayDate,
                    'LPCR_DateFin__c'=>todayDate.addDays(60)
                    };
                        
                        SBQQ__Quote__c quoteB2C = (SBQQ__Quote__c) UM002_TestDataFactory.createSObject('SBQQ__Quote__c', defaultVal);
            insert quoteB2C;
            
            Integer price = 200;
            defaultVal = new Map<String, Object> {
                'Name' => 'quoteLine-B2C',
                    'SBQQ__StartDate__c' => System.Today(),
                    'SBQQ__Product__c' => prod.Id,
                    'SBQQ__Quantity__c' => 1,
                    'SBQQ__ListPrice__c' => price,
                    'SBQQ__CustomerPrice__c' => price,
                    'SBQQ__NetPrice__c' => price,
                    'SBQQ__SpecialPrice__c' => price,
                    'SBQQ__Quote__c' => quoteB2C.Id,
                    'SBQQ__PricebookEntryId__c' => priceBookEntry1.Id,
                    'SBQQ__PricingMethod__c' => 'List',
                    'SBQQ__ChargeType__c' => 'Recurring',
                    'SBQQ__BillingType__c' => 'Advance',
                    'SBQQ__BillingFrequency__c' => 'Monthly',
                    'LPCR_Region__c' => 'Paris',
                    'LPCR_NumeroPurchaseOrder__c' => '12345678',
                    'LPCR_EntiteJuridique__c' => UM002_TestDataFactory.setupLegalEntity().Id
                    };
                        
                        SBQQ__QuoteLine__c quoteLineB2C= (SBQQ__QuoteLine__c) UM002_TestDataFactory.createSObject('SBQQ__QuoteLine__c', defaultVal);
            insert quoteLineB2C;
            
            
            oppB2C.SBQQ__PrimaryQuote__c = quoteB2C.Id;
            update oppB2C;
            
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
                    'SBQQ__Opportunity2__c' => oppB2B.Id,
                    'LPCR_DateDebut__c'=>todayDate,
                    'LPCR_DateFin__c'=>todayDate.addDays(60)
                    
                    };
                        
                        SBQQ__Quote__c quoteB2B = (SBQQ__Quote__c) UM002_TestDataFactory.createSObject('SBQQ__Quote__c', defaultVal);
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
                        
                        SBQQ__QuoteLine__c quoteLineB2B= (SBQQ__QuoteLine__c) UM002_TestDataFactory.createSObject('SBQQ__QuoteLine__c', defaultVal);
              defaultVal.put('Name','quoteLine-B2B-2');
                        
                        SBQQ__QuoteLine__c quoteLineB2B2= (SBQQ__QuoteLine__c) UM002_TestDataFactory.createSObject('SBQQ__QuoteLine__c', defaultVal);
            insert new List<SBQQ__QuoteLine__c>{quoteLineB2B,quoteLineB2B2};
            
                oppB2B.SBQQ__PrimaryQuote__c = quoteB2B.Id;
            update oppB2B;
                //Order the quote to create Order / OrderItems
                update new SBQQ__Quote__c (Id = quoteB2B.Id, SBQQ__Ordered__c = true);    
            
            Order orderB2B= [SELECT ID, blng__BillNow__c ,Status FROM Order WHERE SBQQ__Quote__c = :quoteB2B.Id];  
            List<OrderItem> orderItems = [SELECT Id,SBQQ__DefaultSubscriptionTerm__c  FROM OrderItem WHERE OrderID = :orderB2B.Id];
            for(OrderItem eachOrderItem : orderItems){
                eachOrderItem.SBQQ__DefaultSubscriptionTerm__c=1;
            }
            update orderItems;      
        }
        
        @isTest
        private static void APB009_GenerateLienFamilleFacture_Test(){
            System.runAs(UM002_TestDataFactory.createUser()){
                  Test.startTest();
                Account accB2B = [SELECT Id, name from Account where name ='Test-B2B' LIMIT 1];
                Account accB2C = [SELECT Id, name from Account where name ='Test-B2C' LIMIT 1];
                Account accCreche = [SELECT Id, name from Account where name ='Test-Creche' LIMIT 1];
                SBQQ__Quote__c quoteB2C = [SELECT Id,SBQQ__Account__c FROM SBQQ__Quote__c WHERE SBQQ__Account__c=:accB2C.Id];
                SBQQ__Quote__c quoteB2B = [SELECT Id,SBQQ__Account__c FROM SBQQ__Quote__c WHERE SBQQ__Account__c=:accB2B.Id];
              
                
                Order  orderB2B = [SELECT Id, blng__BillNow__c ,Status,SBQQ__Quote__c FROM Order WHERE SBQQ__Quote__c = :quoteB2B.Id];  
                orderB2B.status='Activated';
                update orderB2B;
                
                Map<String, Object>     defaultVal = new Map<String, Object> {
                    'RecordTypeId'=>CONTRACT_B2B_RT_ID,
                        'AccountId' => accB2B.Id,
                        
                        'LPCR_DureeContratJour__c'=>100,
                        'SBQQ__Quote__c'=>quoteB2B.Id,
                        'Status'=>'Draft',
                        'LPCR_Creche__c'=>accCreche.Id
                        };
                            Contract contractB2B = (Contract) UM002_TestDataFactory.createSObject('Contract', defaultVal);
                insert contractB2B;
                
                
                defaultVal = new Map<String, Object> {
                    'RecordTypeId'=>CONTRACT_B2C_RT_ID,
                        'AccountId' => accB2C.Id,
                        
                        'LPCR_DureeContratJour__c'=>100,
                        'SBQQ__Quote__c'=>quoteB2C.Id,
                        'LPCR_ContractEntreprise__c'=>contractB2B.Id,
                        'Status'=>'Draft',
                        'LPCR_Creche__c'=>accCreche.Id
                        };
                            Contract contractB2C = (Contract) UM002_TestDataFactory.createSObject('Contract', defaultVal);
                insert contractB2C;
                
                orderB2B.blng__BillNow__c=true;
                update orderB2B;
                
                Map<Id,blng__Invoice__c> mapOfInvoice = new Map<Id,blng__Invoice__c>([SELECT Id, blng__Account__c,blng__Account__r.Name ,LPCR_LiaisonFamilleFacture__c
                                                                                      FROM blng__Invoice__c
                                                                                      WHERE  blng__Order__c  = :orderB2B.Id ]);   
                List<blng__InvoiceLine__c> listOfInvoiceLine = [SELECT Id,LPCR_Creche__c,blng__StartDate__c,blng__EndDate__c ,blng__Invoice__c,blng__Invoice__r.blng__Account__c,blng__OrderProduct__r.SBQQ__Contract__c
                                                                FROM blng__InvoiceLine__c
                                                                WHERE blng__Invoice__c =:mapOfInvoice.values().get(0).Id ];
                update new List<blng__InvoiceLine__c>{new blng__InvoiceLine__c(Id = listOfInvoiceLine.get(0).Id ,LPCR_Creche__c= accCreche.Id),new blng__InvoiceLine__c(Id = listOfInvoiceLine.get(1).Id ,LPCR_Creche__c= accCreche.Id)};
                
                
                APB009_GenerateLienFamilleFacture generateLienFamilleFacture = new APB009_GenerateLienFamilleFacture();
                generateLienFamilleFacture.execute(null);
                
                Test.stopTest();
                
                List<LPCR_LienFamilleFacture__c> listOfLienFamilleFactureFromBD = [SELECT Id,LPCR_Facture__c,LPCR_LigneFacture__c,LPCR_ContratFamille__c,LPCR_ContratEntreprise__c
                                                                                   FROM LPCR_LienFamilleFacture__c 
                                                                                   WHERE LPCR_Facture__c in :mapOfInvoice.KeySet() ];
                
                blng__Invoice__c invoice = [SELECT Id,LPCR_LiaisonFamilleFacture__c
                                            FROM blng__Invoice__c
                                            WHERE  Id  = :mapOfInvoice.values().get(0).Id ];   
                
                System.assertEquals(2,listOfLienFamilleFactureFromBD.size());
                System.assertEquals(true,invoice.LPCR_LiaisonFamilleFacture__c);
                
            }
        }
    }