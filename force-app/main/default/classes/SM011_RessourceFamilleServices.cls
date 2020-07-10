/**
* @author Ayoub Ouarti
* @created 25/03/2020
* @description Service class for RessourceFamille Object
*/
public with sharing class SM011_RessourceFamilleServices implements Queueable{
    List<LPCR_RessourceFamille__c> listRessourceFamille;
    Map<Id,LPCR_RessourceFamille__c> newMapRessourceFamille;
    Map<Id,LPCR_RessourceFamille__c> oldMapRessourceFamille;
    public SM011_RessourceFamilleServices(List<LPCR_RessourceFamille__c> listRessourceFamille ) {
        this.listRessourceFamille = listRessourceFamille;
    }
    public SM011_RessourceFamilleServices( Map<Id,LPCR_RessourceFamille__c> newMapRessourceFamille,Map<Id,LPCR_RessourceFamille__c> oldMapRessourceFamille ) {
        this.newMapRessourceFamille = newMapRessourceFamille;
        this.oldMapRessourceFamille = oldMapRessourceFamille;
        
    }
    public void execute(QueueableContext context) {
        SM011_RessourceFamilleServices.updateTheBaremeCaf(this.listRessourceFamille,this.oldMapRessourceFamille,this.newMapRessourceFamille);
    }
    
    /*
	*	@description : this method set for the RessourceFamille the appropriate BaremCaf 
	*	@param List<LPCR_RessourceFamille__c> listRessFamiToAdjustBaremCaf, Map<Id,LPCR_RessourceFamille__c> newMapRessourceFamille,Map<Id,LPCR_RessourceFamille__c> oldMapRessourceFamille
    *	@returns void
    */
    public static void updateTheBaremeCaf(List<LPCR_RessourceFamille__c> listRessFamiToAdjustBaremCaf, Map<Id,LPCR_RessourceFamille__c> newMapRessourceFamille,Map<Id,LPCR_RessourceFamille__c> oldMapRessourceFamille){
        PAD.log('SM011_RessourceFamilleServices', 'updateTheBaremeCaf','Without checking the params');
        
        Set<Integer> ressFamilleStartDateYears = new Set<Integer>();
        Date maxRessFamilleDateFin = null;
        Decimal minNbrEnfant = null;
        
        Map<Id,LPCR_RessourceFamille__c> mapRessFamiToAdjustBaremCafClone= new Map<Id,LPCR_RessourceFamille__c>();
        
        if( UM003_TypeManager.isNullOrEmpty(listRessFamiToAdjustBaremCaf)){
            listRessFamiToAdjustBaremCaf = new List<LPCR_RessourceFamille__c>();
            for(LPCR_RessourceFamille__c eachRessourceFamille : newMapRessourceFamille.values()){
                if(eachRessourceFamille.LPCR_DateFin__c == null 
                   &&(oldMapRessourceFamille.get(eachRessourceFamille.Id).LPCR_NombreEnfants__c != eachRessourceFamille.LPCR_NombreEnfants__c ||
                      oldMapRessourceFamille.get(eachRessourceFamille.Id).LPCR_NombreEnfantHandicape__c != eachRessourceFamille.LPCR_NombreEnfantHandicape__c   )){
                          listRessFamiToAdjustBaremCaf.add(eachRessourceFamille);
                      }
            }
        }
        //Gather the start Dates for each RessourceFamille & the minimal number of Enfants
        if( UM003_TypeManager.isNotNullAndNotEmpty(listRessFamiToAdjustBaremCaf)){
            for(LPCR_RessourceFamille__c eachRessourceFamille : listRessFamiToAdjustBaremCaf){
                ressFamilleStartDateYears.add(eachRessourceFamille.LPCR_DateDebut__c.Year());
                if(minNbrEnfant==null || minNbrEnfant>eachRessourceFamille.LPCR_NombreEnfants__c){
                    minNbrEnfant=eachRessourceFamille.LPCR_NombreEnfants__c;
                }
            }
            
            //Search listBaremeCaf By Date & By Higher Or Equal Number Enfants 
            List<LPCR_BaremeCaf__c> listBaremeCaf = EM014_BaremeCafEntity.getByDateByNbrEnfHigherOrEqual(ressFamilleStartDateYears,minNbrEnfant);
            
            //Map each ressource familly with the appropriate list of BaremeCaf (Same Year(LPCR_DateDebut__c) and LPCR_NombreEnfants__c<= eachBaremeCaf.LPCR_NombresEnfants__c)
            Map<Id,List<LPCR_BaremeCaf__c>> mapRessFamiWithListBaremeCaf = new Map<Id,List<LPCR_BaremeCaf__c>>();
            if( UM003_TypeManager.isNotNullAndNotEmpty(listBaremeCaf)){
                for(LPCR_RessourceFamille__c eachRessourceFamille : listRessFamiToAdjustBaremCaf){
                    for(LPCR_BaremeCaf__c eachBaremeCaf : listBaremeCaf){
                        if(eachRessourceFamille.LPCR_DateDebut__c.Year() ==eachBaremeCaf.LPCR_DateDebut__c.Year() 
                           && eachRessourceFamille.LPCR_NombreEnfants__c<= eachBaremeCaf.LPCR_NombresEnfants__c){
                               if(!mapRessFamiWithListBaremeCaf.containsKey(eachRessourceFamille.Id)){
                                   mapRessFamiWithListBaremeCaf.put(eachRessourceFamille.Id,new List<LPCR_BaremeCaf__c>());
                               }
                               mapRessFamiWithListBaremeCaf.get(eachRessourceFamille.Id).add(eachBaremeCaf);
                           }
                    }
                }
                
                LPCR_RessourceFamille__c eachRessourceFamilleClone = new LPCR_RessourceFamille__c();
                LPCR_BaremeCaf__c lastBaremeCaf = null;
                Integer level=0;
                Decimal previousTauxEffortParEnfant =0;
                
                for(LPCR_RessourceFamille__c eachRessourceFamille : listRessFamiToAdjustBaremCaf){  
                    eachRessourceFamilleClone = new LPCR_RessourceFamille__c();
                    eachRessourceFamilleClone.Id = eachRessourceFamille.Id;
                    level =0;
                    previousTauxEffortParEnfant=0;
                    
                    //Set for each ressource familly  the appropriate BaremeCaf 
                    for(LPCR_BaremeCaf__c eachBaremeCaf : mapRessFamiWithListBaremeCaf.get(eachRessourceFamille.Id)){
                        if(eachRessourceFamille.LPCR_NombreEnfants__c ==eachBaremeCaf.LPCR_NombresEnfants__c){
                            eachRessourceFamilleClone.LPCR_BaremeCaf__c = eachBaremeCaf.Id;
                            eachRessourceFamilleClone.LPCR_TauxEffort__c  = eachBaremeCaf.LPCR_TauxEffortParEnfant__c ; 
                            previousTauxEffortParEnfant =eachBaremeCaf.LPCR_TauxEffortParEnfant__c;
                            mapRessFamiToAdjustBaremCafClone.put(eachRessourceFamilleClone.Id,eachRessourceFamilleClone);
                        }else if( eachRessourceFamille.LPCR_NombreEnfantHandicape__c>0 
                                 && level<eachRessourceFamille.LPCR_NombreEnfantHandicape__c 
                                 && previousTauxEffortParEnfant != eachBaremeCaf.LPCR_TauxEffortParEnfant__c){
                                     previousTauxEffortParEnfant =eachBaremeCaf.LPCR_TauxEffortParEnfant__c;
                                     eachRessourceFamilleClone.LPCR_BaremeCaf__c = eachBaremeCaf.Id; 
                                     eachRessourceFamilleClone.LPCR_TauxEffort__c  = eachBaremeCaf.LPCR_TauxEffortParEnfant__c ; 
                                     mapRessFamiToAdjustBaremCafClone.put(eachRessourceFamilleClone.Id,eachRessourceFamilleClone);
                                     level++;
                                 }
                        if(lastBaremeCaf==null || eachBaremeCaf.LPCR_NombresEnfants__c > lastBaremeCaf.LPCR_NombresEnfants__c){
                            lastBaremeCaf=eachBaremeCaf;
                        }
                    }
                    if(eachRessourceFamilleClone.LPCR_BaremeCaf__c == null){
                        eachRessourceFamilleClone.LPCR_BaremeCaf__c = lastBaremeCaf.Id;
                        mapRessFamiToAdjustBaremCafClone.put(eachRessourceFamilleClone.Id,eachRessourceFamilleClone);
                        
                    }                    
                }   
            }   
        }
        
        update mapRessFamiToAdjustBaremCafClone.values();
        
        
        
    }
}