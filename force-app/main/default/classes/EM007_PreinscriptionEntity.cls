<<<<<<< HEAD
/**
* @author Achraf ABOUL
* @date 10/03/2020
* @Description Entity class for Preinscription
*/
public class EM007_PreinscriptionEntity {

=======
public with sharing class EM007_PreinscriptionEntity {
    @AuraEnabled
    public static List<LPCR_Preinscription__c> getListofPreinscription() {
        return [SELECT Id, LPCR_Statut__c FROM LPCR_Preinscription__c];

    }
>>>>>>> 544cb76de2c72e9581cf12b067d643f627722c46
}