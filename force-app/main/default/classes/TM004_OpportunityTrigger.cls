/**
* @author Achraf ABOUL
* @created 20/02/2020
* @description Trigger action handler on Opportunity Object
*/
public class TM004_OpportunityTrigger extends TM000_TriggerHandler{
    private Map<Id, Opportunity> newOpportunitiesMap;
    private Map<Id, Opportunity> oldOpportunitiesMap;
    private List<Opportunity> newOpportunitiesList;
    
    public TM004_OpportunityTrigger() {
        this.newOpportunitiesMap = (Map<Id, Opportunity>) Trigger.newMap;
        this.oldOpportunitiesMap = (Map<Id, Opportunity>) Trigger.oldMap;
        this.newOpportunitiesList = (List<Opportunity>) Trigger.new;
    }
    protected override void afterInsert() {
        if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex')){
            SM007_LeadServices.opportunitiesIds = new Set<Id>(newOpportunitiesMap.keySet());
            SM004_OpportunityServices.setAccountStatus(newOpportunitiesMap);
        }
    }
    
    protected override void afterUpdate() {
        if (!FeatureManagement.checkPermission('LPCR_ByPass')){
            SM004_OpportunityServices.setAccountStatus(newOpportunitiesMap,oldOpportunitiesMap);
        }
    }
}