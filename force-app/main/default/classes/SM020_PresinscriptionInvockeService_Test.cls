/**
* @author Saurabh
* @date 02/07/2020
* @description Test class for SM020_PresinscriptionInvockeService
*/

@isTest
public class SM020_PresinscriptionInvockeService_Test {
	@isTest
    static void presinscriptionSendEmail_Test(){
        Test.setMock(HttpCalloutMock.class, new MCK001_LPCRHttpCalloutMockImpl());
        Id enfantContactRecordTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Contact', 'Enfant');
        Account acc = UM002_TestDataFactory.createAccount('test');
        insert acc;
        UM002_TestDataFactory.ContactTdf c = new UM002_TestDataFactory.ContactTdf();
        Contact contact= c.create('Test','Test', acc);
        contact.RecordTypeId = enfantContactRecordTypeId;
        insert contact;
        LPCR_Preinscription__c  preinsciption = UM002_TestDataFactory.createPreinscription('test', 'test',acc.Id,contact.Id );
        preinsciption.LPCR_HeureDebutLundi__c   = DateTime.newInstance(2020, 01, 01, 8, 0, 0).Time();
        preinsciption.LPCR_HeureFinLundi__c    = DateTime.newInstance(2020, 01, 01, 16, 0, 0).Time();
        
        preinsciption.LPCR_HeureDebutMardi__c   = DateTime.newInstance(2020, 01, 01, 8, 0, 0).Time();
        preinsciption.LPCR_HeureFinMardi__c    = DateTime.newInstance(2020, 01, 01, 16, 0, 0).Time();
        
        preinsciption.LPCR_HeureDebutMercredi__c   = DateTime.newInstance(2020, 01, 01, 8, 0, 0).Time();
        preinsciption.LPCR_HeureFinMercredi__c    = DateTime.newInstance(2020, 01, 01, 16, 0, 0).Time();
        
        preinsciption.LPCR_HeureDebutJeudi__c   = DateTime.newInstance(2020, 01, 01, 8, 0, 0).Time();
        preinsciption.LPCR_HeureFinJeudi__c    = DateTime.newInstance(2020, 01, 01, 16, 0, 0).Time();
        
        preinsciption.LPCR_HeureDebutVendredi__c   = DateTime.newInstance(2020, 01, 01, 8, 0, 0).Time();
        preinsciption.LPCR_HeureFinVendredi__c    = DateTime.newInstance(2020, 01, 01, 16, 0, 0).Time();
        
        preinsciption.LPCR_Creche__c = acc.Id;
        preinsciption.LPCR_ReponseCrecheMunicipale__c='Refus';
        preinsciption.LPCR_DateEntreeCreche__c= Date.newInstance(2020, 09, 01);
        preinsciption.LPCR_DateEntreeEntreprise__c = Date.today().addDays(-3);
        preinsciption.LPCR_Revenu__c =12000;
        
        insert preinsciption;
        
        Test.startTest();
        
        List<SM020_PresinscriptionInvockeService.PresinscriptionParameter> presinscriptionParameters = new List<SM020_PresinscriptionInvockeService.PresinscriptionParameter>();
        SM020_PresinscriptionInvockeService.PresinscriptionParameter perms = new SM020_PresinscriptionInvockeService.PresinscriptionParameter();
        perms.presinscriptionId = preinsciption.id;
        perms.fromEmail = 'test@mail.com';
        perms.toEmail = 'mytest@mail.com';
        perms.subject = 'subject';
        perms.body = 'body';
        presinscriptionParameters.add(perms);
        SM020_PresinscriptionInvockeService.presinscriptionSendEmail(presinscriptionParameters);
        
        Test.stopTest();
    }
}