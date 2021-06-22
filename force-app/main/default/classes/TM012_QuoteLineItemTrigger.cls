/**
* @author Dario Correnti
* @created 19/05/2020
* @description Trigger actions on QuoteLine Object
*/
public with sharing class TM012_QuoteLineItemTrigger extends TM000_TriggerHandler {
    
    private List<SBQQ__QuoteLine__c> newQuoteLineList;
    private Map<Id,SBQQ__QuoteLine__c> newQuoteLineMap;
    private Map<Id,SBQQ__QuoteLine__c> oldQuoteLineMap;
    public TM012_QuoteLineItemTrigger() {
        
        this.newQuoteLineList = (List<SBQQ__QuoteLine__c>) Trigger.new;
        this.newQuoteLineMap = (Map<Id, SBQQ__QuoteLine__c>) Trigger.newMap;
        this.oldQuoteLineMap = (Map<Id, SBQQ__QuoteLine__c>) Trigger.oldMap;
    }
    
    protected override void beforeInsert() {
        
        if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex')){
            
            SM013_QuoteLineServices.checkExistingRegistrationFee(newQuoteLineList);
            SM013_QuoteLineServices.setBillThroughDateOverride(newQuoteLineList);
            SM013_QuoteLineServices.calculateQuoteLine(newQuoteLineList);
        }
    }
    
    protected override void beforeUpdate() {
        if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex')) {

			SM013_QuoteLineServices.setBillThroughDateOverride(newQuoteLineList);            
            SM013_QuoteLineServices.calculateQuoteLine(newQuoteLineList);
        }
    }
    protected override void afterInsert() {
        if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex')) {
            SM013_QuoteLineServices.updateIndexationRemiseQuote(newQuoteLineList,newQuoteLineMap);
        }
        
    }
    protected override void afterUpdate() {
        if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex')) {
            SM013_QuoteLineServices.updateRemiseQuote(oldQuoteLineMap,newQuoteLineMap);
        }
    }

}
