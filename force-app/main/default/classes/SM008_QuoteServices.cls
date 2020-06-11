/**
* @author Achraf ABOUL
* @date 28/02/2020
* @description Service class for SBQQ__Quote__c
* @edited by hanae
*/
public with sharing class SM008_QuoteServices {
    
    
    //added by hanae
    public static void updateQuotes(List<SBQQ__Quote__c> quotesList){
        Id acceuilRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote,Label.LPCR_ContratA);
        Id referencementRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote,Label.LPCR_Referencement);
        Id reservataireRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote,Label.LPCR_Reservataire);
        List<SBQQ__Quote__c> renewalOppList = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> cummonQuoteList = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> B2CQuoteList = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> B2BQuoteList = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> B2BInsertQuoteList = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> B2CInsertQuoteList = new List<SBQQ__Quote__c>();
        Set<String> opptyIds = UM003_TypeManager.getFieldsOfListObjects(quotesList,Label.LPCR_Opportunity2);
        Set<String> acctIds = UM003_TypeManager.getFieldsOfListObjects(quotesList,Label.LPCR_CrecheF);
        Map<ID,Account> acctMap = new Map<ID,Account>([SELECT Id, LPCR_TypeCreche__c, LPCR_EntiteJuridique__c, LPCR_TypeFacturation__c  FROM Account WHERE Id in:acctIds]);
        Map<Id,Opportunity> opptyMap = new  Map<Id,Opportunity>([SELECT Id,LPCR_BillingFrequency__c, LPCR_TypeFacturation__c,LPCR_IndexationConvenue__c, SBQQ__RenewedContract__c, SBQQ__AmendedContract__c  from Opportunity WHERE Id in :opptyIds]);
        Set<String> renewedContractIds = UM003_TypeManager.getFieldsOfListObjects(opptyMap.Values(),Label.LPCR_RenewedContract);
        Set<String> amendedContractIds = UM003_TypeManager.getFieldsOfListObjects(opptyMap.Values(),Label.LPCR_AmendedContract);
        Map<Id,Contract> contractMap = new Map<Id,Contract>([SELECT Id, LPCR_DateDebut__c, LPCR_DateFin__c, LPCR_ChiffreAffaire__c ,LPCR_MethodeRenouvellement__c ,LPCR_RenouvellementConvenu__c   From Contract Where Id =: renewedContractIds]);
        Map<Id,Contract> amendedContractMap = new Map<Id,Contract>([SELECT Id, LPCR_DateDebut__c, LPCR_DateFin__c, LPCR_ChiffreAffaire__c ,LPCR_MethodeRenouvellement__c ,LPCR_RenouvellementConvenu__c,SBQQ__RenewalUpliftRate__c   From Contract Where Id =: amendedContractIds]);
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                for (SBQQ__Quote__c eachQuote : quotesList){
                    renewalOppList.add(eachQuote);
                    if(eachQuote.RecordTypeId == referencementRecTypeId || eachQuote.RecordTypeId == reservataireRecTypeId){
                        B2BInsertQuoteList.add(eachQuote);
                    }
                    if(eachQuote.RecordTypeId == acceuilRecTypeId){
                        B2CInsertQuoteList.add(eachQuote);
                    }
                }
            }
            if(Trigger.isInsert || Trigger.isUpdate){
                for(SBQQ__Quote__c eachQuote : quotesList){
                    if(eachQuote.RecordTypeId == acceuilRecTypeId || eachQuote.RecordTypeId == referencementRecTypeId || eachQuote.RecordTypeId == reservataireRecTypeId){
                        cummonQuoteList.add(eachQuote);
                    }
                    if(eachQuote.RecordTypeId == acceuilRecTypeId){
                        B2CQuoteList.add(eachQuote);
                    }
                    if(eachQuote.RecordTypeId == referencementRecTypeId || eachQuote.RecordTypeId == reservataireRecTypeId){
                        B2BQuoteList.add(eachQuote);
                    }
                }
            }
            SM008_QuoteServices.setQuoteFields(renewalOppList);
            SM008_QuoteServices.setB2CbeforInsertBQuotes(B2CInsertQuoteList,acctMap);
            SM008_QuoteServices.setB2BandB2CQuotesFromContract(cummonQuoteList, acctMap,  opptyMap, contractMap, amendedContractMap);
            SM008_QuoteServices.setB2CQuotesFromContract(B2CQuoteList,  acctMap, opptyMap, amendedContractMap, contractMap);
            SM008_QuoteServices.setB2BQuotesFromContract(B2BQuoteList, acctMap, opptyMap, contractMap);
            SM008_QuoteServices.setB2BbeforInsertBQuotesFromContract(B2BInsertQuoteList, acctMap, opptyMap, contractMap);
        }
    }
    
    
    
    
    
    
    
    public static void setB2BandB2CQuotesFromContract(List<SBQQ__Quote__c> quotesList,  Map<ID,Account> acctMap, Map<Id,Opportunity> opptyMap,  Map<Id,Contract> contractMap, Map<Id,Contract> amendedContractMap){
        for (SBQQ__Quote__c eachQuote : quotesList){
            if(Label.LPCR_Renewal.equals(eachQuote.SBQQ__Type__c)){
                if(opptyMap.containsKey(eachQuote.SBQQ__Opportunity2__c)){
                    if(contractMap.containsKey(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c)){
                        eachQuote.LPCR_DateDebut__c = contractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_DateDebut__c;
                        eachQuote.LPCR_DateFin__c = contractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_DateFin__c ;
                        eachQuote.LPCR_ChiffreAffaire__c = contractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_ChiffreAffaire__c  ;
                    }
                }
            }
            if(Label.LPCR_QuoteT.equals(eachQuote.SBQQ__Type__c)){
                if(eachQuote.LPCR_DateDebut__c != Null){
                    eachQuote.SBQQ__StartDate__c = eachQuote.LPCR_DateDebut__c ;
                }
            }
            if(Label.LPCR_Amendment.equals(eachQuote.SBQQ__Type__c)){
                if(opptyMap.containsKey(eachQuote.SBQQ__Opportunity2__c)){
                    if(amendedContractMap.containsKey(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c)){
                        eachQuote.LPCR_DateDebut__c = amendedContractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).LPCR_DateDebut__c;
                        eachQuote.LPCR_DateFin__c = amendedContractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).LPCR_DateFin__c ;
                        eachQuote.LPCR_ChiffreAffaire__c = amendedContractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).LPCR_ChiffreAffaire__c  ;
                    }
                }
            }
        }
    }
    
    public static void setB2CQuotesFromContract(List<SBQQ__Quote__c> quotesList,  Map<ID,Account> acctMap, Map<Id,Opportunity> opptyMap,  Map<Id,Contract> amendedContractMap,Map<Id,Contract> contractMap){
        Date dueDateRenewal = date.newInstance(System.Today().year(), 08, 31);
        Date dueDateQuote = date.newInstance(System.Today().year(), 12, 31);
        for (SBQQ__Quote__c eachQuote : quotesList){
            if(acctMap.containsKey(eachQuote.LPCR_Creche__c)){
                eachQuote.LPCR_TypeCreche__c = acctMap.get(eachQuote.LPCR_Creche__c).LPCR_TypeCreche__c;
                eachQuote.LPCR_EntiteJuridique__c  = acctMap.get(eachQuote.LPCR_Creche__c).LPCR_EntiteJuridique__c ;
            }
            if(Label.LPCR_Renewal.equals(eachQuote.SBQQ__Type__c)){
                if(opptyMap.containsKey(eachQuote.SBQQ__Opportunity2__c)){
                    if(contractMap.containsKey(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c)){
                        eachQuote.LPCR_RenouvellementConvenu__c = contractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_RenouvellementConvenu__c  ;
                        if(Label.LPCR_Non.equals(contractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_RenouvellementConvenu__c)){
                            eachQuote.SBQQ__RenewalUpliftRate__c = 0;
                        }
                    }
                }
            }
            if(Label.LPCR_Renewal.equals(eachQuote.SBQQ__Type__c) || Label.LPCR_QuoteT.equals(eachQuote.SBQQ__Type__c)){
                        Date endDate = eachQuote.LPCR_DateFin__c;
                        if(acctMap.containsKey(eachQuote.LPCR_Creche__c)){
                            if(Label.LPCR_MAC.equals(acctMap.get(eachQuote.LPCR_Creche__c).LPCR_TypeCreche__c)){
                                if(eachQuote.LPCR_DateFin__c < dueDateQuote){
                                    eachQuote.SBQQ__EndDate__c = eachQuote.LPCR_DateFin__c ;
                                }
                                else{
                                    eachQuote.SBQQ__EndDate__c = dueDateQuote;
                                } 
                            }
                            else if(Label.LPCR_MICRO.equals(acctMap.get(eachQuote.LPCR_Creche__c).LPCR_TypeCreche__c)){
                                if(eachQuote.LPCR_DateFin__c < dueDateRenewal){
                                    eachQuote.SBQQ__EndDate__c = eachQuote.LPCR_DateFin__c ;
                                }
                                else{
                                    eachQuote.SBQQ__EndDate__c = dueDateRenewal;
                                }  
                            }
                        }
            }
            if(Label.LPCR_Amendment.equals(eachQuote.SBQQ__Type__c)){
                if(opptyMap.containsKey(eachQuote.SBQQ__Opportunity2__c)){
                    if(amendedContractMap.containsKey(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c)){
                        eachQuote.LPCR_RenouvellementConvenu__c = amendedContractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).LPCR_RenouvellementConvenu__c  ;
                        eachQuote.LPCR_TypeFacturation__c=opptyMap.get(eachQuote.SBQQ__Opportunity2__c).LPCR_TypeFacturation__c;
                        if(Label.LPCR_Non.equals(amendedContractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).LPCR_RenouvellementConvenu__c)){
                            eachQuote.SBQQ__RenewalUpliftRate__c = 0;
                        } 
                    }
                    
                }
            }
            if(Label.LPCR_QuoteT.equals(eachQuote.SBQQ__Type__c) && acctMap.containsKey(eachQuote.LPCR_Creche__c)){
                eachQuote.LPCR_TypeFacturation__c   = acctMap.get(eachQuote.LPCR_Creche__c).LPCR_TypeFacturation__c ;
            }
        }
    }
    
    
    
    
    public static void setB2BQuotesFromContract(List<SBQQ__Quote__c> quotesList,  Map<ID,Account> acctMap, Map<Id,Opportunity> opptyMap,  Map<Id,Contract> contractMap){
        Date dueDateQuote = date.newInstance(System.Today().year(), 12, 31);
        for (SBQQ__Quote__c eachQuote : quotesList){
            if(Label.LPCR_Renewal.equals(eachQuote.SBQQ__Type__c)){
                if(opptyMap.containsKey(eachQuote.SBQQ__Opportunity2__c) ){
                    if(contractMap.containsKey(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c)){
                        eachQuote.LPCR_MethodeRenouvellement__c = contractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_MethodeRenouvellement__c;
                        //Date endDate = eachQuote.LPCR_DateFin__c;
                        if(Label.LPCR_Express.equals(eachQuote.LPCR_MethodeRenouvellement__c) ||Label.LPCR_SansRenouvellement.equals(eachQuote.LPCR_MethodeRenouvellement__c) ){
                            if(eachQuote.LPCR_DateFin__c.year() == System.Today().year()){
                                eachQuote.SBQQ__EndDate__c = eachQuote.LPCR_DateFin__c ;
                            }
                            else{
                                eachQuote.SBQQ__EndDate__c = dueDateQuote;
                            } 
                        }
                        else if(Label.LPCR_Tacite.equals(eachQuote.LPCR_MethodeRenouvellement__c)){
                            eachQuote.SBQQ__EndDate__c = dueDateQuote;
                        }
                    }
                } 
            }
            if(Label.LPCR_QuoteT.equals(eachQuote.SBQQ__Type__c)){
                if(eachQuote.LPCR_DateFin__c < dueDateQuote){
                    eachQuote.SBQQ__EndDate__c = eachQuote.LPCR_DateFin__c ;
                }
                else{
                    eachQuote.SBQQ__EndDate__c = dueDateQuote;
                }
            }
        }
    }
    
    public static void setB2CbeforInsertBQuotes(List<SBQQ__Quote__c> quotesList,  Map<ID,Account> acctMap){
        for (SBQQ__Quote__c eachQuote : quotesList){
            if(acctMap.containsKey(eachQuote.LPCR_Creche__c)){
                if(Label.LPCR_MAC.equals(acctMap.get(eachQuote.LPCR_Creche__c).LPCR_TypeCreche__c)){
                    eachQuote.LPCR_BatchCommande__c = 'MAC';
                }
                else if(Label.LPCR_MICRO.equals(acctMap.get(eachQuote.LPCR_Creche__c).LPCR_TypeCreche__c)){
                    eachQuote.LPCR_BatchCommande__c = 'MICRO';
                }
            }
        }
    }
    
    
    public static void setB2BbeforInsertBQuotesFromContract(List<SBQQ__Quote__c> quotesList,  Map<ID,Account> acctMap, Map<Id,Opportunity> opptyMap,  Map<Id,Contract> contractMap){
        Date dueDateQuote = date.newInstance(System.Today().year(), 12, 31);
        for (SBQQ__Quote__c eachQuote : quotesList){
            eachQuote.LPCR_BatchCommande__c = 'B2B';
            if(Label.LPCR_Renewal.equals(eachQuote.SBQQ__Type__c)){
                if(opptyMap.containsKey(eachQuote.SBQQ__Opportunity2__c) ){
                    if(contractMap.containsKey(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c)){
                        eachQuote.LPCR_RenouvellementConvenu__c = contractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_RenouvellementConvenu__c  ;
                        if(Label.LPCR_Non.equals(contractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_RenouvellementConvenu__c)){
                            eachQuote.SBQQ__RenewalUpliftRate__c = 0;
                        } 
                    }
                }
            }
        }
    }
    
    
    
    //end of hanae's part
    
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
        Map<Id,Opportunity> opptyMap = new  Map<Id,Opportunity>([SELECT Id,LPCR_BillingFrequency__c, LPCR_TypeFacturation__c,LPCR_IndexationConvenue__c, SBQQ__RenewedContract__c, LPCR_PlanningEnfant__c  from Opportunity WHERE Id in :opptyIds]);
        for (SBQQ__Quote__c eachQuote : quotesList){
            if(opptyMap.containsKey(eachQuote.SBQQ__Opportunity2__c) && 'Renewal'.equals(eachQuote.SBQQ__Type__c)){
                eachQuote.SBQQ__BillingFrequency__c=opptyMap.get(eachQuote.SBQQ__Opportunity2__c).LPCR_BillingFrequency__c;
                eachQuote.LPCR_TypeFacturation__c=opptyMap.get(eachQuote.SBQQ__Opportunity2__c).LPCR_TypeFacturation__c;
                eachQuote.LPCR_IndexationConvenue__c=opptyMap.get(eachQuote.SBQQ__Opportunity2__c).LPCR_IndexationConvenue__c;
                eachQuote.LPCR_PlanningEnfant__c=opptyMap.get(eachQuote.SBQQ__Opportunity2__c).LPCR_PlanningEnfant__c;
                if('Non'.equals(eachQuote.LPCR_IndexationConvenue__c)){
                    eachQuote.SBQQ__RenewalUpliftRate__c=null;
                }
            }
            else if(opptyMap.containsKey(eachQuote.SBQQ__Opportunity2__c) && 'Amendment'.equals(eachQuote.SBQQ__Type__c)){	
                eachQuote.LPCR_PlanningEnfant__c=opptyMap.get(eachQuote.SBQQ__Opportunity2__c).LPCR_PlanningEnfant__c;	
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