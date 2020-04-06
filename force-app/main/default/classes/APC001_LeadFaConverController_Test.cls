/**
* @ author Hanae Makboub
* @created 21/02/2020
* @description Test Class  on APC001_LeadFaConverController
*/

@isTest
public with sharing class APC001_LeadFaConverController_Test {
    
    @testSetup
    public static void setup(){
        Id accountCrecheRTId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Creche);
        Map<String,Account> accountsMap  = new Map<String, Account>();
        accountsMap.put('Creche1', UM002_TestDataFactory.createAccByRT('Creche1', accountCrecheRTId));
        accountsMap.put('Creche2', UM002_TestDataFactory.createAccByRT('Creche2', accountCrecheRTId));
        accountsMap.put('Creche3', UM002_TestDataFactory.createAccByRT('Creche3', accountCrecheRTId));
        insert accountsMap.values();

        Id leadFamilleRTId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Lead, Label.LPCR_Famille); 
        Map<String, Object> fieldsMap = new Map<String, Object>();
        fieldsMap.put('LastName', 'CurrentLastName');
        fieldsMap.put('FirstName', 'CurrentLeadFirstName');
        fieldsMap.put('Phone', '12');
        fieldsMap.put('Company', 'LeadCompanyName');
        fieldsMap.put('RecordTypeId', leadFamilleRTId);
        fieldsMap.put('LPCR_CodeCreche1__c', accountsMap.get('Creche1').Id);
        fieldsMap.put('LPCR_CodeCreche2__c', accountsMap.get('Creche2').Id);
        fieldsMap.put('LPCR_CodeCreche3__c', accountsMap.get('Creche3').Id);
        fieldsMap.put('LPCR_NomEnfant1__c', 'NomEnfant1');
        fieldsMap.put('LPCR_NomEnfant2__c', 'NomEnfant2');
        fieldsMap.put('LPCR_NomEnfant3__c', 'NomEnfant3');
        fieldsMap.put('LPCR_PrenomEnfant1__c', 'PrenomEnfant1');
        fieldsMap.put('LPCR_PrenomEnfant2__c', 'PrenomEnfant2');
        fieldsMap.put('LPCR_PrenomEnfant3__c', 'PrenomEnfant3');

        Lead currentLeadFamille = UM002_TestDataFactory.createLeads(1, fieldsMap).get(0);
        insert currentLeadFamille;
    }
    @isTest
    public static void getRelatedCreches_Test(){
        Id leadId = [SELECT Id from Lead limit 1].Id;
        Test.startTest();
        List<Account> crechesList = APC001_LeadFaConverController.getRelatedCreches(leadId);
        System.assertEquals(3, crechesList.size());
        Test.stopTest();
    }
    @isTest
    public static void getEnfants_Test(){
        Id leadId = [SELECT Id from Lead limit 1].Id;
        Test.startTest();
        List<APC001_LeadFaConverController.WRP002_EnfantWrapper> enfantsList = (List<APC001_LeadFaConverController.WRP002_EnfantWrapper>) JSON.deserialize(APC001_LeadFaConverController.getEnfants(leadId), List<APC001_LeadFaConverController.WRP002_EnfantWrapper>.class);
        System.assertEquals(3, enfantsList.size());
        Test.stopTest();
    }
    /*
    @isTest
    public static void getAccountsByRecordtype_Test(){
        RecordType crecheRecType = [SELECT Id FROM RecordType WHERE Name='Crèche' AND SObjectType = 'Account' limit 1];
        Test.startTest();
        List<Account> lstAcc = APC001_LeadFaConverController.getAccountsByRecordtype(crecheRecType.Id);
        System.assertEquals(1, lstAcc.size());
        Test.stopTest();
    }*/
    /*
    @isTest
    public static void convertLead_Test() {
        System.runAs(UM002_TestDataFactory.createUser()){
            List<Contact> lstCon = new List<contact>();
            List<Contact> lstCons = new List<contact>();
            List<Account> lstAcc = new List<Account>();
            List<Contact> conLst = new List<contact>();
            List<Contact> consLst = new List<contact>();
            List<Account> accLst = new List<Account>();
            List<Contact> conAcclst = new List<contact>();
            List<Contact> consAcclst = new List<contact>();
            List<Account> accslst = new List<Account>();
            Date myDate = Date.newInstance(2019, 2, 17);
            RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName='Famille' AND SobjectType='Lead' limit 1];
            List<Lead> lstLead = UM002_TestDataFactory.createLeadsWithAllFields(1,rc.Id,'zzz','x','zzz','test','Nouveau','zzz@test.com','zzz',myDate,'zzz@zzz.com','0138482','M');
            insert lstLead; 
            List<Lead> lstleads = UM002_TestDataFactory.createLeadsWithAllFields(1,rc.Id,'xxx','z','xxx','test','Nouveau','xxx@test.com','xxx',myDate,'xxx@xxx.com','0138482','');
            insert lstleads; 
            List<Lead> lstleadAcc = UM002_TestDataFactory.createLeadsWithAllFields(1,rc.Id,'yy','c','c','test','Nouveau','yyy@test.com','yy',myDate,'yyy@yyy.com','0138482','');
            insert lstleadAcc; 
            Test.startTest();
           // APC001_LeadFaConverController.convertLead(lstLead.get(0).Id);
            //APC001_LeadFaConverController.convertLead(lstleads.get(0).Id);
            //APC001_LeadFaConverController.convertLead(lstleadAcc.get(0).Id);
            lstCon = [SELECT Id FROM Contact WHERE Name ='x zzz'];
            lstCons = [SELECT Id FROM Contact WHERE Name ='M zzz zzz'];
            lstAcc = [SELECT Id FROM Account WHERE Name ='Famille zzz zzz'];
            system.assertEquals(1,lstCon.size());
            system.assertEquals(2,lstCons.size());
            system.assertEquals(1,lstAcc.size());
            conLst = [SELECT Id FROM Contact WHERE Name ='z xxx'];
            consLst = [SELECT Id FROM Contact WHERE Name ='xxx xxx'];
            accLst = [SELECT Id FROM Account WHERE Name ='Famille xxx xxx'];
            system.assertEquals(1,conLst.size());
            system.assertEquals(2,consLst.size());
            system.assertEquals(1,accLst.size());
            conAcclst = [SELECT Id FROM Contact WHERE Name ='c yy'];
            consAcclst = [SELECT Id FROM Contact WHERE Name ='c yy'];
            accslst = [SELECT Id FROM Account WHERE Name ='Famille yy'];
            system.assertEquals(3,conAcclst.size());
            system.assertEquals(3,consAcclst.size());
            system.assertEquals(1,accslst.size());
            Test.stopTest();
        } 
    }
    */
}