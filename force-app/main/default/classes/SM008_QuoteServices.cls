/**
* @author Achraf ABOUL
* @date 28/02/2020
* @description Service class for SBQQ__Quote__c
* @edited by hanae
*/
public with sharing class SM008_QuoteServices {
    public static Id acceuilRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote,Label.LPCR_ContratA);
    public static Id acceuilApprRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote,Label.LPCR_Accueil_Approuve);
    public static Id referencementRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote,Label.LPCR_Referencement);
    public static Id referencementApprRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote,Label.LPCR_Referencement_Approuve);
    public static Id reservataireRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote,Label.LPCR_Reservataire);
    public static Id referencementApprouveRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote,Label.LPCR_Referencement_Approuve);
    public static Id reservataireApprouveRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote,Label.LPCR_Reservataire_Approuve);
    public static Id reservataireApprRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote,Label.LPCR_Reservataire_Approuve);
    
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
        
        Map<Id,Contract> contractMap = new Map<Id,Contract>([SELECT Id, RecordType.DeveloperName,LPCR_DateFinMaxQuoteLine__c,LPCR_RenouvellementPlanFacturation__c,LPCR_NouveauPlanFacturation__c,LPCR_InitAutoAvecDateDebut__c,LPCR_DateDebut__c, LPCR_DateFin__c ,LPCR_MethodeRenouvellement__c,LPCR_MasterDevis__c, LPCR_Sales_Rep__c,LPCR_ResponsableADV__c,LPCR_ResponsableServiceFamille__c,LPCR_EntiteJuridique__c,LPCR_TypeCreche__c, LPCR_PlanningEnfant__c,LPCR_ContactEnfant__c,LPCR_ContractEntreprise__c,LPCR_ContactRepresentant1__c,LPCR_ContactRepresentant2__c,LPCR_CongesJours__c,LPCR_DureePreavisMois__c, LPCR_TypeAccueil__c, LPCR_Creche__c, LPCR_ChiffreAffaire__c, LPCR_FraisDossier__c, LPCR_Section__c, LPCR_CompteFacturation__c  From Contract Where Id =: renewedContractIds]);
        Map<Id,Contract> amendedContractMap = new Map<Id,Contract>([SELECT Id,RecordType.DeveloperName,LPCR_RenouvellementPlanFacturation__c,LPCR_NouveauPlanFacturation__c,LPCR_InitAutoAvecDateDebut__c, LPCR_DateDebut__c, LPCR_DateFin__c ,LPCR_MethodeRenouvellement__c ,SBQQ__RenewalUpliftRate__c,LPCR_MasterDevis__c, LPCR_Sales_Rep__c,LPCR_ResponsableADV__c,LPCR_ResponsableServiceFamille__c,LPCR_EntiteJuridique__c, LPCR_TypeCreche__c, LPCR_Creche__c, LPCR_ContactEnfant__c,LPCR_ContractEntreprise__c,LPCR_ContactRepresentant1__c,LPCR_ContactRepresentant2__c, LPCR_CongesJours__c, LPCR_DureePreavisMois__c, LPCR_TypeAccueil__c, LPCR_ChiffreAffaire__c,LPCR_FraisDossier__c,LPCR_Section__c,LPCR_CompteFacturation__c,LPCR_IndexationConvenue__c  From Contract Where Id =: amendedContractIds]);
        
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                for (SBQQ__Quote__c eachQuote : quotesList){
                    if(Label.LPCR_Renewal.equals(eachQuote.SBQQ__Type__c) || Label.LPCR_Amendment.equals(eachQuote.SBQQ__Type__c)){
                        renewalOppList.add(eachQuote);
                    }
                    if(eachQuote.RecordTypeId == referencementRecTypeId || eachQuote.RecordTypeId == referencementApprRecTypeId || eachQuote.RecordTypeId == reservataireRecTypeId || eachQuote.RecordTypeId == reservataireApprRecTypeId){
                        B2BInsertQuoteList.add(eachQuote);
                    }
                    if(eachQuote.RecordTypeId == acceuilRecTypeId || eachQuote.RecordTypeId == acceuilApprRecTypeId){
                        B2CInsertQuoteList.add(eachQuote);
                    }
                }
            }
            if(Trigger.isInsert || Trigger.isUpdate){
                for(SBQQ__Quote__c eachQuote : quotesList){
                    if(eachQuote.RecordTypeId == acceuilRecTypeId || eachQuote.RecordTypeId == acceuilApprRecTypeId || eachQuote.RecordTypeId == referencementRecTypeId || eachQuote.RecordTypeId == referencementApprRecTypeId || eachQuote.RecordTypeId == reservataireRecTypeId || eachQuote.RecordTypeId == reservataireApprRecTypeId){
                        cummonQuoteList.add(eachQuote);
                    }
                    if(eachQuote.RecordTypeId == acceuilRecTypeId || eachQuote.RecordTypeId == acceuilApprRecTypeId){
                        B2CQuoteList.add(eachQuote);
                    }
                    if(eachQuote.RecordTypeId == referencementRecTypeId || eachQuote.RecordTypeId == referencementApprRecTypeId || eachQuote.RecordTypeId == reservataireRecTypeId || eachQuote.RecordTypeId == reservataireApprRecTypeId){
                        B2BQuoteList.add(eachQuote);
                    }
                }
            }
            
            
            if(renewalOppList.size()>0){
                SM008_QuoteServices.setQuoteFields(renewalOppList,contractMap,amendedContractMap, opptyMap, acctMap);
            }
            if(B2CInsertQuoteList.size()>0){
                SM008_QuoteServices.setB2CbeforInsertBQuotes(B2CInsertQuoteList,acctMap,opptyMap,amendedContractMap,contractMap);
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
                SM008_QuoteServices.setB2BbeforInsertBQuotesFromContract(B2BInsertQuoteList, acctMap, opptyMap, contractMap, amendedContractMap);
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
                        if(eachQuote.RecordTypeId != referencementRecTypeId && eachQuote.RecordTypeId != referencementApprRecTypeId && eachQuote.RecordTypeId != reservataireRecTypeId && eachQuote.RecordTypeId != reservataireApprRecTypeId){
                            eachQuote.LPCR_ChiffreAffaire__c = contractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_ChiffreAffaire__c  ;
                        }
                        if(eachQuote.RecordTypeId == referencementRecTypeId || eachQuote.RecordTypeId == referencementApprRecTypeId){
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
                        if(eachQuote.RecordTypeId != referencementRecTypeId && eachQuote.RecordTypeId != referencementApprRecTypeId && eachQuote.RecordTypeId != reservataireRecTypeId && eachQuote.RecordTypeId != reservataireApprRecTypeId){
                            eachQuote.LPCR_ChiffreAffaire__c = amendedContractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).LPCR_ChiffreAffaire__c  ;
                        }
                        if(eachQuote.RecordTypeId == referencementRecTypeId || eachQuote.RecordTypeId == referencementApprRecTypeId){
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
            
            if(acctMap.containsKey(eachQuote.LPCR_Creche__c)){
                eachQuote.LPCR_TypeCreche__c = acctMap.get(eachQuote.LPCR_Creche__c).LPCR_TypeCreche__c;
                eachQuote.LPCR_EntiteJuridique__c  = acctMap.get(eachQuote.LPCR_Creche__c).LPCR_EntiteJuridique__c ;
            }
            if(Label.LPCR_Renewal.equals(eachQuote.SBQQ__Type__c)){
                if(opptyMap.containsKey(eachQuote.SBQQ__Opportunity2__c)){
                    if(contractMap.containsKey(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c)){
                        eachQuote.LPCR_EntiteJuridique__c = contractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_EntiteJuridique__c;
                        eachQuote.LPCR_TypeCreche__c = contractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_TypeCreche__c ;
                        eachQuote.LPCR_PlanningEnfant__c = opptyMap.get(eachQuote.SBQQ__Opportunity2__c).LPCR_PlanningEnfant__c;
                        eachQuote.LPCR_ContactEnfant__c = contractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_ContactEnfant__c ;
                        eachQuote.LPCR_Creche__c = contractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_Creche__c ;
                        eachQuote.LPCR_ContractEntreprise__c = contractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_ContractEntreprise__c ;
                        eachQuote.LPCR_ContactRepresentant1__c = contractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_ContactRepresentant1__c ;
                        eachQuote.LPCR_ContactRepresentant2__c = contractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_ContactRepresentant2__c ;
                        eachQuote.LPCR_DureePreavisMois__c = contractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_DureePreavisMois__c ;
                        eachQuote.LPCR_TypeAccueil__c = contractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_TypeAccueil__c ;
                        if(acctMap.containsKey(eachQuote.LPCR_Creche__c)){
                            if(Label.LPCR_MAC.equals(acctMap.get(eachQuote.LPCR_Creche__c).LPCR_TypeCreche__c)){
                                eachQuote.LPCR_BatchCommande__c = Label.LPCR_MAC;
                            }
                            else if(Label.LPCR_MICRO.equals(acctMap.get(eachQuote.LPCR_Creche__c).LPCR_TypeCreche__c)){
                                eachQuote.LPCR_BatchCommande__c = Label.LPCR_MICRO;
                            }
                        }
                    }
                }
            }
            
            
            
            
            if(Label.LPCR_QuoteT.equals(eachQuote.SBQQ__Type__c) && acctMap.containsKey(eachQuote.LPCR_Creche__c)){
                eachQuote.LPCR_TypeFacturation__c   = acctMap.get(eachQuote.LPCR_Creche__c).LPCR_TypeFacturation__c ;
                eachQuote.LPCR_EntiteJuridique__c  = acctMap.get(eachQuote.LPCR_Creche__c).LPCR_EntiteJuridique__c ;
                eachQuote.LPCR_TypeCreche__c = acctMap.get(eachQuote.LPCR_Creche__c).LPCR_TypeCreche__c;
                if(Label.LPCR_MAC.equals(acctMap.get(eachQuote.LPCR_Creche__c).LPCR_TypeCreche__c)){
                    eachQuote.LPCR_IndexationConvenue__c = 'Non';
                }
                if(Label.LPCR_MICRO.equals(acctMap.get(eachQuote.LPCR_Creche__c).LPCR_TypeCreche__c)){
                    eachQuote.LPCR_IndexationConvenue__c = 'Oui';
                }
            }
            
            
            
            
            
            if(Label.LPCR_Renewal.equals(eachQuote.SBQQ__Type__c) || Label.LPCR_QuoteT.equals(eachQuote.SBQQ__Type__c)){
                if(eachQuote.SBQQ__StartDate__c != null){
                    // added by saurabh IS-1577   Get default uplift rate from custom metadata
                    Map<String, LPCR_Default_Uplift_Rate__mdt> defaultUpliftRateMap = new Map<String, LPCR_Default_Uplift_Rate__mdt>();

                    for(LPCR_Default_Uplift_Rate__mdt eachDefaultUpliftRate : [SELECT Id ,MasterLabel,LPCR_RenewalUpliftRate__c FROM LPCR_Default_Uplift_Rate__mdt]){
                        defaultUpliftRateMap.put(eachDefaultUpliftRate.MasterLabel, eachDefaultUpliftRate);
                    }

                    Date dueStartDateQuote = date.newInstance(eachQuote.SBQQ__StartDate__c.year(), 12, 31);                               
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
                                Date dueDateRenewal2 = date.newInstance(eachQuote.SBQQ__StartDate__c.year(), 08, 31);
                                Date nextYearDueDateRenewal2 = date.newInstance(eachQuote.SBQQ__StartDate__c.year()+1, 08, 31);
                                
                                // added by saurabh IS-1577 set default uplift rate
                                if(Label.LPCR_QuoteT.equals(eachQuote.SBQQ__Type__c) && eachQuote.SBQQ__StartDate__c.month() != 7 && eachQuote.SBQQ__StartDate__c.month() != 8 && defaultUpliftRateMap.containsKey(Label.LPCR_MICRO) && eachQuote.SBQQ__RenewalUpliftRate__c != defaultUpliftRateMap.get(Label.LPCR_MICRO).LPCR_RenewalUpliftRate__c ){
                                    eachQuote.SBQQ__RenewalUpliftRate__c = defaultUpliftRateMap.get(Label.LPCR_MICRO).LPCR_RenewalUpliftRate__c;
                                }else if(Label.LPCR_Renewal.equals(eachQuote.SBQQ__Type__c) && eachQuote.SBQQ__RenewalUpliftRate__c == null && defaultUpliftRateMap.containsKey(Label.LPCR_MICRO)){
                                    eachQuote.SBQQ__RenewalUpliftRate__c = defaultUpliftRateMap.get(Label.LPCR_MICRO).LPCR_RenewalUpliftRate__c;
                                }

                                if(eachQuote.LPCR_DateFin__c < dueDateRenewal2){
                                    eachQuote.SBQQ__EndDate__c = eachQuote.LPCR_DateFin__c ;
                                }
                                else{
                                        if(eachQuote.SBQQ__StartDate__c < dueDateRenewal2){
                                            eachQuote.SBQQ__EndDate__c = dueDateRenewal2;
                                        }else{
                                            if(eachQuote.LPCR_DateFin__c < nextYearDueDateRenewal2){
                                                eachQuote.SBQQ__EndDate__c = eachQuote.LPCR_DateFin__c ;
                                            }else{
                                                eachQuote.SBQQ__EndDate__c = nextYearDueDateRenewal2;
                                            }
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
                        eachQuote.LPCR_EntiteJuridique__c  = amendedContractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).LPCR_EntiteJuridique__c ;
                        eachQuote.LPCR_TypeCreche__c  = amendedContractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).LPCR_TypeCreche__c ;
                        if(eachQuote.LPCR_PlanningEnfant__c == null){
                            eachQuote.LPCR_PlanningEnfant__c=opptyMap.get(eachQuote.SBQQ__Opportunity2__c).LPCR_PlanningEnfant__c;
                        } 
                        eachQuote.LPCR_Creche__c  = amendedContractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).LPCR_Creche__c ;
                        eachQuote.LPCR_ContactEnfant__c  = amendedContractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).LPCR_ContactEnfant__c ;
                        eachQuote.LPCR_ContractEntreprise__c  = amendedContractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).LPCR_ContractEntreprise__c ;
                        eachQuote.LPCR_ContactRepresentant1__c  = amendedContractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).LPCR_ContactRepresentant1__c ;
                        eachQuote.LPCR_ContactRepresentant2__c  = amendedContractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).LPCR_ContactRepresentant2__c ;
                        eachQuote.LPCR_DureePreavisMois__c  = amendedContractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).LPCR_DureePreavisMois__c ;
                        eachQuote.LPCR_TypeAccueil__c  = amendedContractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).LPCR_TypeAccueil__c ;
                        if(acctMap.containsKey(eachQuote.LPCR_Creche__c)){
                            if(Label.LPCR_MAC.equals(acctMap.get(eachQuote.LPCR_Creche__c).LPCR_TypeCreche__c)){
                                eachQuote.LPCR_BatchCommande__c = Label.LPCR_MAC;
                            }
                            else if(Label.LPCR_MICRO.equals(acctMap.get(eachQuote.LPCR_Creche__c).LPCR_TypeCreche__c)){
                                eachQuote.LPCR_BatchCommande__c = Label.LPCR_MICRO;
                            }
                        }
                        
                    }
                    
                }
            }
        }
    }
    
    
    
    
    public static void setB2BQuotesFromContract(List<SBQQ__Quote__c> quotesList,  Map<ID,Account> acctMap, Map<Id,Opportunity> opptyMap,  Map<Id,Contract> contractMap){
        Date dueDateRenewal = date.newInstance(System.Today().year(), 08, 31);
        Date dueDateQuote = date.newInstance(System.Today().year(), 12, 31);
        Date nextYearDueDateRenewal = date.newInstance(System.Today().year()+1, 08, 31);
        
        for (SBQQ__Quote__c eachQuote : quotesList){    
            
            if(Label.LPCR_Renewal.equals(eachQuote.SBQQ__Type__c)){
                
                if(eachQuote.SBQQ__StartDate__c != null){
                    
                    Date dueStartDateQuote = date.newInstance(eachQuote.SBQQ__StartDate__c.year(), 12, 31);
                    if(opptyMap.containsKey(eachQuote.SBQQ__Opportunity2__c) ){
                        
                        if(contractMap.containsKey(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c)){
                            
                            eachQuote.LPCR_MethodeRenouvellement__c = contractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_MethodeRenouvellement__c;

                            if(Label.LPCR_Express.equals(eachQuote.LPCR_MethodeRenouvellement__c) ||Label.LPCR_SansRenouvellement.equals(eachQuote.LPCR_MethodeRenouvellement__c) ){
                                
                                // RESERVATAIRE
                                if (eachQuote.RecordTypeId == reservataireRecTypeId || eachQuote.RecordTypeId == reservataireApprouveRecTypeId) { 
                                    
                                    if (eachQuote.LPCR_DateFin__c < dueStartDateQuote){
                                        eachQuote.SBQQ__EndDate__c = eachQuote.LPCR_DateFin__c ;
                                    }
                                    else {
                                        eachQuote.SBQQ__EndDate__c = dueStartDateQuote;
                                    }
                                }
                                // REFERENCEMENT
                                else { 
                                    if (eachQuote.LPCR_DateFinMaxQuoteLine__c < dueStartDateQuote){
                                        eachQuote.SBQQ__EndDate__c = eachQuote.LPCR_DateFinMaxQuoteLine__c;   
                                    }
                                    else {
                                        eachQuote.SBQQ__EndDate__c = dueStartDateQuote;
                                    }
                                }
                            }
                            else if(Label.LPCR_Tacite.equals(eachQuote.LPCR_MethodeRenouvellement__c)){
                                eachQuote.SBQQ__EndDate__c = dueStartDateQuote;
                            }
                        }
                    } 
                }               
            }
            
            if(Label.LPCR_QuoteT.equals(eachQuote.SBQQ__Type__c)){
                if(eachQuote.SBQQ__StartDate__c != null){
                    Date dueStartDateQuote = date.newInstance(eachQuote.SBQQ__StartDate__c.year(), 12, 31);
                    if(eachQuote.LPCR_DateDebut__c != Null){
                        eachQuote.SBQQ__StartDate__c = eachQuote.LPCR_DateDebut__c ;
                    }
                    if(eachQuote.LPCR_DateFin__c < dueStartDateQuote){
                        eachQuote.SBQQ__EndDate__c = eachQuote.LPCR_DateFin__c ;
                    }
                    else{
                        eachQuote.SBQQ__EndDate__c = dueStartDateQuote;
                    }
                }               
            }
        }
    }
    
    public static void setB2CbeforInsertBQuotes(List<SBQQ__Quote__c> quotesList,  Map<ID,Account> acctMap, Map<Id,Opportunity> opptyMap,  Map<Id,Contract> amendedContractMap,Map<Id,Contract> renewedcontractMap){
        Set<String> contractIds = UM003_TypeManager.getFieldsOfListObjects(quotesList,'LPCR_ContractEntreprise__c');
        Map<Id,Contract> contractMap = new  Map<Id,Contract>([SELECT Id, LPCR_Sales_Rep__c,LPCR_ResponsableADV__c,LPCR_ResponsableServiceFamille__c   from Contract WHERE Id in :contractIds]);
        
        for (SBQQ__Quote__c eachQuote : quotesList){
            if(Label.LPCR_QuoteT.equals(eachQuote.SBQQ__Type__c)){
                if(acctMap.containsKey(eachQuote.LPCR_Creche__c)){
                    if(Label.LPCR_MAC.equals(acctMap.get(eachQuote.LPCR_Creche__c).LPCR_TypeCreche__c)){
                        eachQuote.LPCR_BatchCommande__c = 'MAC';
                    }
                    else if(Label.LPCR_MICRO.equals(acctMap.get(eachQuote.LPCR_Creche__c).LPCR_TypeCreche__c)){
                        eachQuote.LPCR_BatchCommande__c = 'MICRO';
                    }
                }
            }
            if(!Label.LPCR_Renewal.equals(eachQuote.SBQQ__Type__c) && !Label.LPCR_Amendment.equals(eachQuote.SBQQ__Type__c) && contractMap.containsKey(eachQuote.LPCR_ContractEntreprise__c)){
                eachQuote.SBQQ__SalesRep__c = contractMap.get(eachQuote.LPCR_ContractEntreprise__c).LPCR_Sales_Rep__c;
                eachQuote.LPCR_ResponsableADV__c = contractMap.get(eachQuote.LPCR_ContractEntreprise__c).LPCR_ResponsableADV__c;
                eachQuote.LPCR_ResponsableServiceFamille__c = contractMap.get(eachQuote.LPCR_ContractEntreprise__c).LPCR_ResponsableServiceFamille__c;
            }

            if(Label.LPCR_Renewal.equals(eachQuote.SBQQ__Type__c)){
                if(opptyMap.containsKey(eachQuote.SBQQ__Opportunity2__c)){
                    if(renewedcontractMap.containsKey(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c)){
                        eachQuote.LPCR_CongesJours__c = renewedcontractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_CongesJours__c ;
                    }
                }
            }
            if(Label.LPCR_Amendment.equals(eachQuote.SBQQ__Type__c)){
                if(opptyMap.containsKey(eachQuote.SBQQ__Opportunity2__c)){
                    if(amendedContractMap.containsKey(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c)){
                        eachQuote.LPCR_CongesJours__c  = amendedContractMap.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).LPCR_CongesJours__c ;
                    }
                }
            }
        }
    }
    
    
    public static void setB2BbeforInsertBQuotesFromContract(List<SBQQ__Quote__c> quotesList,  Map<ID,Account> acctMap, Map<Id,Opportunity> opptyMap,  Map<Id,Contract> contractMap, Map<Id,Contract> amendedContractMap){
        Date dueDateQuote = date.newInstance(System.Today().year(), 12, 31);
        for (SBQQ__Quote__c eachQuote : quotesList){
            if(Label.LPCR_QuoteT.equals(eachQuote.SBQQ__Type__c)){
                eachQuote.LPCR_BatchCommande__c = 'B2B';
            }
        }
    }
    
    public static void updateOppsFromQuotes(List<SBQQ__Quote__c> quotesList){
        Set<Id> oppsIds = new Set<Id>();
        for(SBQQ__Quote__c eachQuote : quotesList){
            if(eachQuote.SBQQ__Status__c.equals('Signé')){
                oppsIds.add(eachQuote.SBQQ__Opportunity2__c);
            }
        }
        List<Opportunity> oppsToUpdate = EM004_OpportunityEntity.getOppsByIds(oppsIds);
        for(Opportunity eachOpp : oppsToUpdate){
            eachOpp.StageName = 'Signée';
        }
        update oppsToUpdate;
        
    }

    /*
        > Si au moin un Devis est en statut ("Signé", "Prêt pour commande", ou "Actif") et que la valeur du statut n'était pas client
        ==> Mettre à jour le statut du compte à Client 
        > Sinon si tous les devis au statut terminé ou annulé
        ==> Mettre à jour le statut du compte à Ancien Client 
        > Sinon 
        ==> Mettre à jour le statut du compte à Prospect 
    */
    public static void updateAccountsFromQuotes(List<SBQQ__Quote__c> quotesList,Map<Id, SBQQ__Quote__c> oldQuotesMap){

        List<SBQQ__Quote__c> quotesToProcess = new List<SBQQ__Quote__c>();
        if(oldQuotesMap != null){
            // We are in update context => take only the quotes whos their status changed
            for(SBQQ__Quote__c q : quotesList){
                if(q.SBQQ__Status__c != oldQuotesMap.get(q.id).SBQQ__Status__c){
                    quotesToProcess.add(q);
                }
            }
        }else{
            // We are in insert mode => take all new quotes
            quotesToProcess = quotesList;
        }

        if(quotesToProcess.size()>0){

            List<Account> accountsToUpdate = new List<Account>();

            Set<Id> accountsIds = new Set<Id>();
            for(SBQQ__Quote__c eachQuote : quotesList){
                if(!accountsIds.contains(eachQuote.SBQQ__Account__c)){
                    accountsIds.add(eachQuote.SBQQ__Account__c);
                }
            }

            List<Account> accountsInScope = [SELECT Id,LPCR_Statut__c,(SELECT Id,SBQQ__Status__c FROM SBQQ__Quotes__r) FROM Account WHERE Id IN :accountsIds];

            for(Account eachAcc : accountsInScope){

                Boolean allQuotesClos = true;
                Boolean isClient = false;
                for(SBQQ__Quote__c eachQuote : eachAcc.SBQQ__Quotes__r){
                    
                    if(eachQuote.SBQQ__Status__c != 'Terminé' && eachQuote.SBQQ__Status__c != 'Annulé'){
                        
                        allQuotesClos = false;

                        if( eachQuote.SBQQ__Status__c == 'Signé'                ||
                            eachQuote.SBQQ__Status__c == 'Prêt pour commande'   ||
                            eachQuote.SBQQ__Status__c == 'Actif' )
                        {
                            // Il existe au moins un devis signé actif ou pret 
                            isClient = true;
                            break;
                        }

                    }
                }
                
                if(allQuotesClos){
                    // tous les devis au statut terminé ou annulé
                    if(eachAcc.LPCR_Statut__c != 'Ancien client'){
                        eachAcc.LPCR_Statut__c = 'Ancien client';
                        accountsToUpdate.add(eachAcc);
                    }
                }else{
                    if(isClient){
                        if(eachAcc.LPCR_Statut__c != 'Client'){
                            //au moin un Devis est en statut ("Signé", "Prêt pour commande", ou "Actif") et que la valeur du statut n'était pas client
                            eachAcc.LPCR_Statut__c = 'Client';
                            accountsToUpdate.add(eachAcc);
                        }
                    }else if(eachAcc.LPCR_Statut__c != 'Prospect'){
                        eachAcc.LPCR_Statut__c = 'Prospect';
                        accountsToUpdate.add(eachAcc);
                    }
                }
            }
            if(accountsToUpdate.size() > 0 ){
                update accountsToUpdate;
            }
        }
    }
    
    public static void setQuoteFields(List<SBQQ__Quote__c> quotesList,Map<Id,Contract> renewedContract,Map<Id,Contract> amendedContract, Map<Id,Opportunity> opptyMap, Map<Id,Account> acctMap){
         Map<String,Schema.RecordTypeInfo> mapQuoteRT = Schema.getGlobalDescribe().get(Label.LPCR_Quote).getDescribe().getRecordTypeInfosByDeveloperName();
		
        for (SBQQ__Quote__c eachQuote : quotesList){
            
            if(opptyMap.containsKey(eachQuote.SBQQ__Opportunity2__c) && 'Renewal'.equals(eachQuote.SBQQ__Type__c)){
                eachQuote.ApprovalStatus__c = Label.LPCR_ApprovalStatusApproved;
                eachQuote.SBQQ__BillingFrequency__c=opptyMap.get(eachQuote.SBQQ__Opportunity2__c).LPCR_BillingFrequency__c;
                eachQuote.LPCR_TypeFacturation__c=opptyMap.get(eachQuote.SBQQ__Opportunity2__c).LPCR_TypeFacturation__c;
                eachQuote.LPCR_IndexationConvenue__c=opptyMap.get(eachQuote.SBQQ__Opportunity2__c).LPCR_IndexationConvenue__c;
                if(eachQuote.RecordTypeId != referencementRecTypeId && eachQuote.RecordTypeId != referencementApprRecTypeId && eachQuote.RecordTypeId != reservataireRecTypeId && eachQuote.RecordTypeId != reservataireApprRecTypeId){
                    eachQuote.LPCR_PlanningEnfant__c=opptyMap.get(eachQuote.SBQQ__Opportunity2__c).LPCR_PlanningEnfant__c;
                }
                if('Non'.equals(eachQuote.LPCR_IndexationConvenue__c)){
                    eachQuote.SBQQ__RenewalUpliftRate__c=null;
                }
                //
                if(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c != null && renewedContract.containsKey(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c)){
                     
                    eachQuote.RecordTypeId = mapQuoteRT.containsKey(renewedContract.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).RecordType.DeveloperName)
                    ? 
                        mapQuoteRT.get(renewedContract.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).RecordType.DeveloperName).getRecordTypeId()
                    : 
                        eachQuote.RecordTypeId;

                    eachQuote.LPCR_DateFinMaxQuoteLine__c =renewedContract.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_DateFinMaxQuoteLine__c;
                    eachQuote.LPCR_InitAutoAvecDateDebut__c =renewedContract.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_InitAutoAvecDateDebut__c;
                    eachQuote.SBQQ__SalesRep__c = renewedContract.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_Sales_Rep__c;
                    eachQuote.LPCR_ResponsableADV__c = renewedContract.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_ResponsableADV__c;
                    eachQuote.LPCR_ResponsableServiceFamille__c = renewedContract.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_ResponsableServiceFamille__c;
                    eachQuote.LPCR_NouveauPlanFacture__c  = renewedContract.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_NouveauPlanFacturation__c;
                    eachQuote.LPCR_RenouvellementPlanFacture__c  = renewedContract.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_RenouvellementPlanFacturation__c;
                    if(eachQuote.RecordTypeId == referencementRecTypeId || eachQuote.RecordTypeId == referencementApprRecTypeId){
                        eachQuote.LPCR_FraisDossier__c = renewedContract.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_FraisDossier__c;
                    }
                    if(eachQuote.RecordTypeId == referencementRecTypeId || eachQuote.RecordTypeId == referencementApprRecTypeId || eachQuote.RecordTypeId == reservataireRecTypeId || eachQuote.RecordTypeId == reservataireApprouveRecTypeId){
                        eachQuote.LPCR_BatchCommande__c = 'B2B';
                    }
                    
                    if(eachQuote.RecordTypeId == acceuilRecTypeId || eachQuote.RecordTypeId == acceuilApprRecTypeId){
                        eachQuote.LPCR_Section__c = renewedContract.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_Section__c;
                    }
                    eachQuote.LPCR_CompteFacturation__c = renewedContract.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).LPCR_CompteFacturation__c;  
                }
            }
            else if(opptyMap.containsKey(eachQuote.SBQQ__Opportunity2__c) && 'Amendment'.equals(eachQuote.SBQQ__Type__c)){
                  eachQuote.RecordTypeId = mapQuoteRT.containsKey(amendedContract.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).RecordType.DeveloperName)? 
                   mapQuoteRT.get(amendedContract.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).RecordType.DeveloperName).getRecordTypeId()
                    : eachQuote.RecordTypeId;                

                eachQuote.SBQQ__BillingFrequency__c=opptyMap.get(eachQuote.SBQQ__Opportunity2__c).LPCR_BillingFrequency__c;
                if(eachQuote.RecordTypeId == referencementRecTypeId || eachQuote.RecordTypeId == referencementApprRecTypeId || eachQuote.RecordTypeId == reservataireRecTypeId || eachQuote.RecordTypeId == reservataireApprRecTypeId){
                    eachQuote.LPCR_TypeFacturation__c=opptyMap.get(eachQuote.SBQQ__Opportunity2__c).LPCR_TypeFacturation__c;
                }
                if(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c != null && amendedContract.containsKey(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c)){
                    eachQuote.LPCR_InitAutoAvecDateDebut__c =amendedContract.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).LPCR_InitAutoAvecDateDebut__c;
                    eachQuote.SBQQ__SalesRep__c = amendedContract.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).LPCR_Sales_Rep__c;
                    eachQuote.LPCR_ResponsableADV__c = amendedContract.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).LPCR_ResponsableADV__c;
                    eachQuote.LPCR_ResponsableServiceFamille__c = amendedContract.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).LPCR_ResponsableServiceFamille__c;
                    if(eachQuote.RecordTypeId == referencementRecTypeId || eachQuote.RecordTypeId == referencementApprRecTypeId){
                        eachQuote.LPCR_FraisDossier__c = amendedContract.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).LPCR_FraisDossier__c;
                    }
                    if(eachQuote.RecordTypeId == referencementRecTypeId || eachQuote.RecordTypeId == referencementApprRecTypeId || eachQuote.RecordTypeId == reservataireRecTypeId || eachQuote.RecordTypeId == reservataireApprouveRecTypeId){
                        eachQuote.LPCR_MethodeRenouvellement__c =  amendedContract.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).LPCR_MethodeRenouvellement__c;
                        eachQuote.LPCR_IndexationConvenue__c =  amendedContract.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).LPCR_IndexationConvenue__c;
                        eachQuote.LPCR_BatchCommande__c = 'B2B';
                    }
                    
                    
                    if(eachQuote.RecordTypeId == acceuilRecTypeId || eachQuote.RecordTypeId == acceuilApprRecTypeId){
                        eachQuote.LPCR_Section__c = amendedContract.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).LPCR_Section__c;
                    }
                    eachQuote.LPCR_CompteFacturation__c = amendedContract.get(opptyMap.get(eachQuote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).LPCR_CompteFacturation__c;
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
        ID agreementAcc = LPCR_IDsCongaAdobe__c.getInstance().LPCR_AATCONTRAT_ACCUEIL__c; 
        Map<Id,Set<Id>> mapQuoteIDAgreementID = new Map<Id,Set<Id>>();
        mapQuoteIDAgreementID.put(agreementAcc , new Set<Id>() );
        
        for(SBQQ__Quote__c eachNewQuote : newQuoteMap.values()){
            if(eachNewQuote.SBQQ__Status__c != oldQuoteMap.get(eachNewQuote.Id).SBQQ__Status__c && eachNewQuote.SBQQ__Status__c == Label.LPCR_ValideDirectrice ){
                    mapQuoteIDAgreementID.get(agreementAcc).add(eachNewQuote.Id);
            }
        }
        
        if(mapQuoteIDAgreementID.get(agreementAcc).size() > 0)
            SM008_QuoteServices.loadAgreement(mapQuoteIDAgreementID);
        return mapQuoteIDAgreementID;
    }  
    
    // Update current quote, masterContract's Order and masterContract's quote
    public static void updateDueToResilisationAnticipe(List<SBQQ__Quote__c> quotesList){
        
        PAD.logAllList('SM008_QuoteServices','updateDueToResilisationAnticipe','quotesList', quotesList);

        Set<Id> contractIds = new Set<Id>();
        Map<Id,Boolean> contractFlagMap = new Map<Id,Boolean>();

        for(SBQQ__Quote__c eachQuote : quotesList) {

            if (eachQuote.SBQQ__Type__c == 'Amendment' && eachQuote.LPCR_TypeAvenant__c == 'Résiliation') {

                PAD.log('SM008_QuoteServices','updateDueToResilisationAnticipe','eachQuote.SBQQ__StartDate__c:'+ eachQuote.SBQQ__StartDate__c);
                PAD.log('SM008_QuoteServices','updateDueToResilisationAnticipe','eachQuote.LPCR_DateDebut__c:'+ eachQuote.LPCR_DateDebut__c);

                if (eachQuote.SBQQ__StartDate__c == eachQuote.LPCR_DateDebut__c) {
                    eachQuote.LPCR_AnnulationAnticipee__c = true;
                    PAD.log('SM008_QuoteServices','updateDueToResilisationAnticipe','eachQuote.LPCR_AnnulationAnticipee__c:'+ eachQuote.LPCR_AnnulationAnticipee__c);
                } else {
                    eachQuote.LPCR_AnnulationAnticipee__c = false;
                    PAD.log('SM008_QuoteServices','updateDueToResilisationAnticipe','eachQuote.LPCR_AnnulationAnticipee__c:'+ eachQuote.LPCR_AnnulationAnticipee__c);
                }
                contractFlagMap.put(eachQuote.SBQQ__MasterContract__c, eachQuote.LPCR_AnnulationAnticipee__c);
            }
        }

        List<SBQQ__Quote__c> quoteListToUpdate = new List<SBQQ__Quote__c>();
        List<Order> orderListToUpdate = new List<Order>();

        for (Contract c : [SELECT Id, SBQQ__Order__c, SBQQ__Quote__c FROM Contract where id in :contractFlagMap.keySet()]) {
            if (c.SBQQ__Quote__c != null)
                quoteListToUpdate.add(new SBQQ__Quote__c(Id = c.SBQQ__Quote__c, LPCR_AnnulationAnticipee__c = contractFlagMap.get(c.Id)));
            if (c.SBQQ__Order__c != null)
            orderListToUpdate.add(new Order(Id = c.SBQQ__Order__c, LPCR_AnnulationAnticipee__c = contractFlagMap.get(c.Id)));
        }

        PAD.log('SM008_QuoteServices','updateDueToResilisationAnticipe','quoteListToUpdate.size():'+ quoteListToUpdate.size());
        PAD.log('SM008_QuoteServices','updateDueToResilisationAnticipe','orderListToUpdate.size():'+ orderListToUpdate.size());
        
        if (quoteListToUpdate.size() > 0) { 
            update quoteListToUpdate;
        }
        if (orderListToUpdate.size() > 0) {
            update orderListToUpdate;
        }
        
        PAD.logAllList('SM008_QuoteServices','updateDueToResilisationAnticipe','quotesList', quotesList);
    }

    public static Decimal ExactDiffBeetweenDate(Date startDate, Date endDate) {

        PAD.log('SM008_QuoteServices','ExactDiffBeetweenDate','startDate:'+ startDate);
        PAD.log('SM008_QuoteServices','ExactDiffBeetweenDate','endDate:'+ endDate);

        if (startDate == null || endDate == null) {
            PAD.log('SM008_QuoteServices','ExactDiffBeetweenDate','one of the date is null');
            return 0;
        }

        Integer nbMonths = endDate.monthsBetween(startDate);
        
        // Nombre de mois entre premier jour du mois suivant startDate et premier jour du mois de endDate
        Date tmpStartDate = startDate.day() == 1 ? startDate : UM005_DateUtility.lastDateOfMonth(startDate).addDays(1);
        Date tmpEndDate = endDate.day() == 1 ? endDate : Date.newInstance(endDate.year(), endDate.month(), 1); 

        Decimal partOne = tmpStartDate.monthsBetween(tmpEndDate);

        //Nombre de mois (decimal) du nombre de jour de startDate si jour différent du premier jour du mois
        Decimal partTwo = startDate.day() / Date.daysInMonth(startDate.year(),startDate.month());

        //Nombre de mois (decimal) du nombre de jour de endDate si jour différent du premier jour du mois
        Decimal partThree = endDate.day() / Date.daysInMonth(endDate.year(),endDate.month());

        return  (partOne + partTwo + partThree);

    }

    // Update quoteline LPCR_CAUnitaire__c and LPCR_NombrePlace__c for B2B and B2C Micro scope of quote line
    @future
    public static void updateQuoteLineChiffreAffaire(Set<Id> quoteIds){

        PAD.log('SM008_QuoteServices','updateQuoteLineChiffreAffaire','quoteIds:'+ quoteIds);

        List<SBQQ__QuoteLine__c> tmpQuoteLineList = new List<SBQQ__QuoteLine__c>([SELECT Id, SBQQ__ProductCode__c, SBQQ__Quote__c, SBQQ__ChargeType__c, SBQQ__HasConsumptionSchedule__c,
                                                                                    SBQQ__Existing__c, LPCR_PriorQty__c, LPCR_DateDebut__c, LPCR_PrixUnitaire__c, LPCR_DateFin__c, 
                                                                                    SBQQ__PriorQuantity__c, SBQQ__Quantity__c
                                                                                    FROM SBQQ__QuoteLine__c where SBQQ__Quote__c in : quoteIds]);
        List<SBQQ__QuoteLine__c> quoteLineListToUpdate = new List<SBQQ__QuoteLine__c>();
        Map<Id, SBQQ__Quote__c> mapQuote = new Map<Id, SBQQ__Quote__c>([SELECT Id, SBQQ__Type__c, LPCR_TypeCreche__c, LPCR_DateDebut__c, LPCR_DateFin__c, SBQQ__LineItemCount__c, SBQQ__Ordered__c 
                                                                        FROM SBQQ__Quote__c where Id in : quoteIds]);

        for(SBQQ__QuoteLine__c quoteLine : tmpQuoteLineList){
                
            SBQQ__Quote__c quote = mapQuote.get(quoteLine.SBQQ__Quote__c);

            PAD.log('SM008_QuoteServices','updateQuoteLineChiffreAffaire','quote:'+ quote);
            PAD.log('SM008_QuoteServices','updateQuoteLineChiffreAffaire','quoteLine:'+ quoteLine);

            Decimal prixUnitaire = quoteLine.LPCR_PrixUnitaire__c;
            Decimal numberOfMonthInYear = 12;



            if (QuoteLine.SBQQ__ProductCode__c != null && QuoteLine.SBQQ__ProductCode__c.startsWith('BerceauMicro')) {

                prixUnitaire = QuoteLine.LPCR_MontantAnnuelForfaitMICRO__c;
                numberOfMonthInYear = QuoteLine.LPCR_Creche__r.LPCR_TypeMensualisation__c;
            

                if (quote.SBQQ__Type__c == 'Quote' && quote.LPCR_TypeCreche__c != 'MAC' && quote.SBQQ__LineItemCount__c > 0 && quote.SBQQ__Ordered__c == false) {

                    PAD.log('SM008_QuoteServices','updateQuoteLineChiffreAffaire','PART I');

                            if (quoteLine.SBQQ__ChargeType__c == 'Recurring' && quoteLine.SBQQ__HasConsumptionSchedule__c == false) { //then calculate CA field on the Quote Line 
                                
                                quoteLine.LPCR_NombrePlace__c = quoteLine.SBQQ__Quantity__c;
                                Date startDate1 = quoteLine.LPCR_DateDebut__c != null ? quoteLine.LPCR_DateDebut__c : quote.LPCR_DateDebut__c;
                                Date endDate1 = quoteLine.LPCR_DateFin__c != null ? quoteLine.LPCR_DateFin__c : quote.LPCR_DateFin__c;
                                
                                Decimal nbMonths = ExactDiffBeetweenDate(startDate1, endDate1);

                                if (nbMonths < 12)
                                    quoteLine.LPCR_CAUnitaire__c = (quoteLine.SBQQ__Quantity__c * prixUnitaire * nbMonths) / numberOfMonthInYear;

                                if (nbMonths >= 12)
                                    quoteLine.LPCR_CAUnitaire__c = (quoteLine.SBQQ__Quantity__c * prixUnitaire);

                                quoteLineListToUpdate.add(quoteLine);
                            }
                            else {
                                quoteLine.LPCR_CAUnitaire__c = 0; //for One time or Usage.
                                quoteLine.LPCR_NombrePlace__c = 0;
                                quoteLineListToUpdate.add(quoteLine);
                            }
                }
            

                if (quote.SBQQ__Type__c == 'Amendment' && quote.LPCR_TypeCreche__c != 'MAC' && quote.SBQQ__LineItemCount__c > 0 && quote.SBQQ__Ordered__c == false) {

                    PAD.log('SM008_QuoteServices','updateQuoteLineChiffreAffaire','PART II');

                    if (quoteLine.SBQQ__ChargeType__c == 'Recurring' && quoteLine.SBQQ__HasConsumptionSchedule__c == false) { //then populate CA field on the Quote Line  

                        Date startDate2 = quoteLine.SBQQ__StartDate__c != null ? quoteLine.SBQQ__StartDate__c : quote.SBQQ__StartDate__c;                                                                                                                                     
                        Date endDate2 = quoteLine.LPCR_DateFin__c != null ? quoteLine.LPCR_DateFin__c : quote.LPCR_DateFin__c;                                                                                                                                               
                        Date oneYearMark = quoteLine.LPCR_DateDebut__c != null ? quoteLine.LPCR_DateDebut__c.addYears(1) : quote.LPCR_DateDebut__c.addYears(1);  
                        
                        Decimal remainingMonths = ExactDiffBeetweenDate(startDate2, endDate2);
                        Decimal canceledMonths = ExactDiffBeetweenDate(startDate2, oneYearMark);                                                              

                        if (quoteLine.SBQQ__NetTotal__c == 0) { //(QL with no change in term of price nor qty)

                            quoteLine.LPCR_CAUnitaire__c = 0;
                            quoteLine.LPCR_NombrePlace__c = 0;
                        }
                        else if (quoteLine.SBQQ__Existing__c == true && quoteLine.SBQQ__PriorQuantity__c < quoteLine.SBQQ__Quantity__c) { //(original QL with increase of qty)

                            quoteLine.LPCR_NombrePlace__c = quoteLine.SBQQ__EffectiveQuantity__c;

                            if (remainingMonths < 12)
                                quoteLine.LPCR_CAUnitaire__c = (quoteLine.SBQQ__EffectiveQuantity__c * prixUnitaire * remainingMonths ) / numberOfMonthInYear;
                            if (remainingMonths >= 12)
                                quoteLine.LPCR_CAUnitaire__c = (quoteLine.SBQQ__EffectiveQuantity__c * prixUnitaire);
                        }    
                        else if (quoteLine.SBQQ__Existing__c == true && quoteLine.SBQQ__PriorQuantity__c >= quoteLine.SBQQ__Quantity__c) { //(original QL with decrease of qty)

                            if  (startDate2 >= oneYearMark) {// ( amendment after one year mark)
                                quoteLine.LPCR_CAUnitaire__c = 0;
                                quoteLine.LPCR_NombrePlace__c = 0;
                            }
                            else if (startDate2 < oneYearMark) { // ( amendment before one year mark)
                                quoteLine.LPCR_CAUnitaire__c = (quoteLine.SBQQ__EffectiveQuantity__c * prixUnitaire * canceledMonths) / numberOfMonthInYear;
                                quoteLine.LPCR_NombrePlace__c = quoteLine.SBQQ__EffectiveQuantity__c;
                            }
                        }
                        else if (quoteLine.LPCR_Clone__c == true && quoteLine.LPCR_PriorQty__c < quoteLine.SBQQ__Quantity__c) { //(Cloned QL with increase QTY)

                            if  (startDate2 >= oneYearMark) { // ( amendment after one year mark)

                                quoteLine.LPCR_NombrePlace__c = quoteLine.SBQQ__Quantity__c - quoteLine.LPCR_PriorQty__c;
                                
                                if (remainingMonths < 12)
                                    quoteLine.LPCR_CAUnitaire__c = ((quoteLine.SBQQ__Quantity__c - quoteLine.LPCR_PriorQty__c)  * prixUnitaire  * remainingMonths) / numberOfMonthInYear;
                                if (remainingMonths >= 12)
                                    quoteLine.LPCR_CAUnitaire__c = (quoteLine.SBQQ__Quantity__c - quoteLine.LPCR_PriorQty__c) * prixUnitaire;
                            }
                            if  (startDate2 < oneYearMark) { // ( amendment before one year mark)

                                quoteLine.LPCR_NombrePlace__c = quoteLine.SBQQ__Quantity__c; 
                                
                                if (remainingMonths < 12)
                                    quoteLine.LPCR_CAUnitaire__c = (quoteLine.SBQQ__Quantity__c * prixUnitaire  * remainingMonths) / numberOfMonthInYear;
                                if (remainingMonths >= 12)
                                    quoteLine.LPCR_CAUnitaire__c = (quoteLine.SBQQ__Quantity__c * prixUnitaire);
                            }
                        }
                        else if (quoteLine.LPCR_Clone__c == true && quoteLine.LPCR_PriorQty__c >= quoteLine.SBQQ__Quantity__c) { //(Cloned QL with decrease QTY)

                            if  (startDate2 >= oneYearMark) { // ( amendment after one year mark)
                                    quoteLine.LPCR_CAUnitaire__c = 0;
                                    quoteLine.LPCR_NombrePlace__c = 0;
                            }
                            if  (startDate2 < oneYearMark) { // ( amendment before one year mark)
                                
                                quoteLine.LPCR_NombrePlace__c = quoteLine.SBQQ__Quantity__c;
                                
                                if (remainingMonths < 12)
                                    quoteLine.LPCR_CAUnitaire__c = (quoteLine.SBQQ__Quantity__c * prixUnitaire  * remainingMonths) / numberOfMonthInYear;
                                if (remainingMonths >= 12)
                                    quoteLine.LPCR_CAUnitaire__c = (quoteLine.SBQQ__Quantity__c * prixUnitaire);
                            }
                        }
                        else if (quoteLine.LPCR_Clone__c == false && quoteLine.SBQQ__Existing__c == false) { //(brand new QL)

                            quoteLine.LPCR_NombrePlace__c = quoteLine.SBQQ__Quantity__c;

                            if (remainingMonths < 12)
                                quoteLine.LPCR_CAUnitaire__c = (quoteLine.SBQQ__Quantity__c * prixUnitaire  * remainingMonths) / numberOfMonthInYear;
                            if (remainingMonths >= 12)
                                quoteLine.LPCR_CAUnitaire__c = (quoteLine.SBQQ__Quantity__c * prixUnitaire);
                        }

                        quoteLineListToUpdate.add(quoteLine);
                    }
                    else {
                        quoteLine.LPCR_CAUnitaire__c = 0;
                        quoteLine.LPCR_NombrePlace__c = 0;
                        quoteLineListToUpdate.add(quoteLine);
                    }
                }
            }        
        }

        if(quoteLineListToUpdate.size() > 0) {
            
            PAD.log('SM008_QuoteServices','updateQuoteLineChiffreAffaire','PART III - quoteLineListToUpdate.size():' + quoteLineListToUpdate.size());

            SBQQ.TriggerControl.disable();
            try {
                update quoteLineListToUpdate; 
            } finally {
                SBQQ.TriggerControl.enable();
            }
        } 
    }
}
