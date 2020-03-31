/**
* @ author Hanae Makboub
* @created 19/02/2020
* @description Test Class to display tables of plannings for each quote in a VFP001_GenererDocAnn2 VF page
*/

@isTest
public with sharing class VFC001_GenererDocAnn2_Test {
    @isTest
    public static void getPlannings_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            List<Account> accounts = UM002_TestDataFactory.createAccounts(100, 'testAccount');
            List<Opportunity> opps = UM002_TestDataFactory.createOpportunities(100, 'testOpp', 'Prospecting');
            insert accounts;
            insert opps;
            List<SBQQ__Quote__c> quotes = UM002_TestDataFactory.createQuotes(1, accounts, opps);
            insert quotes;
            SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c WHERE id IN: quotes limit 1];
            Time debutTime = Time.newInstance(08, 30, 2, 20);
            Time finTime = Time.newInstance(16, 30, 2, 20);
            List<LPCR_PlanningPrevisionnel__c> plannings = UM002_TestDataFactory.createPlannings(100,quote.Id,debutTime,finTime,debutTime,finTime,debutTime,finTime,debutTime,finTime,debutTime,finTime);
            insert plannings;
            Test.startTest();
            PageReference pageRef = Page.VFP001_GenererDocAnn2; // Add your VF page Name here
            pageRef.getParameters().put('recordId', String.valueOf(quote.Id));
            Test.setCurrentPage(pageRef);
            
            VFC001_GenererDocAnn2 planningController = new VFC001_GenererDocAnn2();
            List<LPCR_PlanningPrevisionnel__c> planing =[SELECT Id,LPCR_Contrat__c FROM LPCR_PlanningPrevisionnel__c];
            planningController.getPlannings();
        }
        
    }
    
    
    
}