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
        Contact contactnullemail= c.create('Testnull','Testnull', acc);
        contactnullemail.RecordTypeId = enfantContactRecordTypeId;
        insert contactnullemail;
        Contact contact= c.create('Test','Test', acc);
        contact.RecordTypeId = enfantContactRecordTypeId;
        contact.Email = 'test@gmail.com';
        insert contact;
        List<LPCR_Preinscription__c> lstPreinscrition = UM002_TestDataFactory.createPreinscriptions(200,'test1','test2','Recommandation validée',acc.Id,contact.Id);
        insert lstPreinscrition;
        List<LPCR_Preinscription__c> lstPreinscritionnullemail = UM002_TestDataFactory.createPreinscriptions(1,'nomenfantnull','test3','Recommandation validée',acc.Id,contactnullemail.Id);
        insert lstPreinscritionnullemail;
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
         Map<Id, LPCR_Preinscription__c> preInscriptionsMap =  new Map<Id, LPCR_Preinscription__c>([SELECT ID from LPCR_Preinscription__c where NomEnfant__c!='nomenfantnull']);
         List<Id> preInscriptionIds = new List<Id>();
         preInscriptionIds.addAll(preInscriptionsMap.keySet());

         Map<Id, LPCR_Preinscription__c> preInscriptionsMapnull =  new Map<Id, LPCR_Preinscription__c>([SELECT ID from LPCR_Preinscription__c where NomEnfant__c='nomenfantnull']);
         List<Id> preInscriptionIdsnull = new List<Id>();
         preInscriptionIdsnull.addAll(preInscriptionsMapnull.keySet());
         
        Test.startTest();
        APC004_SendMailController.sendMail('Test subject', 'Test body', preInscriptionIds);
        try {
            APC004_SendMailController.sendMail('', null, preInscriptionIdsnull);
        } catch (Exception e ) {
            System.assertNotEquals(null, e.getMessage());
        }
        Test.stopTest();
     }
}