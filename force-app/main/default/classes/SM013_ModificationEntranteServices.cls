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
    //added by saurabh
    public static void createUsageFromModifEntrantes(List<LPCR_ModificationEntrante__c> ModifEntrantesList){
        System.debug('SM013_ModificationEntranteServices');
        List<blng__Usage__c> lstBillingUsage = new List<blng__Usage__c>();
        for(LPCR_ModificationEntrante__c eachModification : ModifEntrantesList){
            if('Modification Heure Supplémentaire MAC'.equals(eachModification.LPCR_Evenement__c) &&
               'Modification Heure Occasionnel MAC'.equals(eachModification.LPCR_Evenement__c) &&
               'Modification Heure Déduite MAC'.equals(eachModification.LPCR_Evenement__c) &&
               'Modification Facturation Adaptation'.equals(eachModification.LPCR_Evenement__c) &&
               'Nombre de repas'.equals(eachModification.LPCR_Evenement__c) &&
               'Abscence'.equals(eachModification.LPCR_Evenement__c)
              ){
                  blng__Usage__c newUsage = EM016_ModificationEntranteEntity.createBlngUsage(eachModification,'Hour');
                  System.debug('**** newUsage : '+ newUsage);
                  if(newUsage != null){
                      lstBillingUsage.add(newUsage);
                  }
              }
        }
        if(lstBillingUsage.size() > 0){
            insert lstBillingUsage;
            System.debug('SM013_ModificationEntranteServices billing usage insertd'+lstBillingUsage.size());
        }
    }

    // added by saurabh
    public static void updateQuotesFromModifEntrantesBatch(List<LPCR_ModificationEntrante__c> ModifEntrantesList){
        System.debug('updateQuotesFromModifEntrantesBatch::');
        System.debug('size of ModifEntrantesList : '+ ModifEntrantesList.size());

        Date firstDayOfCurrentMonthDate = Date.newInstance(Date.today().Year(), Date.today().month() ,1) ;
        Date firstDayOfNextMonthDate = Date.newInstance(Date.today().Year(), Date.today().month()+1 ,1) ;
        Date lastDayOfCurrentMonthDate=Date.newInstance(Date.today().Year(), Date.today().month() , Date.daysInMonth(Date.today().year(), Date.today().month())) ;

        Set<String> compteIds = UM003_TypeManager.getFieldsOfListObjects(ModifEntrantesList, 'LPCR_Compte__c');
        Set<String> contactIds = UM003_TypeManager.getFieldsOfListObjects(ModifEntrantesList, 'LPCR_Contact__c');
        Set<String> modifEntrantesIds = UM003_TypeManager.getFieldsOfListObjects(ModifEntrantesList, 'Id');

        Map<Id,LPCR_RessourceFamille__c> ressourceFamilleMap = new Map<Id,LPCR_RessourceFamille__c>();
        Map<Id,Contact> modifEntrantesContactMap = new Map<Id,Contact>();

        List<Contact> allContactUpdateList = new List<Contact>();
        List<Contract> allContractUpdateList = new List<Contract>();
        List<Account> allAccountUpdateList = new List<Account>();
        List<blng__Usage__c> allUsageList = new List<blng__Usage__c>();
        List<blng__Invoice__c> allInvoiceList = new List<blng__Invoice__c>();
        List<LPCR_RessourceFamille__c> listRessourceFamilleToInsert = new List<LPCR_RessourceFamille__c> ();
        List<SBQQ__QuoteLine__c> allListCloneQuoteLine = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__Quote__c> listQuoteForUpdate = new List<SBQQ__Quote__c>();
		Map<String,List<LPCR_DetailModificationPlanning__c>> detailModifPlanningMap = new Map<String,List<LPCR_DetailModificationPlanning__c>>();
        List<LPCR_Planning__c> allPlanningInsertList = new List<LPCR_Planning__c>();
        Map<String, List<LPCR_PlanningPrevisionnel__c>> allPlanningPrevisionnelInsertMap = new Map<String, List<LPCR_PlanningPrevisionnel__c>>();

        for(LPCR_RessourceFamille__c eachRessourceFamille : [SELECT Id,Name,RecordTypeId,LPCR_NombreEnfants__c,LPCR_NombreEnfantHandicape__c,LPCR_CompteFamille__c,LPCR_DateFin__c FROM LPCR_RessourceFamille__c WHERE LPCR_CompteFamille__c IN : compteIds AND LPCR_DateDebut__c =: firstDayOfCurrentMonthDate]){
            if(eachRessourceFamille.LPCR_CompteFamille__c != null){
                ressourceFamilleMap.put(eachRessourceFamille.LPCR_CompteFamille__c, eachRessourceFamille);
            }
        }
        System.debug('size of ressourceFamilleMap : '+ ressourceFamilleMap.size());
        for(Contact contact : [SELECT Id,LPCR_NumeroAllocataire__c, LPCR_AutoriteParentale__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry FROM Contact WHERE Id IN: contactIds]){
            modifEntrantesContactMap.put(contact.Id, contact);
        }
        System.debug('size of modifEntrantesContactMap : '+ modifEntrantesContactMap.size());

        detailModifPlanningMap = SM013_ModificationEntranteServices.getDetailModificationPlanningList(modifEntrantesIds,'Modification Type Planning');

        for(LPCR_ModificationEntrante__c eachModifEntrante : ModifEntrantesList){
            if('Modification Situation Handicapé Enfant Fratrie'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Quantite__c != null && eachModifEntrante.LPCR_Compte__c != null && eachModifEntrante.LPCR_DateEffet__c != null){
                System.debug('Event = Modification Situation Handicapé Enfant Fratrie | '+ eachModifEntrante.Id);
                if(ressourceFamilleMap.containsKey(eachModifEntrante.LPCR_Compte__c)){
                    // 1) Update previous LPCR_FamilyRessource_c with an effective end date (LPCR_DateFin_c) corresponding to last day of current month
                    // 2) Insert a LPCR_FamilyRessource__c record dwith effective start date as 1st of next month
                    LPCR_RessourceFamille__c oldRessourceFamille = ressourceFamilleMap.get(eachModifEntrante.LPCR_Compte__c);
                    LPCR_RessourceFamille__c ressourceFamilleToInsert = createNewRessourceFamille(oldRessourceFamille);
                    ressourceFamilleToInsert.LPCR_NombreEnfantHandicape__c = eachModifEntrante.LPCR_Quantite__c;
                    ressourceFamilleToInsert.LPCR_CompteFamille__c = eachModifEntrante.LPCR_Compte__c;
                    oldRessourceFamille.LPCR_DateFin__c = lastDayOfCurrentMonthDate;
                    listRessourceFamilleToInsert.add(oldRessourceFamille);
                    listRessourceFamilleToInsert.add(ressourceFamilleToInsert);

                    WRP001_QuoteModel quoteModel = executeContractAmenderAPI(eachModifEntrante.LPCR_Contract__c);

                    SBQQ.TriggerControl.disable();

                    List<SBQQ__QuoteLine__c> listCloneQuoteLine = cloneAndCancelSubscriptions(quoteModel);
                    if(listCloneQuoteLine.size() > 0){
                        allListCloneQuoteLine.addAll(listCloneQuoteLine);
                    }

                    SBQQ.TriggerControl.enable();
                    SBQQ__Quote__c quote = quoteModel.record;
                    quote.LPCR_LaunchRecalculation__c = true;
                    listQuoteForUpdate.add(quote);

                }
            }else if('Modification Type Planning'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Quantite__c != null && eachModifEntrante.LPCR_Compte__c != null){
                if(ressourceFamilleMap.containsKey(eachModifEntrante.LPCR_Compte__c)){
                    LPCR_RessourceFamille__c oldRessourceFamille = ressourceFamilleMap.get(eachModifEntrante.LPCR_Compte__c);
                    LPCR_RessourceFamille__c ressourceFamilleToInsert = createNewRessourceFamille(oldRessourceFamille);
                    ressourceFamilleToInsert.LPCR_NombreEnfants__c = eachModifEntrante.LPCR_Quantite__c;
                    ressourceFamilleToInsert.LPCR_RevenusFamille__c = eachModifEntrante.LPCR_RessourceFamille__c;
                    ressourceFamilleToInsert.LPCR_CompteFamille__c = eachModifEntrante.LPCR_Compte__c;
                    oldRessourceFamille.LPCR_DateFin__c = lastDayOfCurrentMonthDate;

                    listRessourceFamilleToInsert.add(oldRessourceFamille);
                    listRessourceFamilleToInsert.add(ressourceFamilleToInsert);

                    if(detailModifPlanningMap.containsKey(eachModifEntrante.Id)){
                        LPCR_Planning__c tmpPlanning = new LPCR_Planning__c();
                        tmpPlanning.LPCR_Devis__c = eachModifEntrante.LPCR_Devis__c;
                        tmpPlanning.LPCR_TypePlanning__c = eachModifEntrante.LPCR_TypePlanning__c;
                        allPlanningInsertList.add(tmpPlanning);

                        allPlanningPrevisionnelInsertMap.put(eachModifEntrante.LPCR_Devis__c, new List<LPCR_PlanningPrevisionnel__c>());

                        for(LPCR_DetailModificationPlanning__c eachDetailModifPlan : detailModifPlanningMap.get(eachModifEntrante.Id)){
                            LPCR_PlanningPrevisionnel__c pl = new LPCR_PlanningPrevisionnel__c(
                                                                               //LPCR_Planning__c = tmpPlanning.Id,
                                                                               LPCR_Contrat__c  =eachModifEntrante.LPCR_Devis__c,
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
                            allPlanningPrevisionnelInsertMap.get(eachModifEntrante.LPCR_Devis__c).add(pl);
                        }
                    }
                    WRP001_QuoteModel quoteModel = executeContractAmenderAPI(eachModifEntrante.LPCR_Contract__c);

                    SBQQ.TriggerControl.disable();

                    List<SBQQ__QuoteLine__c> listCloneQuoteLine = cloneAndCancelSubscriptions(quoteModel);
                    if(listCloneQuoteLine.size() > 0){
                        allListCloneQuoteLine.addAll(listCloneQuoteLine);
                    }

                    SBQQ.TriggerControl.enable();

                    SBQQ__Quote__c quote = quoteModel.record;
                    quote.SBQQ__Status__c = 'Brouillon';
                    listQuoteForUpdate.add(quote);

                }
            }else if('Modification Nombre Jour Congé'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Quantite__c != null && eachModifEntrante.LPCR_Compte__c != null ){
                if(ressourceFamilleMap.containsKey(eachModifEntrante.LPCR_Compte__c)){

                    WRP001_QuoteModel quoteModel = executeContractAmenderAPI(eachModifEntrante.LPCR_Contract__c);

                    SBQQ.TriggerControl.disable();

                    List<SBQQ__QuoteLine__c> listCloneQuoteLine = cloneAndCancelSubscriptions(quoteModel);
                    if(listCloneQuoteLine.size() > 0){
                        allListCloneQuoteLine.addAll(listCloneQuoteLine);
                    }

                    SBQQ.TriggerControl.enable();

                    SBQQ__Quote__c quote = quoteModel.record;
                    quote.LPCR_CongesJours__c = eachModifEntrante.LPCR_Quantite__c;
                    quote.LPCR_LaunchRecalculation__c = true;
                    listQuoteForUpdate.add(quote);

                }
            }else if('Date Fin Contrat'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Quantite__c != null && eachModifEntrante.LPCR_Compte__c != null && eachModifEntrante.LPCR_DateEffet__c != null){
                if(ressourceFamilleMap.containsKey(eachModifEntrante.LPCR_Compte__c)){
                    LPCR_RessourceFamille__c oldRessourceFamille = ressourceFamilleMap.get(eachModifEntrante.LPCR_Compte__c);
                    oldRessourceFamille.LPCR_DateFin__c = eachModifEntrante.LPCR_DateEffet__c;
                    //oldRessourceFamille.LPCR_FinContrat__c = lastDayOfCurrentMonthDate;
                    listRessourceFamilleToInsert.add(oldRessourceFamille);

                    WRP001_QuoteModel quoteModel = executeContractAmenderAPI(eachModifEntrante.LPCR_Contract__c);

                    SBQQ.TriggerControl.disable();

                    List<SBQQ__QuoteLine__c> listCloneQuoteLine = cloneAndCancelSubscriptions(quoteModel);
                    if(listCloneQuoteLine.size() > 0){
                        allListCloneQuoteLine.addAll(listCloneQuoteLine);
                    }

                    SBQQ.TriggerControl.enable();

                    SBQQ__Quote__c quote = quoteModel.record;
                    quote.SBQQ__StartDate__c = firstDayOfNextMonthDate;
                    quote.SBQQ__Status__c = 'Brouillon';
                    listQuoteForUpdate.add(quote);

                }
            }else if('Modification Type Accueil'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Contract__c != null && eachModifEntrante.LPCR_Compte__c != null && eachModifEntrante.LPCR_TypeAccueil__c != null){
                if(ressourceFamilleMap.containsKey(eachModifEntrante.LPCR_Compte__c)){

                    WRP001_QuoteModel quoteModel = executeContractAmenderAPI(eachModifEntrante.LPCR_Contract__c);

                    SBQQ.TriggerControl.disable();

                    List<SBQQ__QuoteLine__c> listCloneQuoteLine = cloneAndCancelSubscriptions(quoteModel);
                    if(listCloneQuoteLine.size() > 0){
                        allListCloneQuoteLine.addAll(listCloneQuoteLine);
                    }

                    SBQQ.TriggerControl.enable();

                    SBQQ__Quote__c quote = quoteModel.record;
                    quote.LPCR_LaunchRecalculation__c = true;
                    quote.SBQQ__Status__c = 'Brouillon';
                    listQuoteForUpdate.add(quote);

                }
            }else if('Modification Adresse Contact Parent'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Contact__c != null ){
                if(modifEntrantesContactMap.containsKey(eachModifEntrante.LPCR_Contact__c)){
                    Contact updateContact = modifEntrantesContactMap.get(eachModifEntrante.LPCR_Contact__c);
                    updateContact.MailingStreet = eachModifEntrante.LPCR_Rue__c;
                    updateContact.MailingCity = eachModifEntrante.LPCR_Ville__c;
                    updateContact.MailingCountry = eachModifEntrante.LPCR_Pays__c;
                    updateContact.MailingPostalCode = eachModifEntrante.LPCR_CodePostal__c;
                    allContactUpdateList.add(updateContact);
                }
            }else if('Modification Autorité Parentale'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Contact__c != null && eachModifEntrante.LPCR_OuiNon__c != null ){
                Contact updateContact = new Contact(Id = eachModifEntrante.LPCR_Contact__c);
                updateContact.LPCR_AutoriteParentale__c = eachModifEntrante.LPCR_OuiNon__c;
                allContactUpdateList.add(updateContact);
            }else if('Modification Numéro Allocataire'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Contact__c != null && eachModifEntrante.LPCR_IDUnique__c != null ){
                Contact updateContact = new Contact(Id = eachModifEntrante.LPCR_Contact__c);
                updateContact.LPCR_NumeroAllocataire__c = eachModifEntrante.LPCR_IDUnique__c;
                allContactUpdateList.add(updateContact);
            }else if('Date Naissance Enfant'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Contact__c != null && eachModifEntrante.LPCR_Date__c != null ){
                Contact updateContact = new Contact(Id = eachModifEntrante.LPCR_Contact__c);
                updateContact.Birthdate = eachModifEntrante.LPCR_Date__c;
                allContactUpdateList.add(updateContact);
            }else if('Modification Section'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Contract__c != null && eachModifEntrante.LPCR_Section__c != null ){
                Contract updateContract = new Contract(Id = eachModifEntrante.LPCR_Contract__c);
                updateContract.LPCR_Section__c = eachModifEntrante.LPCR_Section__c;
                allContractUpdateList.add(updateContract);
            }else if('Modification Mode Garde'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Compte__c != null && eachModifEntrante.LPCR_Garde__c != null ){
                Account updateAccount = new Account(Id = eachModifEntrante.LPCR_Compte__c);
                updateAccount.LPCR_SituationFamiliale__c = eachModifEntrante.LPCR_SituationFamiliale__c;
                updateAccount.LPCR_Garde__c = eachModifEntrante.LPCR_Garde__c;
                allAccountUpdateList.add(updateAccount);
            }else if('Modification Situation Familiale'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Compte__c != null && eachModifEntrante.LPCR_SituationFamiliale__c != null ){
                Account updateAccount = new Account(Id = eachModifEntrante.LPCR_Compte__c);
                updateAccount.LPCR_SituationFamiliale__c = eachModifEntrante.LPCR_SituationFamiliale__c;
                allAccountUpdateList.add(updateAccount);
            }else if('Modification Facturation Adaptation'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Contract__c != null && eachModifEntrante.LPCR_Quantite__c != null ){
                blng__Usage__c newUsage = createBlngUsage(eachModifEntrante,'Hour');
                allUsageList.add(newUsage);
            }else if('Modification Heure Supplémentaire MAC'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Contract__c != null && eachModifEntrante.LPCR_Quantite__c != null ){
                blng__Usage__c newUsage = createBlngUsage(eachModifEntrante,'Hour');
                allUsageList.add(newUsage);
            }else if('Modification Heure Occasionnel MAC'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Contract__c != null && eachModifEntrante.LPCR_Quantite__c != null ){
                blng__Usage__c newUsage = createBlngUsage(eachModifEntrante,'Hour');
                allUsageList.add(newUsage);
            }else if('Modification Heure Déduite MAC'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Contract__c != null && eachModifEntrante.LPCR_Quantite__c != null ){
                blng__Usage__c newUsage = createBlngUsage(eachModifEntrante,'Hour');
                allUsageList.add(newUsage);
            }else if('Nombre de repas'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Contract__c != null && eachModifEntrante.LPCR_Quantite__c != null ){
                blng__Usage__c newUsage = createBlngUsage(eachModifEntrante,'Number (Unit)');
                allUsageList.add(newUsage);
            }else if('NB Heures réalisées'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Invoice__c != null && eachModifEntrante.LPCR_Quantite__c != null ){
                blng__Invoice__c updateInvoice = new blng__Invoice__c(Id = eachModifEntrante.LPCR_Invoice__c);
                updateInvoice.LPCR_NbHeuresRealise__c = eachModifEntrante.LPCR_Quantite__c;
                allInvoiceList.add(updateInvoice);
            }else if('Commentaire individuel facture'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Invoice__c != null && eachModifEntrante.LPCR_Commentaire__c != null ){
                blng__Invoice__c updateInvoice = new blng__Invoice__c(Id = eachModifEntrante.LPCR_Invoice__c);
                updateInvoice.blng__Notes__c = eachModifEntrante.LPCR_Commentaire__c;
                allInvoiceList.add(updateInvoice);
            }else if('Commentaire global facture'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Invoice__c != null && eachModifEntrante.LPCR_Commentaire__c != null ){
                blng__Invoice__c updateInvoice = new blng__Invoice__c(Id = eachModifEntrante.LPCR_Invoice__c);
                updateInvoice.blng__Notes__c = eachModifEntrante.LPCR_Commentaire__c;
                allInvoiceList.add(updateInvoice);
            }else if('Abscence'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Contract__c != null && eachModifEntrante.LPCR_Quantite__c != null ){
                blng__Usage__c newUsage = createBlngUsage(eachModifEntrante,'Hour');
                allUsageList.add(newUsage);
            }else if('Validation Contrat Directrice'.equals(eachModifEntrante.LPCR_Evenement__c) && eachModifEntrante.LPCR_Contract__c != null && eachModifEntrante.LPCR_Devis__c != null ){
                SBQQ__Quote__c updateQuote = new SBQQ__Quote__c(Id = eachModifEntrante.LPCR_Devis__c);
                updateQuote.SBQQ__Status__c = 'Validé directrice';
                listQuoteForUpdate.add(updateQuote);
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
                }
            }

            if(insertPlanningPrevisionnelList.size() > 0){
                insert insertPlanningPrevisionnelList;
            }
        }
        if(allListCloneQuoteLine.size() > 0){
            SBQQ.TriggerControl.disable();
            UPSERT allListCloneQuoteLine;
            SBQQ.TriggerControl.enable();
        }
        if(listQuoteForUpdate.size() > 0){
            UPDATE listQuoteForUpdate;
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
    }

    public static LPCR_RessourceFamille__c createNewRessourceFamille(LPCR_RessourceFamille__c oldRessourceFamille){
        Date firstDayOfNextMonthDate = Date.newInstance(Date.today().Year(), Date.today().month()+1 ,1) ;
        LPCR_RessourceFamille__c ressourceFamilleToInsert = new LPCR_RessourceFamille__c(
            LPCR_DateDebut__c=firstDayOfNextMonthDate,
            LPCR_CompteFamille__c=oldRessourceFamille.LPCR_CompteFamille__c
            //LPCR_Produit__c=oldRessourceFamille.LPCR_Produit__c,
            );
        if(oldRessourceFamille.RecordTypeId!=null){
            ressourceFamilleToInsert.RecordTypeId=oldRessourceFamille.RecordTypeId;
        }
        return ressourceFamilleToInsert;

    }

    public static WRP001_QuoteModel executeContractAmenderAPI(Id contractID){
        UM006_ContractAmender amender = new UM006_ContractAmender();
        WRP001_QuoteModel quote = amender.load(contractID);
        UM007_QuoteReader reader = new UM007_QuoteReader();
        WRP001_QuoteModel quoteModel = reader.read(quote.record.id); //
        UM008_QuoteCalculator calculator = new UM008_QuoteCalculator();
        calculator.calculate(quoteModel, 'UM009_Callback');
        return quoteModel;
    }

    public static List<SBQQ__QuoteLine__c> cloneAndCancelSubscriptions(WRP001_QuoteModel quoteModel){
        List<SBQQ__QuoteLine__c> listCloneQuoteLine = new List<SBQQ__QuoteLine__c>();
        for(WRP002_QuoteLineModel eachQuoteLine : quoteModel.lineItems){
            SBQQ__QuoteLine__c newQLI = eachQuoteLine.record.clone(false,false,false,false);
            SBQQ__QuoteLine__c updateQLI = eachQuoteLine.record;
            updateQLI.SBQQ__Quantity__c = 0;
            listCloneQuoteLine.add(newQLI);
            listCloneQuoteLine.add(updateQLI);
        }
        return listCloneQuoteLine;
    }
    public static blng__Usage__c createBlngUsage(LPCR_ModificationEntrante__c modifEntrante, String UnitOfMeasure){
        String eventName = modifEntrante.LPCR_Evenement__c.toUpperCase().replaceAll(' ','_');
        blng__Usage__c newUsage = new blng__Usage__c();
        if('Abscence'.equals(modifEntrante.LPCR_Evenement__c)){
            newUsage.LPCR_TypeEvenement__c = 'Modification Absence';
        }else{
            newUsage.LPCR_TypeEvenement__c = modifEntrante.LPCR_Evenement__c;
        }
        newUsage.blng__StartDateTime__c = modifEntrante.LPCR_HeureDateDebut__c;
        newUsage.blng__EndDateTime__c = modifEntrante.LPCR_HeureDateFin__c;
        newUsage.blng__Quantity__c = modifEntrante.LPCR_Quantite__c;
        newUsage.blng__MatchingId__c = modifEntrante.LPCR_Contract__c+''+eventName+''+modifEntrante.LPCR_Compte__c;
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

}