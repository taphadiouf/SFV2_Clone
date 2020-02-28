/**
* @author Achraf ABOUL
* @created 26/02/2020
* @description Services class on Lead Object
*/
public class SM007_LeadServices {
    public static void syncOppRecordType(String leadRecordTypeName, String oppRecordTypeName, List<Lead> leadsList){
        Id leadRecordTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Lead',leadRecordTypeName);
        Id opportunityRecordTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Opportunity', oppRecordTypeName);
        Set<Id> oppsIdsToSync = new Set<Id>();
        for(Lead eachLead : leadsList){
            if(eachLead.recordTypeId != null && (''+eachLead.recordTypeId).equals(''+leadRecordTypeId)){
                oppsIdsToSync.add(eachLead.convertedOpportunityId);
            }
        }
        List<Opportunity> oppsToSync = EM004_OpportunityEntity.getOppsByIds(oppsIdsToSync);
        for(Opportunity eachOpp : oppsToSync){
            eachOpp.RecordTypeId = opportunityRecordTypeId;
        }
        update oppsToSync;
    }
}