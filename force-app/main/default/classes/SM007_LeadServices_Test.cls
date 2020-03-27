/**
* @author Achraf ABOUL
* @created 28/02/2020
* @description Test Class of SM007_LeadServices.
*/
@isTest
public class SM007_LeadServices_Test {
    @testSetup 
    
    static void testSetup(){
        Id entrepriseLeadRecordType = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Lead', 'Entreprise');
        Id aoPublicReservLeadRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Lead', 'AO_PublicReservation');
        Id aoPublicDSPLeadRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Lead', 'AO_PublicDSP');
        List<Lead> entrepriseLeads = UM002_TestDataFactory.createLeads(100, entrepriseLeadRecordType, 'entrepriseLead', 'entrepriseLead', 'Nouveau', 'test@test.com');
        List<Lead> aoPublicReservLeads = UM002_TestDataFactory.createLeads(100, aoPublicReservLeadRT, 'aoPublicReservLeads', 'aoPublicReservLeads', 'Nouveau', 'test@test.com');
        List<Lead> aoPublicDSPLeads = UM002_TestDataFactory.createLeads(100, aoPublicDSPLeadRT, 'aoPublicDSPLeads', 'aoPublicDSPLeads', 'Nouveau', 'test@test.com');
        
        insert entrepriseLeads;
        insert aoPublicReservLeads;
        insert aoPublicDSPLeads;

        List<Account> accs =  new List<Account>();
        accs.add(UM002_TestDataFactory.createAccount('creche1'));
        accs.add(UM002_TestDataFactory.createAccount('creche2'));
        accs.add(UM002_TestDataFactory.createAccount('creche3'));
        insert accs;
        
        insert UM002_TestDataFactory.createStructuresAOFromLeads(3, entrepriseLeads);
        insert UM002_TestDataFactory.createStructuresAOFromLeads(3, aoPublicReservLeads);
        insert UM002_TestDataFactory.createStructuresAOFromLeads(3, aoPublicDSPLeads);
    }     
    //Test the method syncOppRecordType from SM007_LeadServices.syncOppRecordType method indirectly by using the Lead before update trigger
    
    @isTest
    private static void syncOppRecordType_Test(){
        List<Lead> entrepriseLeads = [SELECT Id,RecordTypeId FROM Lead WHERE Name = 'entrepriseLead'];
        List<Lead> aoPublicReservLeads = [SELECT Id,RecordTypeId FROM Lead WHERE Name = 'aoPublicReservLeads'];
        
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        List<Database.LeadConvert> leadsToConvert = new List<Database.LeadConvert>();
        Database.LeadConvert tempLc;
        for(Lead eachLead : entrepriseLeads){
            tempLc = new Database.LeadConvert();
            tempLc.setLeadId(eachLead.id);
            tempLc.setDoNotCreateOpportunity(false);
            tempLc.setConvertedStatus(convertStatus.MasterLabel);
            leadsToConvert.add(tempLc);
        }
        for(Lead eachLead : aoPublicReservLeads){
            tempLc = new Database.LeadConvert();
            tempLc.setLeadId(eachLead.id);
            tempLc.setDoNotCreateOpportunity(false);
            tempLc.setConvertedStatus(convertStatus.MasterLabel);
            leadsToConvert.add(tempLc);
        }
        Test.startTest();
        System.runAs(UM002_TestDataFactory.createUser()){
            List<Database.LeadConvertResult> lcr = Database.convertLead(leadsToConvert);
            for(Database.LeadConvertResult eachResult : lcr){
                System.assert(eachResult.isSuccess());
            }
            Id entrepriseOppRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Opportunity', 'Entreprise');
            Id aoOppRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Opportunity', 'AOPublicReservation');
                       
            List<Opportunity> entrepriseOpps = [SELECT Id FROM Opportunity WHERE RecordTypeId = :entrepriseOppRecTypeId];
            List<Opportunity> aoOpps = [SELECT Id FROM Opportunity WHERE RecordTypeId = :aoOppRecTypeId];
            System.assertEquals(entrepriseLeads.size(), entrepriseOpps.size(), 'Error in SM007_LeadServices_Test : problem in synchronizing Lead recordtype: Entreprise, with Opportunity recordtype: Entreprise RecordType');
            System.assertEquals(aoPublicReservLeads.size(), aoOpps.size(), 'Error in SM007_LeadServices_Test : problem in synchronizing Lead recordtype: AO_PublicReservation, with Opportunity recordtype: AOPublicReservataire');

        }
        Test.stopTest();
    }
    @isTest
    public static void createLiensCrecheLead_Test(){

        Account creche1 = [SELECT Id FROM Account WHERE Name = 'creche1' limit 1];
        Account creche2 = [SELECT Id FROM Account WHERE Name = 'creche2' limit 1];
        Account creche3 = [SELECT Id FROM Account WHERE Name = 'creche3' limit 1];
        Test.startTest();
        List<Lead> leads1 = UM002_TestDataFactory.createLeadsWithCrecheLink( 100, 'lead lastname 1', 'lead company 1', 'Nouveau', 'test1@test.com', creche1.Id, '1');
        List<Lead> leads2 = UM002_TestDataFactory.createLeadsWithCrecheLink( 100, 'lead lastname 2', 'lead company 2', 'Nouveau', 'test2@test.com', creche2.Id, '2');
        List<Lead> leads3 = UM002_TestDataFactory.createLeadsWithCrecheLink( 100, 'lead lastname 3', 'lead company 3', 'Nouveau', 'test3@test.com', creche3.Id, '3');
        
        insert leads1;
        insert leads2;
        insert leads3;
        Test.stopTest();
        List<LPCR_LienCrecheLead__c> liens1 = [SELECT Id FROM LPCR_LienCrecheLead__c WHERE LPCR_Creche__c = :creche1.Id];
        List<LPCR_LienCrecheLead__c> liens2 = [SELECT Id FROM LPCR_LienCrecheLead__c WHERE LPCR_Creche__c = :creche2.Id];
        List<LPCR_LienCrecheLead__c> liens3 = [SELECT Id FROM LPCR_LienCrecheLead__c WHERE LPCR_Creche__c = :creche3.Id];
        System.assertEquals(100, liens1.size());
        System.assertEquals(100, liens2.size());
        System.assertEquals(100, liens3.size());
        //Test the method syncOppRecordType from SM007_LeadServices.linkStructureAOsToOpps method indirectly by using the Lead before update trigger
    }
    @isTest 
    public static void linkStructureAOsToOpps_Test(){
        List<Lead> entrepriseLeads = [SELECT Id,RecordTypeId FROM Lead WHERE Name = 'entrepriseLead'];
        List<Lead> aoPublicReservLeads = [SELECT Id,RecordTypeId FROM Lead WHERE Name = 'aoPublicReservLeads'];
        List<Lead> aoPublicDSPLeads = [SELECT Id,RecordTypeId FROM Lead WHERE Name = 'aoPublicDSPLeads'];

        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        List<Database.LeadConvert> leadsToConvert = new List<Database.LeadConvert>();
        Database.LeadConvert tempLc;
        for(Lead eachLead : entrepriseLeads){
            tempLc = new Database.LeadConvert();
            tempLc.setLeadId(eachLead.id);
            tempLc.setDoNotCreateOpportunity(false);
            tempLc.setConvertedStatus(convertStatus.MasterLabel);
            leadsToConvert.add(tempLc);
        }
        for(Lead eachLead : aoPublicReservLeads){
            tempLc = new Database.LeadConvert();
            tempLc.setLeadId(eachLead.id);
            tempLc.setDoNotCreateOpportunity(false);
            tempLc.setConvertedStatus(convertStatus.MasterLabel);
            leadsToConvert.add(tempLc);
        }
        for(Lead eachLead : aoPublicDSPLeads){
            tempLc = new Database.LeadConvert();
            tempLc.setLeadId(eachLead.id);
            tempLc.setDoNotCreateOpportunity(false);
            tempLc.setConvertedStatus(convertStatus.MasterLabel);
            leadsToConvert.add(tempLc);
        }
        Test.startTest();
        List<Database.LeadConvertResult> lcr = Database.convertLead(leadsToConvert);
            for(Database.LeadConvertResult eachResult : lcr){
                System.assert(eachResult.isSuccess());
            }
            List<LPCR_Structure_AO__c> structuresWithOpp = [SELECT Id, opportunite__c FROM LPCR_Structure_AO__c WHERE opportunite__c != null];
            System.assertEquals(600, structuresWithOpp.size());
        Test.stopTest();
    }
}