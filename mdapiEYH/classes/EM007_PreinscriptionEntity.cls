/**
* @author Achraf ABOUL
* @date 10/03/2020
* @Description Entity class for Preinscription
*/
public with sharing class EM007_PreinscriptionEntity {
    @AuraEnabled
    public static List<LPCR_Preinscription__c> getListofPreinscriptionById(List<Id> preinscriptionIds) {
        return [SELECT Id, LPCR_Statut__c FROM LPCR_Preinscription__c WHERE Id IN :preinscriptionIds];
    }
    @AuraEnabled
    public static List<LPCR_Preinscription__c> getPreinscriptionsByAccId(Id accId) {
        return [SELECT Id, LPCR_Statut__c, LPCR_Creche__r.Name, NomEnfant__c, LPCR_PrenomEnfant__c, LPCR_DateEntreeCreche__c FROM LPCR_Preinscription__c WHERE LPCR_CompteEntreprise__c = :accId];
    }
}