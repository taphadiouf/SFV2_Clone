/**
 * @author Nerea Leguinazabal 
 * @created 08/10/2021
* @description Trigger  handler on Billing Treatement Object
*/
public class TM026_BillingTreatmentTrigger extends TM000_TriggerHandler{
    private Map<Id, blng__BillingTreatment__c> newBillingTreatmentMap;
    private Map<Id, blng__BillingTreatment__c> oldBillingTreatmentMap;
    private List<blng__BillingTreatment__c> newBillingTreatmentList;
    
    public TM026_BillingTreatmentTrigger() {
        this.newBillingTreatmentMap = (Map<Id, blng__BillingTreatment__c>) Trigger.newMap;
        this.oldBillingTreatmentMap = (Map<Id, blng__BillingTreatment__c>) Trigger.oldMap;
        this.newBillingTreatmentList = (List<blng__BillingTreatment__c>) Trigger.new;
    }

    protected override void beforeUpdate() {
        if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex')){
            SM031_BillingTreatmentServices.setFinanceBook(newBillingTreatmentList);
        }
    }
}