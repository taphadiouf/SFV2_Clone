/**
* @author Makboub Hanae
* @created 21/02/2020
* @description Apex class on the convert button in the lead famille convertion process
* @Updated by: Achraf ABOUL(Salesforce) 08/04/2020
*/
public with sharing class APC001_LeadFaConverController{
    
    @AuraEnabled(cacheable = false)
    public static List<Account> getRelatedCreches(Id leadId){
        
        List<LPCR_LienCrecheLead__c> tmpLienCrecheLead = [SELECT Id, LPCR_Creche__c from LPCR_LienCrecheLead__c where LPCR_Lead__c = :leadId];
        Set<Id> accIdsSet = new Set<Id>();
        Set<String> accFieldsSet = new Set<String>();
        
        accFieldsSet.add('Name');
        
        for (LPCR_LienCrecheLead__c elem : tmpLienCrecheLead) {
            accIdsSet.add(elem.LPCR_Creche__c);
        }
        
        return new EM005_AccountEntity().getByIds(accIdsSet, accFieldsSet);
    }
    
    @AuraEnabled(cacheable=true)
    public static String getEnfants(Id leadId){
        
        List<WRP002_EnfantWrapper> enfants = new List<WRP002_EnfantWrapper>();
        Set<String> fields = new Set<String>();
        for(Integer i = 1; i < 4; i++){
            fields.add('LPCR_NomEnfant' + i + '__c');
            fields.add('LPCR_PrenomEnfant' + i + '__c');
        }
        Lead currentLead = (Lead) new EM002_LeadEntity().getById(leadId, fields);
        String tempNom;
        String tempPrenom;
        for(Integer i = 1; i < 4; i++){
            tempNom = (String) currentLead.get('LPCR_NomEnfant' + i + '__c');
            tempPrenom = (String) currentLead.get('LPCR_PrenomEnfant' + i + '__c');
            if(!String.isBlank(tempNom) && !String.isBlank(tempPrenom)){
                enfants.add(new WRP002_EnfantWrapper(i, tempNom, tempPrenom, 'Enfant '+i));
            }
        }
        return JSON.serialize(enfants);
    }
    
    public class WRP002_EnfantWrapper{
        
        Integer num;
        String nom;
        String  prenom;
        String label;
        public WRP002_EnfantWrapper(Integer num, String nom, String prenom, String label){
            this.num  = num;
            this.nom = nom;
            this.prenom = prenom;
            this.label = label;
        }
    } 
    
    @AuraEnabled(cacheable=false)
    public static List<Account> getAccountsByRecordtypeName(String recordTypeName, String leadId) {
        
        List<Account> accounts = new List<Account>();
        Id recordtypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(System.Label.LPCR_Account,recordTypeName);
        if(UM003_TypeManager.idNotNull(recordtypeId)){
            //Filter compte société picklist on acctouns of parent1 and parent2
            List<Id> ComptesSocieteParentsIds = new List<Id>();
            for(Lead l : [Select id,LPCR_CompteSociete__c,LPCR_CompteSocieteCoDemandeur__c from lead where id=:leadId]){
                ComptesSocieteParentsIds.add(l.LPCR_CompteSociete__c);
                ComptesSocieteParentsIds.add(l.LPCR_CompteSocieteCoDemandeur__c);
            }
            accounts = [SELECT Name FROM Account WHERE (RecordTypeId = :recordtypeId) AND (id IN :ComptesSocieteParentsIds)];
        }
        return accounts;
    }
    
    @AuraEnabled()
    public static string convertLeadCtrl(Id leadId, List<Integer> enfantsIndexes, String chosenCrecheId, Id chosenCompteId,Boolean isContratAccueil){
        
        Lead currentLead = EM002_LeadEntity.getAllLeadfielsById(leadId);
        String prenomCoDemandeur = currentLead.LPCR_PrenomCoDemandeur__c;                                         
        String nomCoDemandeur = currentLead.LPCR_NomCoDemandeur__c;                                         
        String civiliteCoDemandeur = currentLead.LPCR_CiviliteCoDemandeur__c;
        String accountName = Label.LPCR_Famille + ' ' + currentLead.LastName;
        system.debug('accountName'+accountName);
        
        
        
        boolean isvalid = true;
        String errMsg = 'Veuillez vérifier le suivant : ';
        String saveResultMsg = '';
        String contactFirstName = (String.isNotBlank(civiliteCoDemandeur) ? (civiliteCoDemandeur + ' ') : '') + prenomCoDemandeur;
        Integer count = 0;
        
        if(currentLead.Address == Null){
            isvalid = False ;
            errMsg += 'le champ Adresse est manquant';
        }
        if(contactFirstName.length()>40){
            isvalid = False ;
            errMsg += 'le champ Prénom co-demandeur est trop long';
        }
        if(!isvalid){
            throw new AuraHandledException(errMsg);
        }
        
        
        //Create Account (Famille)
        Account newFamilleAccount = new Account(
            Name = Label.LPCR_Famille + ' ' + currentLead.LastName + ((nomCoDemandeur != null && nomCoDemandeur <> currentLead.LastName) ? (' ' +nomCoDemandeur) : ''), 
            RecordTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(System.Label.LPCR_Account,System.Label.LPCR_Famille),
            Phone = currentLead.Phone,
            LPCR_SituationFamiliale__c  = currentLead.LPCR_SituationFamiliale__c,
            ShippingStreet = currentLead.Address.getStreet(),
            ShippingCity = currentLead.Address.getCity(),
            ShippingState = currentLead.Address.getState(),
            ShippingCountry = currentLead.Address.getCountry(),
            ShippingPostalCode = currentLead.Address.getPostalCode(),
            ShippingGeocodeAccuracy = currentLead.Address.getGeocodeAccuracy(),
            ShippingLatitude = currentLead.Address.getLatitude(),
            ShippingLongitude = currentLead.Address.getLongitude(),
            BillingStreet = currentLead.Address.getStreet(),
            BillingCity = currentLead.Address.getCity(),
            BillingState = currentLead.Address.getState(),
            BillingCountry = currentLead.Address.getCountry(),
            BillingPostalCode = currentLead.Address.getPostalCode(),
            BillingGeocodeAccuracy = currentLead.Address.getGeocodeAccuracy(),
            BillingLatitude = currentLead.Address.getLatitude(),
            BillingLongitude = currentLead.Address.getLongitude() 
        );
        
        List<Database.SaveResult> accountSaveResultList = new List<Database.SaveResult>();
        Database.SaveResult saveResult = Database.insert(newFamilleAccount, false);
        accountSaveResultList.add(saveResult);
        errMsg = '';
        
        saveResultMsg = validateSaveResult(accountSaveResultList);
        if(String.isNotBlank(saveResultMsg)){
            errMsg = 'Un doublon a été détécté sur le '+ saveResultMsg;
            isvalid = False ;
            throw new AuraHandledException(errMsg);
        }
        
        ///Create contacts (Enfants and Representants(Parent RT) )
        //Map : Contact Variable Name => Contact Record
        
        Map<String, Contact> newContactsMap = new Map<String, Contact>();
        
        //Representants part (Parent)
        Id familleContactRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(System.Label.LPCR_Contact, System.Label.LPCR_Parent);
        newContactsMap.put('contactRep1', new Contact(
            LastName =currentLead.LastName, 
            FirstName = currentLead.FirstName, 
            OwnerId = currentLead.OwnerId, 
            Phone = currentLead.Phone,
            MobilePhone = currentLead.MobilePhone, 
            Email = currentLead.Email,
            MailingStreet = currentLead.Address.getStreet(),
            MailingCity = currentLead.Address.getCity(),
            MailingState = currentLead.Address.getState(),
            MailingCountry = currentLead.Address.getCountry(),
            MailingPostalCode = currentLead.Address.getPostalCode(),
            AccountId = newFamilleAccount.Id,
            RecordTypeId = familleContactRT,
            LPCR_NomEntreprise__c = currentLead.Company,
            Title = currentLead.Title 
        ));        
        if(String.isNotBlank(prenomCoDemandeur) || String.isNotBlank(nomCoDemandeur)){
            newContactsMap.put('contactRep2', new Contact(
                FirstName = (String.isNotBlank(civiliteCoDemandeur) ? (civiliteCoDemandeur + ' ') : '') + prenomCoDemandeur,
                LastName = nomCoDemandeur, 
                OwnerId = currentLead.OwnerId, 
                // Birthdate = currentLead.LPCR_DateNaissance1__c,
                Email = currentLead.LPCR_EmailCoDemandeur__c,
                MailingStreet = currentLead.Address.getStreet(),
                MailingCity = currentLead.Address.getCity(),
                MailingState = currentLead.Address.getState(),
                MailingCountry = currentLead.Address.getCountry(),
                MailingPostalCode = currentLead.Address.getPostalCode(),
                AccountId = newFamilleAccount.Id,
                RecordTypeId = familleContactRT,
                MobilePhone = currentLead.LPCR_TelephoneMobileCoDemandeur__c,
                Phone = currentLead.LPCR_TelephoneCoDemandeur__c,
                Title = currentLead.LPCR_ProfessionCoDemandeur__c,
                LPCR_NomEntreprise__c = currentLead.LPCR_SocieteCoDemandeur__c 
            ));
        }
        //Enfants part
        Id enfantContactRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(System.Label.LPCR_Contact, System.Label.LPCR_Enfant);
        if(! isContratAccueil){
            System.debug('PRA JSON getEnfants((Id)currentLead.get(id)' +getEnfants((Id)currentLead.get('id')));
            List<WRP002_EnfantWrapper> listEnfants = (List<WRP002_EnfantWrapper>) JSON.deserialize(getEnfants((Id)currentLead.get('id')),List<WRP002_EnfantWrapper>.class);
            List<Integer> listNumeroEnfant = new List<Integer>();
            for(WRP002_EnfantWrapper enfant :listEnfants){
                listNumeroEnfant.add(enfant.num);
            }
            enfantsIndexes = listNumeroEnfant;
        }
        for(Integer eachIndex : enfantsIndexes){
            newContactsMap.put(
                ('contactEnfant'+ eachIndex),
                new Contact(
                    FirstName = (String) currentLead.get('LPCR_PrenomEnfant' + eachIndex + '__c'),
                    LastName = (String) currentLead.get('LPCR_NomEnfant' + eachIndex + '__c'), 
                    Birthdate = (Date) currentLead.get('LPCR_DateNaissance' + eachIndex + '__c'), 
                    OwnerId = currentLead.OwnerId, 
                    AccountId = newFamilleAccount.Id,
                    RecordTypeId = enfantContactRT,
                    // IS-2502 Mapping contact enfant depuis le lead
                    LPCR_AmplitudeHoraireLundi__c = (String) currentLead.get('LPCR_AmplitudeHoraireLundi' + eachIndex + '__c'),
                    LPCR_AmplitudeHoraireMardi__c = (String) currentLead.get('LPCR_AmplitudeHoraireMardi' + eachIndex + '__c'),
                    LPCR_AmplitudeHoraireMercredi__c = (String) currentLead.get('LPCR_AmplitudeHoraireMercredi' + eachIndex + '__c'),
                    LPCR_AmplitudeHoraireJeudi__c = (String) currentLead.get('LPCR_AmplitudeHoraireJeudi' + eachIndex + '__c'),
                    LPCR_AmplitudeHoraireVendredi__c = (String) currentLead.get('LPCR_AmplitudeHoraireVendredi' + eachIndex + '__c'),
                    LPCR_DatePreinscription__c=(Date) currentLead.LPCR_DatePreinscription__c, 
                    LPCR_DateEntreeCrecheSouhaitee__c=(Date) currentLead.get('LPCR_DateEntreeCreche' + eachIndex + '__c')
                ));
        }
        
        List<Database.SaveResult> saveResultList = Database.insert(newContactsMap.values(), false);
        errMsg = '';
        saveResultMsg = '';
        saveResultMsg = validateSaveResult(saveResultList);
        if(String.isNotBlank(saveResultMsg)){
            errMsg = 'Un doublon a été détécté sur le '+ saveResultMsg;
            isvalid = False ;
            throw new AuraHandledException(errMsg);
        }
        //Set Reprsentants1 and Reprsentants2 fields for contactEnfant
        // IS-2502 Mapping contact enfant depuis le lead
        for(Integer eachIndex : enfantsIndexes){
            if(newContactsMap.get('contactRep1') != null)
                newContactsMap.get('contactEnfant'+ eachIndex).LPCR_Representant1__c=newContactsMap.get('contactRep1').Id;
            if(newContactsMap.get('contactRep2') != null)
                newContactsMap.get('contactEnfant'+ eachIndex).LPCR_Representant2__c=newContactsMap.get('contactRep2').Id;
        }
        try {
            upsert newContactsMap.values();
        } catch (Exception e ) {
            throw new AuraHandledException(e.getMessage() + '|Line :' + e.getLineNumber());
        }
        
        //Set Reprsentants1 and Reprsentants2 fields for newFamilleAccount  
        newFamilleAccount.LPCR_Representant1__c = newContactsMap.get('contactRep1').Id;
        if(newContactsMap.get('contactRep2') != null) newFamilleAccount.LPCR_Representant2__c = newContactsMap.get('contactRep2').Id;
        
        try {
            update newFamilleAccount;
        } catch (Exception e ) {
            throw new AuraHandledException(e.getMessage() + '|Line :' + e.getLineNumber());
        }
        
        //Create AccountContactRelation for Reprsentants1 and Reprsentants2 contacts
        List<AccountContactRelation> accountContactRelations = new List<AccountContactRelation>();
        if(currentLead.LPCR_CompteSociete__c != null){
            accountContactRelations.add(
                new AccountContactRelation(
                    ContactId = newContactsMap.get('contactRep1').Id,
                    AccountId = currentLead.LPCR_CompteSociete__c
                )
            );
        }
        if(newContactsMap.get('contactRep2') != null){
            if(currentLead.LPCR_CompteSocieteCoDemandeur__c != null){
                accountContactRelations.add(    
                    new AccountContactRelation(
                        ContactId = newContactsMap.get('contactRep2').Id,
                        AccountId = currentLead.LPCR_CompteSocieteCoDemandeur__c
                    )
                );
            }
        }
        try{
            insert accountContactRelations;
        }
        catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage() + '|Line :' + e.getLineNumber());
        }
        //Authorize Convertion
        try {
            update new Lead(id=leadId,LPCR_Tech_BloqueConversion__c=false);
        } catch (Exception e ) {
            throw new AuraHandledException(e.getMessage() + '|Line :' + e.getLineNumber());
        }
        //Convert the lead
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(leadId);
        lc.setDoNotCreateOpportunity(!isContratAccueil);
        lc.setConvertedStatus(convertStatus.MasterLabel);
        lc.setAccountId(newFamilleAccount.Id);
        lc.setContactId(newContactsMap.get('contactRep1').Id);
        if(chosenCompteId == null){
            if(isContratAccueil){
                lc.setOpportunityName(newFamilleAccount.name);
            }
        }
        try {
            Database.LeadConvertResult lcr = Database.convertLead(lc); 
        } catch (DmlException e ) {
            update new Lead(id=leadId,LPCR_Tech_BloqueConversion__c=true);
            throw new AuraHandledException(e.getMessage());
        }        
        //Create a quote for each child (enfant)
        List<LPCR_LienCrecheLead__c> lienCrecheLeadList = [select Id, LPCR_creche__c From LPCR_LienCrecheLead__c where LPCR_Creche__r.Name = :chosenCrecheId And LPCR_Lead__c =:leadId];
        if(lienCrecheLeadList.size()!= 0){
            Set<String> crecheIds = UM003_TypeManager.getFieldsOfListObjects(lienCrecheLeadList,'LPCR_creche__c');
            Id crecheId = [SELECT Id, Name FROM Account where id in :crecheIds Limit 1].Id;
            List<SBQQ__Quote__c> quotesList = new List<SBQQ__Quote__c>();
            Contact tmpContactEnfant;
            Contact tmpContactRep1;
            Contact tmpContactRep2;
            currentLead = EM002_LeadEntity.getAllLeadfielsById(leadId);
            Id quoteRTAccueil = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote, Label.LPCR_ContratA);
            for(Integer eachIndex : enfantsIndexes){
                tmpContactEnfant = newContactsMap.get('contactEnfant' + eachIndex);
                tmpContactRep1 = newContactsMap.get('contactRep1');
                tmpContactRep2 = newContactsMap.get('contactRep2');   
                quotesList.add(
                    new SBQQ__Quote__c(
                        LPCR_DateDebut__c = (Date) currentLead.get('LPCR_DateEntreeCreche' + eachIndex + '__c'),
                        LPCR_Creche__c = crecheId,
                        SBQQ__Account__c = chosenCompteId,
                        LPCR_ContactEnfant__c = (tmpContactEnfant != null ? tmpContactEnfant.Id : null),
                        LPCR_ContactRepresentant1__c = (tmpContactRep1 != null ? tmpContactRep1.Id : null),
                        LPCR_ContactRepresentant2__c = (tmpContactRep2 != null ? tmpContactRep2.Id : null),
                        SBQQ__Opportunity2__c = currentLead.convertedOpportunityId !=null ? currentLead.convertedOpportunityId : '',
                        LPCR_Creation_conforme__c = true,
                        RecordTypeId = quoteRTAccueil
                    )
                );
            }
            try{
                insert quotesList;
            }
            catch(DmlException e) {
                System.debug('The following exception has occurred while inserting quote: ' + e.getMessage());
                throw new AuraHandledException(e.getMessage() + '|Line :' + e.getLineNumber());
            }
            
            if(currentLead.LPCR_TypePrestation__c == Label.LPCR_Occasionnel){
                for(SBQQ__Quote__c eachQuote : quotesList){
                    eachQuote.LPCR_TypeAccueil__c = Label.LPCR_Occasionnel;
                }
                try{
                    update quotesList;
                }
                catch(DmlException e) {
                    System.debug('The following exception has occurred while updating quote: ' + e.getMessage());
                    throw new AuraHandledException(e.getMessage() + '|Line :' + e.getLineNumber());
                }
            }
        }
        if(isContratAccueil){
            // PRA IS-2330 Modification de la page d'atterrissage conversion pour le renvoyer sur l'opp famille
            currentLead = EM002_LeadEntity.getAllLeadfielsById(leadId);
            return currentLead.convertedOpportunityId;
        }

        return null;
    }
    
    public static string validateSaveResult(List<Database.SaveResult> saveResultList) {
        System.debug('**** validateSaveResult : size : '+ saveResultList.size());
        String errmsg = '';
        for(Integer i=0;i<saveResultList.size();i++){
            Database.SaveResult saveResult = saveResultList.get(i);
            if (!saveResult.isSuccess()) {
                for (Database.Error error : saveResult.getErrors()) {
                    // If there are duplicates, an error occurs
                    // Process only duplicates and not other errors 
                    //   (e.g., validation errors)
                    if (error instanceof Database.DuplicateError) {
                        Database.DuplicateError duplicateError = (Database.DuplicateError)error;
                        Datacloud.DuplicateResult duplicateResult = duplicateError.getDuplicateResult();
                        
                        // Return only match results of matching rules that 
                        //  find duplicate records
                        Datacloud.MatchResult[] matchResults = duplicateResult.getMatchResults();
                        
                        // Just grab first match result (which contains the 
                        //   duplicate record found and other match info)
                        Datacloud.MatchResult matchResult = matchResults[0];
                        
                        Datacloud.MatchRecord[] matchRecords = matchResult.getMatchRecords();
                        
                        // Add matched record to the duplicate records variable
                        for (Datacloud.MatchRecord matchRecord : matchRecords) {
                            System.debug('MatchRecord: ' + matchRecord.getRecord());
                            String matchingId = matchRecord.getRecord().Id;
                            if( matchingId.startsWith('001')){
                                Account acc = (Account) matchRecord.getRecord();
                                errmsg = ' compte : '+ acc.Name;
                            }else if(matchingId.startsWith('003')){
                                Contact cont = (Contact) matchRecord.getRecord();
                                errmsg = ' contact : '+ cont.Name;
                            }
                        }
                    }else{
                        errmsg += '|validateResult Error : ' + error.getMessage();
                    }
                }
                
            }
        }
        return errmsg;
    }
}