/**
* @author Ayoub Ouarti
* @date 03/03/2020
* @Description Queries about Attachment
*/
@isTest
public with sharing class APC002_AttachmentController_Test {


    @testSetup
    public static void setup(){
         Account acc = UM002_TestDataFactory.createAccount('test');
         insert acc;
        
    }

    @isTest
    public static void saveAndgetAllAttachments_Test(){

         Account acc = [SELECT name From Account WHERE Name = 'test'];
        //Id idParent, String strFileName, String base64Data,String description
        APC002_AttachmentController.save(acc.Id,'Test','TEST','Test');
        List<Attachment> attachments = APC002_AttachmentController.getAllAttachments();
        System.assertNotEquals(null, attachments,'Attachment not created');
        System.assertNotEquals(0, attachments.size(),'Attachment not created');
    }
   

}