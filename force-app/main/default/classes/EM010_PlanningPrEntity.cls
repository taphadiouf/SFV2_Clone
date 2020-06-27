/**
* @ author Hanae Makboub
* @created 19/02/2020
* @description Entity Class for Object LPCR_PlanningPrevisionnel__c
*/
public with sharing class EM010_PlanningPrEntity {
    public static List<LPCR_PlanningPrevisionnel__c> getPlanningsByQuoteId(Id idQuote) {
     /*
        return [SELECT Id,
               		   LPCR_Contrat__c,
                	   LPCR_HeureDebutLundi__c, 
                	   LPCR_HeureFinLundi__c , 
                	   LPCR_HeureDebutMardi__c, 
                       LPCR_HeureFinMardi__c, 
                       LPCR_HeureDebutMercredi__c, 
                       LPCR_HeureFinMercredi__c ,
                       LPCR_HeureDebutJeudi__c, 
                       LPCR_HeureFinJeudi__c , 
                       LPCR_HeureDebutVendredi__c, 
                	   LPCR_HeureFinVendredi__c 
                FROM LPCR_PlanningPrevisionnel__c
                Where LPCR_Contrat__c =: idQuote ];

      */
        return null;
    }
}