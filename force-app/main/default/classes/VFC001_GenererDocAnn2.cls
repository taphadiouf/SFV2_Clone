/**
* @ author Hanae Makboub
* @created 18/02/2020
* @description controller to display tables of plannings for each quote in a VFP001_GenererDocAnn2 VF page
*/

public with sharing class VFC001_GenererDocAnn2 {
    
    SBQQ__Quote__c currentRecord;
    public VFC001_GenererDocAnn2() {
        //  currentRecord = new SBQQ__Quote__c(id=controller.getRecord().id);
        currentRecord = new SBQQ__Quote__c(id=Apexpages.currentPage().getParameters().get('recordId'));  
    }
    
    public List<planningPrevisionnelWrapper> getPlannings(){
        List<LPCR_PlanningPrevisionnel__c> plannings= EM010_PlanningPrEntity.getPlanningsByQuoteId(currentRecord.id);
        List<planningPrevisionnelWrapper> wrapperPlannings = new List<planningPrevisionnelWrapper>();
        for(LPCR_PlanningPrevisionnel__c pl : plannings ){
            wrapperPlannings.add(new planningPrevisionnelWrapper(pl));
        }
        return wrapperPlannings;
    }
    
    
    public class planningPrevisionnelWrapper{
        public String LPCR_Contrat{get;set;}
        public String LPCR_HeureDebutLundi{get;set;}
        public String LPCR_HeureFinLundi{get;set;} 
        public String LPCR_HeureDebutMardi{get;set;}
        public String LPCR_HeureFinMardi{get;set;}
        public String LPCR_HeureDebutMercredi{get;set;}
        public String LPCR_HeureFinMercredi{get;set;}
        public String LPCR_HeureDebutJeudi{get;set;} 
        public String LPCR_HeureFinJeudi{get;set;}
        public String LPCR_HeureDebutVendredi{get;set;}
        public String LPCR_HeureFinVendredi{get;set;}
        public planningPrevisionnelWrapper(LPCR_PlanningPrevisionnel__c pl){
            LPCR_HeureDebutLundi = convertTimeToString(pl.LPCR_HeureDebutLundi__c);
            LPCR_HeureFinLundi = convertTimeToString(pl.LPCR_HeureFinLundi__c);
            LPCR_HeureDebutMardi = convertTimeToString(pl.LPCR_HeureDebutMardi__c);
            LPCR_HeureFinMardi = convertTimeToString(pl.LPCR_HeureFinMardi__c);
            LPCR_HeureDebutMercredi = convertTimeToString(pl.LPCR_HeureDebutMercredi__c);
            LPCR_HeureFinMercredi = convertTimeToString(pl.LPCR_HeureFinMercredi__c);
            LPCR_HeureDebutJeudi = convertTimeToString(pl.LPCR_HeureDebutJeudi__c);
            LPCR_HeureFinJeudi = convertTimeToString(pl.LPCR_HeureFinJeudi__c);
            LPCR_HeureDebutVendredi = convertTimeToString(pl.LPCR_HeureDebutVendredi__c);
            LPCR_HeureFinVendredi = convertTimeToString(pl.LPCR_HeureFinVendredi__c);
        }
        public String convertTimeToString(Time tm){
            if(tm != null){
                return tm.hour()+':'+tm.minute();
            }
            return '';
        }
    }
    
    
}