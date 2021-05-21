public class TM025_BonAchatPartenaireTrigger extends TM000_TriggerHandler  {
    private Map<Id, LPCR_BonAchatPartenaire__c> newBonAchatPartenaireMap;
    public TM025_BonAchatPartenaireTrigger() {
        this.newBonAchatPartenaireMap = (Map<Id, LPCR_BonAchatPartenaire__c>) Trigger.newMap;

    }
    protected override void afterInsert() {
        if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex')){
            SM030_BonAchatPartenaireService.populateBonAchatContrat(newBonAchatPartenaireMap);
        }
    }
}
