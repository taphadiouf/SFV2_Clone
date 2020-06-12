/**
* @author Hanae MAKBOUB
* @date 15/05/2020
* @description Service class for LPCR_ModificationEntrante__c
*/
public with sharing class SM013_ModificationEntranteServices {
    public static List<SBQQ__Quote__c> updateQuotesFromModifEntrantes(List<LPCR_ModificationEntrante__c> ModifEntrantesList){
        List<LPCR_ModificationEntrante__c> evtModifEntrantesList = EM016_ModificationEntranteEntity.getModifEntranteById(ModifEntrantesList); 
        Map<Id,LPCR_ModificationEntrante__c> mapDevisModifictionEntrante = new Map<Id,LPCR_ModificationEntrante__c>();
        for(LPCR_ModificationEntrante__c eachModification : evtModifEntrantesList){
            mapDevisModifictionEntrante.put(eachModification.LPCR_Devis__c , eachModification);
        }
        List<SBQQ__Quote__c> quotesToUpdate = EM006_QuoteEntity.getQuoteModifById(mapDevisModifictionEntrante.keySet());
        for(SBQQ__Quote__c eachQuote : quotesToUpdate ){
            eachQuote.SBQQ__Status__c = System.Label.LPCR_QuoteValide ;
        }
        update quotesToUpdate;
        return quotesToUpdate;
    }
    
    // added by saurabh    
    public static void sendAgreementFromModifEntrantes(List<LPCR_ModificationEntrante__c> ModifEntrantesList, Map<Id, LPCR_ModificationEntrante__c> oldModificationsentrantesMap){
        Map<String,LPCR_Type_Evenement_Intranet__mdt> mapTypeEvenement = new Map<String,LPCR_Type_Evenement_Intranet__mdt>();
        Map<String, String> mapAgreementTemplate = new Map<String, String>();
        Map<String, String> mapSendAgreementTemplate = new Map<String,String>();
        
        for(LPCR_Type_Evenement_Intranet__mdt eachTypeEvenement : [SELECT Id, DeveloperName, MasterLabel, Label, QualifiedApiName, LPCR_Processus__c, LPCR_Validation__c, LPCR_ContratAccueil__c, LPCR_Annexe2__c, LPCR_Annexe3__c FROM LPCR_Type_Evenement_Intranet__mdt]){
            mapTypeEvenement.put(eachTypeEvenement.MasterLabel, eachTypeEvenement);
        }        
        
        for(LPCR_AdobeAgreementTemplate__mdt tem : [SELECT ID, DeveloperName, LPCR_Agreement_Template_Name__c, LPCR_Agreeement_Template_Id__c FROM LPCR_AdobeAgreementTemplate__mdt]){
            mapAgreementTemplate.put(tem.DeveloperName, tem.LPCR_Agreeement_Template_Id__c);
        }
        
        for(LPCR_ModificationEntrante__c eachModification : ModifEntrantesList){
            if(eachModification.LPCR_Evenement__c != null && eachModification.LPCR_EtatTraitement__c != oldModificationsentrantesMap.get(eachModification.Id).LPCR_EtatTraitement__c){
                if(mapTypeEvenement.containsKey(eachModification.LPCR_Evenement__c)){
                    LPCR_Type_Evenement_Intranet__mdt typeEvenement = mapTypeEvenement.get(eachModification.LPCR_Evenement__c);
                    
                    if(typeEvenement.LPCR_ContratAccueil__c && typeEvenement.LPCR_Annexe2__c){
                        //If only LPCR_ContratAccueil_c and LPCR_Annexe2_c are both checked then send agreement template CONTRAT_ET_ANNEXE2
                        if(mapAgreementTemplate.containsKey('CONTRAT_ET_ANNEXE2')){
                            mapSendAgreementTemplate.put(eachModification.LPCR_Compte__c, mapAgreementTemplate.get('CONTRAT_ET_ANNEXE2'));
                        }	                        
                    }else{
                        if(typeEvenement.LPCR_Annexe2__c){
                            // if only LPCR_Annexe2__c is checked then send agreement template ANNEXE2
                            if(mapAgreementTemplate.containsKey('CONTRAT_ANNEXE2')){
                                mapSendAgreementTemplate.put(eachModification.LPCR_Compte__c, mapAgreementTemplate.get('CONTRAT_ANNEXE2'));
                            }
                        }else if(typeEvenement.LPCR_Annexe3__c){
                            // if only LPCR_Annexe3__c is checked then send agreement template ANNEXE3
                            if(mapAgreementTemplate.containsKey('CONTRAT_ANNEXE3')){
                                mapSendAgreementTemplate.put(eachModification.LPCR_Compte__c, mapAgreementTemplate.get('CONTRAT_ANNEXE3'));
                            }
                        }
                    }
                }
            }
        }
        if(mapSendAgreementTemplate.size() > 0){
            sendAgreement(mapSendAgreementTemplate);
        }
        
    }
    
    // added by saurabh
    @future (callout=true)
    public static void sendAgreement(Map<String, String> mapSendAgreementTemplate) {
        try {
            for(String key : mapSendAgreementTemplate.keySet()){
                Id tmpIdAggree = echosign_dev1.AgreementTemplateService.load( mapSendAgreementTemplate.get(key) , key);
                echosign_dev1.EchoSignApiService.SendDocumentResult tmp = echosign_dev1.EchoSignApiService.sendDocument(tmpIdAggree);  
            }
            
        } catch (Exception E) { System.debug('Exception: ' + e.getStackTraceString());}       
    }   
    
}