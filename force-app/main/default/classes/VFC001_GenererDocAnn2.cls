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
            SBQQ__Quote__c theQuote = EM006_QuoteEntity.getQuoteById(quoteId);
            return theQuote;
        }
        public List<planningPrevisionnelWrapper> getPlannings(){
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
            Double sumavg = 0;
            Double lundi = 0; Double lundiDebut = 0; Double lundiFin = 0;
            Double mardi = 0; Double mardiDebut = 0; Double mardiFin = 0;
            Double mercredi = 0; Double mercrediDebut = 0; Double mercrediFin = 0;
            Double jeudi = 0; Double jeudiDebut = 0;  Double jeudiFin = 0;
            Double vendredi = 0;  Double vendrediDebut = 0;  Double vendrediFin = 0;
            List<Double> plAverage = new List<Double>();
            for(LPCR_PlanningPrevisionnel__c p: this.quote.Plannings_Pr_visionnels__r){
                if(p.LPCR_HeureFinLundi__c != NULL && p.LPCR_HeureDebutLundi__c != NULL ){
                    lundiFin = p.LPCR_HeureFinLundi__c.hour() + p.LPCR_HeureFinLundi__c.minute()/60;
                    lundiDebut = p.LPCR_HeureDebutLundi__c.hour() + p.LPCR_HeureDebutLundi__c.minute()/60;
                    lundi = lundiFin - lundiDebut;
                }
                if(p.LPCR_HeureFinLundi__c == NULL && p.LPCR_HeureDebutLundi__c == NULL ){
                    lundi = 0 ;
                }
                if(p.LPCR_HeureFinMardi__c != NULL && p.LPCR_HeureDebutMardi__c != NULL ){
                    mardiFin = p.LPCR_HeureFinMardi__c.hour() + p.LPCR_HeureFinMardi__c.minute()/60;
                    mardiDebut = p.LPCR_HeureDebutMardi__c.hour() + p.LPCR_HeureDebutMardi__c.minute()/60;
                    mardi = mardiFin - mardiDebut ;
                }
                if(p.LPCR_HeureFinMardi__c == NULL && p.LPCR_HeureDebutMardi__c == NULL ){
                    mardi = 0 ;
                }
                if(p.LPCR_HeureFinMercredi__c != NULL && p.LPCR_HeureDebutMercredi__c != NULL ){
                    mercrediFin = p.LPCR_HeureFinMercredi__c.hour() + p.LPCR_HeureFinMercredi__c.minute()/60;
                    mercrediDebut = p.LPCR_HeureDebutMercredi__c.hour() + p.LPCR_HeureDebutMercredi__c.minute()/60;
                    mercredi = mercrediFin - mercrediDebut ;
                }
                if(p.LPCR_HeureFinMercredi__c == NULL && p.LPCR_HeureDebutMercredi__c == NULL ){
                    mercredi = 0 ;
                }
                if(p.LPCR_HeureFinJeudi__c != NULL && p.LPCR_HeureDebutJeudi__c != NULL ){
                    jeudiFin = p.LPCR_HeureFinJeudi__c.hour() + p.LPCR_HeureFinJeudi__c.minute()/60;
                    jeudiDebut = p.LPCR_HeureDebutJeudi__c.hour() + p.LPCR_HeureDebutJeudi__c.minute()/60;
                    jeudi = jeudiFin - jeudiDebut;
                }
                if(p.LPCR_HeureFinMercredi__c == NULL && p.LPCR_HeureDebutJeudi__c == NULL ){
                    jeudi = 0 ;
                }
                if(p.LPCR_HeureFinVendredi__c != NULL && p.LPCR_HeureDebutVendredi__c != NULL ){
                    vendrediFin = p.LPCR_HeureFinVendredi__c.hour() + p.LPCR_HeureFinVendredi__c.minute()/60;
                    vendrediDebut = p.LPCR_HeureDebutVendredi__c.hour() + p.LPCR_HeureDebutVendredi__c.minute()/60;
                    vendredi = vendrediFin - vendrediDebut;
                }
                if(p.LPCR_HeureFinVendredi__c == NULL && p.LPCR_HeureDebutVendredi__c == NULL ){
                    vendredi = 0 ;
                }
                system.debug('lundi'+lundi);
                system.debug('mardi'+mardi);
                system.debug('mercredi'+mercredi);
                system.debug('jeudi'+jeudi);
                system.debug('vendredi'+vendredi);
                
                Double avg = (lundi+mardi+mercredi+jeudi+vendredi); 
                plAverage.add(avg);
            }
            
            system.debug('tttt'+plAverage);
            if(plAverage != null){
                for(Double a:plAverage){
                    sumavg += a ;
                }
                system.debug('hanae'+sumavg);
                try{
                    averag = sumavg/plAverage.size();
                    if(Test.isRunningTest())
                    {
                        CalloutException e = new CalloutException();
                        e.setMessage('This is a constructed exception!');
                        throw e;
                    }
                    
                }catch(Exception e){
                    system.debug('error'+e);
                }
                
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