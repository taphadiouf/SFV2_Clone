/**
 * @ author Makboub Hanae
 * @ created 21/02/2020
 * @ description Apex class on the convert button in the lead famille convertion process
 */




public with sharing class APC001_IS241_LeadFaConverController {
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountsByRecordtype(String recordTypeName) {
        Id recordtypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Account','Crèche');
        List<Account> accounts = [SELECT Name FROM Account WHERE RecordTypeId = :recordtypeId];
        return accounts;
    }

    @AuraEnabled()
    public static Id createAccountFromLead(Id leadId){
        Contact newContact2 = new Contact();
        Account newAccount = new Account();
        Contact contactEnfant1 = new Contact();
        Lead currentLead = EM002_LeadEntity.getAllLeadfielsById(leadId);
        Contact newContact1 = new Contact(LastName =currentLead.LastName, OwnerId = currentLead.OwnerId, Phone = currentLead.Phone, Email = currentLead.Email );
        insert newContact1;
        if(currentLead.LPCR_CiviliteCoDemandeur__c == NULL){
            newContact2 = new Contact(LastName =currentLead.LPCR_PrenomCoDemandeur__c+' '+currentLead.LPCR_NomCoDemandeur__c, Birthdate = currentLead.LPCR_DateNaissance1__c, OwnerId = currentLead.OwnerId, Email = currentLead.LPCR_EmailCoDemandeur__c );
        }else{
            newContact2 = new Contact(LastName =currentLead.LPCR_CiviliteCoDemandeur__c+' '+currentLead.LPCR_PrenomCoDemandeur__c+' '+currentLead.LPCR_NomCoDemandeur__c, Birthdate = currentLead.LPCR_DateNaissance1__c, OwnerId = currentLead.OwnerId, Email = currentLead.LPCR_EmailCoDemandeur__c );
        }
        insert newContact2;
        if(newContact1.LastName.equals(newContact2.LastName)){
            newAccount = new Account(Name = 'Famille '+currentLead.LastName);
        }else{
            newAccount = new Account(Name = 'Famille '+currentLead.LastName+' '+currentLead.LPCR_NomCoDemandeur__c, RecordTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Account','Famille'));
        }
        insert newAccount;    
        if(currentLead.LPCR_CiviliteCoDemandeur__c == NULL){
            contactEnfant1 = new Contact(LastName =currentLead.LPCR_PrenomCoDemandeur__c+' '+currentLead.LPCR_NomCoDemandeur__c, Birthdate = currentLead.LPCR_DateNaissance1__c, OwnerId = currentLead.OwnerId);
        }else{
            contactEnfant1 = new Contact(LastName =currentLead.LPCR_CiviliteCoDemandeur__c+' '+currentLead.LPCR_PrenomCoDemandeur__c+' '+currentLead.LPCR_NomCoDemandeur__c, Birthdate = currentLead.LPCR_DateNaissance1__c, OwnerId = currentLead.OwnerId);
        }
        insert contactEnfant1;    
        return newContact1.Id;
    }
}