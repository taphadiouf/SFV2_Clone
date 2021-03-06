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
                     LPCR_TauxEffort__c,
                     LPCR_TauxHoraire__c,
                     LPCR_TauxMensuel__c ,
                     LPCR_RevenusFamille__c,
                     LPCR_CongesJours__c,
                     LPCR_NombreHeuresMois__c
                     From SBQQ__Quote__c 
                     WHERE Id=:quoteId];
            
        }
    
    public static List<SBQQ__Quote__c> getQuoteModifById (Set<Id> quoteId){
        return [SELECT Id, SBQQ__Status__c  FROM SBQQ__Quote__c WHERE Id =: quoteId];
    }
}