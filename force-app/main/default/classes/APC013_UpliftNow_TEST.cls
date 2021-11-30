/**
 * @description       : 
 * @author            : Widaad Papauretty
 * @group             : 
 * @last modified on  : 10-15-2021
 * @last modified by  : Widaad Papauretty
**/
@isTest

public with sharing class APC013_UpliftNow_TEST {
    
    private static final Id CONTRACT_RESERVATRICE_RT_ID =   EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract, Label.LPCR_Reservataire);
    private static final Id B2C_RT_ID =                     EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Famille);

    @isTest
    public static void APC013_UpliftNow_TEST() {

  
        //create account
        Account acc = UM002_TestDataFactory.createAccounts(1, 'test').get(0);
        insert acc; 
        
        //create opportunity
        Opportunity opp = UM002_TestDataFactory.createOpportunities(10, 'testOpp', 'Client').get(0);
        insert opp;

        //create contract
        Contract con = new Contract (   AccountID               = acc.id,
                                        SBQQ__Opportunity__c    = opp.id,
                                        LPCR_Sales_Rep__c       = UserInfo.getUserId(),
                                        LPCR_ResponsableADV__c  = UserInfo.getUserId(),
                                        LPCR_ResponsableServiceFamille__c = UserInfo.getUserId(),
                                        StartDate               = System.today(),
                                        ContractTerm            = 12,
                                        LPCR_DateDebut__c       = Date.newInstance(2020,10, 01),
                                        LPCR_DateFin__c         = Date.newInstance(2020, 10, 30),
                                        LPCR_MethodeRenouvellement__c = 'Express',
                                        RecordTypeId = CONTRACT_RESERVATRICE_RT_ID
                                    );

        insert con;

        APC013_UpliftNow.doUplift(con.id);
        
        //create quote & quote lines
        // SBQQ__Quote__c quote =UM002_TestDataFactory.createQuotes(1, acc, opp);
        // insert quote;


    }
}