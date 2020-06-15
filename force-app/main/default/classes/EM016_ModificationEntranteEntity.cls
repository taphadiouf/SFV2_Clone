/**
* @author Hanae MAKBOUB
* @date 15/05/2020
* @Description Queries about LPCR_ModificationEntrante__c
*/
public with sharing class EM016_ModificationEntranteEntity extends EM001_AbstractObjectEntity{
    
    public EM016_ModificationEntranteEntity(){
        super('LPCR_ModificationEntrante__c');
    }
    
    public static List<LPCR_ModificationEntrante__c> getModifEntranteById(List<LPCR_ModificationEntrante__c> modifId){
        return [SELECT Id, LPCR_Evenement__c,LPCR_Devis__c  FROM LPCR_ModificationEntrante__c WHERE LPCR_Evenement__c  = 'Validation Contrat Directrice' AND id =:modifId];
    }

    public static blng__Usage__c createBlngUsage(LPCR_ModificationEntrante__c modifEntrante, String UnitOfMeasure){
        String eventName = modifEntrante.LPCR_Evenement__c.toUpperCase().replaceAll(' ','_');
        blng__Usage__c newUsage = new blng__Usage__c();
        if('Abscence'.equals(modifEntrante.LPCR_Evenement__c)){
            newUsage.LPCR_TypeEvenement__c = 'Modification Absence';
        }else{
            newUsage.LPCR_TypeEvenement__c = modifEntrante.LPCR_Evenement__c;
        }
        newUsage.blng__StartDateTime__c = modifEntrante.LPCR_HeureDateDebut__c;
        newUsage.blng__EndDateTime__c = modifEntrante.LPCR_HeureDateFin__c;
        newUsage.blng__Quantity__c = modifEntrante.LPCR_Quantite__c;
        newUsage.blng__MatchingId__c = modifEntrante.LPCR_Contact__c+''+eventName+''+modifEntrante.LPCR_Compte__c;
        newUsage.blng__UnitOfMeasure__c = (UnitOfMeasure != null)?UnitOfMeasure:'';
        newUsage.LPCR_ContactEnfant__c = modifEntrante.LPCR_Contact__c;
        return newUsage;
    } 
	
}