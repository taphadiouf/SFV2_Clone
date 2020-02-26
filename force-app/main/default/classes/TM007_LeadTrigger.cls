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
        if (PAD.canTrigger('SM001_TestIfByPassed')) SM001_TestIfByPassed.executeMethod();
        System.debug('trigger launched from conversion');
        System.debug(this.newLeadsList.get(0));
        System.debug(this.newLeadsList.get(0).isConverted);
        System.debug(this.newLeadsList.get(0).convertedOpportunityId);
    }
    
}