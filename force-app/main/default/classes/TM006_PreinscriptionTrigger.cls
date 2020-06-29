/**
* @author Ayoub Ouarti
* @created 25/02/2020
* @description Trigger on 
*/
public class TM006_PreinscriptionTrigger extends TM000_TriggerHandler{
    private Map<Id, LPCR_Preinscription__c> newPreinscriptionsMap;
    private Map<Id, LPCR_Preinscription__c> oldPreinscriptionsMap;
    private List<LPCR_Preinscription__c> newPreinscriptionsList;
    
    public TM006_PreinscriptionTrigger() {
        this.newPreinscriptionsMap = (Map<Id, LPCR_Preinscription__c>) Trigger.newMap;
        this.oldPreinscriptionsMap = (Map<Id, LPCR_Preinscription__c>) Trigger.oldMap;
        this.newPreinscriptionsList = (List< LPCR_Preinscription__c>) Trigger.new;
    }
    
    protected override void afterUpdate() {
        if (!FeatureManagement.checkPermission('LPCR_ByPass')){
            SM006_PreinscriptionServices.generateOpptyAndQuote(this.newPreinscriptionsMap,this.oldPreinscriptionsMap);
        }
       
    }

    protected override void beforeUpdate() {
        if (!FeatureManagement.checkPermission('LPCR_ByPass')){
            SM009_ParametrageScoreServices.setScoreOnpreinscriptions(newPreinscriptionsList);
            SM006_PreinscriptionServices.setStatusWhenValidateFormulaireIsTrue(this.newPreinscriptionsMap,this.oldPreinscriptionsMap);
        }
    }

    protected override void beforeInsert() {
        if (!FeatureManagement.checkPermission('LPCR_ByPass')){
            SM009_ParametrageScoreServices.setScoreOnpreinscriptions(newPreinscriptionsList);
            SM006_PreinscriptionServices.setStatusWhenValidateFormulaireIsTrue(newPreinscriptionsList);
        }
    }
}