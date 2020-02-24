/**
 * @author Hanae Makboub, Ayoub Ouarti
 * @created 12/02/2020
 * @description Test Class  on SM003_TaskServices
 */
@isTest
public with sharing class SM003_TaskServices_TEST {
    @testSetup 
    static void testSetup(){
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName='Famille' AND SobjectType='Lead' limit 1];
            List<Lead> leads = UM002_TestDataFactory.createLeads(100,rc.Id,'test','test','Nouveau','test@test.com');
            List<Lead> leads2 = UM002_TestDataFactory.createLeads(100,rc.Id,'test1','test1','Entreprise','test1@test.com');
        
            insert leads;
            insert leads2;

    }

    @isTest
    public static void LEAD_RG03_IS250_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            
            Test.startTest();
            Map<Id,Lead> mapLeads = new Map<Id,Lead>([SELECT Id,Name FROM Lead]);
            List<Task> tasks = UM002_TestDataFactory.createTasks(mapLeads.keyset());
            insert tasks;
            Lead myLead1 = [Select Status ,LPCR_DatePriseEnChargeCommercial__c FROM Lead WHERE LastName='test' limit 1];
            Lead myLead2 = [Select Status ,LPCR_DatePriseEnChargeCommercial__c FROM Lead WHERE LastName='test1' limit 1];
            system.assertEquals('En cours', myLead1.status);
            system.assertEquals(Date.today(), myLead1.LPCR_DatePriseEnChargeCommercial__c);
            system.assertEquals(Date.today(), myLead2.LPCR_DatePriseEnChargeCommercial__c);
            Test.stopTest();
        }
    }
}