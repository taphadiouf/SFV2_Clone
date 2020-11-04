@isTest
public class APB014_ModificationEntrante_Test {

    @isTest
    static void APB014_TraitementModificationEntrante_Test() {

        Account acc = UM002_TestDataFactory.createAccount('test acc');
        insert acc;
        Account acc2 = UM002_TestDataFactory.createAccount('test2 acc');
        insert acc2;
        Contract contract = UM002_TestDataFactory.createContract(acc.id);	
        insert contract;

        List<Opportunity> oppties = UM002_TestDataFactory.createOpportunities(1, 'test opp', 'Prospecting');
        insert oppties;

        SBQQ__Quote__c quote = UM002_TestDataFactory.createQuotes(1, new List<Account>{acc}, oppties).get(0);
        insert quote;

        contract.SBQQ__Quote__c = quote.id;
        update contract;

        Id rtContactFamille = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Contact', 'Famille' );
        Contact contact = UM002_TestDataFactory.createContact('test contact', rtContactFamille);
        insert contact;

        LPCR_RessourceFamille__c rf = new LPCR_RessourceFamille__c();
        rf.LPCR_CompteFamille__c = acc2.id;
        rf.LPCR_ContactEnfant__c = contact.id;
        insert rf;

        LPCR_ModificationEntrante__c tempModif = new LPCR_ModificationEntrante__c(LPCR_Devis__c  = quote.Id,LPCR_Contract__c = contract.Id,LPCR_Evenement__c  = 'Validation Contrat Directrice');
        tempModif.LPCR_DateEffet__c = Date.today().addDays(-1);
        tempModif.LPCR_EtatTraitement__c = false;
        tempModif.LPCR_Statut__c = 'Validée';
        tempModif.LPCR_Quantite__c = 1;
        tempModif.LPCR_Compte__c = acc2.id ;
        tempModif.LPCR_Contact__c = contact.id;
        insert tempModif;

        Test.startTest();
        APB014_TraitementModificationEntrante sc1 = new APB014_TraitementModificationEntrante();
        sc1.execute(null);
        Test.stopTest();


        LPCR_ModificationEntrante__c afterModif = [SELECT id,LPCR_EtatTraitement__c FROM LPCR_ModificationEntrante__c WHERE LPCR_Evenement__c='Validation Contrat Directrice'];
        SBQQ__Quote__c afterQuote = [SELECT id,SBQQ__Status__c FROM SBQQ__Quote__c WHERE SBQQ__Account__c=:acc.id];

        System.assertEquals(true, afterModif.LPCR_EtatTraitement__c);
        System.assertEquals(afterQuote.SBQQ__Status__c, 'Validé directrice');

    }
}
