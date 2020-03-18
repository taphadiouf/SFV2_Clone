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
    public static void  createLiensCrecheLead(List<Lead> leadsList){
        List<LPCR_LienCrecheLead__c> liensCrechesLeads = new  List<LPCR_LienCrecheLead__c>();
        for(Lead eachLead : leadsList){
            if(!String.isEmpty(eachLead.LPCR_CodeCreche1__c)){
                liensCrechesLeads.add(new LPCR_LienCrecheLead__c(
                    LPCR_Creche__c = eachLead.LPCR_CodeCreche1__c,
                    LPCR_Lead__c = eachLead.Id,
                    LPCR_OrdrePreference__c = 1
                ));
            }
            if(!String.isEmpty(eachLead.LPCR_CodeCreche2__c)){
                liensCrechesLeads.add(new LPCR_LienCrecheLead__c(
                    LPCR_Creche__c = eachLead.LPCR_CodeCreche2__c,
                    LPCR_Lead__c = eachLead.Id,
                    LPCR_OrdrePreference__c = 2
                ));
            }
            if(!String.isEmpty(eachLead.LPCR_CodeCreche3__c)){
                liensCrechesLeads.add(new LPCR_LienCrecheLead__c(
                    LPCR_Creche__c = eachLead.LPCR_CodeCreche3__c,
                    LPCR_Lead__c = eachLead.Id,
                    LPCR_OrdrePreference__c = 3
                ));
            }
        }
        insert liensCrechesLeads;
    }
}