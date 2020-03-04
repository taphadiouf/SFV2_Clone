/**
* @ author Hanae Makboub
* @created 21/02/2020
* @description Test Class  on APC001_LeadFaConverController
*/

@isTest
public with sharing class APC001_LeadFaConverController_Test {
    
    @testSetup
    public static void setup(){
        RecordType crecheRecType = [SELECT Id FROM RecordType WHERE Name='Crèche' AND SObjectType = 'Account' limit 1];
        Account acc = UM002_TestDataFactory.createAccByRT('Test Acc', crecheRecType.Id);
        insert acc;
    }
    @isTest
    public static void getAccountsByRecordtype_Test(){
        RecordType crecheRecType = [SELECT Id FROM RecordType WHERE Name='Crèche' AND SObjectType = 'Account' limit 1];
        Test.startTest();
        List<Account> lstAcc = APC001_LeadFaConverController.getAccountsByRecordtype(crecheRecType.Id);
        System.assertEquals(1, lstAcc.size());
        Test.stopTest();
    }
    @isTest
    public static void APC001_LeadFaConverController_Test() {
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
            APC001_LeadFaConverController.createAccountFromLead(lstLead.get(0).Id);
            APC001_LeadFaConverController.createAccountFromLead(lstleads.get(0).Id);
            APC001_LeadFaConverController.createAccountFromLead(lstleadAcc.get(0).Id);
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
}