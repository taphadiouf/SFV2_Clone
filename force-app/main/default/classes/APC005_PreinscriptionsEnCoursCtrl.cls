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
                    eachPreInsc.LPCR_CompteFamille__c,
                    eachPreInsc.LPCR_Creche__r.Name, 
                    eachPreInsc.LPCR_Creche__c, 
                    eachPreInsc.LPCR_ContactParent__r.Name,
                    eachPreInsc.LPCR_ContactParent__c,
                    eachPreInsc.LPCR_EnfantNom__c,
                    eachPreInsc.LPCR_EnfantPrenom__c,
                    eachPreInsc.LPCR_ContactEnfant__c,
                    eachPreInsc.LPCR_DateEntreeCreche__c));
        }
        return JSON.serialize(preinscWrapperList);
    }
    public class WRP001_PreinscriptionWrapper{
        private String domain = URL.getSalesforceBaseUrl().getProtocol()+'://'+System.URL.getSalesforceBaseUrl().getHost().remove('-api' );
        private String recId;
        private String name;
        private String statut;
        private String compteFamille;
        private String compteFamilleId;
        private String creche;
        private String crecheId;
        private String contactParent;
        private String contactParentId;
        private String nomEnfant;
        private String prenomEnfant;
        private String contactEnfantId;
        private Date dateEntree;
        WRP001_PreinscriptionWrapper(String recId,String name, String statut,String compteFamille,String compteFamilleId, String creche,String crecheId,String contactParent,String contactParentId, String nomEnfant,String prenomEnfant,String contactEnfantId, Date dateEntree){
          this.recId = domain+'/'+recId;
          this.name = name;
          this.statut = statut;
          this.compteFamille = compteFamille;  
          this.compteFamilleId = compteFamilleId <> null ? domain+'/'+compteFamilleId :'';  
          this.creche = creche;
          this.crecheId = crecheId <> null ? domain+'/'+crecheId :'';   
          this.contactParent = contactParent;
          this.contactParentId = contactParentId <> null ? domain+'/'+contactParentId :'';   
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
          this.contactEnfantId = contactEnfantId <> null ? domain+'/'+contactEnfantId :'';   
          this.dateEntree = dateEntree;
        }
    }
}