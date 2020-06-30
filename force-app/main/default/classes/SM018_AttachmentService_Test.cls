/**
* @author Saurabh
* @date 30/06/2020
* @description Test class for SM018_AttachmentService
*/
@isTest
public class SM018_AttachmentService_Test {
	@isTest
    static void sendLPCRDocumentByCallout_Test(){
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MCK001_LPCRHttpCalloutMockImpl());
        
        Account acc = UM002_TestDataFactory.createAccounts(1, 'testAccount').get(0);
        insert acc;
        
        List<Attachment> attachmentList = new List<Attachment>();
        Attachment attach1 = UM002_TestDataFactory.createAttachement('Attach1', 'Testing Body', acc.Id, 'Facture');
        Attachment attach2 = UM002_TestDataFactory.createAttachement('Attach2', 'Testing Body', acc.Id, 'Contrat');
        Attachment attach3 = UM002_TestDataFactory.createAttachement('Attach2', 'Testing Body', acc.Id, 'Test');
        attachmentList.add(attach1);
        attachmentList.add(attach2);
        attachmentList.add(attach3);
        
        insert attachmentList;
      
        Test.stopTest();
        List<LPCR_Log__c> successLogList = [SELECT Id, Name, LPCR_TargetObject__c, LPCR_Result__c FROM LPCR_Log__c WHERE LPCR_Result__c = 'Success'];
        List<LPCR_Log__c> errorLogList = [SELECT Id, Name, LPCR_TargetObject__c, LPCR_Result__c FROM LPCR_Log__c WHERE LPCR_Result__c = 'Error'];
        
        System.assertEquals(2, successLogList.size(), 'sendLPCRDocumentByCallout_Test success log failed');
        System.assertEquals(1, errorLogList.size(), 'sendLPCRDocumentByCallout_Test error log failed');
    }
}