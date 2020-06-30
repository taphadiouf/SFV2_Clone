@isTest
public with sharing class APB001_ProcessLPCR_Log_Test {
    @testsetup
    static void setup() {
        Test.setMock(HttpCalloutMock.class, new MCK001_LPCRHttpCalloutMockImpl());
        Account acc = UM002_TestDataFactory.createAccount('test');
        insert acc;
        List<Attachment> atts = UM002_TestDataFactory.createAttachements(10,'test','test',acc.Id);
        insert atts;
        List<LPCR_Log__c> logs= UM002_TestDataFactory.createLogsFromAttachments('test','Sent','Document LPCR', atts);    
        insert logs;
    }

    static testmethod void test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            APB001_ProcessLPCR_Log lpcrLog = new APB001_ProcessLPCR_Log();
            Id batchId = Database.executeBatch(lpcrLog);
            Test.stopTest();
            System.assertEquals(0, [select count() from Attachment where Name='test']);
        }
    }
}