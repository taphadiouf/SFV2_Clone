/**
* @author Achraf ABOUL
* @date 12/03/2020
* @Description PreinscriptionsEnCours component controller
*/
public with sharing class APC005_PreinscriptionsEnCoursController {
    public APC005_PreinscriptionsEnCoursController() {

    }
    @AuraEnabled(cacheable=true)
    public static String getPreInscriptionsByAcc(Id accId){
        system.debug('Hello from backend');
        System.debug('accId : ' + accId);
        List<WRP001_PreinscriptionWrapper> preinscWrapperList = new List<WRP001_PreinscriptionWrapper>();
        for(LPCR_Preinscription__c eachPreInsc :  EM007_PreinscriptionEntity.getPreinscriptionsByAccId(accId)){
                preinscWrapperList.add(new WRP001_PreinscriptionWrapper(
                    eachPreInsc.Id,
                    eachPreInsc.LPCR_Statut__c, 
                    eachPreInsc.LPCR_Creche__r.Name, 
                    eachPreInsc.NomEnfant__c + ' ' + eachPreInsc.LPCR_PrenomEnfant__c,
                    eachPreInsc.LPCR_DateEntreeCreche__c));
        }
        return JSON.serialize(preinscWrapperList);
    }
    public class WRP001_PreinscriptionWrapper{
        private String recId;
        private String statut;
        private String creche;
        private String nomEnfant;
        private Date dateEntree;
        WRP001_PreinscriptionWrapper(String recId, String statut, String creche, String nomEnfant, Date dateEntree){
          this.recId = recId;
          this.statut = statut;
          this.creche = creche;
          this.nomEnfant = nomEnfant;
          this.dateEntree = dateEntree;
        }
    }
}
