@isTest
public class EM009_StructureAOEntity_Test {
    
    @isTest
    static void EM009_StructureAOEntity_Test() {
        EM009_StructureAOEntity entity = new EM009_StructureAOEntity();
        
       System.assertEquals('Lead', entity.getObjectName());
       System.assertEquals('EM002_LeadEntity', entity.getDataManagerClassName());

        Id leadFamilleRTId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Lead, Label.LPCR_Famille);
        Lead familleLead =  UM002_TestDataFactory.createLeads(1, leadFamilleRTId, 'leadlastName', 'companyname', 'Email@gmail.com').get(0);

        insert familleLead;

        LPCR_Structure_AO__c str = new LPCR_Structure_AO__c(LPCR_Lead__c = familleLead.Id);
        insert str;

        List<LPCR_Structure_AO__c> res = EM009_StructureAOEntity.getStructuresAOByLeads(new Set<Id>{familleLead.Id});//leadsIds
        System.assertNotEquals(0, res.size());
    }
}


