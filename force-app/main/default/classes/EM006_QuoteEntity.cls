/**
* @author Ayoub Ouarti
* @date 26/02/2020
* @Description Queries about SBQQ__Quote__c
*/
public with sharing class EM006_QuoteEntity extends EM001_AbstractObjectEntity{

    public EM006_QuoteEntity(){
        super('SBQQ__Quote__c');
    }
    public static List<SBQQ__Quote__c> saveOrUpdte(List<SBQQ__Quote__c> quotes){
        if(UM003_TypeManager.isNotNullAndNotEmpty(quotes) ){
            upsert quotes;
        }
     return  quotes; 
    }

    public static SBQQ__Quote__c saveOrUpdte(SBQQ__Quote__c quote){
        if(UM003_TypeManager.isNotNull(quote)){
            upsert quote;
        }
     return  quote; 
    }
	public static SBQQ__Quote__c getQuoteById(Id quoteId){
            return  [Select Id, 
                     SBQQ__StartDate__c,
                     SBQQ__EndDate__c, 
                     LPCR_ContactEnfant__r.FirstName,
                     LPCR_ContactEnfant__r.LastName,
                     LPCR_Creche__r.ShippingCity, 
                     LPCR_TypePlanning__c,
                     LPCR_RessourcesMensuelles__c,
                     (Select Id, 
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
                      FROM Plannings_Pr_visionnels__r )
                     From SBQQ__Quote__c 
                     WHERE Id=:quoteId];
            
        }
}