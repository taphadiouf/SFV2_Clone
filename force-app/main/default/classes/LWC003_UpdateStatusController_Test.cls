@isTest
public with sharing class LWC003_UpdateStatusController_Test {
    @testSetup
    public static void setup(){
        Id enfantContactRecordTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Contact', 'Enfant');
        Account acc = UM002_TestDataFactory.createAccount('test');
        insert acc;
        
        UM002_TestDataFactory.ContactTdf c = new UM002_TestDataFactory.ContactTdf();
        Contact contact= c.create('Test','Test', acc);
        contact.RecordTypeId = enfantContactRecordTypeId;
        insert contact;
        List<LPCR_Preinscription__c> lstPreinscrition = UM002_TestDataFactory.createPreinscription(200,'test1','test2','Recommandation validée',acc.Id,contact.Id);
        insert lstPreinscrition;
       
    }
    @isTest
    public static void  getPicklistvalues_Test() {
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            LWC003_UpdateStatusController.getPicklistvalues();
            Test.stopTest();
        }
    }
    
    @isTest
    public static void updateLstPreinscription_Test() {
        System.runAs(UM002_TestDataFactory.createUser()){
            Map<Id, LPCR_Preinscription__c> preinscriptionIdsMap = new Map<Id, LPCR_Preinscription__c>([SELECT Id,LPCR_Statut__c FROM LPCR_Preinscription__c]);
            List<Id> preinscriptionIds = new List<Id>(preinscriptionIdsMap.keySet());
            Test.startTest();
            LWC003_UpdateStatusController.updateLstPreinscription('Option', preinscriptionIds);
            Test.stopTest();
        }
        
    }
}