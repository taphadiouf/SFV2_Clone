@isTest
public with sharing class APC010_AmendLexContractController_Test {
    
    
    private static final Id CONTRACT_RESERVATRICE_RT_ID =   EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract, Label.LPCR_Reservataire);
    private static final Id B2C_RT_ID =                     EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Famille);

    @isTest
    private static void APC010_AmendLexContractController_Test() {


        Account acc = UM002_TestDataFactory.createAccounts(1, 'test').get(0);acc.RecordTypeId = B2C_RT_ID;
        insert acc;

        List<Opportunity> opps = UM002_TestDataFactory.createOpportunities(100, 'testOpp', 'Prospecting');
        Opportunity opp = opps.get(0);
        insert opp;

        Contract con = new Contract(    AccountID               = acc.id,
                                        SBQQ__Opportunity__c    = opp.id,
                                        LPCR_Sales_Rep__c       = UserInfo.getUserId(),
                                        LPCR_ResponsableADV__c  = UserInfo.getUserId(),
                                        LPCR_ResponsableServiceFamille__c = UserInfo.getUserId(),
                                        StartDate               = System.today(),
                                        ContractTerm            = 12,
                                        LPCR_DateDebut__c       = Date.newInstance(2020,05, 01),
                                        LPCR_DateFin__c         = Date.newInstance(2020, 05, 30),
                                        LPCR_MethodeRenouvellement__c = 'Express',
                                        RecordTypeId = CONTRACT_RESERVATRICE_RT_ID);
        insert con;
        String negativeResult = APC010_AmendLexContractController.getContractDetails(con.id);
        System.assertEquals(System.label.LPCR_AmendLexError,negativeResult);

        con.SBQQ__AmendmentStartDate__c = System.today();
        update con;

        String positiveResult = APC010_AmendLexContractController.getContractDetails(con.id);
        System.assertEquals(null,positiveResult);

    }
}