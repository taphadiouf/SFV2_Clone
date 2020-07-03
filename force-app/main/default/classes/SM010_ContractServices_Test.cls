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
        Opportunity opp2 = UM002_TestDataFactory.createOpportunities(1, 'test2', 'Prospecting').get(0);
        insert opp2;
        
        SBQQ__Quote__c quote = UM002_TestDataFactory.createQuote('test',opp.Id, acc.Id, standardPricebookId, 'Quote');
        quote.SBQQ__Primary__c =true;
        insert quote;
        
        SBQQ__Quote__c quote2 = UM002_TestDataFactory.createQuote('test2',opp2.Id, acc.Id, standardPricebookId, 'Quote');
        quote2.SBQQ__Primary__c =true;
        insert quote2;
        
        Product2 prod = UM002_TestDataFactory.createProduct('test', billingRule.Id, revRecRule.Id,taxRule.Id );
        prod.SBQQ__SubscriptionPricing__c ='Fixed Price';
        insert prod;
        
        PricebookEntry priceBookEntry1 = UM002_TestDataFactory.createPricebookEntry(standardPricebookId,prod.Id);
        insert priceBookEntry1;
        
        SBQQ__QuoteLine__c quoteLine = UM002_TestDataFactory.createQuoteLine(prod.Id, quote.Id, priceBookEntry1.Id, 200,1);
        insert quoteLine;
        opp.SBQQ__PrimaryQuote__c =quote.Id;
        
        
        
        SBQQ__QuoteLine__c quoteLine2 = UM002_TestDataFactory.createQuoteLine(prod.Id, quote2.Id, priceBookEntry1.Id, 150,1);
        insert quoteLine2;
        opp2.SBQQ__PrimaryQuote__c =quote2.Id;
        
        
        update new List<Opportunity>{opp,opp2};
            
            LPCR_Planning__c planningEnfant = new LPCR_Planning__c();
        insert planningEnfant;
        
        quote.SBQQ__Ordered__c  = true; 
        quote.LPCR_IndexationConvenue__c='Oui';
        quote.LPCR_TypeFacturation__c='Arrears';
        quote.SBQQ__BillingFrequency__c='Invoice Plan';
        quote.LPCR_DateDebut__c = Date.today();
        quote.LPCR_DateFin__c = Date.today() + 10;
        quote.LPCR_ChiffreAffaire__c = 1000;
        quote.SBQQ__RenewalUpliftRate__c = 2; 
        quote.LPCR_PlanningEnfant__c = planningEnfant.id;
        quote.LPCR_BatchCommande__c = 'Batch 2';
        quote.LPCR_ResponsableADV__c = UserInfo.getUserId();
        quote.SBQQ__SalesRep__c = UserInfo.getUserId();
        quote.LPCR_ResponsableServiceFamille__c = UserInfo.getUserId();
        
        quote2.SBQQ__Ordered__c  = true; 
        quote2.LPCR_IndexationConvenue__c='non';
        quote2.LPCR_TypeFacturation__c='Arrears';
        quote2.SBQQ__BillingFrequency__c='Invoice Plan';
        quote2.LPCR_DateDebut__c = Date.today();
        quote2.LPCR_DateFin__c = Date.today() + 100;
        quote2.LPCR_ChiffreAffaire__c = 100;
        quote2.SBQQ__RenewalUpliftRate__c = 2; 
        quote2.LPCR_PlanningEnfant__c = planningEnfant.id;
        quote2.LPCR_BatchCommande__c = 'Batch 2';
        
        
        update new List<SBQQ__Quote__c>{quote,quote2};
            
            Set<Id> quotesIds = new Set<Id>{quote2.Id,quote.Id};
                List<Order> orders = Database.query('SELECT Id ,SBQQ__Contracted__c , Status ,OpportunityId,EffectiveDate FROM Order WHERE SBQQ__Quote__c  in :quotesIds');
        for(Order order: orders)
        {
            order.status ='Activated';
        }
        update orders;
        
        
    }
    
    
    @isTest
    private static void setContractFieldsTest(){        
        System.runAs(UM002_TestDataFactory.createUser()){
            Date lastMonth=Date.newInstance(System.today().Year(), System.today().month() - 1, System.today().day()+1) ;
            
            Test.startTest();
            
            Account acc = [SELECT Id, name from Account where name ='test' ];
            
            SBQQ__Quote__c quote = Database.query('SELECT Id,LPCR_DureeContratJour__c,SBQQ__SalesRep__c, LPCR_ResponsableADV__c, LPCR_ResponsableServiceFamille__c,LPCR_IndexationConvenue__c,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c,LPCR_MasterDevis__c ,LPCR_DateDebut__c,LPCR_DateFin__c,LPCR_ChiffreAffaire__c, LPCR_MethodeRenouvellement__c,SBQQ__RenewalUpliftRate__c,LPCR_TypeEntreprise__c,LPCR_PlanningEnfant__c FROM SBQQ__Quote__c WHERE SBQQ__BillingCity__c = \'test\'');
            Order order = Database.query('SELECT Id , Status ,SBQQ__Contracted__c FROM Order WHERE SBQQ__Quote__c  = \''+quote.Id+'\'');       
            
            order.SBQQ__Contracted__c=true; 
            update order;
            
            Contract contract =null; 
            try{
                contract = [SELECT Id,SBQQ__Order__c, LPCR_Sales_Rep__c ,LPCR_ResponsableADV__c, LPCR_ResponsableServiceFamille__c, LPCR_BillingFrequency__c,LPCR_TypeFacturation__c,Status,StartDate,ContractTerm,LPCR_DateRenouvellement__c,LPCR_RenouvellementAutomatique__c, SBQQ__RenewalQuoted__c,LPCR_JoursAvance__c, LPCR_PlanningEnfant__c FROM Contract 
                            WHERE SBQQ__Order__c =:order.Id ]; 
            }catch(Exception e){
                PAD.log('SM010_ContractServices_Test','setContractFieldsTest','Error , Contract not get generated');
                contract = UM002_TestDataFactory.createContract(acc.Id,quote.Id,null);
            }
            
            //contract.LPCR_RenouvellementAutomatique__c=true;
            contract.StartDate=lastMonth;
            contract.ContractTerm =1;
            contract.SBQQ__RenewalQuoted__c=false;
            upsert contract;
            contract = [SELECT Id,LPCR_BatchCommande__c	 FROM Contract
                        WHERE SBQQ__Quote__c =:quote.Id ]; 
            System.assertEquals('Batch 2', contract.LPCR_BatchCommande__c,'LPCR_BatchCommande__c on the quote is not the same on the Contract');
			contract.SBQQ__Order__c = order.Id;
            update contract;
            Test.stopTest();
            contract = [SELECT Id,LPCR_DureeContratJour__c,LPCR_Sales_Rep__c, LPCR_ResponsableADV__c, LPCR_ResponsableServiceFamille__c, SBQQ__Order__c,LPCR_BatchCommande__c,LPCR_IndexationConvenue__c,LPCR_BillingFrequency__c,LPCR_TypeFacturation__c,LPCR_MasterDevis__c,Status,StartDate,ContractTerm,LPCR_DateRenouvellement__c,LPCR_RenouvellementAutomatique__c, SBQQ__RenewalQuoted__c,LPCR_JoursAvance__c,LPCR_DateDebut__c,LPCR_DateFin__c,LPCR_ChiffreAffaire__c, LPCR_MethodeRenouvellement__c,SBQQ__RenewalUpliftRate__c,LPCR_PlanningEnfant__c FROM Contract
                        WHERE SBQQ__Order__c =:order.Id ]; 
            System.assertNotEquals(null, contract.LPCR_IndexationConvenue__c,'LPCR_IndexationConvenue__c is null');
            
            System.assertEquals(quote.LPCR_IndexationConvenue__c, contract.LPCR_IndexationConvenue__c,'LPCR_IndexationConvenue__c is not the same on the contract');
            
            System.assertNotEquals(null, contract.LPCR_TypeFacturation__c,'LPCR_TypeFacturation__c is null');
            
            System.assertNotEquals(null, contract.LPCR_BillingFrequency__c,'LPCR_BillingFrequency__c is null');
            
            System.assertEquals(quote.LPCR_TypeFacturation__c, contract.LPCR_TypeFacturation__c,'LPCR_TypeFacturation__c on the quote is not the same on the Contract');
            
            System.assertEquals(quote.SBQQ__BillingFrequency__c, contract.LPCR_BillingFrequency__c,'LPCR_BillingFrequency__c on the quote is not the same on the Contract');
            
            System.assertEquals(quote.LPCR_MasterDevis__c, contract.LPCR_MasterDevis__c,'LPCR_MasterDevis__c on the quote is not the same on the Contract');
            
            System.assertEquals(quote.LPCR_MasterDevis__c, contract.LPCR_MasterDevis__c,'LPCR_MasterDevis__c on the quote is not the same on the Contract');
            
            System.assertEquals(quote.LPCR_DateDebut__c, contract.LPCR_DateDebut__c,'LPCR_DateDebut__c on the quote is not the same on the Contract');
            
            System.assertEquals(quote.LPCR_DateFin__c, contract.LPCR_DateFin__c,'LPCR_DateFin__c on the quote is not the same on the Contract');
            
            System.assertEquals(quote.LPCR_ChiffreAffaire__c, contract.LPCR_ChiffreAffaire__c,'LPCR_ChiffreAffaire__c on the quote is not the same on the Contract');
            
            System.assertEquals(quote.LPCR_PlanningEnfant__c, contract.LPCR_PlanningEnfant__c,'LPCR_PlanningEnfant__c on the quote is not the same on the Contract');
            
            System.assertEquals(true, contract.LPCR_RenouvellementAutomatique__c,'LPCR_RenouvellementAutomatique__c on the quote is not the same on the Contract');
            
            System.assertEquals('Batch 2', contract.LPCR_BatchCommande__c,'LPCR_BatchCommande__c on the order.quote is not the same on the Contract');
            
            System.assertEquals(quote.LPCR_DureeContratJour__c, contract.LPCR_DureeContratJour__c,'LPCR_DureeContratJour__c on the quote is not the same on the Contract');
            
            System.assertEquals(quote.SBQQ__SalesRep__c, contract.LPCR_Sales_Rep__c,'LPCR_Sales_Rep__c on the quote is not the same on the Contract');
            
            System.assertEquals(quote.LPCR_ResponsableADV__c, contract.LPCR_ResponsableADV__c,'LPCR_ResponsableADV__c on the quote is not the same on the Contract');
            
            System.assertEquals(quote.LPCR_ResponsableServiceFamille__c, contract.LPCR_ResponsableServiceFamille__c,'LPCR_ResponsableServiceFamille__c on the quote is not the same on the Contract');
            
        }
    }
    
    
    
    
    @isTest
    private static void setContractFieldsTest2(){        
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            Date lastMonth=Date.newInstance(System.today().Year(), System.today().month() - 1, System.today().day()+1) ;
            Account acc = [SELECT Id, name from Account where name ='test' ];
            
            SBQQ__Quote__c quote = Database.query('SELECT Id,LPCR_DureeContratJour__c,LPCR_IndexationConvenue__c,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c,LPCR_MasterDevis__c ,LPCR_DateDebut__c,LPCR_DateFin__c,LPCR_ChiffreAffaire__c, LPCR_MethodeRenouvellement__c,SBQQ__RenewalUpliftRate__c,LPCR_TypeEntreprise__c,LPCR_PlanningEnfant__c FROM SBQQ__Quote__c WHERE SBQQ__BillingCity__c = \'test\'');
            Order order = Database.query('SELECT Id , Status ,SBQQ__Contracted__c FROM Order WHERE SBQQ__Quote__c  = \''+quote.Id+'\'');
            
            SBQQ__Quote__c quote2 = Database.query('SELECT Id,LPCR_DureeContratJour__c,LPCR_IndexationConvenue__c,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c,LPCR_MasterDevis__c ,LPCR_DateDebut__c,LPCR_DateFin__c,LPCR_ChiffreAffaire__c, LPCR_MethodeRenouvellement__c,SBQQ__RenewalUpliftRate__c,LPCR_TypeEntreprise__c,LPCR_PlanningEnfant__c FROM SBQQ__Quote__c WHERE SBQQ__BillingCity__c = \'test2\'');
            Order order2 = Database.query('SELECT Id , Status ,SBQQ__Contracted__c FROM Order WHERE SBQQ__Quote__c  = \''+quote2.Id+'\'');
            
            
            
            
            order.SBQQ__Contracted__c=true; 
            update order;
            
            Contract contract =null; 
            try{
                contract = [SELECT Id,LPCR_DureeContratJour__c,SBQQ__Order__c,LPCR_BillingFrequency__c,LPCR_TypeFacturation__c,Status,StartDate,ContractTerm,LPCR_DateRenouvellement__c,LPCR_RenouvellementAutomatique__c, SBQQ__RenewalQuoted__c,LPCR_JoursAvance__c, LPCR_PlanningEnfant__c FROM Contract 
                            WHERE SBQQ__Order__c =:order.Id ]; 
            }catch(Exception e){
                PAD.log('SM010_ContractServices_Test','setContractFieldsTest2','Error , Contract not get generated');
                contract = UM002_TestDataFactory.createContract(acc.Id,quote.Id,order.Id);
            }
            
            //contract.LPCR_RenouvellementAutomatique__c=true;
            contract.StartDate=lastMonth;
            contract.ContractTerm =1;
            contract.SBQQ__RenewalQuoted__c=false;
            upsert contract;
            
            contract.SBQQ__Order__c=order2.Id;
            update contract;
            Test.stopTest();
            contract = [SELECT Id,SBQQ__Order__c,LPCR_BatchCommande__c,LPCR_IndexationConvenue__c,LPCR_BillingFrequency__c,LPCR_TypeFacturation__c,LPCR_MasterDevis__c,Status,StartDate,ContractTerm,LPCR_DateRenouvellement__c,LPCR_RenouvellementAutomatique__c, SBQQ__RenewalQuoted__c,LPCR_JoursAvance__c,LPCR_DateDebut__c,LPCR_DateFin__c,LPCR_ChiffreAffaire__c, LPCR_MethodeRenouvellement__c,SBQQ__RenewalUpliftRate__c,LPCR_PlanningEnfant__c FROM Contract 
                        WHERE SBQQ__Order__c =:order2.Id ]; 
            
            System.assertEquals(quote2.LPCR_IndexationConvenue__c, contract.LPCR_IndexationConvenue__c,'LPCR_IndexationConvenue__c is not the same on the contract');
            
            System.assertEquals(quote2.LPCR_DateFin__c, contract.LPCR_DateFin__c,'LPCR_DateFin__c is wrong');
            
            System.assertEquals(quote2.LPCR_ChiffreAffaire__c, contract.LPCR_ChiffreAffaire__c,'LPCR_ChiffreAffaire__c is wrong');
            
        }
    }
    
    @isTest
    private static void setOrderFieldsTest(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Date lastMonth=Date.newInstance(System.today().Year(), System.today().month() - 1, System.today().day()+1) ;
            
            Test.startTest();
            
            Account acc = [SELECT Id, name from Account where name ='test' ];
            
            SBQQ__Quote__c quote = Database.query('SELECT Id,LPCR_IndexationConvenue__c,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c,LPCR_MasterDevis__c ,LPCR_DateDebut__c,LPCR_DateFin__c,LPCR_ChiffreAffaire__c, LPCR_MethodeRenouvellement__c,SBQQ__RenewalUpliftRate__c,LPCR_TypeEntreprise__c,LPCR_PlanningEnfant__c FROM SBQQ__Quote__c WHERE SBQQ__BillingCity__c = \'test\'');
            Order order = Database.query('SELECT Id , Status ,SBQQ__Contracted__c FROM Order WHERE SBQQ__Quote__c  = \''+quote.Id+'\'');
            
            order.SBQQ__Contracted__c=true;
            update order;
            
            Contract contract =null;
            try{
                contract = [SELECT Id,SBQQ__Order__c,LPCR_BillingFrequency__c,LPCR_TypeFacturation__c,Status,StartDate,ContractTerm,LPCR_DateRenouvellement__c,LPCR_RenouvellementAutomatique__c, SBQQ__RenewalQuoted__c,LPCR_JoursAvance__c, LPCR_PlanningEnfant__c FROM Contract
                            WHERE SBQQ__Order__c =:order.Id ];
            }catch(Exception e){
                PAD.log('SM010_ContractServices_Test','setOrderFieldsTest','Error , Contract not get generated');
                contract = UM002_TestDataFactory.createContract(acc.Id,quote.Id,order.Id);
            }
            
            //contract.LPCR_RenouvellementAutomatique__c=true;
            contract.StartDate=lastMonth;
            contract.ContractTerm =1;
            contract.SBQQ__RenewalQuoted__c=false;
            upsert contract;
            
            OrderItem orderItem = [Select id, orderId, SBQQ__Contract__c from orderItem where orderId =:order.Id];
            
            
            contract = [SELECT Id,SBQQ__Order__c,LPCR_BatchCommande__c,LPCR_IndexationConvenue__c,LPCR_BillingFrequency__c,LPCR_TypeFacturation__c,LPCR_MasterDevis__c,Status,StartDate,ContractTerm,LPCR_DateRenouvellement__c,LPCR_RenouvellementAutomatique__c, SBQQ__RenewalQuoted__c,LPCR_JoursAvance__c,LPCR_DateDebut__c,LPCR_DateFin__c,LPCR_ChiffreAffaire__c, LPCR_MethodeRenouvellement__c,SBQQ__RenewalUpliftRate__c,LPCR_PlanningEnfant__c FROM Contract
                        WHERE SBQQ__Order__c =:order.Id ];
            
            orderItem.SBQQ__Contract__c = contract.id;
            update orderItem;
            
            LPCR_PlanFacturation__c billingPlan = new LPCR_PlanFacturation__c();
            billingPlan.LPCR_OrderItem__c = orderItem.id;
            insert billingPlan;
            
            contract.LPCR_BatchCommande__c = 'Batch 1';
            contract.SBQQ__RenewalUpliftRate__c = 5;
            update contract;
            
            Order order1 = [Select blng__InvoiceBatch__c from order where id =: order.Id ];
            
            Test.stopTest();
            System.assertEquals('Batch 1', order1.blng__InvoiceBatch__c,'blng__InvoiceBatch__c not updated on order');
            
        }
    }
    @IsTest
    static void setTypeEnregistrement_Test(){
        
        Test.startTest();
        
        Order currentOrder = [SELECT Id, LPCR_TypeEnregistrement__c FROM Order limit 1];
        currentOrder.LPCR_TypeEnregistrement__c = 'TestTypeEnregistrement';
        update currentOrder;
        Account currentAccount = [SELECT Id FROM Account limit 1];
        Contract newContract = UM002_TestDataFactory.createContract(currentAccount.Id, currentOrder.Id);
        insert newContract;
        Test.stopTest();
        newContract = [SELECT Id,LPCR_TypeEnregistrement__c FROM Contract WHERE Id = :newContract.Id limit 1];
        System.assertEquals('TestTypeEnregistrement', newContract.LPCR_TypeEnregistrement__c);
        
    }
    
}