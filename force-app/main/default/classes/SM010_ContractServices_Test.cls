/**
* @author Ayoub Ouarti
* @created 23/03/2020
* @description Test Class for SM010_ContractServices
* @updated by Achraf ABOUL(aaboul@salesforce.com) on 08/05/2020
*/
@isTest
public class SM010_ContractServices_Test {
    
    @testsetup
    static void setup(){
        Id standardPricebookId = Test.getStandardPricebookId();
        
        UM002_TestDataFactory.insertBillingCustomSettings();
        
        blng__LegalEntity__c billingLegalEntity = UM002_TestDataFactory.setupLegalEntity();
        
        blng__RevenueRecognitionRule__c revRecRule = UM002_TestDataFactory.setupRevRec(billingLegalEntity.Id);
        
        blng__BillingRule__c billingRule = UM002_TestDataFactory.setupBillingRule(billingLegalEntity.Id);
        
        blng__TaxRule__c taxRule = UM002_TestDataFactory.setupTaxRule(billingLegalEntity.Id);
        
        Id familleAccountRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Famille);
        Account acc = UM002_TestDataFactory.createAccounts(1,familleAccountRT,'test').get(0);
        acc.SBQQ__RenewalModel__c ='Contract Based';
        insert acc;
        
        Opportunity opp = UM002_TestDataFactory.createOpportunities(1, 'test', 'Prospecting').get(0);
        insert opp;
        SBQQ__Quote__c quote = UM002_TestDataFactory.createQuote('test',opp.Id, acc.Id, standardPricebookId, 'Quote');
        
        quote.SBQQ__Primary__c =true;
        insert quote;
                
        Product2 prod = UM002_TestDataFactory.createProduct('test', billingRule.Id, revRecRule.Id,taxRule.Id );
        prod.SBQQ__SubscriptionPricing__c ='Fixed Price';
        insert prod;
        
        PricebookEntry priceBookEntry1 = UM002_TestDataFactory.createPricebookEntry(standardPricebookId,prod.Id);
        insert priceBookEntry1;
        
        SBQQ__QuoteLine__c quoteLine = UM002_TestDataFactory.createQuoteLine(prod.Id, quote.Id, priceBookEntry1.Id, 200,1);
        insert quoteLine;
        opp.SBQQ__PrimaryQuote__c =quote.Id;
        update opp;
        LPCR_Planning__c planningEnfant = new LPCR_Planning__c();
        insert planningEnfant;
        
        quote.SBQQ__Ordered__c  = true; 
        quote.LPCR_IndexationConvenue__c='Oui';
        quote.LPCR_TypeFacturation__c='Arrears';
        quote.SBQQ__BillingFrequency__c='Invoice Plan';
        quote.LPCR_RenouvellementConvenu__c = 'Oui';
        quote.LPCR_DateDebut__c = Date.today();
        quote.LPCR_DateFin__c = Date.today() + 10;
        quote.LPCR_ChiffreAffaire__c = 1000;
        quote.SBQQ__RenewalUpliftRate__c = 2; 
        quote.LPCR_PlanningEnfant__c = planningEnfant.id;

        update quote;
        
        Order order = Database.query('SELECT Id ,SBQQ__Contracted__c , Status ,OpportunityId,EffectiveDate FROM Order WHERE SBQQ__Quote__c  = \''+quote.Id+'\'');
        order.status ='Activated';
        update order;
        
        
    }
    
    
    @isTest
    private static void setContractFieldsTest(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Date lastMonth=Date.newInstance(System.today().Year(), System.today().month() - 1, System.today().day()+1) ;
            Account acc = [SELECT Id, name from Account where name ='test' ];
            
            SBQQ__Quote__c quote = Database.query('SELECT Id,LPCR_IndexationConvenue__c,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c,LPCR_MasterDevis__c ,LPCR_RenouvellementConvenu__c,LPCR_DateDebut__c,LPCR_DateFin__c,LPCR_ChiffreAffaire__c, LPCR_MethodeRenouvellement__c,SBQQ__RenewalUpliftRate__c,LPCR_TypeEntreprise__c,LPCR_PlanningEnfant__c FROM SBQQ__Quote__c WHERE SBQQ__BillingCity__c = \'test\'');
            Order order = Database.query('SELECT Id , Status ,SBQQ__Contracted__c FROM Order WHERE SBQQ__Quote__c  = \''+quote.Id+'\'');
            
            Test.startTest();
            
            order.SBQQ__Contracted__c=true; 
            update order;
            
            Contract contract =null; 
           try{
                contract = [SELECT Id,SBQQ__Order__c,LPCR_BillingFrequency__c,LPCR_TypeFacturation__c,Status,StartDate,ContractTerm,LPCR_DateRenouvellement__c,LPCR_RenouvellementAutomatique__c, SBQQ__RenewalQuoted__c,LPCR_JoursAvance__c, LPCR_PlanningEnfant__c FROM Contract 
                            WHERE SBQQ__Order__c =:order.Id ]; 
            }catch(Exception e){
                system.debug('Error , Contract not get generated');
                contract = UM002_TestDataFactory.createContract(acc.Id,quote.Id,order.Id);
            }
           
            //contract.LPCR_RenouvellementAutomatique__c=true;
            contract.StartDate=lastMonth;
            contract.ContractTerm =1;
            contract.SBQQ__RenewalQuoted__c=false;
            upsert contract;
        
            Test.stopTest();
            contract = [SELECT Id,SBQQ__Order__c,LPCR_IndexationConvenue__c,LPCR_BillingFrequency__c,LPCR_TypeFacturation__c,LPCR_MasterDevis__c,Status,StartDate,ContractTerm,LPCR_DateRenouvellement__c,LPCR_RenouvellementAutomatique__c, SBQQ__RenewalQuoted__c,LPCR_JoursAvance__c,LPCR_RenouvellementConvenu__c,LPCR_DateDebut__c,LPCR_DateFin__c,LPCR_ChiffreAffaire__c, LPCR_MethodeRenouvellement__c,SBQQ__RenewalUpliftRate__c,LPCR_PlanningEnfant__c FROM Contract 
                        WHERE SBQQ__Order__c =:order.Id ]; 
            System.assertNotEquals(null, contract.LPCR_IndexationConvenue__c,'LPCR_IndexationConvenue__c is null');

            System.assertEquals(quote.LPCR_IndexationConvenue__c, contract.LPCR_IndexationConvenue__c,'LPCR_IndexationConvenue__c is not the same on the contract');

            System.assertNotEquals(null, contract.LPCR_TypeFacturation__c,'LPCR_TypeFacturation__c is null');

            System.assertNotEquals(null, contract.LPCR_BillingFrequency__c,'LPCR_BillingFrequency__c is null');

            System.assertEquals(quote.LPCR_TypeFacturation__c, contract.LPCR_TypeFacturation__c,'LPCR_TypeFacturation__c on the quote is not the same on the Contract');

            System.assertEquals(quote.SBQQ__BillingFrequency__c, contract.LPCR_BillingFrequency__c,'LPCR_BillingFrequency__c on the quote is not the same on the Contract');

            System.assertEquals(quote.LPCR_MasterDevis__c, contract.LPCR_MasterDevis__c,'LPCR_MasterDevis__c on the quote is not the same on the Contract');

            System.assertEquals(quote.LPCR_MasterDevis__c, contract.LPCR_MasterDevis__c,'LPCR_MasterDevis__c on the quote is not the same on the Contract');
            
            System.assertEquals(quote.LPCR_RenouvellementConvenu__c, contract.LPCR_RenouvellementConvenu__c,'LPCR_RenouvellementConvenu__c on the quote is not the same on the Contract');
            
            System.assertEquals(quote.LPCR_DateDebut__c, contract.LPCR_DateDebut__c,'LPCR_DateDebut__c on the quote is not the same on the Contract');
            
            System.assertEquals(quote.LPCR_DateFin__c, contract.LPCR_DateFin__c,'LPCR_DateFin__c on the quote is not the same on the Contract');
            
            System.assertEquals(quote.LPCR_ChiffreAffaire__c, contract.LPCR_ChiffreAffaire__c,'LPCR_ChiffreAffaire__c on the quote is not the same on the Contract');
            
            System.assertEquals(quote.LPCR_PlanningEnfant__c, contract.LPCR_PlanningEnfant__c,'LPCR_PlanningEnfant__c on the quote is not the same on the Contract');
            
            System.assertEquals(true, contract.LPCR_RenouvellementAutomatique__c,'LPCR_RenouvellementAutomatique__c on the quote is not the same on the Contract');
        
            System.assertEquals(quote.LPCR_DureeContratJour__c, contract.LPCR_DureeContratJour__c,'LPCR_DureeContratJour__c on the quote is not the same on the Contract');

        }
    }
    
}