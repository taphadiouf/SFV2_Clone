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
        return [SELECT Id, LPCR_Statut__c,Name,LPCR_CompteFamille__r.Name,LPCR_CompteFamille__c,LPCR_ContactParent__r.Name,LPCR_ContactParent__c, LPCR_Creche__r.Name,LPCR_Creche__c, LPCR_EnfantNom__c, LPCR_EnfantPrenom__c,LPCR_ContactEnfant__c, LPCR_DateEntreeCreche__c FROM LPCR_Preinscription__c WHERE LPCR_CompteEntreprise__c = :accId];
    }
}