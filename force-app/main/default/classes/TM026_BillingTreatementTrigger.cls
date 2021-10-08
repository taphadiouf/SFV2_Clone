/**
 * @author Nerea Leguinazabal 
 * @created 08/10/2021
* @description Trigger  handler on Billing Treatement Object
*/
public class TM026_BillingTreatementTrigger extends TM000_TriggerHandler{
    private Map<Id, blng__BillingTreatement__c> newBillingTreatementMap;
    private Map<Id, blng__BillingTreatement__c> oldBillingTreatementMap;
    private List<blng__BillingTreatement__c> newBillingTreatementList;
    
    public TM026_BillingTreatementTrigger() {
        this.newBillingTreatementMap = (Map<Id, blng__BillingTreatement__c>) Trigger.newMap;
        this.oldBillingTreatementMap = (Map<Id, blng__BillingTreatement__c>) Trigger.oldMap;
        this.newBillingTreatementList = (List<blng__BillingTreatement__c>) Trigger.new;
    }

    protected override void beforeUpdate() {
        if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex')){
            SM031_BillingTreatementServices.setFinanceBook(newBillingTreatementList);
        }
    }
}