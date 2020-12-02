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
    public static void save_Test(){

         Account acc = [SELECT name From Account WHERE Name = 'test'];
        //Id idParent, String strFileName, String base64Data,String description
        Test.setMock(HttpCalloutMock.class, new MCK001_LPCRHttpCalloutMockImpl());
        try {
            APC002_AttachmentController.save(null,null,'TEST','Test','PDF');
        } catch (Exception e ) {
            System.assertNotEquals(null, e.getMessage());
        }
        
        Attachment att = APC002_AttachmentController.save(acc.Id,'Test','TEST','Test','PDF');
        APC002_AttachmentController.sendDocument(att.id);
    }


}