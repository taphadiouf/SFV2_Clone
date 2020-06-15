/**
* @author Achraf ABOUL 
* @date 05/06/2020
* @Description Test class for APC007_ShowCrechesLpcrController
*/
@isTest
public with sharing class APC007_ShowCrechesLpcrController_Test {
   
    @testsetup
    public static void setup(){
        Id accountFamilleRTId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Famille);
        Id reseauCrecheAccountRTId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_ReseauLPCR);
        Account familleAccount= UM002_TestDataFactory.createAccounts(1, accountFamilleRTId, 'testAccount').get(0);
        List<Account> reseauAccounts= UM002_TestDataFactory.createAccounts(50, reseauCrecheAccountRTId, 'reseauAccount');
        insert familleAccount;
        insert reseauAccounts;

        Id leadFamilleRTId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Lead, Label.LPCR_Famille);
        Lead familleLead =  UM002_TestDataFactory.createLeads(1, leadFamilleRTId, 'leadlastName', 'companyname', 'Email@gmail.com').get(0);
        insert familleLead;

        Id enfantContactRecordTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contact, Label.LPCR_Enfant);
        UM002_TestDataFactory.ContactTdf c = new UM002_TestDataFactory.ContactTdf();
        Contact newContact= c.create('Test','Test', familleAccount);
        newContact.RecordTypeId = enfantContactRecordTypeId;
        insert newContact;
        LPCR_Preinscription__c newpreinscrition = UM002_TestDataFactory.createPreinscriptions(1,'test1','test2','Recommandation validée',familleAccount.Id,newContact.Id).get(0);
        insert newpreinscrition;
    }
    @isTest
    public static void getAccountsTest(){
        
        Test.startTest();
        Id accountId = [SELECT Id FROM Account WHERE Name = 'testAccount' limit 1].Id;
        Id leadId = [SELECT Id FROM Lead  limit 1].Id;
        Id preinscriptionId = [SELECT Id FROM LPCR_Preinscription__c limit 1].Id;
        APC007_ShowCrechesLpcrController.getAccounts(accountId, 'CompteFamille');
        APC007_ShowCrechesLpcrController.getAccounts(leadId, 'LeadFamille');
        APC007_ShowCrechesLpcrController.getAccounts(preinscriptionId, 'Preinscription');
        Test.stopTest();
        
    }
}
