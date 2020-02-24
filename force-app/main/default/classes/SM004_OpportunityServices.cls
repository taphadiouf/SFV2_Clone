/**
* @author Achraf ABOUL
* @created 20/02/2020
* @description Services class on Opportunity Object
*/
public class SM004_OpportunityServices {
    
    public static void syncOppRecordType(String recordTypeName, Map<Id, Opportunity> oppsMap){
        Id leadRecordTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Lead',recordTypeName);
        Id opportunityRecordTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Opportunity',recordTypeName);
        List<Lead> lll = [select id,name,lastname,firstname,email,phone,recordtypeId, convertedOpportunityId from lead];
        System.debug('ùùùùùùm : ' + lll);
        System.debug('*********$$$$$ : ' + EM002_LeadEntity.getLeadsByOppsAndRecordType(leadRecordTypeId, oppsMap.keySet()));
        for(Lead eachLead : EM002_LeadEntity.getLeadsByOppsAndRecordType(leadRecordTypeId, oppsMap.keySet())){
            System.debug('*****here again');
            oppsMap.get(eachLead.convertedOpportunityId).RecordTypeId = opportunityRecordTypeId;
        }
    }
}