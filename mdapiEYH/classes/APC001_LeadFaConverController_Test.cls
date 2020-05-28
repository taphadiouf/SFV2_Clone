/**
* @author Hanae Makboub
* @created 21/02/2020
* @description Test Class  on APC001_LeadFaConverController
* @Updated by: Achraf ABOUL(Salesforce) 08/04/2020
*/

@isTest
public with sharing class APC001_LeadFaConverController_Test {
    
    @testSetup
    public static void setup(){
        Id accountCrecheRTId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Creche);
        Id accountEntrepriseRTId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Entreprise);
        Map<String,Account> accountsMap  = new Map<String, Account>();
        accountsMap.put('Creche1', UM002_TestDataFactory.createAccByRT('Creche1', accountCrecheRTId));
        accountsMap.put('Creche2', UM002_TestDataFactory.createAccByRT('Creche2', accountCrecheRTId));
        accountsMap.put('Creche3', UM002_TestDataFactory.createAccByRT('Creche3', accountCrecheRTId));
        accountsMap.put('Entreprise1', UM002_TestDataFactory.createAccByRT('Entreprise1', accountEntrepriseRTId));
        insert accountsMap.values();
        
        Id leadFamilleRTId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Lead, Label.LPCR_Famille); 
        Map<String, Object> fieldsMap = new Map<String, Object>();
        fieldsMap.put('LastName', 'CurrentLeadLastName');
        fieldsMap.put('FirstName', 'CurrentLeadFirstName');
        fieldsMap.put('Phone', '12');
        fieldsMap.put('Company', 'LeadCompanyName');
        fieldsMap.put('RecordTypeId', leadFamilleRTId);
        fieldsMap.put('LPCR_PrenomCoDemandeur__c', 'PrenomCoDemandeur');
        fieldsMap.put('LPCR_NomCoDemandeur__c', 'NomCoDemandeur');
        fieldsMap.put('LPCR_CodeCreche1__c', accountsMap.get('Creche1').Id);
        fieldsMap.put('LPCR_CodeCreche2__c', accountsMap.get('Creche2').Id);
        fieldsMap.put('LPCR_CodeCreche3__c', accountsMap.get('Creche3').Id);
        fieldsMap.put('LPCR_NomEnfant1__c', 'NomEnfant1');
        fieldsMap.put('LPCR_NomEnfant2__c', 'NomEnfant2');
        fieldsMap.put('LPCR_NomEnfant3__c', 'NomEnfant3');
        fieldsMap.put('LPCR_PrenomEnfant1__c', 'PrenomEnfant1');
        fieldsMap.put('LPCR_PrenomEnfant2__c', 'PrenomEnfant2');
        fieldsMap.put('LPCR_PrenomEnfant3__c', 'PrenomEnfant3');
        fieldsMap.put('LPCR_CompteSociete__c', accountsMap.get('Entreprise1').Id);
        fieldsMap.put('LPCR_CompteSocieteCoDemandeur__c', accountsMap.get('Entreprise1').Id);
        fieldsMap.put('Street', '3 Avenue Octave Greards');
        fieldsMap.put('City', 'Paris');
        fieldsMap.put('PostalCode', '75007');
        fieldsMap.put('State', '');
        fieldsMap.put('LPCR_TypePrestation__c', 'Occasionnel');
        Lead currentLeadFamille = UM002_TestDataFactory.createLeads(1, fieldsMap).get(0);
        insert currentLeadFamille;
    }
    @isTest
    public static void getRelatedCreches_Test(){
        Id leadId = [SELECT Id from Lead limit 1].Id;
        Test.startTest();
        List<Account> crechesList = APC001_LeadFaConverController.getRelatedCreches(leadId);
        System.assertEquals(3, crechesList.size());
        Test.stopTest();
    }
    @isTest
    public static void getEnfants_Test(){
        Id leadId = [SELECT Id from Lead limit 1].Id;
        Test.startTest();
        List<APC001_LeadFaConverController.WRP002_EnfantWrapper> enfantsList = (List<APC001_LeadFaConverController.WRP002_EnfantWrapper>) JSON.deserialize(APC001_LeadFaConverController.getEnfants(leadId), List<APC001_LeadFaConverController.WRP002_EnfantWrapper>.class);
        System.assertEquals(3, enfantsList.size());
        Test.stopTest();
    }
    
    @isTest
    public static void getAccountsByRecordtypeName_Test(){
        Test.startTest();
        List<Account> crecheAccountsList = APC001_LeadFaConverController.getAccountsByRecordtypeName(Label.LPCR_Creche);
        System.assertEquals(3, crecheAccountsList.size());
        Test.stopTest();
    }
    
    @isTest
    public static void convertLeadCtrl_Test() {
        System.runAs(UM002_TestDataFactory.createUser()){
            //Get the current lead with wanted fields
            Set<String> leadFields = new Set<String>();
            leadFields.add('LPCR_CodeCreche1__c');
            leadFields.add('LPCR_CodeCreche2__c');
            leadFields.add('LPCR_CodeCreche3__c');
            leadFields.add('LPCR_CompteSociete__c');
            leadFields.add('LPCR_CompteSocieteCoDemandeur__c');
            leadFields.add('LPCR_TypePrestation__c');
            Lead currentLead = (Lead) new EM002_LeadEntity().getAll(leadFields).get(0);
            
            //Initialize the enfantsIndexes
            List<Integer> enfantsIndexes = new List<Integer>();
            enfantsIndexes.add(Integer.valueOf('1'));
            enfantsIndexes.add(Integer.valueOf('2'));
            enfantsIndexes.add(Integer.valueOf('3'));
            
            //Get the account "Entreprise"
            Id accountEntrepriseRTId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Entreprise);
            Set<String> accountFilterSet = new Set<String>();
            accountFilterSet.add(String.valueOf(accountEntrepriseRTId));
            Account entrepriseAccount = (Account) new EM005_AccountEntity().getBy(Label.LPCR_RecordTypeId, accountFilterSet, null).get(0);
            
            Test.startTest();
            APC001_LeadFaConverController.convertLeadCtrl(currentLead.Id, enfantsIndexes, currentLead.LPCR_CodeCreche1__c, entrepriseAccount.Id);
            
            //Assert the creation of account Famille + The fields LPCR_Representant1__c and LPCR_Representant2__c are well filled
            Id accountFamilleRTId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Famille);
            accountFilterSet = new Set<String>();
            accountFilterSet.add(''+accountFamilleRTId);
            Set<String> accountFields = new Set<String>();
            accountFields.add('LPCR_Representant1__c');
            accountFields.add('LPCR_Representant2__c');
            Map<Id, Account> accountFamilleMap = new Map<Id, Account>((List<Account>) new EM005_AccountEntity().getBy(Label.LPCR_RecordTypeId, accountFilterSet, accountFields));
            System.assertEquals(1, accountFamilleMap.size());
            System.assertNotEquals(null, accountFamilleMap.values().get(0).LPCR_Representant1__c);
            System.assertNotEquals(null, accountFamilleMap.values().get(0).LPCR_Representant2__c);
            
            //Assert the creation of contacts : "Representant1 and Representant 2"
            Id contactParentRTId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contact, Label.LPCR_Parent);
            Set<String> contactFilterSet = new Set<String>();
            contactFilterSet.add(String.valueOf(contactParentRTId));
            Map<Id, Contact> representContactsMap = new Map<Id,Contact>((List<Contact>) new EM011_ContactEntity().getBy(Label.LPCR_RecordTypeId, contactFilterSet, null));
            System.assertEquals(2, representContactsMap.size());
            
            //Assert the creation of contacts : "Enfants"
            Id contactEnfantRTId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contact, Label.LPCR_Enfant);
            contactFilterSet = new Set<String>();
            contactFilterSet.add(String.valueOf(contactEnfantRTId));
            Map<Id, Contact> enfantsContactsMap = new Map<Id, Contact> ((List<Contact>) new EM011_ContactEntity().getBy(Label.LPCR_RecordTypeId, contactFilterSet, null));
            System.assertEquals(3, enfantsContactsMap.size());
            
            //Assert the creation of AccountContactRelation for Representant1 and Representant2
            Set<Id> relatedAccountsIds = new Set<Id>();
            relatedAccountsIds.add(currentLead.LPCR_CompteSociete__c);
            relatedAccountsIds.add(currentLead.LPCR_CompteSocieteCoDemandeur__c);
            
            List<AccountContactRelation> accContactRelations = [SELECT Id FROM AccountContactRelation WHERE ContactId IN :representContactsMap.keySet() AND AccountId IN :relatedAccountsIds];
            System.assertEquals(2, accContactRelations.size());
            
            //Assert the creation of quotes
            List<SBQQ__Quote__c> quotesList = new EM006_QuoteEntity().getBy(Label.LPCR_ContactEnfant, enfantsContactsMap.keySet(), null);
            System.assertEquals(3, quotesList.size());
            Test.stopTest();
        } 
    }
}