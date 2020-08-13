/**
* @author Hanae Makboub
* @date 11/02/2020
* @SOQL Queries about Lead
* @Last update : 20/02/2020 by Achraf ABOUL
*/
public with sharing class EM002_LeadEntity extends DM000_SObject{
    
    @TestVisible
    protected override String getDataManagerClassName() {
        return EM002_LeadEntity.class.getName();
    }
    
    
    @TestVisible
    protected override String getObjectName() {
        return Schema.sObjectType.Lead.name;
    }
    
    public EM002_LeadEntity(){
        super('Lead');
    }
    public static List<Lead> getLeadsByOppsAndRecordType(Id leadRecordTypeId, Set<Id> opportunitiesIds) {
        return [SELECT Id FROM Lead WHERE 
                convertedOpportunityId IN :opportunitiesIds
                AND RecordTypeId = :leadRecordTypeId];
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
    public static List<Lead> getLeadsByIdsAndStatus(set<Id> setLeadIds, String status) {
        return [SELECT Id, Status,RecordType.Name , LPCR_DatePriseEnChargeCommercial__c,RecordType.DeveloperName
                FROM Lead 
                WHERE Id In :setLeadIds 
                AND Status = :status];
    }
    public static Lead getAllLeadfielsById(Id leadId){
        
        String SobjectApiName = 'Lead';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
        
        String commaSepratedFields = '';
        for(String fieldName : fieldMap.keyset()){
            if(commaSepratedFields == null || commaSepratedFields == ''){
                commaSepratedFields = fieldName;
            }else{
                commaSepratedFields = commaSepratedFields + ', ' + fieldName;
            }
        }
        
        String query = 'select ' + commaSepratedFields + ' from ' + SobjectApiName + ' WHERE Id = :leadId Limit 1';
        
        Lead leadLst = Database.query(query);
        
        return leadLst;    
    }
    
}