/**
* @ author Hanae Makboub
* @created 18/02/2020
* @description controller to display tables of plannings for each quote in a VFP001_GenererDocAnn2 VF page
*/

public with sharing class VFC001_GenererDocAnn2 {
    public Annex2Wrapper annex{get;set;}
    //SBQQ__Quote__c currentRecord;
    public VFC001_GenererDocAnn2() {
        //currentRecord = new SBQQ__Quote__c(id=Apexpages.currentPage().getParameters().get('recordId'));
        annex = new Annex2Wrapper(Apexpages.currentPage().getParameters().get('recordId'));
    }
    
    
    
    public class Annex2Wrapper{
        public List<planningPrevisionnelWrapper> planningPrevisionnels{get;set;}
        public SBQQ__Quote__c quote{get;set;}
        public Double LPCR_AverageTime{get;set;}
        public SBQQ__Quote__c getQuoteById(Id quoteId){
            return  [Select Id, 
                     SBQQ__StartDate__c,
                     SBQQ__EndDate__c, 
                     LPCR_ContactEnfant__r.Name,
                     LPCR_Creche__r.ShippingCity, 
                     LPCR_RessourcesMensuelles__c,
                     (Select Id, 
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
                      FROM Plannings_Pr_visionnels__r )
                     From SBQQ__Quote__c 
                     WHERE Id=:quoteId];
            
        }
        public List<planningPrevisionnelWrapper> getPlannings(){
            //List<LPCR_PlanningPrevisionnel__c> plannings= EM010_PlanningPrEntity.getPlanningsByQuoteId(currentRecord.id);
            List<planningPrevisionnelWrapper> wrapperPlannings = new List<planningPrevisionnelWrapper>();
            for(LPCR_PlanningPrevisionnel__c pl : this.quote.Plannings_Pr_visionnels__r ){
                wrapperPlannings.add(new planningPrevisionnelWrapper(pl));
            }
            return wrapperPlannings;
        }
        public Annex2Wrapper(Id quoteId){
            this.quote=getQuoteById(quoteId);
            this.planningPrevisionnels = getPlannings();
            getTimeAverage();
        }
        public void getTimeAverage(){
            Double averag = 0;
            Integer sumavg = 0;
            List<Integer> plAverage = new List<Integer>();
            for(LPCR_PlanningPrevisionnel__c p: this.quote.Plannings_Pr_visionnels__r){
                try{
                     Integer avg = (((p.LPCR_HeureFinLundi__c.hour() - p.LPCR_HeureDebutLundi__c.hour())+ (p.LPCR_HeureFinLundi__c.minute()-p.LPCR_HeureDebutLundi__c.minute()))+
                          			((p.LPCR_HeureFinMardi__c.hour() - p.LPCR_HeureDebutMardi__c.hour())+ (p.LPCR_HeureFinMardi__c.minute()-p.LPCR_HeureDebutMardi__c.minute()))+
                                  	((p.LPCR_HeureFinMercredi__c.hour() - p.LPCR_HeureDebutMercredi__c.hour())+ (p.LPCR_HeureFinMercredi__c.minute()-p.LPCR_HeureDebutMercredi__c.minute()))+
                                    ((p.LPCR_HeureFinJeudi__c.hour() - p.LPCR_HeureDebutJeudi__c.hour())+ (p.LPCR_HeureFinJeudi__c.minute()-p.LPCR_HeureDebutJeudi__c.minute()))+
                                    ((p.LPCR_HeureFinVendredi__c.hour() - p.LPCR_HeureDebutVendredi__c.hour())+ (p.LPCR_HeureFinVendredi__c.minute()-p.LPCR_HeureDebutVendredi__c.minute()))); 
               plAverage.add(avg);
                }
                catch(Exception e){
                    system.debug('error'+e);
                }
              
            }
           
            system.debug('tttt'+plAverage);
            if(plAverage != null){
                for(Integer a:plAverage){
                    sumavg += a ;
                }
                system.debug('hanae'+sumavg);
                averag = sumavg/plAverage.size();
                system.debug('ha'+averag);
            }
           this.LPCR_AverageTime = averag;
        }
    }
    public class planningPrevisionnelWrapper{
        
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
            String tt = '';
            if(tm != null){
                tt = tm.hour()+':'+tm.minute();
            }
            return tt;
        }
        
    }
    
    
}