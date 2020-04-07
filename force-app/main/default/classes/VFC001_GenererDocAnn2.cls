/**
* @ author Hanae Makboub
* @created 18/02/2020
* @description controller to display tables of plannings for each quote in a VFP001_GenererDocAnn2 VF page
* @edited by Hanae on the 06/04/2020
*/

public with sharing class VFC001_GenererDocAnn2 {
    SBQQ__Quote__c currentRecord;
    public List<SBQQ__Quote__c> quotes{get;set;}
    public List<QPWrapper> QPWrappers{get;set;}
    public VFC001_GenererDocAnn2() {
        //  currentRecord = new SBQQ__Quote__c(id=controller.getRecord().id);
        currentRecord = new SBQQ__Quote__c(id=Apexpages.currentPage().getParameters().get('recordId')); 
        this.QPWrappers = new List<QPWrapper>();
        this.quotes = new List<SBQQ__Quote__c>();
        
        List<SBQQ__Quote__c> quo = [Select Id, SBQQ__StartDate__c,SBQQ__EndDate__c , (Select Id, 
                                                                                      LPCR_Contrat__c,
                                                                                      LPCR_HeureDebutLundi__c, 
                                                                                      LPCR_HeureFinLundi__c , 
                                                                                      LPCR_HeureDebutMardi__c, 
                                                                                      LPCR_HeureFinMardi__c, 
                                                                                      LPCR_HeureDebutMercredi__c, 
                                                                                      LPCR_HeureFinMercredi__c ,
                                                                                      LPCR_HeureDebutJeudi__c, 
                                                                                      LPCR_HeureFinJeudi__c , 
                                                                                      LPCR_HeureDebutVendredi__c, 
                                                                                      LPCR_HeureFinVendredi__c 
                                                                                      FROM Plannings_Pr_visionnels__r ) From SBQQ__Quote__c WHERE Id=:currentRecord.id];
        this.quotes = quo;
        List<SBQQ__Quote__c> quotesForWrapper = [Select Id, SBQQ__StartDate__c,SBQQ__EndDate__c From SBQQ__Quote__c WHERE Id=:currentRecord.Id];
        List<LPCR_PlanningPrevisionnel__c> plansForSelect = new List<LPCR_PlanningPrevisionnel__c>();
        List<QPWrapper> plansForWrapper = new List<QPWrapper>() ;
        SBQQ__Quote__c q;
        if(quotesForWrapper != null && !quotesForWrapper.isEmpty()){
            q = quotesForWrapper.get(0);
            plansForSelect = [Select Id, 
                               LPCR_Contrat__c,
                               LPCR_HeureDebutLundi__c, 
                               LPCR_HeureFinLundi__c , 
                               LPCR_HeureDebutMardi__c, 
                               LPCR_HeureFinMardi__c, 
                               LPCR_HeureDebutMercredi__c, 
                               LPCR_HeureFinMercredi__c ,
                               LPCR_HeureDebutJeudi__c, 
                               LPCR_HeureFinJeudi__c , 
                               LPCR_HeureDebutVendredi__c, 
                               LPCR_HeureFinVendredi__c 
                               FROM LPCR_PlanningPrevisionnel__c Where LPCR_Contrat__c =:q.Id];
            for(LPCR_PlanningPrevisionnel__c p :plansForSelect ){
                plansForWrapper.add(new QPWrapper(p));
            }
            if(plansForWrapper != null){
                QPWrapper wrapper = new QPWrapper(q, plansForWrapper);
                this.QPWrappers.add(wrapper);
            }
        }
    }
    public class QPWrapper{
        public SBQQ__Quote__c quote{get;set;}
        public List<QPWrapper> plannings{get;set;}
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
        public QPWrapper(LPCR_PlanningPrevisionnel__c pl ){
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
        String tt = '';
        if(tm != null){
            tt = tm.hour()+':'+tm.minute();
        }
        return tt;
    }
        public QPWrapper(SBQQ__Quote__c q, List<QPWrapper> plans){
            quote = q;
            plannings = plans;
            
        }
        
    }

    
}