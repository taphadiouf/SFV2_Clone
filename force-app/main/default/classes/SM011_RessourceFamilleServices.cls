/**
* @author Ayoub Ouarti
* @created 25/03/2020
* @description Service class for RessourceFamille Object
*/
public with sharing class SM011_RessourceFamilleServices {
  
  public static void createNewRessourceFamilleRecord(Map<Id,LPCR_RessourceFamille__c> newMapRessourceFamille,Map<Id,LPCR_RessourceFamille__c> oldMapRessourceFamille){
       List<LPCR_RessourceFamille__c> listRessourceFamilleToInsert = new List<LPCR_RessourceFamille__c> ();
       Date lastDayOfCurrentMonthDate=Date.newInstance(Date.today().Year(), Date.today().month() , Date.daysInMonth(Date.today().year(), Date.today().month())) ;
       Date firstDayOfNextMonthDate=Date.newInstance(Date.today().Year(), Date.today().month()+1 ,1) ;

        for(LPCR_RessourceFamille__c eachRessourceFamille : newMapRessourceFamille.values()){
            if(oldMapRessourceFamille.get(eachRessourceFamille.Id).LPCR_TauxMensuel__c != eachRessourceFamille.LPCR_TauxMensuel__c ){
                eachRessourceFamille.LPCR_DateFin__c=lastDayOfCurrentMonthDate;    
                listRessourceFamilleToInsert.add(new LPCR_RessourceFamille__c(
                                                LPCR_TauxMensuel__c=eachRessourceFamille.LPCR_TauxMensuel__c,
                                                LPCR_DateDebut__c=firstDayOfNextMonthDate,
                                                LPCR_CompteFamille__c=eachRessourceFamille.LPCR_CompteFamille__c,
                                                LPCR_Produit__c=eachRessourceFamille.LPCR_Produit__c,
                                                RecordTypeId=eachRessourceFamille.RecordTypeId,
                                                Name=eachRessourceFamille.Name));     
            }
        }

        EM012_RessourceFamilleEntity.saveOrUpdte(listRessourceFamilleToInsert);
    }
}
