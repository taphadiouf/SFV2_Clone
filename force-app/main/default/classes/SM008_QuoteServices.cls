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
        Map<Id,Opportunity> opptyMap = new  Map<Id,Opportunity>([SELECT Id,LPCR_BillingFrequency__c, LPCR_TypeFacturation__c,LPCR_IndexationConvenue__c  from Opportunity WHERE Id in :opptyIds]);
        
        for (SBQQ__Quote__c eachQuote : quotesList){
            if(opptyMap.containsKey(eachQuote.SBQQ__Opportunity2__c) && 'Renewal'.equals(eachQuote.SBQQ__Type__c)){
                eachQuote.SBQQ__BillingFrequency__c=opptyMap.get(eachQuote.SBQQ__Opportunity2__c).LPCR_BillingFrequency__c;
                eachQuote.LPCR_TypeFacturation__c=opptyMap.get(eachQuote.SBQQ__Opportunity2__c).LPCR_TypeFacturation__c;
                eachQuote.LPCR_IndexationConvenue__c=opptyMap.get(eachQuote.SBQQ__Opportunity2__c).LPCR_IndexationConvenue__c;
                if('Non'.equals(eachQuote.LPCR_IndexationConvenue__c)){
                    eachQuote.SBQQ__RenewalUpliftRate__c=null;
                }
            }
        }
        
    }
    
    public static void setQuoteFieldsFromContract(List<SBQQ__Quote__c> quotesList){
        Integer quoteRenewalTerm = 12;
        Set<String> oppIds = UM003_TypeManager.getFieldsOfListObjects(quotesList,'SBQQ__Opportunity2__c');
        Map<Id,Contract> contractMap = new Map<Id,Contract>();
        for(Contract eachContract : [SELECT Id,LPCR_RenouvellementConvenu__c,LPCR_DateDebut__c,LPCR_DateFin__c,LPCR_MethodeRenouvellement__c,SBQQ__RenewalOpportunity__c FROM Contract WHERE SBQQ__RenewalOpportunity__c =: oppIds]){
            if(!contractMap.containsKey(eachContract.SBQQ__RenewalOpportunity__c)){
                contractMap.put(eachContract.SBQQ__RenewalOpportunity__c,eachContract);
            }
        }
        
        for(SBQQ__Quote__c eachQuote : quotesList){
            // Check if the quote type field equals to 'Renewal'
            if(contractMap.containsKey(eachQuote.SBQQ__Opportunity2__c) && 'Renewal'.equals(eachQuote.SBQQ__Type__c)){
                Contract contract = contractMap.get(eachQuote.SBQQ__Opportunity2__c);
                eachQuote.SBQQ__RenewalTerm__c = quoteRenewalTerm;
                if(contract.LPCR_DateDebut__c != null){
                    eachQuote.SBQQ__StartDate__c = contract.LPCR_DateDebut__c;
                    eachQuote.LPCR_DateDebut__c = eachQuote.SBQQ__StartDate__c;
                }   
                
                eachQuote.LPCR_RenouvellementConvenu__c = contract.LPCR_RenouvellementConvenu__c;
                if('Non'.equals(eachQuote.LPCR_RenouvellementConvenu__c)){
                    eachQuote.SBQQ__RenewalUpliftRate__c = 0;
                }
                eachQuote.LPCR_MethodeRenouvellement__c = contract.LPCR_MethodeRenouvellement__c;
                if('Express'.equals(contract.LPCR_MethodeRenouvellement__c) || 'Sans renouvellement'.equals(contract.LPCR_MethodeRenouvellement__c)){
                    if(contract.LPCR_DateFin__c != null && contract.LPCR_DateFin__c != null && System.Today().year() == contract.LPCR_DateFin__c.year()){
                        eachQuote.SBQQ__EndDate__c = contract.LPCR_DateFin__c;
                        eachQuote.LPCR_DateFin__c =  eachQuote.SBQQ__EndDate__c;
                    }else{
                        eachQuote.SBQQ__EndDate__c = date.newInstance(System.Today().year(), 12, 31);
                        eachQuote.LPCR_DateFin__c = eachQuote.SBQQ__EndDate__c;
                    }    
                }
                
            }
        }
        
    }
    
    public static void updatQuoteFields(List<SBQQ__Quote__c> quotesList){
        Integer quoteRenewalTerm = 12;
        for(SBQQ__Quote__c eachQuote : quotesList){
            // Check if the quote type field equals to 'Renewal'
            if('Renewal'.equals(eachQuote.SBQQ__Type__c)){
                eachQuote.SBQQ__RenewalTerm__c = quoteRenewalTerm;
                eachQuote.SBQQ__StartDate__c = eachQuote.LPCR_DateDebut__c;
                
                if('Express'.equals(eachQuote.LPCR_MethodeRenouvellement__c) || 'Sans renouvellement'.equals(eachQuote.LPCR_MethodeRenouvellement__c)){
                    if(eachQuote.LPCR_DateFin__c != null && System.Today().year() == eachQuote.LPCR_DateFin__c.year()){
                        eachQuote.SBQQ__EndDate__c = eachQuote.LPCR_DateFin__c;
                    }else{                        
                        eachQuote.SBQQ__EndDate__c = date.newInstance(System.Today().year(), 12, 31);
                    }    
                }                
            }
        }
    }
}