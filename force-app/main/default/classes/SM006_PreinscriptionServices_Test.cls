/**
* @author Ayoub Ouarti
* @created 27/02/2020
* @description Test Class of SM006_PreinscriptionServices.
*/
@isTest
public class SM006_PreinscriptionServices_Test {
    
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
        insert preinsciption;
    }        
    
    //Test the method createOpptyAndQuoteForPreinsc_Test from SM006_PreinscriptionServices class indirectly
    @isTest
    public static void createOpptyAndQuoteForPreinsc_Test(){
        
        LPCR_Preinscription__c  preinsciption  = [SELECT LPCR_ValidationFormulaire__c,LPCR_Statut__c,LPCR_PrenomEnfant__c,NomEnfant__c,LPCR_CompteFamille__c FROM LPCR_Preinscription__c WHERE LPCR_PrenomEnfant__c = 'test'];
        preinsciption.LPCR_Statut__c='Confirmé';
        update preinsciption;
        List<Opportunity> opptys = [SELECT Id,AccountId FROM Opportunity WHERE AccountId = :preinsciption.LPCR_CompteFamille__c];
        List<SBQQ__Quote__c> quotes = [SELECT Id,RecordTypeId,SBQQ__Account__c FROM SBQQ__Quote__c WHERE SBQQ__Account__c = :preinsciption.LPCR_CompteFamille__c];
        
        Test.startTest();
        System.runAs(UM002_TestDataFactory.createUser()){
            System.assertEquals('Confirmé',preinsciption.LPCR_Statut__c,'Error in SM006_PreinscriptionServices_Test.createOpptyAndQuoteForPreinsc_Test : LPCR_Preinscription__c.LPCR_Statut__c not equals Confirmé ');
            System.assertEquals(1,opptys.size(),'Error in SM006_PreinscriptionServices_Test.createOpptyAndQuoteForPreinsc_Test : Fail to create the exacte number of Opportunities');
            System.assertEquals(1,quotes.size(),'Error in SM006_PreinscriptionServices_Test.createOpptyAndQuoteForPreinsc_Test : Fail to create the exacte number of Quotes');
            
            Id accueilQuoteRecordTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndDeveloperName('SBQQ__Quote__c','Contrat_Accueil');
            for(SBQQ__Quote__c eachQuote : quotes){
                System.assertEquals(accueilQuoteRecordTypeId,eachQuote.RecordTypeId,'Error in SM006_PreinscriptionServices_Test.createOpptyAndQuoteForPreinsc_Test : Fail to create the exacte record type for Quote');
                
            }      
        }
        Test.stopTest();
        
    }
    
    
    //Test the method setStatusWhenValidateFormulaireIsTrue_Test from SM006_PreinscriptionServices class indirectly
    @isTest
    public static void setStatusWhenValidateFormulaireIsTrue_Test(){
        
        LPCR_Preinscription__c  preinsciption  = [SELECT LPCR_ValidationFormulaire__c,LPCR_Statut__c,LPCR_PrenomEnfant__c,NomEnfant__c,LPCR_CompteFamille__c FROM LPCR_Preinscription__c WHERE LPCR_PrenomEnfant__c = 'test'];
        preinsciption.LPCR_Statut__c='Confirmé';
        Test.startTest();
        System.runAs(UM002_TestDataFactory.createUser()){
            preinsciption.LPCR_ValidationFormulaire__c=true;
            update preinsciption;
            preinsciption  = [SELECT LPCR_ValidationFormulaire__c,LPCR_Statut__c,LPCR_PrenomEnfant__c,NomEnfant__c,LPCR_CompteFamille__c FROM LPCR_Preinscription__c WHERE LPCR_PrenomEnfant__c = 'test'];
            System.assertEquals('Liste d’attente',preinsciption.LPCR_Statut__c,'Error in SM006_PreinscriptionServices_Test.setStatusWhenValidateFormulaireIsTrue_Test : LPCR_Preinscription__c.LPCR_Statut__c not equals Liste d’attente ');            
            Test.stopTest();    
        }
        
        
    }
}