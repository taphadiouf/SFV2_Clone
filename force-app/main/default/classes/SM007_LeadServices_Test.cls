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
            List<Lead> entrepriseLeads = UM002_TestDataFactory.createLeads(5, entrepriseLeadRecordType, 'entrepriseLead', 'entrepriseLead', 'Nouveau', 'test@test.com');
            List<Lead> aoPublicReservLeads = UM002_TestDataFactory.createLeads(5, aoPublicReservLeadRT, 'aoPublicReservLeads', 'aoPublicReservLeads', 'Nouveau', 'test@test.com');
            List<Lead> aoPublicDSPLeads = UM002_TestDataFactory.createLeads(5, aoPublicDSPLeadRT, 'aoPublicDSPLeads', 'aoPublicDSPLeads', 'Nouveau', 'test@test.com');
            List<Lead> aoPartenaireLeads = UM002_TestDataFactory.createLeads(5, partenaireLeadRT, 'aoPartenaireLeads', 'aoPartenaireLeads', 'Nouveau', 'test@test.com');

            insert entrepriseLeads;
            insert aoPublicReservLeads;
            insert aoPublicDSPLeads;
            insert aoPartenaireLeads;

            List<Account> accs =  new List<Account>();
            accs.add(UM002_TestDataFactory.createAccount('creche1'));
            accs.add(UM002_TestDataFactory.createAccount('creche2'));
            accs.add(UM002_TestDataFactory.createAccount('creche3'));
            insert accs;
            
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

        User testUser = UM002_TestDataFactory.createUser();
        PermissionSet psC = [SELECT Id FROM PermissionSet WHERE Name = 'LPCR_SalesforceCPQAdmin' limit 1];
        PermissionSet psB = [SELECT Id FROM PermissionSet WHERE Name = 'LPCR_SalesforceBillingAdmin' limit 1];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'LPCR_Admin' limit 1];
        insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = psC.Id);
        insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = psB.Id);
        insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps.Id);
        //System.runAs(UM002_TestDataFactory.createUser()){
        System.runAs(testUser){

            List<Database.LeadConvertResult> lcr = Database.convertLead(leadsToConvert);
            for(Database.LeadConvertResult eachResult : lcr){
                System.assert(eachResult.isSuccess());
                PAD.log('SM007_LeadServices_Test', 'syncLeadRT', 'getContactId():' + eachResult.getContactId());
            }
            Id opportunityRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Opportunity', convMappingRecord.LPCR_OpportunityRT__c);
            Id accountRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Account', convMappingRecord.LPCR_AccountRT__c);
            Id contactRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Contact', convMappingRecord.LPCR_ContactRT__c);

            
            List<Opportunity> opporunitiesRslts = [SELECT Id FROM Opportunity WHERE RecordTypeId = :opportunityRecTypeId];
            List<Account> accountsRslts = [SELECT Id FROM Account WHERE RecordTypeId = :accountRecTypeId];
            List<Contact> contactsRslts = [SELECT Id, RecordType.Id, RecordType.Name FROM Contact];// Pb on RT Contact converted to fix

            for (Contact c : contactsRslts) {
            PAD.log('SM007_LeadServices_Test', 'syncLeadRT', 'c.RecordType.Name:' + c.RecordType.Name);
            }

            System.assertEquals(leadsRecords.size(), opporunitiesRslts.size());
            System.assertEquals(leadsRecords.size(), accountsRslts.size());

            PAD.log('SM007_LeadServices_Test', 'syncLeadRT', 'leadsRecords.size():' + leadsRecords.size());
            PAD.log('SM007_LeadServices_Test', 'syncLeadRT', 'contactsRslts.size():' + contactsRslts.size());
            System.assertEquals(leadsRecords.size(), contactsRslts.size());
            
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

    
    //Test the method syncOppRecordType from SM007_LeadServices.linkStructureAOsToOpps method indirectly by using the Lead before update trigger
    @isTest 
    public static void linkStructureAOsToOpps_Test(){
        List<Lead> entrepriseLeads = [SELECT Id,RecordTypeId FROM Lead WHERE Name = 'entrepriseLead'];
        List<Lead> aoPublicReservLeads = [SELECT Id,RecordTypeId FROM Lead WHERE Name = 'aoPublicReservLeads'];
        List<Lead> aoPublicDSPLeads = [SELECT Id,RecordTypeId FROM Lead WHERE Name = 'aoPublicDSPLeads'];
         Test.startTest();
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
       
        List<Database.LeadConvertResult> lcr = Database.convertLead(leadsToConvert);
        for(Database.LeadConvertResult eachResult : lcr){
            System.assert(eachResult.isSuccess());
        }
        List<LPCR_Structure_AO__c> structuresWithOpp = [SELECT Id, opportunite__c FROM LPCR_Structure_AO__c WHERE opportunite__c != null];
        System.assertEquals(30, structuresWithOpp.size());
        Test.stopTest();
    }



    @isTest 
    public static void mapFieldsFromLeadToOpp_Test(){
        List<Lead> leadsPublicToConvert = [SELECT Id,RecordTypeId FROM Lead WHERE Name IN ('aoPublicReservLeads','aoPublicDSPLeads')];

         Test.startTest();
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        List<Database.LeadConvert> leadsToConvert = new List<Database.LeadConvert>();
        Database.LeadConvert tempLc;
        for(Lead eachLead : leadsPublicToConvert){
            tempLc = new Database.LeadConvert();
            tempLc.setLeadId(eachLead.id);
            tempLc.setDoNotCreateOpportunity(false);
            tempLc.setConvertedStatus(convertStatus.MasterLabel);
            leadsToConvert.add(tempLc);
        }
       
        List<Database.LeadConvertResult> lcr = Database.convertLead(leadsToConvert);
        for(Database.LeadConvertResult eachResult : lcr){
            System.assert(eachResult.isSuccess());
        }

        //Test Mappings after conversion:
        List<Lead> leadsPublicToConvertCheckMap = [SELECT Id,ConvertedOpportunityId,RecordTypeId,LPCR_IDAO__c,LPCR_ObjetAO__c,LPCR_DebutContrat__c,LPCR_DureeContrat__c,LPCR_FinContrat__c FROM Lead WHERE Name IN ('aoPublicReservLeads','aoPublicDSPLeads')];

        Id aoPublicReservationRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Lead', 'AO_PublicReservation');
        Id aoPublicDSPRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Lead', 'AO_PublicDSP');
        // MAP(lead, idopp)
        Map<Lead, Id> filtredLeadsMap = new Map<Lead, Id>();
        for(Lead eachLead : leadsPublicToConvertCheckMap){
            if(!String.isEmpty(eachLead.recordTypeId) && (eachLead.recordTypeId.equals(aoPublicReservationRT) || eachLead.recordTypeId.equals(aoPublicDSPRT))){
                filtredLeadsMap.put(eachLead, eachLead.convertedOpportunityId);
            }
        }
        // MAP(idopp, Opp)
        Map<Id,Opportunity> idsOpps = new Map<Id,Opportunity>([SELECT Id,LPCR_IDAO__c,LPCR_ObjetAO__c,LPCR_DebutContrat__c,LPCR_DureeContrat__c,LPCR_FinContrat__c 
                                                                FROM Opportunity
                                                                WHERE id in :filtredLeadsMap.values()]);
        // MAP(lead, opp)
        Map<Lead, Opportunity> LeadOpps = new Map<Lead, Opportunity>();
        for(Lead eachLead : filtredLeadsMap.keyset()){
            LeadOpps.put( eachLead , idsOpps.get(filtredLeadsMap.get(eachLead)) );
        }

        for(Lead eachLead : filtredLeadsMap.keyset()){
            system.assertEquals(eachLead.LPCR_IDAO__c, LeadOpps.get(eachLead).LPCR_IDAO__c , 'field LPCR_IDAO__c not mapped correctly');
            system.assertEquals(eachLead.LPCR_ObjetAO__c, LeadOpps.get(eachLead).LPCR_ObjetAO__c , 'field LPCR_ObjetAO__c not mapped correctly');
            system.assertEquals(eachLead.LPCR_DebutContrat__c, LeadOpps.get(eachLead).LPCR_DebutContrat__c , 'field LPCR_DebutContrat__c not mapped correctly');
            system.assertEquals(eachLead.LPCR_FinContrat__c, LeadOpps.get(eachLead).LPCR_FinContrat__c , 'field LPCR_FinContrat__c not mapped correctly');
        }
        Test.stopTest();
    }
}