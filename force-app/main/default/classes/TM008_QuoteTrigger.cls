/**
* @author Achraf ABOUL
* @created 28/02/2020
* @description Trigger action handler on SBQQ__Quote__c Object
*/
public class TM008_QuoteTrigger extends TM000_TriggerHandler{
    private Map<Id, SBQQ__Quote__c> newQuotesMap;
    private Map<Id, SBQQ__Quote__c> oldQuotesMap;
    private List<SBQQ__Quote__c> newQuotesList;
    private String strnewQuotesMap;
    private String stroldQuotesMap;
    
    public TM008_QuoteTrigger() {
        this.newQuotesMap = (Map<Id, SBQQ__Quote__c>) Trigger.newMap;
        this.oldQuotesMap = (Map<Id, SBQQ__Quote__c>) Trigger.oldMap;
        this.newQuotesList = (List<SBQQ__Quote__c>) Trigger.new;
        
        
        
    } 
    protected override void beforeUpdate() {
               if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex') && runUpdateOnce && !System.isFuture()){

                SM008_QuoteServices.updateDateRevision(newQuotesList,oldQuotesMap);
                SM008_QuoteServices.updateOppsFromQuotes(newQuotesList);
                SM008_QuoteServices.updateQuotes(newQuotesList);
                
                
                if (!System.isBatch() && !System.isFuture()) {
                    SM008_QuoteServices.updateQuoteLineChiffreAffaire(UM003_TypeManager.getIdsOfListObjects(newQuotesList));
                }
                
            
        }
        
    }
    
    protected override void beforeInsert() {
        if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex')){     
            SM008_QuoteServices.updateQuotes(newQuotesList); 
            SM008_QuoteServices.updateDateRevision(newQuotesList,null);
            
        }
    }

    protected override void afterInsert() {
        if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex')){
            SM008_QuoteServices.updateAccountsFromQuotes(newQuotesList,null);
            SM008_QuoteServices.updateMontantIndexation(newQuotesMap);
            SM008_QuoteServices.updateRTDevis(newQuotesMap);
            SM008_QuoteServices.updateNumeroAvenant(newQuotesList);
        }
    }
    
    protected override void afterUpdate(){
        
        if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex') && runUpdateOnce && !System.isFuture()){

                SM008_QuoteServices.generateAgreementTemp(this.newQuotesMap,this.oldQuotesMap);
                SM008_QuoteServices.updateAccountsFromQuotes(newQuotesList,oldQuotesMap);
                
        }
        runUpdateOnce = false;
        
            
    }
    
    
}