@isTest
public with sharing class SM025_SendContact_Callout_Test {
    @isTest
    private static void SM025_SendContact_Callout_Test() {

        Test.setMock(HttpCalloutMock.class, new MCK001_LPCRHttpCalloutMockImpl());

        Id entrepriseRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Entreprise);
        //Id entrepriseRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Famille);
        Account  acc1 = new Account(Name = 'name1z',recordtypeid=entrepriseRecTypeId,LPCR_PASDESIRET__C=true);
        insert acc1;

        Contact c = new Contact(    FirstName = 'first',
                        	Lastname = 'last',
                        	AccountId = acc1.id,
                        	Email = 'firstlast@gmail.com');
        Test.startTest();
        insert c;
        Test.stopTest();

        LPCR_Log__c log = [SELECT id,LPCR_Result__c from LPCR_Log__c where LPCR_TargetObject__c =: c.id limit 1];
        System.assertEquals(UM010_Constant.SUCCESS, log.LPCR_Result__c);
        System.assertEquals(c.LPCR_ContactAEnvoyer__c, false);
        
    }
}
