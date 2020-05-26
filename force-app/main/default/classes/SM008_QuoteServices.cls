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
    //added by hanae
    

    public static void loadAgreement(Map<Id,Set<Id>> mapQuoteAgreement) {
        try {
            for (Id key: mapQuoteAgreement.KeySet()){
                if(mapQuoteAgreement.get(key).size()>0){
                    for(Id eachQuoteId: mapQuoteAgreement.get(key)){
                        Id tmpIdAggree = echosign_dev1.AgreementTemplateService.load( key , eachQuoteId);
                        echosign_dev1.EchoSignApiService.SendDocumentResult tmp = echosign_dev1.EchoSignApiService.sendDocument(tmpIdAggree);
                    }   
                }
            }
        } catch (Exception E) { 
            System.debug('Exception: ' + e.getStackTraceString());
        }  
    }
    
    
    
    public static Map<Id,Set<Id>> generateAgreementTemp(Map<Id,SBQQ__Quote__c> newQuoteMap,Map<Id,SBQQ__Quote__c> oldQuoteMap ){
        ID agreementMac = LPCR_TemplateSignatureElectronique__c.getInstance().LPCR_IDTemplateContratAccueilMAC__c; 
        ID agreementMicro = LPCR_TemplateSignatureElectronique__c.getInstance().LPCR_IDTemplateContratAccueilMICRO__c; 
        Map<Id,Set<Id>> mapQuoteIDAgreementID = new Map<Id,Set<Id>>();
        mapQuoteIDAgreementID.put(agreementMac , new Set<Id>() );
        mapQuoteIDAgreementID.put(agreementMicro , new Set<Id>() );
        List<SBQQ__Quote__c> quoteMap = [Select Id,SBQQ__Status__c,LPCR_Creche__c, LPCR_Creche__r.LPCR_TypeCreche__c From SBQQ__Quote__c Where Id=: newQuoteMap.KeySet()];
        for(SBQQ__Quote__c eachNewQuote : quoteMap){
            if(eachNewQuote.SBQQ__Status__c != oldQuoteMap.get(eachNewQuote.Id).SBQQ__Status__c && eachNewQuote.SBQQ__Status__c == Label.LPCR_ValideDirectrice ){
                if(Label.LPCR_MAC.equals(eachNewQuote.LPCR_Creche__r.LPCR_TypeCreche__c)){
                    mapQuoteIDAgreementID.get(agreementMac).add(eachNewQuote.Id);
                }
                if(Label.LPCR_MICRO.equals(eachNewQuote.LPCR_Creche__r.LPCR_TypeCreche__c)){
                    mapQuoteIDAgreementID.get(agreementMicro).add(eachNewQuote.Id);
                }
            }
        }
        SM008_QuoteServices.loadAgreement(mapQuoteIDAgreementID);
        return mapQuoteIDAgreementID;
    } 
}