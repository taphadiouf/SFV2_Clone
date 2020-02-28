/**
* @author Achraf ABOUL
* @date 28/02/2020
* @description Service class for SBQQ__Quote__c
*/
public with sharing class SM008_QuoteServices {
    public static void updateOppsFromQuotes(List<SBQQ__Quote__c> quotesList){
        Set<Id> oppsIds = new Set<Id>();
        for(SBQQ__Quote__c eachQuote : quotesList){
            if(eachQuote.SBQQ__Status__c.equals('Accepted')){
                oppsIds.add(eachQuote.SBQQ__Opportunity2__c);
            }
        }
        List<Opportunity> oppsToUpdate = EM004_OpportunityEntity.getOppsByIds(oppsIds);
        for(Opportunity eachOpp : oppsToUpdate){
            eachOpp.StageName = 'Signée';
        }
        
    }
    public static void updateAccountsFromQuotes(List<SBQQ__Quote__c> quotesList){
        Set<Id> accountsIds = new Set<Id>();
        for(SBQQ__Quote__c eachQuote : quotesList){
            if(eachQuote.SBQQ__Status__c.equals('Accepted')){
                accountsIds.add(eachQuote.SBQQ__Account__c);
            }
        }
        List<Account> accountsToUpdate = EM005_AccountEntity.getAccsByIds(accountsIds);
        for(Account eachAcc : accountsToUpdate){
            eachAcc.LPCR_Statut__c = 'Client';
        }
        
    }
}