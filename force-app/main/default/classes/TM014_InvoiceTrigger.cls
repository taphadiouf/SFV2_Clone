/**
* @author Saurabh
* @created 15/06/2020
* @description Trigger actions on blng__Invoice__c Object
*/

public with sharing class TM014_InvoiceTrigger extends TM000_TriggerHandler {
    private Map<Id, blng__Invoice__c> newInvoiceMap;
    private Map<Id, blng__Invoice__c> oldInvoiceMap;
    private List<blng__Invoice__c> newInvoiceList;
    
    public TM014_InvoiceTrigger() {
        this.newInvoiceMap = (Map<Id, blng__Invoice__c>) Trigger.newMap;
        this.oldInvoiceMap = (Map<Id, blng__Invoice__c>) Trigger.oldMap;
        this.newInvoiceList = (List<blng__Invoice__c>) Trigger.new;
    }
    protected override void beforeInsert() {
        if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex')){
            SM015_InvoiceServices.setFieldsOnInvoice(newInvoiceList,newInvoiceMap,true);
        }
    }
    protected override void beforeUpdate() {
        if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex')){
            SM015_InvoiceServices.setCongePrisPeriode(newInvoiceList,newInvoiceMap);
            SM015_InvoiceServices.setFieldsOnInvoice(newInvoiceList,newInvoiceMap,false);
        }
    }
    protected override void afterUpdate() {
        if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex')){
            SM015_InvoiceServices.createPaymentAndPaymentAllocation(newInvoiceList, oldInvoiceMap);
            // added by saurabh
            if(!System.isFuture() &&  !System.isBatch()){
                if(Limits.getFutureCalls() < Limits.getLimitFutureCalls()){
                    SM015_InvoiceServices.afterUpdateCreateCreditNoteAllocation(newInvoiceList, oldInvoiceMap);
                }
            }
        }
    }
}