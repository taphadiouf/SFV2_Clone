/**
* @author Achraf ABOUL
* @date 10/03/2020
* @Description Test class of APC004_SendMailController
*/
@isTest
public class APC004_SendMailController_Test {

    @testSetup
    public static void setup(){
        Id enfantContactRecordTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Contact', 'Enfant');
        Account acc = UM002_TestDataFactory.createAccount('test');
        insert acc;
        
        UM002_TestDataFactory.ContactTdf c = new UM002_TestDataFactory.ContactTdf();
        Contact contact= c.create('Test','Test', acc);
        contact.RecordTypeId = enfantContactRecordTypeId;
        contact.Email = 'test@gmail.com';
        insert contact;
        List<LPCR_Preinscription__c> lstPreinscrition = UM002_TestDataFactory.createPreinscriptions(200,'test1','test2','Recommandation validée',acc.Id,contact.Id);
        insert lstPreinscrition;
        for(LPCR_Preinscription__c eachPreinscription : lstPreinscrition){
            eachPreinscription.LPCR_ContactParent__c = contact.Id;
        }
        update lstPreinscrition;
        User u = UM002_TestDataFactory.createUser();
        System.runAs(u){
        EmailTemplate emTemplate = UM002_TestDataFactory.createEmailTemplate('Test', 'Test', 'custom');
        insert emTemplate;
        }
        
       
    }
     @isTest
     public static void getAllMailTemplatesTest(){
         Test.startTest();
            APC004_SendMailController.getAllMailTemplates();
         Test.stopTest();
     }
     @isTest
     public static void sendMailTest(){
         Map<Id, LPCR_Preinscription__c> preInscriptionsMap =  new Map<Id, LPCR_Preinscription__c>([SELECT ID from LPCR_Preinscription__c]);
         List<Id> preInscriptionIds = new List<Id>();
         preInscriptionIds.addAll(preInscriptionsMap.keySet());
        Test.startTest();
            APC004_SendMailController.sendMail('Test subject', 'Test body', preInscriptionIds);
         Test.stopTest();
     }
}