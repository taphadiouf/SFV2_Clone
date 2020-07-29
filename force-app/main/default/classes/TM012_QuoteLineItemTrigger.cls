/**
* @author Dario Correnti
* @created 19/05/2020
* @description Trigger actions on QuoteLine Object
*/
public with sharing class TM012_QuoteLineItemTrigger extends TM000_TriggerHandler {
    //private Map<Id, SBQQ__QuoteLine__c> newQuoteLineMap;
    private List<SBQQ__QuoteLine__c> newQuoteLineList;
    
    public TM012_QuoteLineItemTrigger() {
        //this.newQuoteLineMap = (Map<Id, SBQQ__QuoteLine__c>) Trigger.newMap;
        this.newQuoteLineList = (List<SBQQ__QuoteLine__c>) Trigger.new;
    }
    protected override void beforeInsert() {
        if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex')){
            SM013_QuoteLineServices.checkExistingRegistrationFee(newQuoteLineList);
        }
    }
}