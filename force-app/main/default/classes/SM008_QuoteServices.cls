/**
* @author Achraf ABOUL
* @date 28/02/2020
* @description Service class for SBQQ__Quote__c
* @edited by hanae
*/
public with sharing class SM008_QuoteServices {
    public static Id acceuilRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote,Label.LPCR_ContratA);
    public static Id referencementRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote,Label.LPCR_Referencement);
    public static Id reservataireRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote,Label.LPCR_Reservataire);
    
    //added by hanae
    public static void updateQuotes(List<SBQQ__Quote__c> quotesList){
        
        List<SBQQ__Quote__c> renewalOppList = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> cummonQuoteList = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> B2CQuoteList = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> B2BQuoteList = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> B2BInsertQuoteList = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> B2CInsertQuoteList = new List<SBQQ__Quote__c>();
        Set<String> opptyIds = UM003_TypeManager.getFieldsOfListObjects(quotesList,Label.LPCR_Opportunity2);
        Set<String> acctIds = UM003_TypeManager.getFieldsOfListObjects(quotesList,Label.LPCR_CrecheF);
        Map<ID,Account> acctMap = new Map<ID,Account>([SELECT Id, LPCR_TypeCreche__c, LPCR_EntiteJuridique__c, LPCR_TypeFacturation__c  FROM Account WHERE Id in:acctIds]);
        Map<Id,Opportunity> opptyMap = new  Map<Id,Opportunity>([SELECT Id,LPCR_BillingFrequency__c, LPCR_TypeFacturation__c,LPCR_IndexationConvenue__c, SBQQ__RenewedContract__c, SBQQ__AmendedContract__c,LPCR_PlanningEnfant__c  from Opportunity WHERE Id in :opptyIds]);
        Set<String> renewedContractIds = UM003_TypeManager.getFieldsOfListObjects(opptyMap.Values(),Label.LPCR_RenewedContract);
        Set<String> amendedContractIds = UM003_TypeManager.getFieldsOfListObjects(opptyMap.Values(),Label.LPCR_AmendedContract);

        Map<Id,Contract> contractMap = new Map<Id,Contract>([SELECT Id, LPCR_RenouvellementPlanFacture__c,LPCR_NouveauPlanFacture__c,LPCR_InitAutoAvecDateDebut__c,LPCR_DateDebut__c, LPCR_DateFin__c, LPCR_ChiffreAffaire__c ,LPCR_MethodeRenouvellement__c,LPCR_MasterDevis__c, LPCR_Sales_Rep__c,LPCR_ResponsableADV__c,LPCR_ResponsableServiceFamille__c    From Contract Where Id =: renewedContractIds]);
        Map<Id,Contract> amendedContractMap = new Map<Id,Contract>([SELECT Id,LPCR_RenouvellementPlanFacture__c,LPCR_NouveauPlanFacture__c,LPCR_InitAutoAvecDateDebut__c, LPCR_DateDebut__c, LPCR_DateFin__c, LPCR_ChiffreAffaire__c ,LPCR_MethodeRenouvellement__c ,SBQQ__RenewalUpliftRate__c,LPCR_MasterDevis__c, LPCR_Sales_Rep__c,LPCR_ResponsableADV__c,LPCR_ResponsableServiceFamille__c   From Contract Where Id =: amendedContractIds]);

        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                for (SBQQ__Quote__c eachQuote : quotesList){
                    if(Label.LPCR_Renewal.equals(eachQuote.SBQQ__Type__c) || Label.LPCR_Amendment.equals(eachQuote.SBQQ__Type__c)){
                        renewalOppList.add(eachQuote);
                    }
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


            if(renewalOppList.size()>0){
                SM008_QuoteServices.setQuoteFields(renewalOppList,contractMap,amendedContractMap, opptyMap);
            }
            if(B2CInsertQuoteList.size()>0){
                SM008_QuoteServices.setB2CbeforInsertBQuotes(B2CInsertQuoteList,acctMap);
            }
            if(cummonQuoteList.size()>0){
                SM008_QuoteServices.setB2BandB2CQuotesFromContract(cummonQuoteList, acctMap,  opptyMap, contractMap, amendedContractMap);
            }
            if(B2CQuoteList.size()>0){
                SM008_QuoteServices.setB2CQuotesFromContract(B2CQuoteList,  acctMap, opptyMap, amendedContractMap, contractMap);
            }
            if(B2BQuoteList.size()>0){
                SM008_QuoteServices.setB2BQuotesFromContract(B2BQuoteList, acctMap, opptyMap, contractMap);
            }
            if(B2BInsertQuoteList.size()>0){
                SM008_QuoteServices.setB2BbeforInsertBQuotesFromContract(B2BInsertQuoteList, acctMap, opptyMap, contractMap);
            }

        }
    }
    
    
    
    
    
    
    
    public static void setB2BandB2CQuotesFromContract(List<SBQQ__Quote__c> quotesList,  Map<ID,Account> acctMap, Map<Id,Opportunity> opptyMap,  Map<Id,Contract> contractMap, Map<Id,Contract> amendedContractMap){
        for (SBQQ__Quote__c eachQuote : quotesList){
            if(Label.LPCR_Renewal.equals(eachQuote.SBQQ__Type__c)){
                if(opptyMap.containsKey(eachQuote.SBQQ__Opportunity2__c)){
                    if(contractMap.containsKey(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c)){
                        eachQuote.LPCR_DateDebut__c = contractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_DateDebut__c;
                        eachQuote.LPCR_DateFin__c = contractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_DateFin__c ;
                        if(eachQuote.RecordTypeId != referencementRecTypeId && eachQuote.RecordTypeId != reservataireRecTypeId){
                            eachQuote.LPCR_ChiffreAffaire__c = contractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_ChiffreAffaire__c  ;
                        }
                        if(eachQuote.RecordTypeId == referencementRecTypeId){
                            eachQuote.LPCR_MasterDevis__c = contractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_MasterDevis__c;
                        }
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
                        if(eachQuote.RecordTypeId != referencementRecTypeId && eachQuote.RecordTypeId != reservataireRecTypeId){
                            eachQuote.LPCR_ChiffreAffaire__c = amendedContractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).LPCR_ChiffreAffaire__c  ;
                        }
                        if(eachQuote.RecordTypeId == referencementRecTypeId){
                            eachQuote.LPCR_MasterDevis__c = amendedContractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).LPCR_MasterDevis__c;
                        }
                    }
                }
            }
        }
    }
    
    public static void setB2CQuotesFromContract(List<SBQQ__Quote__c> quotesList,  Map<ID,Account> acctMap, Map<Id,Opportunity> opptyMap,  Map<Id,Contract> amendedContractMap,Map<Id,Contract> contractMap){
        Date dueDateRenewal = date.newInstance(System.Today().year(), 08, 31);
        Date dueDateQuote = date.newInstance(System.Today().year(), 12, 31);
        Date nextYearDueDateRenewal = date.newInstance(System.Today().year()+1, 08, 31);

        for (SBQQ__Quote__c eachQuote : quotesList){
            Date dueStartDateQuote = date.newInstance(eachQuote.SBQQ__StartDate__c.year(), 12, 31);
            if(acctMap.containsKey(eachQuote.LPCR_Creche__c)){
                eachQuote.LPCR_TypeCreche__c = acctMap.get(eachQuote.LPCR_Creche__c).LPCR_TypeCreche__c;
                eachQuote.LPCR_EntiteJuridique__c  = acctMap.get(eachQuote.LPCR_Creche__c).LPCR_EntiteJuridique__c ;
            }
            if(Label.LPCR_Renewal.equals(eachQuote.SBQQ__Type__c)){
                if(opptyMap.containsKey(eachQuote.SBQQ__Opportunity2__c)){
                    if(contractMap.containsKey(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c)){
                            eachQuote.SBQQ__RenewalUpliftRate__c = 0;
                    }
                }
            }
            if(Label.LPCR_Renewal.equals(eachQuote.SBQQ__Type__c) || Label.LPCR_QuoteT.equals(eachQuote.SBQQ__Type__c)){
                        Date endDate = eachQuote.LPCR_DateFin__c;
                        if(acctMap.containsKey(eachQuote.LPCR_Creche__c)){
                            if(Label.LPCR_MAC.equals(acctMap.get(eachQuote.LPCR_Creche__c).LPCR_TypeCreche__c)){
                                if(eachQuote.LPCR_DateFin__c < dueStartDateQuote){
                                    eachQuote.SBQQ__EndDate__c = eachQuote.LPCR_DateFin__c ;
                                }
                                else{
                                    eachQuote.SBQQ__EndDate__c = dueStartDateQuote;
                                } 
                            }
                            else if(Label.LPCR_MICRO.equals(acctMap.get(eachQuote.LPCR_Creche__c).LPCR_TypeCreche__c)){
                                if(eachQuote.LPCR_DateFin__c < dueDateRenewal){
                                    eachQuote.SBQQ__EndDate__c = eachQuote.LPCR_DateFin__c ;
                                }
                                else{
                                        if(eachQuote.SBQQ__StartDate__c < dueDateRenewal){
                                            eachQuote.SBQQ__EndDate__c = dueDateRenewal;
                                        }else{
                                            if(eachQuote.LPCR_DateFin__c < nextYearDueDateRenewal){
                                                eachQuote.SBQQ__EndDate__c = eachQuote.LPCR_DateFin__c ;
                                            }else{
                                                eachQuote.SBQQ__EndDate__c = nextYearDueDateRenewal;
                                            }
                                        }
                                }  
                            }
                        }
            }
            if(Label.LPCR_Amendment.equals(eachQuote.SBQQ__Type__c)){
                if(opptyMap.containsKey(eachQuote.SBQQ__Opportunity2__c)){
                    if(amendedContractMap.containsKey(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c)){
                        eachQuote.LPCR_TypeFacturation__c=opptyMap.get(eachQuote.SBQQ__Opportunity2__c).LPCR_TypeFacturation__c;
                            eachQuote.SBQQ__RenewalUpliftRate__c = 0;
                    }
                    
                }
            }
            if(Label.LPCR_QuoteT.equals(eachQuote.SBQQ__Type__c) && acctMap.containsKey(eachQuote.LPCR_Creche__c)){
                eachQuote.LPCR_TypeFacturation__c   = acctMap.get(eachQuote.LPCR_Creche__c).LPCR_TypeFacturation__c ;
            }
        }
    }
    
    
    
    
    public static void setB2BQuotesFromContract(List<SBQQ__Quote__c> quotesList,  Map<ID,Account> acctMap, Map<Id,Opportunity> opptyMap,  Map<Id,Contract> contractMap){
        Date dueDateRenewal = date.newInstance(System.Today().year(), 08, 31);
        Date dueDateQuote = date.newInstance(System.Today().year(), 12, 31);
        Date nextYearDueDateRenewal = date.newInstance(System.Today().year()+1, 08, 31);

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
        }
    }
    
    public static void setB2CbeforInsertBQuotes(List<SBQQ__Quote__c> quotesList,  Map<ID,Account> acctMap){
        Set<String> contractIds = UM003_TypeManager.getFieldsOfListObjects(quotesList,'LPCR_ContractEntreprise__c');
        Map<Id,Contract> contractMap = new  Map<Id,Contract>([SELECT Id, LPCR_Sales_Rep__c,LPCR_ResponsableADV__c,LPCR_ResponsableServiceFamille__c   from Contract WHERE Id in :contractIds]);

        for (SBQQ__Quote__c eachQuote : quotesList){
            if(acctMap.containsKey(eachQuote.LPCR_Creche__c)){
                if(Label.LPCR_MAC.equals(acctMap.get(eachQuote.LPCR_Creche__c).LPCR_TypeCreche__c)){
                    eachQuote.LPCR_BatchCommande__c = 'MAC';
                }
                else if(Label.LPCR_MICRO.equals(acctMap.get(eachQuote.LPCR_Creche__c).LPCR_TypeCreche__c)){
                    eachQuote.LPCR_BatchCommande__c = 'MICRO';
                }
            }
            if(!Label.LPCR_Renewal.equals(eachQuote.SBQQ__Type__c) && !Label.LPCR_Amendment.equals(eachQuote.SBQQ__Type__c) && contractMap.containsKey(eachQuote.LPCR_ContractEntreprise__c)){
                eachQuote.SBQQ__SalesRep__c = contractMap.get(eachQuote.LPCR_ContractEntreprise__c).LPCR_Sales_Rep__c;
                eachQuote.LPCR_ResponsableADV__c = contractMap.get(eachQuote.LPCR_ContractEntreprise__c).LPCR_ResponsableADV__c;
                eachQuote.LPCR_ResponsableServiceFamille__c = contractMap.get(eachQuote.LPCR_ContractEntreprise__c).LPCR_ResponsableServiceFamille__c;
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
                            eachQuote.SBQQ__RenewalUpliftRate__c = 0;
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
    public static void setQuoteFields(List<SBQQ__Quote__c> quotesList,Map<Id,Contract> renewedContract,Map<Id,Contract> amendedContract, Map<Id,Opportunity> opptyMap){
        for (SBQQ__Quote__c eachQuote : quotesList){
            Id quoteRecTypeId = null;
            if(eachQuote.LPCR_TypeEnregistrement__c != '' && Schema.getGlobalDescribe().get(Label.LPCR_Quote).getDescribe().getRecordTypeInfosByDeveloperName().get(eachQuote.LPCR_TypeEnregistrement__c)!=null){
                quoteRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote,eachQuote.LPCR_TypeEnregistrement__c);
            }
            
            if(quoteRecTypeId != null){
                eachQuote.RecordTypeId = quoteRecTypeId;
            }
      
            if(opptyMap.containsKey(eachQuote.SBQQ__Opportunity2__c) && 'Renewal'.equals(eachQuote.SBQQ__Type__c)){
                eachQuote.ApprovalStatus__c = Label.LPCR_ApprovalStatusApproved;
                eachQuote.SBQQ__BillingFrequency__c=opptyMap.get(eachQuote.SBQQ__Opportunity2__c).LPCR_BillingFrequency__c;
                eachQuote.LPCR_TypeFacturation__c=opptyMap.get(eachQuote.SBQQ__Opportunity2__c).LPCR_TypeFacturation__c;
                eachQuote.LPCR_IndexationConvenue__c=opptyMap.get(eachQuote.SBQQ__Opportunity2__c).LPCR_IndexationConvenue__c;
                if(eachQuote.RecordTypeId != referencementRecTypeId && eachQuote.RecordTypeId != reservataireRecTypeId){
                    eachQuote.LPCR_PlanningEnfant__c=opptyMap.get(eachQuote.SBQQ__Opportunity2__c).LPCR_PlanningEnfant__c;
                }
                if('Non'.equals(eachQuote.LPCR_IndexationConvenue__c)){
                    eachQuote.SBQQ__RenewalUpliftRate__c=null;
                }
                //
                if(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c != null && renewedContract.containsKey(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c)){
                    eachQuote.LPCR_InitAutoAvecDateDebut__c =renewedContract.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_InitAutoAvecDateDebut__c;
                    eachQuote.SBQQ__SalesRep__c = renewedContract.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_Sales_Rep__c;
                    eachQuote.LPCR_ResponsableADV__c = renewedContract.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_ResponsableADV__c;
                    eachQuote.LPCR_ResponsableServiceFamille__c = renewedContract.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_ResponsableServiceFamille__c;
                    eachQuote.LPCR_NouveauPlanFacture__c  = renewedContract.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_NouveauPlanFacture__c;
                    eachQuote.LPCR_RenouvellementPlanFacture__c  = renewedContract.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_RenouvellementPlanFacture__c;
                
                }
            }
            else if(opptyMap.containsKey(eachQuote.SBQQ__Opportunity2__c) && 'Amendment'.equals(eachQuote.SBQQ__Type__c)){	
                eachQuote.SBQQ__BillingFrequency__c=opptyMap.get(eachQuote.SBQQ__Opportunity2__c).LPCR_BillingFrequency__c;
                if(eachQuote.RecordTypeId == referencementRecTypeId || eachQuote.RecordTypeId == reservataireRecTypeId){
                    eachQuote.LPCR_TypeFacturation__c=opptyMap.get(eachQuote.SBQQ__Opportunity2__c).LPCR_TypeFacturation__c;
                }else{
                    eachQuote.LPCR_PlanningEnfant__c=opptyMap.get(eachQuote.SBQQ__Opportunity2__c).LPCR_PlanningEnfant__c;
                }
                
                if(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c != null && renewedContract.containsKey(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c)){
                    eachQuote.LPCR_InitAutoAvecDateDebut__c =amendedContract.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).LPCR_InitAutoAvecDateDebut__c;
                    eachQuote.SBQQ__SalesRep__c = amendedContract.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).LPCR_Sales_Rep__c;
                    eachQuote.LPCR_ResponsableADV__c = amendedContract.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).LPCR_ResponsableADV__c;
                    eachQuote.LPCR_ResponsableServiceFamille__c = amendedContract.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).LPCR_ResponsableServiceFamille__c;
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
            PAD.log('SM008_QuoteServices','loadAgreement', 'Exception: ' + e.getStackTraceString() );
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
        
        if(mapQuoteIDAgreementID.get(agreementMac).size() > 0 || mapQuoteIDAgreementID.get(agreementMicro).size() > 0)
        SM008_QuoteServices.loadAgreement(mapQuoteIDAgreementID);
        return mapQuoteIDAgreementID;
    } 
   
    public static void setTypeEnregistrement(List<SBQQ__Quote__c> quotesList){
        Set<Id> opportunitiesIdsSet = new Set<Id>();
        for(SBQQ__Quote__c eachQuote : quotesList){
            opportunitiesIdsSet.add(eachQuote.SBQQ__Opportunity2__c);
        }
        //Map : Id=>Order (Parent records of the current contracts)
        Map<Id, Opportunity> parentOpportunitiesMap = new Map<Id, Opportunity>([SELECT Id, LPCR_TypeEnregistrement__c FROM Opportunity WHERE Id IN :opportunitiesIdsSet and LPCR_TypeEnregistrement__c !='']);
        if(parentOpportunitiesMap.size()>0){
            for(SBQQ__Quote__c eachQuote: quotesList){
                if(parentOpportunitiesMap.containsKey(eachQuote.SBQQ__Opportunity2__c)){
                    eachQuote.LPCR_TypeEnregistrement__c = parentOpportunitiesMap.get(eachQuote.SBQQ__Opportunity2__c).LPCR_TypeEnregistrement__c;
                }
            }
        }
      
    }
    
}