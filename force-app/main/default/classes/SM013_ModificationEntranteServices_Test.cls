/**
* @author Hanae MAKBOUB
* @date 19/05/2020
* @description Test class for Service class LPCR_ModificationEntrante__c
*/
@isTest
public class SM013_ModificationEntranteServices_Test {
    private static final Id CONTACT_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contact, Label.LPCR_Parent);
    @testSetup 
    static void testSetup(){
        List<Account> accounts = UM002_TestDataFactory.createAccounts(100, 'testAccount');
        List<Opportunity> opps = UM002_TestDataFactory.createOpportunities(100, 'testOpp', 'Prospecting');
        insert accounts;
        insert opps;
        List<SBQQ__Quote__c> quotes = UM002_TestDataFactory.createQuotes(100, accounts, opps);
        insert quotes;
        List<LPCR_ModificationEntrante__c> modifEntrantesValides = UM002_TestDataFactory.createModificationsEntrantes(50,quotes,'Validation Contrat Directrice');
        insert modifEntrantesValides;
        List<LPCR_ModificationEntrante__c> modifEntrantes = UM002_TestDataFactory.createModificationsEntrantes(50,quotes,'Modification Adresse Contact Parent	');
        insert modifEntrantes;
    }
    @isTest
    public static void updateQuotesFromModifEntrantes_Test(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            List<SBQQ__Quote__c> quotesValides = [SELECT Id, SBQQ__Status__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Validé Directrice'];
            System.assertEquals(50, quotesValides.size(), 'Error in SM013_ModificationEntranteServices_Test : problem in updating quotesValides');
            List<SBQQ__Quote__c> quotesNonValides = [SELECT Id, SBQQ__Status__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c != 'Validé Directrice'];
            System.assertEquals(50, quotesNonValides.size(), 'Error in SM013_ModificationEntranteServices_Test : problem in updating quotesNonValides');
            Test.stopTest();
        }
    }
    @isTest
    public static void createUsageFromModifEntrantes_Test(){
        Test.startTest();
        Account acc = UM002_TestDataFactory.createAccounts(1, 'tAccount').get(0);
        insert acc;
        Contact cont = UM002_TestDataFactory.createContacts(1, CONTACT_RT_ID, 'test_lastname', 'test_address').get(0);
        insert cont;
        LPCR_ModificationEntrante__c modifEntrantesValides = new LPCR_ModificationEntrante__c();
        modifEntrantesValides.LPCR_Contact__c= cont.id;
        modifEntrantesValides.LPCR_Compte__c = acc.id;
        modifEntrantesValides.LPCR_Evenement__c= 'Modification Heure Occasionnel MAC';
        modifEntrantesValides.LPCR_HeureDateDebut__c = System.today();
        modifEntrantesValides.LPCR_HeureDateFin__c = System.today().addDays(60);
        modifEntrantesValides.LPCR_Quantite__c = 1;
        insert modifEntrantesValides;
        
        Test.stopTest();
    }
}