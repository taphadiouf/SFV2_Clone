/**
* @author Achraf ABOUL
* @created 20/02/2020
* @description Services class on Opportunity Object
*/
public class SM004_OpportunityServices {
    
    public static void syncOppRecordType(String recordTypeName, Map<Id, Opportunity> oppsMap){
        Id leadRecordTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Lead',recordTypeName);
        Id opportunityRecordTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Opportunity',recordTypeName);
        for(Lead eachLead : EM002_LeadEntity.getLeadsByOppsAndRecordType(leadRecordTypeId, oppsMap.keySet())){
            //this.newOpportunitiesMap.get(eachLead.convertedOpportunityId).RecordTypeId = opportunityRecordTypeId;
        }
    }
}