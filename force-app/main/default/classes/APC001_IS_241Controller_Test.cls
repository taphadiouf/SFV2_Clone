/**
* @ author Hanae Makboub
* @created 21/02/2020
* @description Test Class  on APC001_IS_241Controller
*/

@isTest
public with sharing class APC001_IS_241Controller_Test {
    
    @testSetup
    public static void setup(){
        RecordType crecheRecType = [SELECT Id FROM RecordType WHERE Name='Crèche' AND SObjectType = 'Account' limit 1];
        Account acc = UM002_TestDataFactory.createAcc('Test Acc', crecheRecType.Id);
        insert acc;
    }
    @isTest
    public static void getAccountsByRecordtype_Test(){
        RecordType crecheRecType = [SELECT Id FROM RecordType WHERE Name='Crèche' AND SObjectType = 'Account' limit 1];
        Test.startTest();
        List<Account> lstAcc = APC001_IS_241Controller.getAccountsByRecordtype(crecheRecType.Id);
        System.assertEquals(1, lstAcc.size());
        Test.stopTest();
    }
    @isTest
    public static void APC001_IS_241Controller_Test() {
        System.runAs(UM002_TestDataFactory.createUser()){
            List<Contact> lstCon = new List<contact>();
            List<Contact> lstCons = new List<contact>();
            List<Account> lstAcc = new List<Account>();
            List<Contact> conLst = new List<contact>();
            List<Contact> consLst = new List<contact>();
            List<Account> accLst = new List<Account>();
            List<Contact> conAcccase = new List<contact>();
            List<Contact> consAcccase = new List<contact>();
            List<Account> accCase = new List<Account>();
            Date myDate = Date.newInstance(2019, 2, 17);
            RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName='Famille' AND SobjectType='Lead' limit 1];
            List<Lead> leadId = UM002_TestDataFactory.createLe(1,rc.Id,'zzz','zzz','test','Nouveau','zzz@test.com','zzz',myDate,'zzz@zzz.com','0138482','M');
            insert leadId; 
            List<Lead> thelead = UM002_TestDataFactory.createLe(1,rc.Id,'xxx','xxx','test','Nouveau','xxx@test.com','xxx',myDate,'xxx@xxx.com','0138482','');
            insert thelead; 
            List<Lead> accLeadcase = UM002_TestDataFactory.createLe(1,rc.Id,'y yy','y','test','Nouveau','yyy@test.com','yy',myDate,'yyy@yyy.com','0138482','');
            insert accLeadcase; 
            Test.startTest();
            APC001_IS_241Controller.createAccountFromLead(leadId.get(0).Id);
            APC001_IS_241Controller.createAccountFromLead(thelead.get(0).Id);
            APC001_IS_241Controller.createAccountFromLead(accLeadcase.get(0).Id);
            lstCon = [SELECT Id FROM Contact WHERE LastName ='zzz'];
            lstCons = [SELECT Id FROM Contact WHERE LastName ='M zzz zzz'];
            lstAcc = [SELECT Id FROM Account WHERE Name ='Famille zzz zzz'];
            system.assertEquals(1,lstCon.size());
            system.assertEquals(2,lstCons.size());
            system.assertEquals(1,lstAcc.size());
            conLst = [SELECT Id FROM Contact WHERE LastName ='xxx'];
            consLst = [SELECT Id FROM Contact WHERE LastName ='xxx xxx'];
            accLst = [SELECT Id FROM Account WHERE Name ='Famille xxx xxx'];
            system.assertEquals(1,conLst.size());
            system.assertEquals(2,consLst.size());
            system.assertEquals(1,accLst.size());
            conAcccase = [SELECT Id FROM Contact WHERE LastName ='y yy'];
            consAcccase = [SELECT Id FROM Contact WHERE LastName ='y yy'];
            accCase = [SELECT Id FROM Account WHERE Name ='Famille y yy'];
            system.assertEquals(3,conAcccase.size());
            system.assertEquals(3,consAcccase.size());
            system.assertEquals(1,accCase.size());
            Test.stopTest();
        } 
    }
}