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
        Set<String> oppFields = new Set<String>();
        oppFields.add('RecordTypeId');
        List<Opportunity> oppsToSync = new EM004_OpportunityEntity().getByIds(oppsIdsToSync, oppFields);
        for(Opportunity eachOpp : oppsToSync){
            eachOpp.RecordTypeId = opportunityRecordTypeId;
        }
        update oppsToSync;
    }
    public static void linkStructureAOsToOpps(List<Lead> convertedLeadsList){
        Id aoPublicReservationRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Lead', 'AO_PublicReservation');
        Id aoPublicDSPRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Lead', 'AO_PublicDSP');
        
        Map<Id, Lead> wantedLeadsMap = new Map<Id, Lead>();
        for(Lead eachLead : convertedLeadsList){
            if(!String.isEmpty(eachLead.recordTypeId) && (eachLead.recordTypeId.equals(aoPublicReservationRT) || eachLead.recordTypeId.equals(aoPublicDSPRT))){
                wantedLeadsMap.put(eachLead.id, eachLead);
            }
        }
        List<LPCR_Structure_AO__c> aoStructures = EM009_StructureAOEntity.getStructuresAOByLeads(wantedLeadsMap.keySet());
        for(LPCR_Structure_AO__c eachStructureAO : aoStructures){
            eachStructureAO.opportunite__c = wantedLeadsMap.get(eachStructureAO.LPCR_Lead__c).convertedOpportunityId;
        }
        update aoStructures;
    }
}