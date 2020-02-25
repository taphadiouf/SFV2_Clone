/**
* @author Hanae Makboub
* @date 11/02/2020
* @SOQL Queries about Lead
* @Last update : 20/02/2020 by Achraf ABOUL
*/
public with sharing class EM002_LeadEntity {
    public static List<Lead> getLeadsByOppsAndRecordType(Id leadEntrepriseTypeId, Set<Id> opportunitiesIds) {
        return [SELECT Id FROM Lead WHERE 
                convertedOpportunityId IN :opportunitiesIds
                AND RecordTypeId = :leadEntrepriseTypeId];
    }
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