/**
* @author Ayoub Ouarti
* @created 15/07/2020
* @description Trigger actions on blng__CreditNote__c Object
*/
public with sharing class TM016_CreditNoteTrigger extends TM000_TriggerHandler{
	private Map<Id, blng__CreditNote__c> newCreditNoteMap;
    private Map<Id, blng__CreditNote__c> oldCreditNoteMap;
    private List<blng__CreditNote__c> newCreditNoteList;
    
    public TM016_CreditNoteTrigger() {
        this.newCreditNoteMap = (Map<Id, blng__CreditNote__c>) Trigger.newMap;
        this.oldCreditNoteMap = (Map<Id, blng__CreditNote__c>) Trigger.oldMap;
        this.newCreditNoteList = (List<blng__CreditNote__c>) Trigger.new;
    }
    
    protected override void afterInsert() {
        if (!FeatureManagement.checkPermission('LPCR_ByPass')){
            SM021_CreditNoteServices.updateReleatedObjectsFields(newCreditNoteList);
        }
    }

    protected override void afterUpdate() {
        if (!FeatureManagement.checkPermission('LPCR_ByPass')){
            SM021_CreditNoteServices.afterUpdateCreateCreditNoteAllocation(newCreditNoteList, oldCreditNoteMap);
        }
    }
}