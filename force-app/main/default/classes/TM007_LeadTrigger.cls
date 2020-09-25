/**
* @author Achraf ABOUL
* @created 26/02/2020
* @description Trigger action handler on Lead Object
*/
public class TM007_LeadTrigger extends TM000_TriggerHandler{
    private Map<Id, Lead> newLeadsMap;
    private Map<Id, Lead> oldLeadsMap;
    private List<Lead> newLeadsList;

    public TM007_LeadTrigger() {
        this.newLeadsMap = (Map<Id, Lead>) Trigger.newMap;
        this.oldLeadsMap = (Map<Id, Lead>) Trigger.oldMap;
        this.newLeadsList = (List<Lead>) Trigger.new;
    }

    protected override void beforeUpdate() {
        if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex')){
            List<Lead> convertedLeadsList = new List<Lead>();
            for(Lead eachLead : newLeadsList){
                if(eachLead.isConverted){
                    convertedLeadsList.add(eachLead);
                }
            }
            if(!convertedLeadsList.isEmpty()){
                SM007_LeadServices.syncRecordTypesWithLeads(convertedLeadsList);
                SM007_LeadServices.linkStructureAOsToOpps(convertedLeadsList);
            }
        }    
    }

    protected  override void afterInsert(){
        if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex')){
            SM007_LeadServices.createLiensCrecheLead(newLeadsList);
        }
    }
}