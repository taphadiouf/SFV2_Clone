/**
 * @ author Makboub Hanae
 * @ created 21/02/2020
 * @ description Apex class on the convert button in the lead famille convertion process
 */




public with sharing class APC001_LeadFaConverController {
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountsByRecordtype(String recordTypeName) {
       List<Account> accounts = new List<Account>();
       Id recordtypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(System.Label.LPCR_Account,System.Label.LPCR_Creche);
       if(UM003_TypeManager.idNotNull(recordtypeId)){
            accounts = [SELECT Name FROM Account WHERE RecordTypeId = :recordtypeId];
        }
        return accounts;
    }

    @AuraEnabled()
    public static Id createAccountFromLead(Id leadId){
        Account newAccount = new Account();
        Contact newContact2 = new Contact();
        Contact contactEnfant1 = new Contact();
        Lead currentLead = EM002_LeadEntity.getAllLeadfielsById(leadId);
        if(currentLead.FirstName+' '+currentLead.LastName == currentLead.LPCR_PrenomCoDemandeur__c+' '+currentLead.LPCR_NomCoDemandeur__c || currentLead.FirstName+' '+currentLead.LastName == currentLead.LPCR_CiviliteCoDemandeur__c+' '+currentLead.LPCR_PrenomCoDemandeur__c+' '+currentLead.LPCR_NomCoDemandeur__c ){
            newAccount = new Account(Name = 'Famille '+currentLead.LastName, RecordTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(System.Label.LPCR_Account,System.Label.LPCR_Famille));
        }else{
            newAccount = new Account(Name = 'Famille '+currentLead.LastName+' '+currentLead.LPCR_NomCoDemandeur__c, RecordTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(System.Label.LPCR_Account,System.Label.LPCR_Famille));
        }
        insert newAccount;  
        Contact newContact1 = new Contact(LastName =currentLead.LastName, FirstName = currentLead.FirstName , OwnerId = currentLead.OwnerId, Phone = currentLead.Phone, Email = currentLead.Email, AccountId =newAccount.Id  );
        insert newContact1;
        if(currentLead.LPCR_CiviliteCoDemandeur__c == NULL){
            newContact2 = new Contact(FirstName =currentLead.LPCR_PrenomCoDemandeur__c,LastName = currentLead.LPCR_NomCoDemandeur__c, Birthdate = currentLead.LPCR_DateNaissance1__c, OwnerId = currentLead.OwnerId, Email = currentLead.LPCR_EmailCoDemandeur__c, AccountId =newAccount.Id );
        }else{
            newContact2 = new Contact(FirstName =currentLead.LPCR_CiviliteCoDemandeur__c+' '+currentLead.LPCR_PrenomCoDemandeur__c,LastName = currentLead.LPCR_NomCoDemandeur__c, Birthdate = currentLead.LPCR_DateNaissance1__c, OwnerId = currentLead.OwnerId, Email = currentLead.LPCR_EmailCoDemandeur__c, AccountId =newAccount.Id );
        }
        insert newContact2;
          
        if(currentLead.LPCR_CiviliteCoDemandeur__c == NULL){
            contactEnfant1 = new Contact(FirstName =currentLead.LPCR_PrenomCoDemandeur__c, LastName = currentLead.LPCR_NomCoDemandeur__c, Birthdate = currentLead.LPCR_DateNaissance1__c, OwnerId = currentLead.OwnerId, AccountId =newAccount.Id);
        }else{
            contactEnfant1 = new Contact(FirstName =currentLead.LPCR_CiviliteCoDemandeur__c+' '+currentLead.LPCR_PrenomCoDemandeur__c,LastName = currentLead.LPCR_NomCoDemandeur__c, Birthdate = currentLead.LPCR_DateNaissance1__c, OwnerId = currentLead.OwnerId, AccountId =newAccount.Id);
        }
        insert contactEnfant1;   
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(leadId);
            lc.setDoNotCreateOpportunity(true);
            lc.setConvertedStatus(convertStatus.MasterLabel);
        	lc.setAccountId(newAccount.Id);
        	lc.setContactId(newContact1.Id);
            Database.LeadConvertResult lcr = Database.convertLead(lc); 
        return newContact1.Id;
    }
}