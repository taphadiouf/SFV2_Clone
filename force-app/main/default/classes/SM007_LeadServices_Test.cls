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
        Id aoLeadRecordType = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Lead', 'AO_PublicReservation');
        List<Lead> entrepriseLeads = UM002_TestDataFactory.createLeads(100, entrepriseLeadRecordType, 'entrepriseLead', 'entrepriseLead', 'Nouveau', 'test@test.com');
        List<Lead> aoLeads = UM002_TestDataFactory.createLeads(100, aoLeadRecordType, 'aoLead', 'aoLead', 'Nouveau', 'test@test.com');
        insert entrepriseLeads;
        insert aoLeads;
    }     
    //Test the method syncOppRecordType from SM007_LeadServices class indirectly
    
    @isTest
    private static void syncOppRecordType_Test(){
        List<Lead> entrepriseLeads = [SELECT Id,RecordTypeId FROM Lead WHERE Name = 'entrepriseLead'];
        List<Lead> aoLeads = [SELECT Id,RecordTypeId FROM Lead WHERE Name = 'aoLead'];
        
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
        for(Lead eachLead : aoLeads){
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
            Id aoOppRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Opportunity', 'AOPublicReservataire');
                       
            List<Opportunity> entrepriseOpps = [SELECT Id FROM Opportunity WHERE RecordTypeId = :entrepriseOppRecTypeId];
            List<Opportunity> aoOpps = [SELECT Id FROM Opportunity WHERE RecordTypeId = :aoOppRecTypeId];
            System.assertEquals(entrepriseLeads.size(), entrepriseOpps.size(), 'Error in SM007_LeadServices_Test : problem in synchronizing Lead recordtype: Entreprise, with Opportunity recordtype: Entreprise RecordType');
            System.assertEquals(aoLeads.size(), aoOpps.size(), 'Error in SM007_LeadServices_Test : problem in synchronizing Lead recordtype: AO_PublicReservation, with Opportunity recordtype: AOPublicReservataire');
        }
        Test.stopTest();
    }
}