/**
 * @author Hanae Makboub
 * @created 12/02/2020
 * @description Test Class  on SM001_TaskServices
 */
@isTest
public with sharing class SM001_TaskServices_TEST {
    

    @isTest
    static void LEAD_RG03_IS250_Test(){
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName='Famille']
        List<Lead> leads = UM002_TestDataFactory.createLead(100,'test',rc.Id,'Nouveau');
        List<Lead> leads2 = UM002_TestDataFactory.createLead(100,'test',rc.Id,'deded');
        
        insert leads;
        insert leads2;

        Test.startTest();
        Map<Id,Lead> mapLeads = new Map<Id,Lead>([SELECT Id,Name FROM Lead]);
        List<Task> tasks = UM002_TestDataFactory.createTask(200,mapLeads.keyset());
        insert tasks;
        system.assertEquals([Select Status FROM Lead].status, 'En Cours');
        Test.stopTest();

    }
}
