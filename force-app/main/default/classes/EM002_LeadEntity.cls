/**
* @author Hanae Makboub , Ayoub Ouarti
* @date 11/02/2020
* @SOQL Query to get leads by ID
*/
public with sharing class EM002_LeadEntity {
    
    public static List<Lead> getLeadsBy(set<Id> setLeadIds,String recordTypeName) {
        return [SELECT Id, Status,RecordType.Name ,LPCR_DatePriseEnChargeCommercial__c
                FROM Lead 
                WHERE Id In :setLeadIds 
                AND RecordType.Name= :recordTypeName];
    }
   
    public static List<Lead> getLeadsBy(set<Id> setLeadIds,String recordTypeName,String status) {
        return [SELECT Id, Status,RecordType.Name ,LPCR_DatePriseEnChargeCommercial__c
                FROM Lead 
                WHERE Id In :setLeadIds 
                AND RecordType.Name= :recordTypeName 
                AND Status = :status];
    }
    
}