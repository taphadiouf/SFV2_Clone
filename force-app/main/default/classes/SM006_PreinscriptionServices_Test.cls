/**
* @author Ayoub Ouarti
* @created 27/02/2020
* @description Test Class of SM006_PreinscriptionServices.
* @Updated by hanae on the 12/03/2020
* @Updated by Achraf ABOUL on the 04/05/2020
*/
@isTest
public class SM006_PreinscriptionServices_Test {
    
    @testSetup 
    
    static void testSetup(){
        Id enfantContactRecordTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Contact', Label.LPCR_Enfant);
        Account acc = UM002_TestDataFactory.createAccount('test');
        insert acc;
        
        UM002_TestDataFactory.ContactTdf c = new UM002_TestDataFactory.ContactTdf();
        Contact contactEnfant= c.create('Test','Test', acc);
        contactEnfant.RecordTypeId = enfantContactRecordTypeId;
        insert contactEnfant;
        List<LPCR_Preinscription__c> lstPreinscritionsOCC = UM002_TestDataFactory.createPreinscriptions(50, Label.LPCR_NonTraite, Label.LPCR_OCC, contactEnfant.Id);
        List<LPCR_Preinscription__c> lstPreinscritionsDEF = UM002_TestDataFactory.createPreinscriptions(50, Label.LPCR_NonTraite, Label.LPCR_DEF, contactEnfant.Id);
        List<LPCR_Preinscription__c> lstPreinscritionsDSP = UM002_TestDataFactory.createPreinscriptions(50, Label.LPCR_NonTraite, Label.LPCR_DSP, contactEnfant.Id);
        insert lstPreinscritionsOCC;
        insert lstPreinscritionsDEF;
        insert lstPreinscritionsDSP;
    }        
    
    //Test the method createOpptyAndQuoteForPreinsc_Test from SM006_PreinscriptionServices class indirectly
    @isTest
    public static void createOpptyAndQuoteForPreinsc_Test(){
        
        
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            List<LPCR_Preinscription__c>  allPreInscrList  = [SELECT LPCR_Statut__c, LPCR_TypePreinscription__c FROM LPCR_Preinscription__c];
            for(LPCR_Preinscription__c eachPreinsc : allPreInscrList){
                eachPreinsc.LPCR_Statut__c = Label.LPCR_Confirme;
            }
            update allPreInscrList;
            List<Opportunity> opptys = [SELECT Id FROM Opportunity];
            List<SBQQ__Quote__c> quotes = [SELECT Id,RecordTypeId FROM SBQQ__Quote__c];
            System.assertEquals(allPreInscrList.size(), opptys.size(),'Error in SM006_PreinscriptionServices_Test.createOpptyAndQuoteForPreinsc_Test : Fail to create the exacte number of Opportunities');
            System.assertEquals(allPreInscrList.size(), quotes.size(),'Error in SM006_PreinscriptionServices_Test.createOpptyAndQuoteForPreinsc_Test : Fail to create the exacte number of Quotes');
            Id accueilQuoteRecordTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('SBQQ__Quote__c','Contrat_Accueil');
            for(SBQQ__Quote__c eachQuote : quotes){
                System.assertEquals(accueilQuoteRecordTypeId, eachQuote.RecordTypeId,'Error in SM006_PreinscriptionServices_Test.createOpptyAndQuoteForPreinsc_Test : Fail to create the exacte record type for Quote');
            } 
            Test.stopTest();
        }
    }
    
    
    //Test the method setStatusWhenValidateFormulaireIsTrue_Test from SM006_PreinscriptionServices class indirectly
    @isTest
    public static void setStatusWhenValidateFormulaireIsTrue_Test(){
        
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            List<LPCR_Preinscription__c>  allPreInscrList  = [SELECT LPCR_ValidationFormulaire__c,LPCR_Statut__c FROM LPCR_Preinscription__c];
            for(LPCR_Preinscription__c eachPreinscr : allPreInscrList){
                eachPreinscr.LPCR_Statut__c = Label.LPCR_Confirme;
                eachPreinscr.LPCR_ValidationFormulaire__c = true;
            }
            update allPreInscrList;
            allPreInscrList  = [SELECT LPCR_Statut__c FROM LPCR_Preinscription__c WHERE LPCR_Statut__c = :Label.LPCR_ListeAtt];
            Test.stopTest(); 
            System.assertEquals(allPreInscrList.size(), allPreInscrList.size(),'Error in SM006_PreinscriptionServices_Test.setStatusWhenValidateFormulaireIsTrue_Test : LPCR_Preinscription__c.LPCR_Statut__c not equals Liste d’attente ');            
               
        }
        
        
    }
}