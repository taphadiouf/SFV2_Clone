@isTest
public with sharing class DM000_SObject_Test {

    @isTest
    static void DM000_SObject_Test() {
        EM002_LeadEntity ent = new EM002_LeadEntity();
        
        RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName='Famille' AND SobjectType='Lead' limit 1];
        List<Lead> leads = UM002_TestDataFactory.createLeads(1,rc.Id,'test','test','Nouveau','test@test.com');
        ent.dmlExecuteRequest('insert',leads,true,'testMethod',DM000_SObject.ProcessType.TRIGGER_SRC);

        Lead l = leads[0];

        ent.getAllWithAllFields();

        ent.getAll(new Set<String>{'name'});

        ent.getByIds(new Set<Id>{l.id},new Set<String>{'name'});

        ent.getById(l.id,new Set<String>{'name'});

        Map<String, Set<String>> filtersMap = new Map<String, Set<String>>();
        filtersMap.put('id', new Set<String>{l.id});
        ent.getBy(new Set<String>{'name'},filtersMap);

        ent.getBy('id',new Set<String>{l.id},new Set<String>{'name'});

        ent.getBy('id',new Set<Id>{l.id},new Set<String>{'name'});

        ent.getFieldDescribeByType('String');

        ent.getPickListValues('Status');

        ent.getFieldsListFor('Lead');

        ent.buildFieldsMap('Lead');

        ent.getRequestAllFields();

        ent.dmlExecuteRequest('update',leads,true,'testMethod',DM000_SObject.ProcessType.LCC_SRC);

    }
}
