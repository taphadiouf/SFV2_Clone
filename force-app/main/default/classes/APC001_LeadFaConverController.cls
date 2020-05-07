/**
* @author Makboub Hanae
* @created 21/02/2020
* @description Apex class on the convert button in the lead famille convertion process
* @Updated by: Achraf ABOUL(Salesforce) 08/04/2020
*/
public with sharing class APC001_LeadFaConverController{
    @AuraEnabled(cacheable = true)
    public static List<Account> getRelatedCreches(Id leadId){
        Set<String> leadFields = new set<String>();
        leadFields.add('LPCR_CodeCreche1__c');
        leadFields.add('LPCR_CodeCreche2__c');
        leadFields.add('LPCR_CodeCreche3__c');
        
        Lead currentLead = (Lead) new EM002_LeadEntity().getById(leadId, leadFields);
        
        Set<Id> accIdsSet = new Set<Id>();
        accIdsSet.add((Id) currentLead.get('LPCR_CodeCreche1__c'));
        accIdsSet.add((Id) currentLead.get('LPCR_CodeCreche2__c'));
        accIdsSet.add((Id) currentLead.get('LPCR_CodeCreche3__c'));
        
        Set<String> accFieldsSet = new Set<String>();
        accFieldsSet.add('Name');
        
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
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountsByRecordtypeName(String recordTypeName) {
        List<Account> accounts = new List<Account>();
        Id recordtypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(System.Label.LPCR_Account,recordTypeName);
        if(UM003_TypeManager.idNotNull(recordtypeId)){
            accounts = [SELECT Name FROM Account WHERE RecordTypeId = :recordtypeId];
        }
        return accounts;
    }
    @AuraEnabled()
    public static void convertLeadCtrl(Id leadId, List<Integer> enfantsIndexes, Id chosenCrecheId, Id chosenCompteId){
        Lead currentLead = EM002_LeadEntity.getAllLeadfielsById(leadId);
        String prenomCoDemandeur = currentLead.LPCR_PrenomCoDemandeur__c;                                         
        String nomCoDemandeur = currentLead.LPCR_NomCoDemandeur__c;                                         
        String civiliteCoDemandeur = currentLead.LPCR_CiviliteCoDemandeur__c; 
        //Create Account (Famille)
        Account newFamilleAccount = new Account(
            Name = Label.LPCR_Famille + ' ' + currentLead.LastName + (nomCoDemandeur != null ? (' ' +nomCoDemandeur) : ''), 
            RecordTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(System.Label.LPCR_Account,System.Label.LPCR_Famille)
        );
        insert newFamilleAccount;  
        ///Create contacts (Enfants and Representants(Parent RT) )
        //Map : Contact Variable Name => Contact Record
        Map<String, Contact> newContactsMap = new Map<String, Contact>();
        //Representants part (Parent)
        Id parentContactRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(System.Label.LPCR_Contact, System.Label.LPCR_Parent);
            newContactsMap.put('contactRep1', new Contact(
            LastName =currentLead.LastName, 
            FirstName = currentLead.FirstName, 
            OwnerId = currentLead.OwnerId, 
            Phone = currentLead.Phone,
            Email = currentLead.Email,
            MailingStreet = currentLead.Address.getStreet(),
            MailingCity = currentLead.Address.getCity(),
            MailingState = currentLead.Address.getState(),
            MailingCountry = currentLead.Address.getCountry(),
            MailingPostalCode = currentLead.Address.getPostalCode(),
            AccountId = newFamilleAccount.Id,
            RecordTypeId = parentContactRT
        ));        
        if(String.isNotBlank(prenomCoDemandeur) && String.isNotBlank(nomCoDemandeur)){
            newContactsMap.put('contactRep2', new Contact(
                FirstName = (String.isNotBlank(civiliteCoDemandeur) ? (civiliteCoDemandeur + ' ') : '') + prenomCoDemandeur,
                LastName = nomCoDemandeur, 
                OwnerId = currentLead.OwnerId, 
                Birthdate = currentLead.LPCR_DateNaissance1__c,
                Email = currentLead.LPCR_EmailCoDemandeur__c,
                MailingStreet = currentLead.Address.getStreet(),
                MailingCity = currentLead.Address.getCity(),
                MailingState = currentLead.Address.getState(),
                MailingCountry = currentLead.Address.getCountry(),
                MailingPostalCode = currentLead.Address.getPostalCode(),
                AccountId = newFamilleAccount.Id,
                RecordTypeId = parentContactRT
            ));
        }
        //Enfants part
        Id enfantContactRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(System.Label.LPCR_Contact, System.Label.LPCR_Enfant);
        for(Integer eachIndex : enfantsIndexes){
            newContactsMap.put(
                ('contactEnfant'+ eachIndex),
                new Contact(
                    FirstName = (String) currentLead.get('LPCR_PrenomEnfant' + eachIndex + '__c'),
                    LastName = (String) currentLead.get('LPCR_NomEnfant' + eachIndex + '__c'), 
                    Birthdate = (Date) currentLead.get('LPCR_DateNaissance' + eachIndex + '__c'), 
                    OwnerId = currentLead.OwnerId, 
                    AccountId = newFamilleAccount.Id,
                    RecordTypeId = enfantContactRT
                ));
        }
        insert newContactsMap.values();
        
        //Set Reprsentants1 and Reprsentants2 fields for newFamilleAccount  
        newFamilleAccount.LPCR_Representant1__c = newContactsMap.get('contactRep1').Id;
        if(newContactsMap.get('contactRep2') != null) newFamilleAccount.LPCR_Representant2__c = newContactsMap.get('contactRep2').Id;
        update newFamilleAccount;
        //Create AccountContactRelation for Reprsentants1 and Reprsentants2 contacts
        List<AccountContactRelation> accountContactRelations = new List<AccountContactRelation>();
        accountContactRelations.add(
            new AccountContactRelation(
                ContactId = newContactsMap.get('contactRep1').Id,
                AccountId = currentLead.LPCR_CompteSociete__c
            )
        );
        if(newContactsMap.get('contactRep2') != null){
            accountContactRelations.add(    
                new AccountContactRelation(
                    ContactId = newContactsMap.get('contactRep2').Id,
                    AccountId = currentLead.LPCR_CompteSocieteCoDemandeur__c
                )
            );
        }
        insert accountContactRelations;
        //Convert the lead
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(leadId);
        lc.setDoNotCreateOpportunity(false);
        lc.setConvertedStatus(convertStatus.MasterLabel);
        lc.setAccountId(newFamilleAccount.Id);
        lc.setContactId(newContactsMap.get('contactRep1').Id);
        Database.LeadConvertResult lcr = Database.convertLead(lc); 
        
        //Create a quote for each child (enfant)
        List<SBQQ__Quote__c> quotesList = new List<SBQQ__Quote__c>();
        Contact tmpContactEnfant;
        Contact tmpContactRep1;
        Contact tmpContactRep2;
        currentLead = EM002_LeadEntity.getAllLeadfielsById(leadId);
            for(Integer eachIndex : enfantsIndexes){
            tmpContactEnfant = newContactsMap.get('contactEnfant' + eachIndex);
            tmpContactRep1 = newContactsMap.get('contactRep1');
            tmpContactRep2 = newContactsMap.get('contactRep2');   
            quotesList.add(
                new SBQQ__Quote__c(
                    LPCR_DateDebut__c = (Date) currentLead.get('LPCR_DateEntreeCreche' + eachIndex + '__c'),
                    LPCR_Creche__c = chosenCrecheId,
                    SBQQ__Account__c = chosenCompteId,
                    LPCR_ContactEnfant__c = (tmpContactEnfant != null ? tmpContactEnfant.Id : null),
                    LPCR_ContactRepresentant1__c = (tmpContactRep1 != null ? tmpContactRep1.Id : null),
                    LPCR_ContactRepresentant2__c = (tmpContactRep2 != null ? tmpContactRep2.Id : null),
                    SBQQ__Opportunity2__c = currentLead.convertedOpportunityId
                )
            );
        }
        insert quotesList;
        
        if(currentLead.LPCR_TypePrestation__c == 'Occasionnel'){
            for(SBQQ__Quote__c eachQuote : quotesList){
                eachQuote.LPCR_TypeAccueil__c = 'Occasionnel';
            }
            update quotesList;
        }
    }
    
    
    
}