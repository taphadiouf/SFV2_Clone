/**
* @author  PDO
* @created 19/03/2021
* @description Trigger on SBQQ__Subscription__c Object
*/
public class TM023_SubscriptionTrigger extends TM000_TriggerHandler {
    private Map<Id, SBQQ__Subscription__c> newSubscriptionMap;
    private Map<Id, SBQQ__Subscription__c> oldSubscriptionMap;
    public TM023_SubscriptionTrigger(){
        this.newSubscriptionMap = (Map<Id, SBQQ__Subscription__c>) Trigger.newMap;
        this.oldSubscriptionMap = (Map<Id, SBQQ__Subscription__c>) Trigger.oldMap;
    }
    protected override void afterInsert() {
        if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex')){
           SM027_SubscriptionService.updateContratNombreBerceau(newSubscriptionMap);
        }
    }

}