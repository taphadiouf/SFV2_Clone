/**
* @author Dario Correnti
* @created 19/05/2020
* @description Trigger actions on QuoteLine Object
*/
public with sharing class TM012_QuoteLineItemTrigger extends TM000_TriggerHandler {
    
    private List<SBQQ__QuoteLine__c> newQuoteLineList;
    
    public TM012_QuoteLineItemTrigger() {
        
        this.newQuoteLineList = (List<SBQQ__QuoteLine__c>) Trigger.new;
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
            SM013_QuoteLineServices.updateIndexationRemiseQuote(newQuoteLineList);
        }
        
    }

}
