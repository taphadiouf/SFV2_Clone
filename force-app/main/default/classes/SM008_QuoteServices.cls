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
        update oppsToUpdate;
        
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
        update accountsToUpdate;
    }
    
    //added by Ayoub
     public static void setQuoteFields(List<SBQQ__Quote__c> quotesList){
        Set<String> opptyIds = UM003_TypeManager.getFieldsOfListObjects(quotesList,'SBQQ__Opportunity2__c');
        Map<Id,Opportunity> opptyMap = new  Map<Id,Opportunity>([SELECT Id,LPCR_BillingFrequency__c, LPCR_TypeFacturation__c,LPCR_RenouvellementConvenu__c  from Opportunity WHERE Id in :opptyIds]);
        
        for (SBQQ__Quote__c eachQuote : quotesList){
            if(opptyMap.containsKey(eachQuote.SBQQ__Opportunity2__c)){
                eachQuote.SBQQ__BillingFrequency__c=opptyMap.get(eachQuote.SBQQ__Opportunity2__c).LPCR_BillingFrequency__c;
                eachQuote.LPCR_TypeFacturation__c=opptyMap.get(eachQuote.SBQQ__Opportunity2__c).LPCR_TypeFacturation__c;
                eachQuote.LPCR_RenouvellementConvenu__c=opptyMap.get(eachQuote.SBQQ__Opportunity2__c).LPCR_RenouvellementConvenu__c;
                if('Non'.equals(eachQuote.LPCR_RenouvellementConvenu__c)){
                   eachQuote.SBQQ__RenewalUpliftRate__c=null;
                }
            }
        }
       
    }
}