@isTest
public with sharing class TM000_TriggerHandler_Test {
    @isTest
    static void TM000_TriggerHandler_Test() {


        TM001_AccountTriggerHandler accTrigg = new TM001_AccountTriggerHandler();
        accTrigg.setMaxLoopCount(50);
        accTrigg.clearMaxLoopCount();

        Account acc = UM002_TestDataFactory.createAccount('test');
        insert acc;

        acc.SBQQ__RenewalModel__c = 'Contract Based';
        update acc;

        acc.SBQQ__RenewalPricingMethod__c = 'Uplift';
        upsert acc;

        delete acc;

        undelete acc;
    }
}
