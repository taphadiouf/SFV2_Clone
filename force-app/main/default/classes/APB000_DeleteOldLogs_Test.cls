@isTest
public with sharing class APB000_DeleteOldLogs_Test {
    
    static testmethod void test(){
        System.runAs(UM002_TestDataFactory.createUser()){

            LPCR_Log__c log = new LPCR_Log__c(Name='Test log');
            insert log;
 
            Test.startTest();
            APB000_DeleteOldLogs lpcrLog = new APB000_DeleteOldLogs();
            lpcrLog.execute(null);

            APB000_DeleteOldLogs apb = new APB000_DeleteOldLogs();
            apb.execute(null,new list<LPCR_Log__c>{log});
            Test.stopTest();
        }
    }
}