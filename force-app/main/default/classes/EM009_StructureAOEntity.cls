/**
* @author Achraf ABOUL
* @date 20/03/2020
* @Description Entity class for LPCR_Structure_AO__c
*/
public with sharing class EM009_StructureAOEntity extends DM000_SObject {
    
    @TestVisible
    protected override String getDataManagerClassName() {
        return EM002_LeadEntity.class.getName();
    }

   
    @TestVisible
    protected override String getObjectName() {
        return Schema.sObjectType.Lead.name;
    }
    
    public static List<LPCR_Structure_AO__c> getStructuresAOByLeads(Set<Id> leadsIds){
        return [SELECT Id,LPCR_Lead__c, Opportunite__c FROM LPCR_Structure_AO__c WHERE LPCR_Lead__c IN :leadsIds];
    }
}
