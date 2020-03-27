/**
* @author Achraf ABOUL
* @date 13/03/2020
* @Description Test class of APC005_PreinscriptionsEnCoursController
*/
@isTest
public with sharing class APC005_PreinscriptionsEnCoursCtrl_Test {
    @testSetup
    public static void setup(){
        Id enfantContactRecordTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Contact', 'Enfant');
        Account acc = UM002_TestDataFactory.createAccount('test');
        insert acc;
        
        UM002_TestDataFactory.ContactTdf c = new UM002_TestDataFactory.ContactTdf();
        Contact contact= c.create('Test','Test', acc);
        contact.RecordTypeId = enfantContactRecordTypeId;
        insert contact;
        List<LPCR_Preinscription__c> lstPreinscrition = UM002_TestDataFactory.createPreinscForEntreprise(200,'test1','test2','Recommandation validée',acc.Id,contact.Id);
        insert lstPreinscrition;
        User u = UM002_TestDataFactory.createUser();
        System.runAs(u){
        EmailTemplate emTemplate = UM002_TestDataFactory.createEmailTemplate('Test', 'Test', 'custom');
        insert emTemplate;
        }
    }
     @isTest
     public static void getPreInscriptionsByAccTest(){
         Id accId = [SELECT Id FROM Account WHERE Name='test' limit 1].Id;
         Test.startTest();
            APC005_PreinscriptionsEnCoursCtrl.getPreInscriptionsByAcc(accId);
         Test.stopTest();
     }
}
