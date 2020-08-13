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
        
        //insert params
        List<LPCR_ParametrageScore__c> listParams = UM002_TestDataFactory.createParametrageScores (acc.Id);       
        insert listParams;
        
        //insert preinscription
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
        
        
        
        preinsciption.LPCR_DateEntreeCreche__c = Date.newInstance(2020, 09, 01);
        preinsciption.LPCR_InteretConfirme__c = true;
        
        preinsciption.LPCR_CompteEntreprise__c = acc.Id;
        insert preinsciption;
        
        
        
    }        
    
    //Test the method setPreinscriptionScore_Test from SM009_ParametrageScoreServices
    @isTest
    public static void setPreinscriptionScore_Test(){
      
        System.runAs(UM002_TestDataFactory.createUser()){
            LPCR_Preinscription__c  preinsciption  = [SELECT LPCR_Score__c, LPCR_Statut__c,LPCR_PrenomEnfant__c,NomEnfant__c,LPCR_CompteFamille__c FROM LPCR_Preinscription__c WHERE LPCR_PrenomEnfant__c = 'test'];
            preinsciption.LPCR_ReponseCrecheMunicipale__c='Autre';
            preinsciption.LPCR_DateEntreeEntreprise__c = Date.today().addDays(-3);
            update preinsciption;
        }
        
        System.assertEquals(2475, [SELECT LPCR_Score__c FROM LPCR_Preinscription__c WHERE LPCR_PrenomEnfant__c = 'test'].LPCR_Score__c);
        
    }
}