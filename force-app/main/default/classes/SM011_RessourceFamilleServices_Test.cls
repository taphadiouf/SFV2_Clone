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
        
        Account acc = UM002_TestDataFactory.createAccounts(1,'test').get(0);
        insert acc;
        
        Product2 prod = new Product2(name='test');
        insert prod;
        List<Date> listStartDates = new List<Date>();
        
        
        insert UM002_TestDataFactory.createRessourceFamille(prod.Id,acc.Id,'test',1500);
        
        List<Decimal> listTauxEffortParEnfant = new List<Decimal>();
        for(Integer i=1;i<=3;i++){
            listTauxEffortParEnfant.add(1);
        }
        for(Integer i=1;i<=3;i++){
            listTauxEffortParEnfant.add(2);
        }
        for(Integer i=1;i<=3;i++){
            listTauxEffortParEnfant.add(3);
        }
        listTauxEffortParEnfant.add(4);
        
        listStartDates = new List<Date>();
        listStartDates.add(Date.newInstance(Date.today().Year(), 1, 1));
        listStartDates.add(Date.newInstance(Date.today().addYears(1).Year(), 1, 1));
        listStartDates.add(Date.newInstance(Date.today().addYears(2).Year(), 1, 1));
        
        List<LPCR_BaremeCAF__c> listBaremeCAF = UM002_TestDataFactory.createBaremeCAF(10, listStartDates,listTauxEffortParEnfant);
        insert listBaremeCAF;
    }
    
    
    @IsTest
    static void createNewRessourceFamilleRecord_Test(){
        
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            Date lastDayOfCurrentMonthDate=Date.newInstance(Date.today().Year(), Date.today().month() , Date.daysInMonth(Date.today().year(), Date.today().month())) ;
            Date firstDayOfNextMonthDate=Date.newInstance(Date.today().Year(), Date.today().month()+1 ,1) ;
            LPCR_RessourceFamille__c ressourceFamille =[SELECT  LPCR_DateFin__c,LPCR_DateDebut__c ,
                                                        LPCR_CompteFamille__c,
                                                        RecordTypeId
                                                        FROM LPCR_RessourceFamille__c WHERE name = 'test' LIMIT 1];

            
            //ressourceFamille.LPCR_TauxMensuel__c*=2;
            update ressourceFamille;
            
            
            
            ressourceFamille =[SELECT  LPCR_DateFin__c,LPCR_DateDebut__c ,
                               LPCR_CompteFamille__c,
                               RecordTypeId
                                FROM LPCR_RessourceFamille__c WHERE name = 'test' AND Id=:ressourceFamille.Id];
            LPCR_RessourceFamille__c newRessourceFamille =  [SELECT LPCR_DateFin__c, LPCR_DateDebut__c ,
                                                             LPCR_CompteFamille__c,
                                                             RecordTypeId FROM LPCR_RessourceFamille__c WHERE name = 'test' AND Id<>:ressourceFamille.Id];
            
            Test.stopTest();
            System.assertEquals(ressourceFamille.LPCR_CompteFamille__c, newRessourceFamille.LPCR_CompteFamille__c,'not the same account');
            //System.assertEquals(ressourceFamille.LPCR_Produit__c, newRessourceFamille.LPCR_Produit__c,'not the same product');
            System.assertEquals(firstDayOfNextMonthDate, newRessourceFamille.LPCR_DateDebut__c,'Date is wrong');
            System.assertEquals(lastDayOfCurrentMonthDate, ressourceFamille.LPCR_DateFin__c,'Date is wrong');
        }
        
    }
    
    @IsTest
    static void updateTheBaremeCaf_Test(){
        
        System.runAs(UM002_TestDataFactory.createUser()){
            List<Date> listStartDates = new List<Date>();
            listStartDates.add(Date.toDay());
            listStartDates.add(Date.toDay().addYears(1));
            listStartDates.add(Date.toDay().addYears(2));
            listStartDates.add(Date.toDay().addYears(2));
            
            List<Decimal> listNbrEnfant = new List<Decimal>();
            listNbrEnfant.add(2);
            listNbrEnfant.add(10);
            listNbrEnfant.add(2);
            listNbrEnfant.add(1);
            
            List<Decimal> listNbrEnfantHandicape = new List<Decimal>();
            listNbrEnfantHandicape.add(2);
            listNbrEnfantHandicape.add(2);
            listNbrEnfantHandicape.add(0);
            listNbrEnfantHandicape.add(1);
            Account acc = [SELECT Name From Account WHERE  Name = 'test'];
            
            Product2 prod = [SELECT Name From Product2 WHERE  Name = 'test'];
            
            Test.startTest();
            List<LPCR_RessourceFamille__c> listRessourceFamille =UM002_TestDataFactory.createRessourceFamille(4, prod.Id, acc.Id, 1000, listStartDates, listNbrEnfant, listNbrEnfantHandicape);
            insert listRessourceFamille;
            
            Test.stopTest();
            listRessourceFamille = [SELECT LPCR_TauxEffort__c,LPCR_BaremeCaf__r.LPCR_TauxEffortParEnfant__c,LPCR_BaremeCaf__c,LPCR_BaremeCaf__r.Name,Name,LPCR_BaremeCaf__r.LPCR_NombresEnfants__c,LPCR_NombreEnfantHandicape__c,LPCR_NombreEnfants__c from  LPCR_RessourceFamille__c WHERE name <> :'test'];
            
            for(LPCR_RessourceFamille__c  eachRessourceFamille : listRessourceFamille){
                
                System.assertNotEquals(null, eachRessourceFamille.LPCR_BaremeCaf__c,'LPCR_BaremeCaf__c is null on the RessourceFamille');
                System.assertNotEquals(null, eachRessourceFamille.LPCR_TauxEffort__c,'LPCR_TauxEffort__c is null on the RessourceFamille');
                System.assertEquals(eachRessourceFamille.LPCR_BaremeCaf__r.LPCR_TauxEffortParEnfant__c, eachRessourceFamille.LPCR_TauxEffort__c,'LPCR_TauxEffortParEnfant__c on LPCR_TauxEffort__c is not equals to LPCR_TauxEffort__c on the RessourceFamille');

                if(eachRessourceFamille.Name.equals('1')){                    
                    System.assertEquals(3,eachRessourceFamille.LPCR_BaremeCaf__r.LPCR_TauxEffortParEnfant__c,'LPCR_BaremeCaf__c is wrong on the RessourceFamille');
                }
                if(eachRessourceFamille.Name.equals('2')){
                    System.assertEquals(4,eachRessourceFamille.LPCR_BaremeCaf__r.LPCR_TauxEffortParEnfant__c   ,'LPCR_BaremeCaf__c is wrong on the RessourceFamille');
                }
                if(eachRessourceFamille.Name.equals('3')){
                    System.assertEquals(1,eachRessourceFamille.LPCR_BaremeCaf__r.LPCR_TauxEffortParEnfant__c   ,'LPCR_BaremeCaf__c is wrong on the RessourceFamille');
                }
                if(eachRessourceFamille.Name.equals('4')){
                    System.assertEquals(2,eachRessourceFamille.LPCR_BaremeCaf__r.LPCR_TauxEffortParEnfant__c   ,'LPCR_BaremeCaf__c is wrong on the RessourceFamille');
                }
            }
            
            
            
        }
    }
}