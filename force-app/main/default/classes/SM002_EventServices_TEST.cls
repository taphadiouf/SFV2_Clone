/**
 * @author Hanae Makboub
 * @created 12/02/2020
 * @description Test Class  on SM002_EventServices
 */
@isTest
public with sharing class SM002_EventServices_TEST {
    

    @isTest
    public static void updateLeadsWithNewEvents_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName='Famille' AND SobjectType='Lead' limit 1];
            List<Lead> leads = UM002_TestDataFactory.createLeads(100,rc.Id,'test','test','Nouveau','test@test.com');
            List<Lead> leads2 = UM002_TestDataFactory.createLeads(100,rc.Id,'test1','test1','Entreprise','test1@test.com');
            
            insert leads;
            insert leads2;
    
            Test.startTest();
            Map<Id,Lead> mapLeads = new Map<Id,Lead>([SELECT Id,Name FROM Lead]);
            List<Event> events = UM002_TestDataFactory.createEvents(mapLeads.keyset(), 4, DateTime.now());
            insert events;
            Lead myLead = [Select Status FROM Lead WHERE LastName='test' limit 1];
            system.assertEquals('En cours', myLead.status);
            Test.stopTest();
        }
        

    }
}