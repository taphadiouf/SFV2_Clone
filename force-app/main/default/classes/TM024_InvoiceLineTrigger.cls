/**
* @author  PDO
* @created 09/04/2021
* @description Trigger on Invoice Line Object
*/
public class TM024_InvoiceLineTrigger extends TM000_TriggerHandler{
    private Map<Id, blng__InvoiceLine__c> newInvoiceLineMap;
    private Map<Id, blng__InvoiceLine__c> oldInvoiceLineMap;
    public TM024_InvoiceLineTrigger(){
        this.newInvoiceLineMap = (Map<Id, blng__InvoiceLine__c>) Trigger.newMap;
        this.oldInvoiceLineMap = (Map<Id, blng__InvoiceLine__c>) Trigger.oldMap;
    }
    protected override void afterInsert() {
        if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex')){
            SM028_InvoiceLineService.populateNumberDaysBillingUsage(newInvoiceLineMap,oldInvoiceLineMap);
        }
    }

}