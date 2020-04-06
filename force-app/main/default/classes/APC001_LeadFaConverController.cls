/**
 * @ author Makboub Hanae
 * @ created 21/02/2020
 * @ description Apex class on the convert button in the lead famille convertion process
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
    public static List<Account> getAccountsByRecordtype(String recordTypeName) {
       List<Account> accounts = new List<Account>();
       Id recordtypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(System.Label.LPCR_Account,recordTypeName);
       if(UM003_TypeManager.idNotNull(recordtypeId)){
            accounts = [SELECT Name FROM Account WHERE RecordTypeId = :recordtypeId];
        }
        return accounts;
    }
    @AuraEnabled()
    public static void convertLead(Id leadId, List<Integer> enfantsIndexes, Id chosenCrecheId){
        Lead currentLead = EM002_LeadEntity.getAllLeadfielsById(leadId);
        //Creation of Account Famille
        Account newFamilleAccount = new Account(
                                    Name = Label.LPCR_Famille+' '+currentLead.LastName+' '+currentLead.LPCR_NomCoDemandeur__c, 
                                    RecordTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(System.Label.LPCR_Account,System.Label.LPCR_Famille)
                                    );
        insert newFamilleAccount;  

        //Creation of contacts (Enfant & Representant => Parent RT)
        List<Contact> newContacts = new List<Contact>();
        Id parentContactRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(System.Label.LPCR_Contact, System.Label.LPCR_Parent);
        Id enfantContactRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(System.Label.LPCR_Contact, System.Label.LPCR_Enfant);
        Contact contactRepresent1 = new Contact(
                                                LastName =currentLead.LastName, 
                                                FirstName = currentLead.FirstName, 
                                                OwnerId = currentLead.OwnerId, 
                                                Phone = currentLead.Phone, 
                                                Email = currentLead.Email, 
                                                AccountId = newFamilleAccount.Id,
                                                RecordTypeId = parentContactRT
                                                );
        newContacts.add(contactRepresent1);
        Contact contactRepresent2;
        if(String.isNotBlank(currentLead.LPCR_PrenomCoDemandeur__c) && String.isNotBlank(currentLead.LPCR_NomCoDemandeur__c)){
            contactRepresent2 = new Contact(
                    FirstName = (String.isNotBlank(currentLead.LPCR_CiviliteCoDemandeur__c) ? (currentLead.LPCR_CiviliteCoDemandeur__c+ ' ') : '') + currentLead.LPCR_PrenomCoDemandeur__c,
                    LastName = currentLead.LPCR_NomCoDemandeur__c, 
                    OwnerId = currentLead.OwnerId, 
                    Birthdate = currentLead.LPCR_DateNaissance1__c,
                    Email = currentLead.LPCR_EmailCoDemandeur__c, 
                    AccountId = newFamilleAccount.Id,
                    RecordTypeId = parentContactRT
                );
            newContacts.add(contactRepresent2);
        }
        //Create contacts enfants
        for(Integer eachNum : enfantsIndexes){
            newContacts.add(
                new Contact(
                    FirstName = (String) currentLead.get('LPCR_PrenomEnfant' + eachNum + '__c'),
                    LastName = (String) currentLead.get('LPCR_NomEnfant' + eachNum + '__c'), 
                    Birthdate = (Date) currentLead.get('LPCR_DateNaissance' + eachNum + '__c'), 
                    OwnerId = currentLead.OwnerId, 
                    AccountId = newFamilleAccount.Id,
                    RecordTypeId = enfantContactRT
                    ));
        }

        insert newContacts;

        //Set (Reprsentants 1 & 2) for newFamilleAccount  
        newFamilleAccount.LPCR_Representant1__c = contactRepresent1.Id;
        if(contactRepresent2 != null) newFamilleAccount.LPCR_Representant2__c = contactRepresent2.Id;
        update newFamilleAccount;

        //Create AccountContactRelation for (Reprsentants 1 & 2)
        List<AccountContactRelation> accountContactRelations = new List<AccountContactRelation>();
        accountContactRelations.add(
            new AccountContactRelation(
                ContactId = contactRepresent1.Id,
                AccountId = currentLead.LPCR_CompteSociete__c
            )
        );
        if(contactRepresent2 != null){
            accountContactRelations.add(
                new AccountContactRelation(
                    ContactId = contactRepresent2.Id,
                    AccountId = currentLead.LPCR_CompteSocieteCoDemandeur__c
            )
        );
        }
        //Convert the lead
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(leadId);
            lc.setDoNotCreateOpportunity(true);
            lc.setConvertedStatus(convertStatus.MasterLabel);
        	lc.setAccountId(newFamilleAccount.Id);
        	lc.setContactId(contactRepresent1.Id);
            Database.LeadConvertResult lcr = Database.convertLead(lc); 
    }


    @AuraEnabled(cacheable=true)
    public static String getEnfants(Id leadId){
        System.debug('run getEnfants');
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
            if(tempNom != null && tempPrenom != null){
                enfants.add(new WRP002_EnfantWrapper(i, tempNom, tempPrenom, 'Enfant '+i));
            }
        }
        System.debug('enfants ' + enfants);
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
}