/**
* @author Hanae MAKBOUB
* @date 15/05/2020
* @description Service class for LPCR_ModificationEntrante__c
*/
public with sharing class SM022_ModificationEntranteServices {
    public static List<SBQQ__Quote__c> updateQuotesFromModifEntrantes(List<LPCR_ModificationEntrante__c> ModifEntrantesList){
        List<LPCR_ModificationEntrante__c> evtModifEntrantesList = EM016_ModificationEntranteEntity.getModifEntranteById(ModifEntrantesList); 
        Map<Id,LPCR_ModificationEntrante__c> mapDevisModifictionEntrante = new Map<Id,LPCR_ModificationEntrante__c>();
        for(LPCR_ModificationEntrante__c eachModification : evtModifEntrantesList){
            mapDevisModifictionEntrante.put(eachModification.LPCR_Contract__r.SBQQ__Quote__c , eachModification);
        }
        List<SBQQ__Quote__c> quotesToUpdate = EM006_QuoteEntity.getQuoteModifById(mapDevisModifictionEntrante.keySet());
        for(SBQQ__Quote__c eachQuote : quotesToUpdate ){
            eachQuote.SBQQ__Status__c = System.Label.LPCR_QuoteValide ;
        }
        update quotesToUpdate;
        return quotesToUpdate;
    }
    
    // added by saurabh updated by Ayoub IS-1273
    public static void sendAgreementFromModifEntrantes(List<LPCR_ModificationEntrante__c> ModifEntrantesList, Map<Id, LPCR_ModificationEntrante__c> oldModificationsentrantesMap){
        Map<String,LPCR_Type_Evenement_Intranet__mdt> mapTypeEvenement = new Map<String,LPCR_Type_Evenement_Intranet__mdt>();
        Map<String, String> mapAgreementTemplate = new Map<String, String>();
        Map<String, String> mapSendAgreementTemplate = new Map<String,String>();
        
        Set<Id> modifEntranteIds = UM003_TypeManager.getIdsOfListObjects(ModifEntrantesList);
        Map<Id,LPCR_Type_Evenement_Intranet__mdt> mapModEentIdWithTypeEve = new Map<Id,LPCR_Type_Evenement_Intranet__mdt>();
        Map<Id,LPCR_ModificationEntrante__c> mapModificationEntrante = new Map<Id,LPCR_ModificationEntrante__c>([SELECT Id , LPCR_Contract__r.OwnerId ,LPCR_Contract__r.LPCR_Creche__c,LPCR_Contract__r.Account.Email__c  From LPCR_ModificationEntrante__c WHERE Id IN :modifEntranteIds ]);
        
        for(LPCR_Type_Evenement_Intranet__mdt eachTypeEvenement : [SELECT Id, LPCR_ReglementCreche__c ,DeveloperName, MasterLabel, Label, QualifiedApiName, LPCR_Processus__c, LPCR_Validation__c, LPCR_ContratAccueil__c, LPCR_Annexe2__c, LPCR_Annexe3__c FROM LPCR_Type_Evenement_Intranet__mdt]){
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
                            if(typeEvenement.LPCR_ReglementCreche__c)mapModEentIdWithTypeEve.put(eachModification.Id,typeEvenement);
                        }	                        
                    }else{
                        if(typeEvenement.LPCR_Annexe2__c){
                            // if only LPCR_Annexe2__c is checked then send agreement template ANNEXE2
                            if(mapAgreementTemplate.containsKey('CONTRAT_ANNEXE2')){
                                mapSendAgreementTemplate.put(eachModification.LPCR_Compte__c, mapAgreementTemplate.get('CONTRAT_ANNEXE2'));
                                if(typeEvenement.LPCR_ReglementCreche__c)mapModEentIdWithTypeEve.put(eachModification.Id,typeEvenement);                            }
                        }else if(typeEvenement.LPCR_Annexe3__c){
                            // if only LPCR_Annexe3__c is checked then send agreement template ANNEXE3
                            if(mapAgreementTemplate.containsKey('CONTRAT_ANNEXE3')){
                                mapSendAgreementTemplate.put(eachModification.LPCR_Compte__c, mapAgreementTemplate.get('CONTRAT_ANNEXE3'));
                                if(typeEvenement.LPCR_ReglementCreche__c)mapModEentIdWithTypeEve.put(eachModification.Id,typeEvenement);                            }
                        }
                    }
                }
            }
        }
        //IS-1273
        final String REGLEMENT_FONCTIONNEMENT_CRECHE_NAME = 'Reglement Fonctionnement creche';
        final String REGLEMENT_FONCTIONNEMENT_CRECHE_LABEL ='Règlement Fonctionnement Crèche';
        final String EMAIL_BODY ='Bonjour, Veuillez trouvez les règle de fonctionnement de votre crèche';
        final String SEND_FROM_EMAIL ='lpcr@lpcr.fr';
        if(mapSendAgreementTemplate.size() > 0){
            sendAgreement(mapSendAgreementTemplate);
            if(UM003_TypeManager.isNotNullAndNotEmpty(mapModEentIdWithTypeEve.values())){
                for(Id eachModEnt : mapModEentIdWithTypeEve.keySet()){
                    SM019_DocumentList_Callout.getDocumentListFutureCallout(SEND_FROM_EMAIL,
                                                                            mapModificationEntrante.get(eachModEnt).LPCR_Contract__r.Account.Email__c,
                                                                            REGLEMENT_FONCTIONNEMENT_CRECHE_LABEL,
                                                                            EMAIL_BODY,
                                                                            mapModificationEntrante.get(eachModEnt).LPCR_Contract__r.OwnerId,
                                                                            REGLEMENT_FONCTIONNEMENT_CRECHE_NAME
                                                                           );
                    
                }
            }
        }
        
    }
    
    // added by saurabh
    public static void sendAgreement(Map<String, String> mapSendAgreementTemplate) {
        try {
            for(String key : mapSendAgreementTemplate.keySet()){
                Id tmpIdAggree = echosign_dev1.AgreementTemplateService.load( mapSendAgreementTemplate.get(key) , key);
                echosign_dev1.EchoSignApiService.SendDocumentResult tmp = echosign_dev1.EchoSignApiService.sendDocument(tmpIdAggree);  
            }
            
        } catch (Exception E) { 
            PAD.log('SM022_ModificationEntranteServices', 'sendAgreement', 'Exception: ' + e.getStackTraceString());
        }       
    }   
    
    
    // added by saurabh
    public static Set<Id> updateQuotesFromModifEntrantesBatch(List<LPCR_ModificationEntrante__c> ModifEntrantesList){
        
        Date firstDayOfCurrentMonthDate = Date.newInstance(Date.today().Year(), Date.today().month() ,1) ;
        Date firstDayOfNextMonthDate = Date.newInstance(Date.today().Year(), Date.today().month()+1 ,1) ;
        Date lastDayOfCurrentMonthDate=Date.newInstance(Date.today().Year(), Date.today().month() , Date.daysInMonth(Date.today().year(), Date.today().month())) ;
        
        Set<String> compteIds = UM003_TypeManager.getFieldsOfListObjects(ModifEntrantesList, 'LPCR_Compte__c');
        Set<String> contactIds = UM003_TypeManager.getFieldsOfListObjects(ModifEntrantesList, 'LPCR_Contact__c');
        Set<String> modifEntrantesIds = UM003_TypeManager.getFieldsOfListObjects(ModifEntrantesList, 'Id');
        Set<String> contractIds = UM003_TypeManager.getFieldsOfListObjects(ModifEntrantesList, 'LPCR_Contract__c');
        Set<Id> newQuoteIds = new Set<Id>();

        Map<Id,LPCR_RessourceFamille__c> ressourceFamilleMap = new Map<Id,LPCR_RessourceFamille__c>();
        Map<Id,Contact> modifEntrantesContactMap = new Map<Id,Contact>();
        Map<Id,Contract> modifEntrantesContractMap = new Map<Id,Contract>();
        
        List<Contact> allContactUpdateList = new List<Contact>();
        List<Contract> allContractUpdateList = new List<Contract>();
        List<Account> allAccountUpdateList = new List<Account>();
        List<blng__Usage__c> allUsageList = new List<blng__Usage__c>();
        List<blng__Invoice__c> allInvoiceList = new List<blng__Invoice__c>();
        List<LPCR_RessourceFamille__c> listRessourceFamilleToInsert = new List<LPCR_RessourceFamille__c> ();
        List<SBQQ__QuoteLine__c> allListCloneQuoteLine = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__Quote__c> listQuoteForUpdate = new List<SBQQ__Quote__c>();
        Map<String,SBQQ__Quote__c> mapOfQuoteForUpdate = new Map<String,SBQQ__Quote__c>();
        Map<String,List<LPCR_DetailModificationPlanning__c>> detailModifPlanningMap = new Map<String,List<LPCR_DetailModificationPlanning__c>>();
        List<LPCR_Planning__c> allPlanningInsertList = new List<LPCR_Planning__c>();
        Map<String, List<LPCR_PlanningPrevisionnel__c>> allPlanningPrevisionnelInsertMap = new Map<String, List<LPCR_PlanningPrevisionnel__c>>();

        Map<String, String> evenementMap =  getPicklistLabelByAPI();

        for(LPCR_RessourceFamille__c eachRessourceFamille : [SELECT Id, Name, RecordTypeId, LPCR_Active__c, LPCR_AnneeRevenu__c, LPCR_BaremeCaf__c, LPCR_Commentaire__c, LPCR_CompteFamille__c,LPCR_CompteFamille__r.Name, LPCR_ContactEnfant__c, LPCR_DateDebut__c, LPCR_DateFin__c, LPCR_DureeContratJour__c, LPCR_FinContrat__c, LPCR_IdExterne_BaremeCaf__c, LPCR_IdExterne_CompteFamille__c, LPCR_IdExterne_ContactEnfant__c, LPCR_IdExterne_Creche__c, LPCR_NombreEnfantHandicape__c, LPCR_NombreEnfants__c, LPCR_RessourcePlafond__c, LPCR_RessourcesPrixPlancher__c, LPCR_RevenusFamille__c, LPCR_SourceDonnees__c, LPCR_StatutValidation__c, LPCR_TauxEffort__c, LPCR_TypeCreche__c, LPCR_TypeMensualisation__c, LPCR_TypePlanning__c, LPCR_creche__c FROM LPCR_RessourceFamille__c WHERE LPCR_CompteFamille__c IN : compteIds AND LPCR_Active__c = true AND LPCR_ContactEnfant__c IN : contactIds]){
            if(eachRessourceFamille.LPCR_ContactEnfant__c != null){
                ressourceFamilleMap.put(eachRessourceFamille.LPCR_ContactEnfant__c, eachRessourceFamille);
            }
        }
        for(Contact contact : [SELECT Id,FirstName, LastName,LPCR_NumeroAllocataire__c, LPCR_AutoriteParentale__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry FROM Contact WHERE Id IN: contactIds]){
            modifEntrantesContactMap.put(contact.Id, contact);
        }
        for(Contract contr : [SELECT Id, EndDate,SBQQ__Quote__c FROM Contract WHERE Id IN: contractIds]){
            modifEntrantesContractMap.put(contr.Id,contr);
        }
        System.debug('size of modifEntrantesContractMap : '+ modifEntrantesContractMap.size());
        
        detailModifPlanningMap = SM022_ModificationEntranteServices.getDetailModificationPlanningList(modifEntrantesIds,'Modification_Type_Planning');
        
        for(LPCR_ModificationEntrante__c eachModifEntrante : ModifEntrantesList){
            if('Modification_Situation_Handicape_Enfant'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Quantite__c != null && eachModifEntrante.LPCR_Compte__c != null && eachModifEntrante.LPCR_DateEffet__c != null){
                if(ressourceFamilleMap.containsKey(eachModifEntrante.LPCR_Contact__c)){
                    // 1) Update previous LPCR_FamilyRessource_c with an effective end date (LPCR_DateFin_c) corresponding to last day of current month
                    // 2) Insert a LPCR_FamilyRessource__c record dwith effective start date as 1st of next month
                    LPCR_RessourceFamille__c oldRessourceFamille = ressourceFamilleMap.get(eachModifEntrante.LPCR_Contact__c);
                    LPCR_RessourceFamille__c ressourceFamilleToInsert = createNewRessourceFamille(oldRessourceFamille);
                    ressourceFamilleToInsert.LPCR_NombreEnfantHandicape__c = eachModifEntrante.LPCR_Quantite__c;
                    ressourceFamilleToInsert.LPCR_CompteFamille__c = eachModifEntrante.LPCR_Compte__c;
                    oldRessourceFamille.LPCR_DateFin__c = lastDayOfCurrentMonthDate;
                    listRessourceFamilleToInsert.add(oldRessourceFamille);
                    listRessourceFamilleToInsert.add(ressourceFamilleToInsert);
                    
                    WRP001_QuoteModel quoteModel = executeContractAmenderAPI(eachModifEntrante.LPCR_Contract__c);
                    cloneAndCancelSubscriptions(quoteModel);
                    
                    SBQQ__Quote__c quote = quoteModel.record;
                    quote.LPCR_LaunchRecalculation__c = true;
                    mapOfQuoteForUpdate.put(quote.id,quote);
                    eachModifEntrante.LPCR_EtatTraitement__c = true;    
                }
            }else if('Modification_Nombre_Enfant_Fratrie'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Quantite__c != null && eachModifEntrante.LPCR_Compte__c != null && eachModifEntrante.LPCR_DateEffet__c != null){
                System.debug('Event = Modification_Nombre_Enfant_Fratrie | '+ eachModifEntrante.Id);
                if(ressourceFamilleMap.containsKey(eachModifEntrante.LPCR_Contact__c)){
                    LPCR_RessourceFamille__c oldRessourceFamille = ressourceFamilleMap.get(eachModifEntrante.LPCR_Contact__c);
                    LPCR_RessourceFamille__c ressourceFamilleToInsert = createNewRessourceFamille(oldRessourceFamille);
                    ressourceFamilleToInsert.LPCR_NombreEnfants__c = eachModifEntrante.LPCR_Quantite__c;
                    ressourceFamilleToInsert.LPCR_CompteFamille__c = eachModifEntrante.LPCR_Compte__c;
                    oldRessourceFamille.LPCR_DateFin__c = lastDayOfCurrentMonthDate;
                    listRessourceFamilleToInsert.add(oldRessourceFamille);
                    listRessourceFamilleToInsert.add(ressourceFamilleToInsert);
                    
                    WRP001_QuoteModel quoteModel = executeContractAmenderAPI(eachModifEntrante.LPCR_Contract__c);
                    cloneAndCancelSubscriptions(quoteModel);
                    
                    SBQQ__Quote__c quote = quoteModel.record;
                    quote.LPCR_LaunchRecalculation__c = true;
                    mapOfQuoteForUpdate.put(quote.id,quote);
                    eachModifEntrante.LPCR_EtatTraitement__c = true;    
                }
            }else if('Modification_Montant_Ressource'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_RessourceFamille__c != null && eachModifEntrante.LPCR_Compte__c != null ){
                System.debug('Event = Modification_Montant_Ressource | '+ eachModifEntrante.Id);
                if(ressourceFamilleMap.containsKey(eachModifEntrante.LPCR_Contact__c)){
                    // 1) Update previous LPCR_FamilyRessource_c with an effective end date (LPCR_DateFin_c) corresponding to last day of current month
                    // 2) Insert a LPCR_FamilyRessource__c record dwith effective start date as 1st of next month
                    LPCR_RessourceFamille__c oldRessourceFamille = ressourceFamilleMap.get(eachModifEntrante.LPCR_Contact__c);
                    LPCR_RessourceFamille__c ressourceFamilleToInsert = createNewRessourceFamille(oldRessourceFamille);
                    ressourceFamilleToInsert.LPCR_RevenusFamille__c = eachModifEntrante.LPCR_RessourceFamille__c;
                    ressourceFamilleToInsert.LPCR_CompteFamille__c = eachModifEntrante.LPCR_Compte__c;
                    oldRessourceFamille.LPCR_DateFin__c = lastDayOfCurrentMonthDate;
                    listRessourceFamilleToInsert.add(oldRessourceFamille);
                    listRessourceFamilleToInsert.add(ressourceFamilleToInsert);
                    
                    WRP001_QuoteModel quoteModel = executeContractAmenderAPI(eachModifEntrante.LPCR_Contract__c);
                    cloneAndCancelSubscriptions(quoteModel);
                    
                    SBQQ__Quote__c quote = quoteModel.record;
                    quote.LPCR_LaunchRecalculation__c = true;
                    mapOfQuoteForUpdate.put(quote.id,quote);
                    eachModifEntrante.LPCR_EtatTraitement__c = true;    
                }
            }else if('Modification_Type_Planning'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Contract__c != null && eachModifEntrante.LPCR_TypePlanning__c != null && eachModifEntrante.LPCR_Compte__c != null){
                if(ressourceFamilleMap.containsKey(eachModifEntrante.LPCR_Contact__c)){
                    
                    WRP001_QuoteModel quoteModel = executeContractAmenderAPI(eachModifEntrante.LPCR_Contract__c);
                    
                    if(detailModifPlanningMap.containsKey(eachModifEntrante.Id)){
                        LPCR_Planning__c tmpPlanning = new LPCR_Planning__c();
                        tmpPlanning.LPCR_Devis__c = quoteModel.record.Id;
                        tmpPlanning.LPCR_TypePlanning__c = eachModifEntrante.LPCR_TypePlanning__c;
                        allPlanningInsertList.add(tmpPlanning);
                        
                        allPlanningPrevisionnelInsertMap.put(quoteModel.record.Id, new List<LPCR_PlanningPrevisionnel__c>());
                        
                        for(LPCR_DetailModificationPlanning__c eachDetailModifPlan : detailModifPlanningMap.get(eachModifEntrante.Id)){
                            LPCR_PlanningPrevisionnel__c pl = new LPCR_PlanningPrevisionnel__c(
                                LPCR_Contrat__c  =quoteModel.record.Id,
                                LPCR_HeureDebutLundi__c = eachDetailModifPlan.LPCR_HeureDebutLundi__c,
                                LPCR_HeureFinLundi__c   = eachDetailModifPlan.LPCR_HeureFinLundi__c,
                                LPCR_HeureDebutMardi__c = eachDetailModifPlan.LPCR_HeureDebutMardi__c,
                                LPCR_HeureFinMardi__c  = eachDetailModifPlan.LPCR_HeureFinMardi__c,
                                LPCR_HeureDebutMercredi__c = eachDetailModifPlan.LPCR_HeureDebutMercredi__c,
                                LPCR_HeureFinMercredi__c = eachDetailModifPlan.LPCR_HeureFinMercredi__c,
                                LPCR_HeureDebutJeudi__c = eachDetailModifPlan.LPCR_HeureDebutJeudi__c,
                                LPCR_HeureFinJeudi__c = eachDetailModifPlan.LPCR_HeureFinJeudi__c,
                                LPCR_HeureDebutVendredi__c = eachDetailModifPlan.LPCR_HeureDebutVendredi__c,
                                LPCR_HeureFinVendredi__c = eachDetailModifPlan.LPCR_HeureFinVendredi__c);
                            allPlanningPrevisionnelInsertMap.get(quoteModel.record.Id).add(pl);
                        }
                    }
                    cloneAndCancelSubscriptions(quoteModel);
                    
                    SBQQ__Quote__c quote = quoteModel.record;
                    quote.SBQQ__Status__c = 'Brouillon';
                    mapOfQuoteForUpdate.put(quote.id,quote);
                    eachModifEntrante.LPCR_EtatTraitement__c = true;
                }
            }else if('Modification_Nombre_Jour_Conge'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Quantite__c != null && eachModifEntrante.LPCR_Contract__c != null ){
                WRP001_QuoteModel quoteModel = executeContractAmenderAPI(eachModifEntrante.LPCR_Contract__c);
                cloneAndCancelSubscriptions(quoteModel);
                
                SBQQ__Quote__c quote = quoteModel.record;
                quote.LPCR_CongesJours__c = eachModifEntrante.LPCR_Quantite__c;
                quote.LPCR_LaunchRecalculation__c = true;
                mapOfQuoteForUpdate.put(quote.id,quote);
                eachModifEntrante.LPCR_EtatTraitement__c = true;                
            }else if('Date_Fin_Contrat'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Contract__c != null && eachModifEntrante.LPCR_Compte__c != null && eachModifEntrante.LPCR_DateEffet__c != null){
                if(ressourceFamilleMap.containsKey(eachModifEntrante.LPCR_Contact__c)){
                    LPCR_RessourceFamille__c oldRessourceFamille = ressourceFamilleMap.get(eachModifEntrante.LPCR_Contact__c);
                    oldRessourceFamille.LPCR_DateFin__c = lastDayOfCurrentMonthDate; 
                    Date endDate = modifEntrantesContractMap.get(eachModifEntrante.LPCR_Contract__c).EndDate;
                    oldRessourceFamille.LPCR_FinContrat__c = endDate; 
                    listRessourceFamilleToInsert.add(oldRessourceFamille);
                    
                    WRP001_QuoteModel quoteModel = executeContractAmenderAPI(eachModifEntrante.LPCR_Contract__c);
                    
                    List<SBQQ__QuoteLine__c> listCloneQuoteLine = new List<SBQQ__QuoteLine__c>();
                    for(WRP002_QuoteLineModel eachQuoteLine : quoteModel.lineItems){
                        SBQQ__QuoteLine__c updateQLI = eachQuoteLine.record;
                        updateQLI.SBQQ__Quantity__c = 0;
                        listCloneQuoteLine.add(updateQLI);
                    }
                    if(listCloneQuoteLine.size() > 0){
                        allListCloneQuoteLine.addAll(listCloneQuoteLine);
                    }                    
                    
                    SBQQ__Quote__c quote = quoteModel.record;
                    quote.SBQQ__StartDate__c = eachModifEntrante.LPCR_DateEffet__c; //endDate ;
                    quote.LPCR_DateResiliation__c = eachModifEntrante.LPCR_DateEffet__c;
                    quote.LPCR_TypeAvenant__c = 'Résiliation';
                    quote.SBQQ__Status__c = 'Brouillon';
                    mapOfQuoteForUpdate.put(quote.id,quote);
                    eachModifEntrante.LPCR_EtatTraitement__c = true;
                }
            }else if('Modification_Type_Accueil'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Contract__c != null && eachModifEntrante.LPCR_TypeAccueil__c != null){
                WRP001_QuoteModel quoteModel = executeContractAmenderAPI(eachModifEntrante.LPCR_Contract__c);
                cloneAndCancelSubscriptions(quoteModel);
                
                SBQQ__Quote__c quote = quoteModel.record;
                quote.LPCR_LaunchRecalculation__c = true;
                quote.SBQQ__Status__c = 'Brouillon';
                mapOfQuoteForUpdate.put(quote.id,quote);
                eachModifEntrante.LPCR_EtatTraitement__c = true;
            }else if('Modification_Adresse_Contact_Parent'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Contact__c != null ){
                if(modifEntrantesContactMap.containsKey(eachModifEntrante.LPCR_Contact__c)){
                    Contact updateContact = modifEntrantesContactMap.get(eachModifEntrante.LPCR_Contact__c);
                    updateContact.MailingStreet = eachModifEntrante.LPCR_Rue__c;
                    updateContact.MailingCity = eachModifEntrante.LPCR_Ville__c;
                    updateContact.MailingCountry = eachModifEntrante.LPCR_Pays__c;
                    updateContact.MailingPostalCode = eachModifEntrante.LPCR_CodePostal__c;
                    allContactUpdateList.add(updateContact);
                    eachModifEntrante.LPCR_EtatTraitement__c = true;
                }
            }else if('Modification_Autorite_Parentale'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Contact__c != null && eachModifEntrante.LPCR_OuiNon__c != null ){
                Contact updateContact = new Contact(Id = eachModifEntrante.LPCR_Contact__c);
                updateContact.LPCR_AutoriteParentale__c = eachModifEntrante.LPCR_OuiNon__c;
                allContactUpdateList.add(updateContact);
                eachModifEntrante.LPCR_EtatTraitement__c = true;
            }else if('Modification_Numero_Allocataire'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Contact__c != null && eachModifEntrante.LPCR_IDUnique__c != null ){
                Contact updateContact = new Contact(Id = eachModifEntrante.LPCR_Contact__c);
                updateContact.LPCR_NumeroAllocataire__c = eachModifEntrante.LPCR_IDUnique__c;
                allContactUpdateList.add(updateContact);
                eachModifEntrante.LPCR_EtatTraitement__c = true;
            }else if('Date_Naissance_Enfant'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Contact__c != null && eachModifEntrante.LPCR_Date__c != null ){
                Contact updateContact = new Contact(Id = eachModifEntrante.LPCR_Contact__c);
                updateContact.Birthdate = eachModifEntrante.LPCR_Date__c;
                allContactUpdateList.add(updateContact);
                eachModifEntrante.LPCR_EtatTraitement__c = true;
            }else if('Modification_Section'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Contract__c != null && eachModifEntrante.LPCR_Section__c != null ){
                Contract updateContract = new Contract(Id = eachModifEntrante.LPCR_Contract__c);
                updateContract.LPCR_Section__c = eachModifEntrante.LPCR_Section__c;
                allContractUpdateList.add(updateContract);
                eachModifEntrante.LPCR_EtatTraitement__c = true;
            }else if('Modification_Mode_Garde'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Compte__c != null && eachModifEntrante.LPCR_Garde__c != null ){
                Account updateAccount = new Account(Id = eachModifEntrante.LPCR_Compte__c);
                updateAccount.LPCR_SituationFamiliale__c = eachModifEntrante.LPCR_SituationFamiliale__c;
                updateAccount.LPCR_Garde__c = eachModifEntrante.LPCR_Garde__c;
                allAccountUpdateList.add(updateAccount);
                eachModifEntrante.LPCR_EtatTraitement__c = true;
            }else if('Modification_Situation_Familiale'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Compte__c != null && eachModifEntrante.LPCR_SituationFamiliale__c != null ){
                Account updateAccount = new Account(Id = eachModifEntrante.LPCR_Compte__c);
                updateAccount.LPCR_SituationFamiliale__c = eachModifEntrante.LPCR_SituationFamiliale__c;
                updateAccount.LPCR_Garde__c = eachModifEntrante.LPCR_Garde__c;
                allAccountUpdateList.add(updateAccount);
                eachModifEntrante.LPCR_EtatTraitement__c = true;
            }else if('Modification_Facturation_Adaptation'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Contract__c != null && eachModifEntrante.LPCR_Quantite__c != null ){
                blng__Usage__c newUsage = createBlngUsage(eachModifEntrante,'Heures','Modification_Facturation_Adaptation','Modification Période d\'Adaptation');
                allUsageList.add(newUsage);
                eachModifEntrante.LPCR_EtatTraitement__c = true;
            }else if('Modification_Heure_Supplementaire_MAC'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Contract__c != null && eachModifEntrante.LPCR_Quantite__c != null ){
                blng__Usage__c newUsage = createBlngUsage(eachModifEntrante,'Heures','Modification_Heure_Supplementaire_MAC',evenementMap.get(eachModifEntrante.LPCR_Evenement__c));
                allUsageList.add(newUsage);
                eachModifEntrante.LPCR_EtatTraitement__c = true;
            }else if('Modification_Heure_Occasionnel_MAC'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Contract__c != null && eachModifEntrante.LPCR_Quantite__c != null ){
                blng__Usage__c newUsage = createBlngUsage(eachModifEntrante,'Heures','Modification_Heure_Occasionnel_MAC',evenementMap.get(eachModifEntrante.LPCR_Evenement__c));
                allUsageList.add(newUsage);
                eachModifEntrante.LPCR_EtatTraitement__c = true;
            }else if('Modification_Heure_Deduite_MAC'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Contract__c != null && eachModifEntrante.LPCR_Quantite__c != null ){
                blng__Usage__c newUsage = createBlngUsage(eachModifEntrante,'Heures','Modification_Heure_Deduite_MAC',evenementMap.get(eachModifEntrante.LPCR_Evenement__c));
                allUsageList.add(newUsage);
                eachModifEntrante.LPCR_EtatTraitement__c = true;
            }else if('Nombre_de_repas'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Contract__c != null && eachModifEntrante.LPCR_Quantite__c != null ){
                blng__Usage__c newUsage = createBlngUsage(eachModifEntrante,'Heures','Nombre_de_repas',evenementMap.get(eachModifEntrante.LPCR_Evenement__c));
                allUsageList.add(newUsage);
                eachModifEntrante.LPCR_EtatTraitement__c = true;
            }else if('NB_Heures_Realisee'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Invoice__c != null && eachModifEntrante.LPCR_Quantite__c != null ){
                blng__Invoice__c updateInvoice = new blng__Invoice__c(Id = eachModifEntrante.LPCR_Invoice__c);
                updateInvoice.LPCR_NbHeuresRealise__c = eachModifEntrante.LPCR_Quantite__c;
                allInvoiceList.add(updateInvoice);
                eachModifEntrante.LPCR_EtatTraitement__c = true;
            }else if('Commentaire_Individuel_Facture'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Invoice__c != null && eachModifEntrante.LPCR_Commentaire__c != null ){
                blng__Invoice__c updateInvoice = new blng__Invoice__c(Id = eachModifEntrante.LPCR_Invoice__c);
                updateInvoice.LPCR_CommentaireIndividuel__c = eachModifEntrante.LPCR_Commentaire__c;
                allInvoiceList.add(updateInvoice);
                eachModifEntrante.LPCR_EtatTraitement__c = true;
            }else if('Commentaire_Global_Facture'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Compte__c != null && eachModifEntrante.LPCR_Commentaire__c != null ){
                Account updateAccount = new Account(Id = eachModifEntrante.LPCR_Compte__c);
                updateAccount.LPCR_Commentaire__c = eachModifEntrante.LPCR_Commentaire__c;
                allAccountUpdateList.add(updateAccount);
                eachModifEntrante.LPCR_EtatTraitement__c = true;
            }else if('Absence'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Contract__c != null && eachModifEntrante.LPCR_Quantite__c != null ){
                blng__Usage__c newUsage = createBlngUsage(eachModifEntrante,'Heures','Absence',evenementMap.get(eachModifEntrante.LPCR_Evenement__c));
                allUsageList.add(newUsage);
                eachModifEntrante.LPCR_EtatTraitement__c = true;
            }else if('Validation Contrat Directrice'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Contract__c != null ){
                SBQQ__Quote__c updateQuote = new SBQQ__Quote__c(Id = modifEntrantesContractMap.get(eachModifEntrante.LPCR_Contract__c).SBQQ__Quote__c);
                updateQuote.SBQQ__Status__c = 'Validé directrice';
                mapOfQuoteForUpdate.put(updateQuote.id,updateQuote);
                eachModifEntrante.LPCR_EtatTraitement__c = true;
            }else if('Regularisation'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Contract__c != null && eachModifEntrante.LPCR_Quantite__c != null ){
                blng__Usage__c newUsage = createBlngUsage(eachModifEntrante,'Heures','Regularisation',evenementMap.get(eachModifEntrante.LPCR_Evenement__c));
                allUsageList.add(newUsage);
                eachModifEntrante.LPCR_EtatTraitement__c = true;
            }
            
        }
        if(listRessourceFamilleToInsert.size() > 0){
            EM012_RessourceFamilleEntity.saveOrUpdte(listRessourceFamilleToInsert);
        }
        if(allPlanningInsertList.size() > 0){
            insert allPlanningInsertList;
            List<LPCR_PlanningPrevisionnel__c> insertPlanningPrevisionnelList = new List<LPCR_PlanningPrevisionnel__c>();
            
            for(LPCR_Planning__c eachPlan : allPlanningInsertList){
                for(LPCR_PlanningPrevisionnel__c eachPlanPre : allPlanningPrevisionnelInsertMap.get(eachPlan.LPCR_Devis__c)){
                    eachPlanPre.LPCR_Planning__c = eachPlan.Id;
                    insertPlanningPrevisionnelList.add(eachPlanPre);
                    if(mapOfQuoteForUpdate.containsKey(eachPlan.LPCR_Devis__c)){
                        mapOfQuoteForUpdate.get(eachPlan.LPCR_Devis__c).LPCR_PlanningEnfant__c = eachPlan.Id;
                    }
                }
            }
            
            if(insertPlanningPrevisionnelList.size() > 0){
                insert insertPlanningPrevisionnelList;
            }
        }
        if(allListCloneQuoteLine.size() > 0){
            UPSERT allListCloneQuoteLine;
        }
        if(mapOfQuoteForUpdate.size() > 0){
            UPDATE mapOfQuoteForUpdate.values();
            // populate newQuoteIds from new quote ids
            for(String key : mapOfQuoteForUpdate.keySet()){
                newQuoteIds.add((Id) key);
            }
        }
        if(allAccountUpdateList.size() > 0){
            UPDATE allAccountUpdateList;
        }
        if(allContractUpdateList.size() > 0){
            UPDATE allContractUpdateList;
        }
        if(allContactUpdateList.size() > 0){
            UPDATE allContactUpdateList;
        }
        if(allInvoiceList.size() > 0){
            UPDATE allInvoiceList;
        }
        if(allUsageList.size() > 0){
            INSERT allUsageList;
        }
        if(ModifEntrantesList.size() > 0){
            UPDATE ModifEntrantesList;
        }
        return newQuoteIds;
    }
    
    public static LPCR_RessourceFamille__c createNewRessourceFamille(LPCR_RessourceFamille__c oldRessourceFamille){
        Date firstDayOfNextMonthDate = Date.newInstance(Date.today().Year(), Date.today().month()+1 ,1) ;
        LPCR_RessourceFamille__c ressourceFamilleToInsert = oldRessourceFamille.clone(false,true,false,false);
        ressourceFamilleToInsert.LPCR_DateDebut__c=firstDayOfNextMonthDate;
        ressourceFamilleToInsert.LPCR_CompteFamille__c=oldRessourceFamille.LPCR_CompteFamille__c;
        ressourceFamilleToInsert.LPCR_DateFin__c = null;
        if(oldRessourceFamille.RecordTypeId!=null){
            ressourceFamilleToInsert.RecordTypeId=oldRessourceFamille.RecordTypeId;
        }
        return ressourceFamilleToInsert;
        
    }
    
    public static WRP001_QuoteModel executeContractAmenderAPI(Id contractID){
        Date firstDayOfNextMonthDate = Date.newInstance(Date.today().Year(), Date.today().month()+1 ,1) ;
        UM006_ContractAmender amender = new UM006_ContractAmender();
        WRP001_QuoteModel quote = amender.load(contractID);
        UM007_QuoteReader reader = new UM007_QuoteReader();
        WRP001_QuoteModel quoteModel = reader.read(quote.record.id);
        quoteModel.record.SBQQ__StartDate__c = firstDayOfNextMonthDate;
        quoteModel.record.LPCR_DateDebut__c = firstDayOfNextMonthDate;
        for(WRP002_QuoteLineModel eachQuoteLine : quoteModel.lineItems){
            eachQuoteLine.record.LPCR_CloneCancel__c = true;
        }
        UM008_QuoteCalculator calculator = new UM008_QuoteCalculator();
        calculator.calculate(quoteModel, 'UM009_Callback');
        
        return quoteModel;
    }
    
    public static void cloneAndCancelSubscriptions(WRP001_QuoteModel quoteModel){
		APC006_CloneQuoteLines.cloneAndResetQL(quoteModel.record.id);	
    }

    public static blng__Usage__c createBlngUsage(LPCR_ModificationEntrante__c modifEntrante, String UnitOfMeasure, String eventType, String eventLabelName){
        blng__Usage__c newUsage = new blng__Usage__c();
        newUsage.LPCR_TypeEvenement__c = eventType;
        newUsage.blng__StartDateTime__c = modifEntrante.LPCR_HeureDateDebut__c;
        newUsage.blng__EndDateTime__c = modifEntrante.LPCR_HeureDateFin__c;
        newUsage.blng__Quantity__c = modifEntrante.LPCR_Quantite__c;
        newUsage.blng__MatchingId__c = modifEntrante.LPCR_Contact__c+''+eventLabelName+''+modifEntrante.LPCR_Compte__c;
        newUsage.blng__UnitOfMeasure__c = UnitOfMeasure;
        return newUsage;
    }
    
    public static Map<String,List<LPCR_DetailModificationPlanning__c>> getDetailModificationPlanningList(Set<String> ids, String eventName){
        Map<String,List<LPCR_DetailModificationPlanning__c>> detailModifPlanningMap = new Map<String,List<LPCR_DetailModificationPlanning__c>>();
        for(LPCR_DetailModificationPlanning__c eachDetailModifPlan : [SELECT Id, Name, LPCR_OrdreTri__c, LPCR_ModificationEntrante__c, LPCR_HeureDebutJeudi__c, LPCR_HeureDebutLundi__c, LPCR_HeureDebutMardi__c, LPCR_HeureDebutMercredi__c, LPCR_HeureDebutVendredi__c, LPCR_HeureFinJeudi__c, LPCR_HeureFinLundi__c, LPCR_HeureFinMardi__c, LPCR_HeureFinMercredi__c, LPCR_HeureFinVendredi__c FROM LPCR_DetailModificationPlanning__c WHERE LPCR_ModificationEntrante__c IN : ids AND LPCR_ModificationEntrante__r.LPCR_Evenement__c =: eventName]){
            if(!detailModifPlanningMap.containsKey(eachDetailModifPlan.LPCR_ModificationEntrante__c)){
                detailModifPlanningMap.put(eachDetailModifPlan.LPCR_ModificationEntrante__c,new List<LPCR_DetailModificationPlanning__c>());
            }
            detailModifPlanningMap.get(eachDetailModifPlan.LPCR_ModificationEntrante__c).add(eachDetailModifPlan);
        }
        return detailModifPlanningMap;
    }
    public static Map<String, String> getPicklistLabelByAPI(){       
        Map<String,String> evenementMap = new Map<String,String>();
        Schema.DescribeFieldResult fieldResult = LPCR_ModificationEntrante__c.LPCR_Evenement__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                
        for( Schema.PicklistEntry f : ple)
        {
            evenementMap.put(f.getValue(), f.getLabel());
        }       
        return evenementMap;
    }
    
}