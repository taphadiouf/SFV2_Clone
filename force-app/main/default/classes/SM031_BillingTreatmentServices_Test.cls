@isTest
public with sharing class SM031_BillingTreatmentServices_Test {
    final private static String ACCOUNTING_FINANCEBOOK_NAME = 'Accounting';
    final private static String BILLINGRULE_NAME = 'BillingRule';

    @TestSetup
    static void setup(){

        blng__BillingRule__c billingRule = new blng__BillingRule__c(blng__InitialBillingTrigger__c = 'Order Product Activation Date', 
                                                                    Name = BILLINGRULE_NAME,
                                                                    blng__GenerateInvoices__c='Yes');
        insert billingRule;
                
            
        blng__InvoicePlan__c invoicePlan =   new blng__InvoicePlan__c();
        insert invoicePlan;

    }

    @isTest
    private static void setFinanceBook (){

        System.runAs(UM002_TestDataFactory.createAdminUser()){

            Test.startTest();
            blng__FinanceBook__c accoutingFinanceBook = new blng__FinanceBook__c(
            blng__Active__c = true, 
            Name = ACCOUNTING_FINANCEBOOK_NAME, 
            blng__PeriodType__c = 'Accounting');
            insert accoutingFinanceBook;

            blng__BillingTreatment__c newBillingTreatment = new blng__BillingTreatment__c(
                blng__BillingRule__c = [SELECT Id FROM blng__BillingRule__c WHERE Name=:BILLINGRULE_NAME LIMIT 1].Id,
                blng__InvoicePlan__c= [SELECT Id FROM blng__InvoicePlan__c LIMIT 1].Id,
                blng__BillingFinanceBook__c = 'a1g1j000000tVLzAAM');
            insert newBillingTreatment;

            System.debug('###ID:'+newBillingTreatment.Id);

            Test.stopTest();

            System.assertEquals([SELECT Id FROM blng__FinanceBook__c WHERE Name=:ACCOUNTING_FINANCEBOOK_NAME].Id, [SELECT blng__BillingFinanceBook__c FROM blng__BillingTreatment__c WHERE Id=:newBillingTreatment.Id].blng__BillingFinanceBook__c);

        }

    }

    @isTest
    private static void setFinanceBookNotFound (){

        System.runAs(UM002_TestDataFactory.createAdminUser()){

            Test.startTest();
            blng__BillingTreatment__c newBillingTreatment = new blng__BillingTreatment__c(
                blng__BillingRule__c = [SELECT Id FROM blng__BillingRule__c WHERE Name=:BILLINGRULE_NAME LIMIT 1].Id,
                blng__InvoicePlan__c= [SELECT Id FROM blng__InvoicePlan__c LIMIT 1].Id,
                blng__BillingFinanceBook__c = 'a1g1j000000tVLzAAM');
            insert newBillingTreatment;

            System.debug('###ID:'+newBillingTreatment.Id);

            Test.stopTest();

            System.assertEquals('a1g1j000000tVLzAAM', [SELECT blng__BillingFinanceBook__c FROM blng__BillingTreatment__c WHERE Id=:newBillingTreatment.Id].blng__BillingFinanceBook__c);

        }

    }
}
