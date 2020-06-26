/**
* @author Ayoub Ouarti
* @created 19/05/2020
* @description Trigger actions on blng__Usage__c Object
*/
public with sharing class TM013_UsageTrigger extends TM000_TriggerHandler {
    private List<blng__Usage__c> newUsageList;
    
    public TM013_UsageTrigger() {
        this.newUsageList = (List<blng__Usage__c>) Trigger.new;
    }
    protected override void beforeInsert() {
        if (!FeatureManagement.checkPermission('LPCR_ByPass')){
            SM014_UsageServices.setUsageFields(newUsageList);
        }
    }
}