/**
* @author Ayoub Ouarti
* @date 26/02/2020
* @Description Queries about SBQQ__Quote__c
*/
public with sharing class EM006_QuoteEntity {

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
    
    public static List<SBQQ__Quote__c> getNewQuotes(Map<Id, SBQQ__Quote__c> newQuotesMap){
        return [SELECT Id,SBQQ__Account__c  FROM SBQQ__Quote__c WHERE Id =: newQuotesMap.KeySet()];
    }

}