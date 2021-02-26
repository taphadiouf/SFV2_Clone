/**
 * @author Erwan Yhuellou
 * @created 26/02/2021
* @description Trigger  handler on Billing Transaction Object
*/
public class TM023_BillingTransactionTrigger extends TM000_TriggerHandler{
    private Map<Id, blng__BillingTransaction__c> newBillingTransactionMap;
    private Map<Id, blng__BillingTransaction__c> oldBillingTransactionMap;
    private List<blng__BillingTransaction__c> newBillingTransactionList;
    
    public TM023_BillingTransactionTrigger() {
        this.newBillingTransactionMap = (Map<Id, blng__BillingTransaction__c>) Trigger.newMap;
        this.oldBillingTransactionMap = (Map<Id, blng__BillingTransaction__c>) Trigger.oldMap;
        this.newBillingTransactionList = (List<blng__BillingTransaction__c>) Trigger.new;
    }

    protected override void beforeUpdate() {
        if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex')){
            SM026_BillingTransactionServices.setCorrespondingRevenueTransactions(oldBillingTransactionMap,newBillingTransactionMap);
        }
    }
}