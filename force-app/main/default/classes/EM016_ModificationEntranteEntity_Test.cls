@isTest
public with sharing class EM016_ModificationEntranteEntity_Test {
    @isTest
    static void EM016_ModificationEntranteEntity_Test() {//TEST
        EM016_ModificationEntranteEntity entity = new EM016_ModificationEntranteEntity();
        Account acc = UM002_TestDataFactory.createAccount('test acc');
        insert acc;
        Contract contract = UM002_TestDataFactory.createContract(acc.id);	
        insert contract;
        List<Opportunity> oppties = UM002_TestDataFactory.createOpportunities(1, 'test opp', 'Prospecting');
        insert oppties;
        SBQQ__Quote__c quote = UM002_TestDataFactory.createQuotes(1, new List<Account>{acc}, oppties).get(0);
        insert quote;
        LPCR_ModificationEntrante__c tempModif = new LPCR_ModificationEntrante__c(
                                    LPCR_Devis__c  = quote.Id,
                                    LPCR_Contract__c = contract.Id,
                                    LPCR_Evenement__c  = 'EVT_VALIDATION_CONTRAT_DIRECTRICE');
        insert tempModif;
        
        Test.startTest();
        List<LPCR_ModificationEntrante__c> listModifs = new List<LPCR_ModificationEntrante__c>{tempModif};
        List<LPCR_ModificationEntrante__c> tempModifResult = EM016_ModificationEntranteEntity.getModifEntranteById(listModifs);
        Test.stopTest();

        System.assertEquals(1, tempModifResult.size());

    }
}