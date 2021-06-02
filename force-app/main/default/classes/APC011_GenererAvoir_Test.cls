
@isTest
public with sharing class APC011_GenererAvoir_Test {
    @testSetup 
    static void  testSetup() {
        
        Account acc = UM002_TestDataFactory.createAccounts(1, 'test').get(0);
        insert acc;
        LPCR_Avoir__c avoir= new LPCR_Avoir__c(LPCR_CompteClient__c=acc.id, LPCR_Montant__c=80, LPCR_Description__c='test', LPCR_DateFacture__c=System.today(), LPCR_NomSociete__c =acc.id);
        insert avoir;
    }
    @isTest
    public static void testMethod1(){
        LPCR_Avoir__c avoir=[SELECT Id, LPCR_CompteClient__c, LPCR_Montant__c, LPCR_Description__c, LPCR_DateFacture__c, LPCR_NomSociete__c FROM LPCR_Avoir__c limit 1 ];
        ApexPages.StandardController sc = new ApexPages.standardController(avoir);

        APC011_GenererAvoir controller = new APC011_GenererAvoir(sc);
        Test.startTest();
        APC011_GenererAvoir.GenererAvoir(avoir.ID);
        Test.stopTest();
    }
}
