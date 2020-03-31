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
        Id partenaireLeadRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Lead', 'Partenaire');
        List<Lead> entrepriseLeads = UM002_TestDataFactory.createLeads(100, entrepriseLeadRecordType, 'entrepriseLead', 'entrepriseLead', 'Nouveau', 'test@test.com');
        List<Lead> aoPublicReservLeads = UM002_TestDataFactory.createLeads(100, aoPublicReservLeadRT, 'aoPublicReservLeads', 'aoPublicReservLeads', 'Nouveau', 'test@test.com');
        List<Lead> aoPublicDSPLeads = UM002_TestDataFactory.createLeads(100, aoPublicDSPLeadRT, 'aoPublicDSPLeads', 'aoPublicDSPLeads', 'Nouveau', 'test@test.com');
        List<Lead> aoPartenaireLeads = UM002_TestDataFactory.createLeads(100, partenaireLeadRT, 'aoPartenaireLeads', 'aoPartenaireLeads', 'Nouveau', 'test@test.com');
        insert entrepriseLeads;
        insert aoPublicReservLeads;
        insert aoPublicDSPLeads;
        insert aoPartenaireLeads;
        
        insert UM002_TestDataFactory.createStructuresAOFromLeads(3, entrepriseLeads);
        insert UM002_TestDataFactory.createStructuresAOFromLeads(3, aoPublicReservLeads);
        insert UM002_TestDataFactory.createStructuresAOFromLeads(3, aoPublicDSPLeads);
        insert UM002_TestDataFactory.createStructuresAOFromLeads(3, aoPartenaireLeads);
    }     
    
    @isTest
    public static void syncLeadEntrepriseRT(){
        syncLeadRT('Entreprise');
    }
    @isTest
    public static void syncLeadPartenaireRT(){
        syncLeadRT('Partenaire');
    }
    @isTest
    public static void syncLeadAOPubDSPRT(){
        syncLeadRT('AO_PublicDSP');
    }
    @isTest
    public static void syncLeadAOPubReservRT(){
        syncLeadRT('AO_PublicReservation');
    }
    private static void syncLeadRT(String leadRTName){
        LPCR_LeadConversionRTMapping__mdt convMappingRecord = [SELECT Id, LPCR_LeadRT__c, LPCR_OpportunityRT__c, LPCR_AccountRT__c, LPCR_ContactRT__c
                                                                FROM LPCR_LeadConversionRTMapping__mdt
                                                                WHERE LPCR_LeadRT__c = :leadRTName];
        Id leadRTId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Lead', leadRTName);
        List<Lead> leadsRecords = [SELECT Id,RecordTypeId FROM Lead WHERE RecordTypeId = :leadRTId];
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        List<Database.LeadConvert> leadsToConvert = new List<Database.LeadConvert>();
        Database.LeadConvert tempLc;
        for(Lead eachLead : leadsRecords){
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
            Id opportunityRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Opportunity', convMappingRecord.LPCR_OpportunityRT__c);
            Id accountRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Account', convMappingRecord.LPCR_AccountRT__c);
            Id contactRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Contact', convMappingRecord.LPCR_ContactRT__c);

            
            List<Opportunity> opporunitiesRslts = [SELECT Id FROM Opportunity WHERE RecordTypeId = :opportunityRecTypeId];
            List<Account> accountsRslts = [SELECT Id FROM Account WHERE RecordTypeId = :accountRecTypeId];
            List<Contact> contactsRslts = [SELECT Id FROM Contact WHERE RecordTypeId = :contactRecTypeId];

            System.assertEquals(leadsRecords.size(), opporunitiesRslts.size());
            System.assertEquals(leadsRecords.size(), accountsRslts.size());
            System.assertEquals(leadsRecords.size(), contactsRslts.size());
            
        }
        Test.stopTest();                                                            
    }

    
    //Test the method syncOppRecordType from SM007_LeadServices.linkStructureAOsToOpps method indirectly by using the Lead before update trigger
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
    /*
    //Test the method syncOppRecordType from SM007_LeadServices.syncOppRecordType method indirectly by using the Lead before update trigger
    @isTest
    private static void syncOppRecordType_Test(){
        List<Lead> entrepriseLeads = [SELECT Id,RecordTypeId FROM Lead WHERE Name = 'entrepriseLead'];
        List<Lead> aoPublicReservLeads = [SELECT Id,RecordTypeId FROM Lead WHERE Name = 'aoPublicReservLeads'];
        List<Lead> aoPublicDSPLeads = [SELECT Id,RecordTypeId FROM Lead WHERE Name = 'aoPublicDSPLeads'];
        List<Lead> partenaireLeads = [SELECT Id,RecordTypeId FROM Lead WHERE Name = 'aoPartenaireLeads'];
        
        List<Lead> allLeads = new List<Lead>();
        allLeads.addAll(entrepriseLeads);
        allLeads.addAll(aoPublicReservLeads);
        //allLeads.addAll(aoPublicDSPLeads);
        //allLeads.addAll(partenaireLeads);
        System.debug('allLeads '+ allLeads);
        System.debug(allLeads.size());
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        List<Database.LeadConvert> leadsToConvert = new List<Database.LeadConvert>();
        Database.LeadConvert tempLc;
        for(Lead eachLead : allLeads){
            tempLc = new Database.LeadConvert();
            tempLc.setLeadId(eachLead.id);
            tempLc.setDoNotCreateOpportunity(false);
            tempLc.setConvertedStatus(convertStatus.MasterLabel);
            leadsToConvert.add(tempLc);
        }
        System.debug('leadsToConvert ' + leadsToConvert);
        System.debug(leadsToConvert.size());
        Test.startTest();
        System.runAs(UM002_TestDataFactory.createUser()){
            List<Database.LeadConvertResult> lcr = Database.convertLead(leadsToConvert);
            for(Database.LeadConvertResult eachResult : lcr){
                System.assert(eachResult.isSuccess());
            }
            Id entrepriseOppRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Opportunity', 'Entreprise');
            Id aoPubReservOppRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Opportunity', 'AOPublicReservation');
            Id aoPubDSPOppRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Opportunity', 'AOPublicDSP');
            Id partenaireOppRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Opportunity', 'Partenaire');
            
            List<Opportunity> entrepriseOpps = [SELECT Id FROM Opportunity WHERE RecordTypeId = :entrepriseOppRecTypeId];
            List<Opportunity> aoPubReservOpps = [SELECT Id FROM Opportunity WHERE RecordTypeId = :aoPubReservOppRecTypeId];
            List<Opportunity> aoPubDSPOpps = [SELECT Id FROM Opportunity WHERE RecordTypeId = :aoPubDSPOppRecTypeId];
            List<Opportunity> partenaireOpps = [SELECT Id FROM Opportunity WHERE RecordTypeId = :aoPubDSPOppRecTypeId];
            System.assertEquals(entrepriseLeads.size(), entrepriseOpps.size());
            System.assertEquals(aoPublicReservLeads.size(), aoPubReservOpps.size());
            System.assertEquals(partenaireLeads.size(), partenaireOpps.size());
            
        }
        Test.stopTest();
    }
    */
}