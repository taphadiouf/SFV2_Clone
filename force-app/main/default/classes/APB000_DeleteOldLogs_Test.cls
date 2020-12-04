@isTest
public with sharing class APB000_DeleteOldLogs_Test {
    
    static testmethod void test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            APB000_DeleteOldLogs lpcrLog = new APB000_DeleteOldLogs();
            lpcrLog.execute(null);
            Test.stopTest();
        }
    }
}