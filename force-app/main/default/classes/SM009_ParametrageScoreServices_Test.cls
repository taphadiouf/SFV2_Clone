/**
* @author Ayoub Ouarti
* @created 27/02/2020
* @description Test Class of SM009_ParametrageScoreServices.
*/
@isTest
public class SM009_ParametrageScoreServices_Test {
    
    @testSetup 
    
    static void testSetup(){
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
        
        
        preinsciption.LPCR_ReponseCrecheMunicipale__c='Non';
        preinsciption.LPCR_DateEntreeCreche__c= Date.newInstance(2020, 09, 01);
        preinsciption.LPCR_DateEntreeEntreprise__c = Date.today().addDays(-3);
        preinsciption.LPCR_Revenu__c =12000;

        
        insert preinsciption;
        
        
        List<LPCR_ParametrageScore__c> listParams = UM002_TestDataFactory.createParametrageScores (acc.Id);       
        insert listParams;
    }        
    
    //Test the method setPreinscriptionScore_Test from SM009_ParametrageScoreServices
    @isTest
    public static void setPreinscriptionScore_Test(){
        
        LPCR_Preinscription__c  preinsciption  = [SELECT LPCR_Score__c, LPCR_Statut__c,LPCR_PrenomEnfant__c,NomEnfant__c,LPCR_CompteFamille__c FROM LPCR_Preinscription__c WHERE LPCR_PrenomEnfant__c = 'test'];
        
        Test.startTest();
        System.runAs(UM002_TestDataFactory.createUser()){
            preinsciption.LPCR_Statut__c = 'Confirmé';
            update preinsciption;
            preinsciption  = [SELECT LPCR_ReponseCrecheMunicipale__c,LPCR_Score__c FROM LPCR_Preinscription__c WHERE LPCR_PrenomEnfant__c = 'test'];
            System.assertEquals(450,preinsciption.LPCR_Score__c,'Error in SM009_ParametrageScoreServices_Test.setPreinscriptionScore_Test : LPCR_Preinscription__c.LPCR_Score__c is wrong');
            preinsciption.LPCR_ReponseCrecheMunicipale__c='Oui';
            update preinsciption; 
            preinsciption  = [SELECT LPCR_ReponseCrecheMunicipale__c,LPCR_Score__c FROM LPCR_Preinscription__c WHERE LPCR_PrenomEnfant__c = 'test'];
            System.assertEquals(420,preinsciption.LPCR_Score__c,'Error in SM009_ParametrageScoreServices_Test.setPreinscriptionScore_Test : LPCR_Preinscription__c.LPCR_Score__c is wrong');
          
        }
        Test.stopTest();
        
    }
}