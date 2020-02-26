/**
* @author Achraf ABOUL
* @created 20/02/2020
* @description Services class on Opportunity Object
*/
public class SM004_OpportunityServices {
    
    public static void syncOppRecordType(String leadRecordTypeName, String oppRecordTypeName, Map<Id, Opportunity> oppsMap){
        Id leadRecordTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Lead',leadRecordTypeName);
        System.debug('here is the leadRecordTypeId: ' + leadRecordTypeId);
        Id opportunityRecordTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Opportunity', oppRecordTypeName);
        System.debug('here is the opp rec type : ' + opportunityRecordTypeId);
        System.debug('Here is the list of leads by a good query'+[SELECT Id,LastName,convertedOpportunityId FROM Lead]);
        System.debug('here is the lisyt of leads : ' + EM002_LeadEntity.getLeadsByOppsAndRecordType(leadRecordTypeId, oppsMap.keySet()));
        for(Lead eachLead : EM002_LeadEntity.getLeadsByOppsAndRecordType(leadRecordTypeId, oppsMap.keySet())){
            oppsMap.get(eachLead.convertedOpportunityId).RecordTypeId = opportunityRecordTypeId;
        }
        System.debug('here is the oppsMap  : ' + oppsMap);
    }
}