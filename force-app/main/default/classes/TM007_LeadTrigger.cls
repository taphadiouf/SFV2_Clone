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
        List<Lead> convertedLeadsList = new List<Lead>();
        for(Lead eachLead : newLeadsList){
            if(eachLead.isConverted){
                convertedLeadsList.add(eachLead);
            }
        }
        if(!convertedLeadsList.isEmpty()){
            SM007_LeadServices.syncOppRecordType('Entreprise', 'Entreprise', convertedLeadsList);
            SM007_LeadServices.syncOppRecordType('AO_PublicReservation', 'AOPublicReservataire', convertedLeadsList);
        }
        
    }
    protected  override void afterInsert(){
        if (PAD.canTrigger('SM001_TestIfByPassed')) SM001_TestIfByPassed.executeMethod();
        SM007_LeadServices.createLiensCrecheLead(newLeadsList);

    }
    
}