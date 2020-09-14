/**
* @author Hanae Makboub
* @created 15/05/2020
* @description Trigger action handler on LPCR_ModificationEntrante__c Object
*/
public class TM012_ModificationEntranteTrigger extends TM000_TriggerHandler{
	private Map<Id, LPCR_ModificationEntrante__c> newModificationsentrantesMap;
    private Map<Id, LPCR_ModificationEntrante__c> oldModificationsentrantesMap;
    private List<LPCR_ModificationEntrante__c> newModificationsentrantesList;
    
    public TM012_ModificationEntranteTrigger() {
        this.newModificationsentrantesMap = (Map<Id, LPCR_ModificationEntrante__c>) Trigger.newMap;
        this.oldModificationsentrantesMap = (Map<Id, LPCR_ModificationEntrante__c>) Trigger.oldMap;
        this.newModificationsentrantesList = (List<LPCR_ModificationEntrante__c>) Trigger.new;
    }
    protected override void afterInsert() {
        if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex')){
            SM022_ModificationEntranteServices.updateQuotesFromModifEntrantes(newModificationsentrantesList);
        }
    }
    protected override void afterUpdate() {
        if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex')){
            SM022_ModificationEntranteServices.sendAgreementFromModifEntrantes(newModificationsentrantesList, oldModificationsentrantesMap);
        }
    }
}