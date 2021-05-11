@isTest
public with sharing class EM012_RessourceFamilleEntity_Test {
    @isTest
    static void testSaveOrUpdte_One() {
        Account  acc = new Account(Name = 'testAccount');	
        insert acc;
        Contact c = new Contact(lastname='TestContact',accountid=acc.id);
        insert c;
        LPCR_RessourceFamille__c r = UM002_TestDataFactory.createRessourceFamille(Date.newInstance(2020, 11, 1),acc.id,c.id);
        LPCR_RessourceFamille__c upserted = EM012_RessourceFamilleEntity.saveOrUpdte(r);
        system.assert(upserted.id != null);
    }
    @isTest
    static void testSaveOrUpdte_List() {
        Account  acc = new Account(Name = 'testAccount');	
        insert acc;
        Contact c = new Contact(lastname='TestContact',accountid=acc.id);
        insert c;
        LPCR_RessourceFamille__c r = UM002_TestDataFactory.createRessourceFamille(Date.newInstance(2020, 12, 1),acc.id,c.id);
        LPCR_RessourceFamille__c r2 = UM002_TestDataFactory.createRessourceFamille(Date.newInstance(2020, 12, 2),acc.id,c.id);
        List<LPCR_RessourceFamille__c> upserted = EM012_RessourceFamilleEntity.saveOrUpdte( new List<LPCR_RessourceFamille__c>{r,r2});
        for(LPCR_RessourceFamille__c eachR : upserted){
            system.assert(eachR.id != null);
        }
    }
}