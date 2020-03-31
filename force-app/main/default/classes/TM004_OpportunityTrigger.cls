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
        if (PAD.canTrigger('SM001_TestIfByPassed')) SM001_TestIfByPassed.executeMethod();
        SM007_LeadServices.opportunitiesIds = new Set<Id>(newOpportunitiesMap.keySet());
        }
}