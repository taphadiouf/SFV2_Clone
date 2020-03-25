/**
* @author Ayoub Ouarti
* @created 25/03/2020
* @description Test Class of RessourceFamilleServices.
*/
@isTest
public with sharing class SM011_RessourceFamilleServices_Test {
        
       
    @TestSetup
    static void setup(){
       Id standardPricebookId = Test.getStandardPricebookId();

        UM002_TestDataFactory.insertBillingCustomSettings();
        
        blng__LegalEntity__c billingLegalEntity = UM002_TestDataFactory.setupLegalEntity();
        
        blng__RevenueRecognitionRule__c revRecRule = UM002_TestDataFactory.setupRevRec(billingLegalEntity.Id);
        
        blng__BillingRule__c billingRule = UM002_TestDataFactory.setupBillingRule(billingLegalEntity.Id);
        
        blng__TaxRule__c taxRule = UM002_TestDataFactory.setupTaxRule(billingLegalEntity.Id);
        
        Account acc = UM002_TestDataFactory.createAccounts(1,'test').get(0);
        insert acc;

        Product2 prod = UM002_TestDataFactory.createProduct('test', billingRule.Id, revRecRule.Id,taxRule.Id );
        insert prod;

       


      LPCR_RessourceFamille__c ressourceFamille=UM002_TestDataFactory.createRessourceFamille(prod.Id,acc.Id,acc.RecordTypeId,'test',1500);
      insert ressourceFamille;

    }
    

    @IsTest
    static void createNewRessourceFamilleRecord_Test(){
      
        System.runAs(UM002_TestDataFactory.createUser()){
        Test.startTest();
        Date lastDayOfCurrentMonthDate=Date.newInstance(Date.today().Year(), Date.today().month() , Date.daysInMonth(Date.today().year(), Date.today().month())) ;
        Date firstDayOfNextMonthDate=Date.newInstance(Date.today().Year(), Date.today().month()+1 ,1) ;
        LPCR_RessourceFamille__c ressourceFamille =[SELECT  LPCR_DateDebut__c ,
                                                LPCR_CompteFamille__c,
                                                LPCR_Produit__c,
                                                RecordTypeId,
                                                LPCR_TauxMensuel__c FROM LPCR_RessourceFamille__c WHERE name = 'test' LIMIT 1];
           
        
            ressourceFamille.LPCR_TauxMensuel__c*=2;
            update ressourceFamille;

            

        ressourceFamille =[SELECT  LPCR_DateDebut__c ,
                                                LPCR_CompteFamille__c,
                                                LPCR_Produit__c,
                                                RecordTypeId,
                                                LPCR_TauxMensuel__c FROM LPCR_RessourceFamille__c WHERE name = 'test' AND Id=:ressourceFamille.Id];
        LPCR_RessourceFamille__c newRessourceFamille =  [SELECT  LPCR_DateDebut__c ,
                                                LPCR_CompteFamille__c,
                                                LPCR_Produit__c,
                                                RecordTypeId,
                                                LPCR_TauxMensuel__c FROM LPCR_RessourceFamille__c WHERE name = 'test' AND Id<>:ressourceFamille.Id];

       Test.stopTest();
        System.assertEquals(ressourceFamille.LPCR_CompteFamille__c, newRessourceFamille.LPCR_CompteFamille__c,'not the same account');
        System.assertEquals(ressourceFamille.LPCR_Produit__c, newRessourceFamille.LPCR_Produit__c,'not the sama product');
        System.assertEquals(firstDayOfNextMonthDate, newRessourceFamille.LPCR_DateDebut__c,'Date is wrong');
        System.assertEquals(lastDayOfCurrentMonthDate, ressourceFamille.LPCR_DateFin__c,'Date is wrong');
        }
       
        
        
    }
}
