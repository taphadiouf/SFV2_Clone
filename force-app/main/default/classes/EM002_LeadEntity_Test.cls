@isTest
public with sharing class EM002_LeadEntity_Test {
    @isTest
    static void EM002_LeadEntity_Test() {


        EM002_LeadEntity ent = new EM002_LeadEntity();
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName='Famille' AND SobjectType='Lead' limit 1];

        System.assertEquals('EM002_LeadEntity', ent.getDataManagerClassName());
        System.assertEquals('Lead', ent.getObjectName());

        //Method 1 : List<Lead> getLeadsByOppsAndRecordType(Id leadRecordTypeId, Set<Id> opportunitiesIds)
        Opportunity opp = UM002_TestDataFactory.createOpportunities(1, 'test', 'Prospecting').get(0);
        insert opp;
        List<Lead> leadsRes = EM002_LeadEntity.getLeadsByOppsAndRecordType(rc.Id,new Set<Id>{opp.id});
        System.assertEquals(0, leadsRes.size());

        // Method 2 : List<Lead> getLeadsBy(set<Id> setLeadIds,String recordTypeName)
        
        List<Lead> leads = UM002_TestDataFactory.createLeads(2,rc.Id,'test','test','Nouveau','test@test.com');
        insert leads;        
        List<Lead> leadRes = EM002_LeadEntity.getLeadsBy((new Map<Id,Lead>(leads)).keySet(),'Famille');
        System.assertNotEquals(0, leadRes.size());
        
        //Method 3 : getLeadsBy(set<Id> setLeadIds,String recordTypeName,String status) 
        leadRes.get(0).Status = 'En cours';
        update leadRes;
        List<Lead> res = EM002_LeadEntity.getLeadsBy((new Map<Id,Lead>(leads)).keySet(),'Famille','En cours');
        System.assertEquals(1, res.size());

        //Method 4 : List<Lead> getLeadsByIdsAndStatus(set<Id> setLeadIds, String status)
        List<Lead> res2 = EM002_LeadEntity.getLeadsByIdsAndStatus((new Map<Id,Lead>(leads)).keySet(),'En cours');
        System.assertEquals(1, res2.size());

        //Method 5 : Lead getAllLeadfielsById(Id leadId)
        Lead lRes = EM002_LeadEntity.getAllLeadfielsById(leadRes.get(0).Id);
        System.debug(lRes);

    }
}
