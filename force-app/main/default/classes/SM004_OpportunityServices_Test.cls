/**
* @author Achraf ABOUL
* @created 21/02/2020
* @description Test Class of SM004_OpportunityServices.
*/
@isTest
public class SM004_OpportunityServices_Test {
    
    @testSetup 
    
    static void testSetup(){
        Id entrepriseLeadRecordType = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Lead', 'Entreprise');
        List<Lead> leads = UM002_TestDataFactory.createLeads(100, entrepriseLeadRecordType, 'test', 'test', 'Nouveau', 'test@test.com');
        insert leads;
    }        
    
    //Test the method syncOppRecordType from SM004_OpportunityServices class indirectly
    @isTest
    public static void syncOppRecordType_Test(){
        List<Lead> leads  = [SELECT Id,RecordTypeId FROM Lead WHERE Name = 'test'];
        
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        List<Database.LeadConvert> leadsToConvert = new List<Database.LeadConvert>();
        Database.LeadConvert tempLc;
        for(Lead eachLead : leads){
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
            Id entrepriseOppRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Opportunity','Entreprise');
            List<Opportunity> oppp = [SELECT Id,Name,RecordTypeId FROM Opportunity];
            
            List<Opportunity> entrepriseOpps = [SELECT Id FROM Opportunity WHERE RecordTypeId = :entrepriseOppRecTypeId];
            System.assertEquals(leads.size(), entrepriseOpps.size(), 'Error in TM004_OpportunityTrigger_Test.afterInsert_Test : problem in synchronizing Opportunity and Lead Entreprise RecordType');
        }
        Test.stopTest();
        
    }
}