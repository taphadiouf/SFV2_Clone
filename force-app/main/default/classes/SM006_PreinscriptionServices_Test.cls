/**
* @author Ayoub Ouarti
* @created 27/02/2020
* @description Test Class of SM006_PreinscriptionServices.
* @Updated by hanae on 12/03/2020
* @Updated by Achraf ABOUL on 04/05/2020
*/
@isTest
public class SM006_PreinscriptionServices_Test {
    
    @testSetup 
    
    static void testSetup(){
        Id enfantContactRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contact, Label.LPCR_Enfant);
      //  List<Contact> enfantsContactsListOCC= UM002_TestDataFactory.createContacts(20, enfantContactRT, 'test_lastname', 'test_address');
      //  List<Contact> enfantsContactsListDEF= UM002_TestDataFactory.createContacts(20, enfantContactRT, 'test_lastname', 'test_address');
        List<Contact> enfantsContactsListDSP= UM002_TestDataFactory.createContacts(20, enfantContactRT, 'test_lastname', 'test_address');
     //   insert enfantsContactsListOCC;  
      //  insert enfantsContactsListDEF;
        insert enfantsContactsListDSP;
        
        Id familleContactRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contact, Label.LPCR_Parent);
     //   List<Contact> parentContactsListOCC= UM002_TestDataFactory.createContacts(20, familleContactRT, 'test_lastname', 'test_address');
        List<Contact> parentContactsListDEF= UM002_TestDataFactory.createContacts(20, familleContactRT, 'test_lastname', 'test_address');
        List<Contact> parentContactsListDSP= UM002_TestDataFactory.createContacts(20, familleContactRT, 'test_lastname', 'test_address');
      //  insert parentContactsListOCC;
      //  insert parentContactsListDEF;
        insert parentContactsListDSP;

        Id familleAccountRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Famille);
      //  List<Account> famillesAccountListOCC= UM002_TestDataFactory.createAccounts(20, familleAccountRT, 'test_name');
     //   List<Account> famillesAccountListDEF= UM002_TestDataFactory.createAccounts(20, familleAccountRT, 'test_name');
        List<Account> famillesAccountListDSP= UM002_TestDataFactory.createAccounts(20, familleAccountRT, 'test_name');
    //    insert famillesAccountListOCC;
     //   insert famillesAccountListDEF;
        insert famillesAccountListDSP;
        
        List<LPCR_Preinscription__c> allPreInscrList = new List<LPCR_Preinscription__c>();
        //Add OCC Preinscription
      //  allPreInscrList.addAll(UM002_TestDataFactory.createPreinscriptions(famillesAccountListOCC, enfantsContactsListOCC, parentContactsListOCC, Label.LPCR_Nouveau, Label.LPCR_OCC));
        //Add DEF Preinscription
    //    allPreInscrList.addAll(UM002_TestDataFactory.createPreinscriptions(famillesAccountListDEF, enfantsContactsListDEF, parentContactsListDEF, Label.LPCR_Nouveau, Label.LPCR_DEF));
        //Add DSP Preinscription
        allPreInscrList.addAll(UM002_TestDataFactory.createPreinscriptions(famillesAccountListDSP, enfantsContactsListDSP, parentContactsListDSP, Label.LPCR_Nouveau, Label.LPCR_DSP));
        
        insert allPreInscrList;
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
            //Assert the creation of opportunities
            System.assertEquals(allPreInscrList.size(), opptys.size(),'Error in SM006_PreinscriptionServices_Test.createOpptyAndQuoteForPreinsc_Test : Fail to create the exacte number of Opportunities');
            //Assert the creation of the quotes
            System.assertEquals(allPreInscrList.size(), quotes.size(),'Error in SM006_PreinscriptionServices_Test.createOpptyAndQuoteForPreinsc_Test : Fail to create the exacte number of Quotes');
            Id accueilQuoteRecordTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote, Label.LPCR_ContratA);
            //Assert that the quotes have the good recordtype which is : Label.LPCR_ContratA (Contrat_Accueil)
            for(SBQQ__Quote__c eachQuote : quotes){
                System.assertEquals(accueilQuoteRecordTypeId, eachQuote.RecordTypeId,'Error in SM006_PreinscriptionServices_Test.createOpptyAndQuoteForPreinsc_Test : Fail to create the exacte record type for Quote');
            } 
            //Assert that the Field LPCR_ContactParent__c of the "Famille" Account is set correctly
            for(LPCR_Preinscription__c eachPreinsc : [SELECT LPCR_ContactParent__c, LPCR_CompteFamille__r.LPCR_Representant1__c FROM LPCR_Preinscription__c]){
                System.assertEquals(eachPreinsc.LPCR_CompteFamille__r.LPCR_Representant1__c, eachPreinsc.LPCR_ContactParent__c, 'Error in SM006_PreinscriptionServices_Test.createOpptyAndQuoteForPreinsc_Test : Fail to update LPCR_Representant1__c of LPCR_CompteFamille__c');
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
            List<LPCR_Preinscription__c> listAttPreinscList  = [SELECT LPCR_Statut__c FROM LPCR_Preinscription__c WHERE LPCR_Statut__c = :Label.LPCR_ListeAtt];
            Test.stopTest(); 
            System.assertEquals(allPreInscrList.size(), listAttPreinscList.size(),'Error in SM006_PreinscriptionServices_Test.setStatusWhenValidateFormulaireIsTrue_Test : LPCR_Preinscription__c.LPCR_Statut__c not equals Liste d’attente ');            
               
        }
    }
}