/**
* @author Achraf ABOUL
* @date 12/03/2020
* @Description PreinscriptionsEnCours component controller
*/
public with sharing class APC005_PreinscriptionsEnCoursCtrl {
    @AuraEnabled(cacheable=true)
    public static String getPreInscriptionsByAcc(Id accId){
        List<WRP001_PreinscriptionWrapper> preinscWrapperList = new List<WRP001_PreinscriptionWrapper>();
        for(LPCR_Preinscription__c eachPreInsc :  EM007_PreinscriptionEntity.getPreinscriptionsByAccId(accId)){
                preinscWrapperList.add(new WRP001_PreinscriptionWrapper(
                    eachPreInsc.Id,
                    eachPreInsc.Name,
                    eachPreInsc.LPCR_Statut__c,
                    eachPreInsc.LPCR_CompteFamille__r.Name,
                    eachPreInsc.LPCR_Creche__r.Name, 
                    eachPreInsc.LPCR_ContactParent__r.Name,
                    eachPreInsc.LPCR_EnfantNom__c,
                    eachPreInsc.LPCR_EnfantPrenom__c,
                    eachPreInsc.LPCR_DateEntreeCreche__c));
        }
        return JSON.serialize(preinscWrapperList);
    }
    public class WRP001_PreinscriptionWrapper{
        private String recId;
        private String name;
        private String statut;
        private String compteFamille;
        private String creche;
        private String contactParent;
        private String nomEnfant;
        private String prenomEnfant;
        private Date dateEntree;
        WRP001_PreinscriptionWrapper(String recId,String name, String statut,String compteFamille, String creche,String contactParent, String nomEnfant,String prenomEnfant, Date dateEntree){
          this.recId = recId;
          this.name = name;
          this.statut = statut;
          this.compteFamille = compteFamille;  
          this.creche = creche;
          this.contactParent = contactParent;
          if(nomEnfant != null && prenomEnfant != null  ){
              this.nomEnfant = nomEnfant+ ' ' + prenomEnfant;
          }
          if(nomEnfant == null && prenomEnfant != null ){
              this.nomEnfant = prenomEnfant;
          }
          if(nomEnfant != null && prenomEnfant == null ){
              this.nomEnfant = nomEnfant;
          }
          if(nomEnfant == null && prenomEnfant == null){
              this.nomEnfant = ' ' ;
          }
          this.dateEntree = dateEntree;
        }
    }
}