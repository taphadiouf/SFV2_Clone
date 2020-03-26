/**
* @author Achraf ABOUL
* @created 26/02/2020
* @description Services class on Lead Object
*/
public class SM007_LeadServices {
    
    public static void syncRecordTypesWithLeads(List<Lead> leadsList){
        //Map : target Object API Name => (Map : Lead recordtype developerName =>  target Recordtype DeveloperName)
        Map<String, Map<String, String>> leadRtToTargetRtMap = new Map<String, Map<String, String>>();
        leadRtToTargetRtMap.put('Opportunity', new Map<String, String>());
        leadRtToTargetRtMap.put('Account', new Map<String, String>());
        leadRtToTargetRtMap.put('Contact', new Map<String, String>());
        LPCR_LeadConversionRTMapping__mdt tempEachLeadConvRTMap;
        //This loop populates leadRtToTargetRtMap
        for(SObject eachLeadConvRTMapping : new EM013_LeadConversionRTMappingEntity().getAllWithAllFields()){
            tempEachLeadConvRTMap = (LPCR_LeadConversionRTMapping__mdt) eachLeadConvRTMapping;
            leadRtToTargetRtMap.get('Opportunity').put(tempEachLeadConvRTMap.LPCR_LeadRT__c, tempEachLeadConvRTMap.LPCR_OpportunityRT__c);
            leadRtToTargetRtMap.get('Account').put(tempEachLeadConvRTMap.LPCR_LeadRT__c, tempEachLeadConvRTMap.LPCR_AccountRT__c);
            leadRtToTargetRtMap.get('Contact').put(tempEachLeadConvRTMap.LPCR_LeadRT__c, tempEachLeadConvRTMap.LPCR_ContactRT__c);
        }
        
        //Map : Object API Name => (Map : recordtype DeveloperName =>  Recordtype Id)
        Map<String, Map<String, Id>> rtNamesToIdsMap = new Map<String, Map<String, String>>();
        rtNamesToIdsMap.put('Opportunity', new Map<String, Id>());
        rtNamesToIdsMap.put('Account', new Map<String, Id>());
        rtNamesToIdsMap.put('Contact', new Map<String, Id>());
        //End Map Def
        //Map : Lead RecordTypeId => Lead recordtype Developer Name
        Map<Id, String> leadRTIdToName = new Map<Id, String>();
        //End Map  Def
        
        //This loop populates rtNamesToIdsMap and leadRTIdToName
        for(RecordType eachRT : [SELECT Id, SObjectType, DeveloperName FROM RecordType 
                                 WHERE (SobjectType = 'Lead' AND DeveloperName IN :leadRtToTargetRtMap.get('Opportunity').keySet())  
                                 OR (SobjectType = 'Opportunity' AND DeveloperName IN :leadRtToTargetRtMap.get('Opportunity').values())  
                                 OR (SobjectType = 'Account' AND DeveloperName IN :leadRtToTargetRtMap.get('Account').values())
                                 OR (SobjectType = 'Contact' AND DeveloperName IN :leadRtToTargetRtMap.get('Contact').values())]){
                                     if(eachRT.SObjectType.equals('Lead')){
                                         leadRTIdToName.put(eachRT.Id, eachRT.DeveloperName);
                                     }
                                     else{
                                         rtNamesToIdsMap.get(eachRT.SObjectType).put(eachRT.DeveloperName, eachRT.Id);
                                     }
                                 }
        
        //Map : targetObject API Name => (Map : target record Id => Lead recordTypeId)
        Map<String, Map<Id, Id>> targetIdToLeadRtIdMap = new Map<String, Map<Id, Id>>();
        targetIdToLeadRtIdMap.put('Opportunity', new Map<Id, Id>());
        targetIdToLeadRtIdMap.put('Account', new Map<Id, Id>());
        targetIdToLeadRtIdMap.put('Contact', new Map<Id, Id>());
        //End Map def
        
        //This loop populates opportunitiesMap, accountsMap and  contactsMap with the mapping between (target record Id) => (Lead recordtypeId)
        for(Lead eachLead : leadsList){ 
            targetIdToLeadRtIdMap.get('Opportunity').put(eachLead.convertedOpportunityId, eachLead.recordTypeId);
            targetIdToLeadRtIdMap.get('Account').put(eachLead.convertedAccountId, eachLead.recordTypeId);
            targetIdToLeadRtIdMap.get('Contact').put(eachLead.convertedContactId, eachLead.recordTypeId);
        }
        
        Map<String, List<SObject>> targetRecordsMap = new Map<String, List<SObject>>();
        Set<String> targetFields = new Set<String>();
        targetFields.add('RecordTypeId');
        targetRecordsMap.put('Opportunity', new EM004_OpportunityEntity().getByIds(targetIdToLeadRtIdMap.get('Opportunity').keySet(), targetFields));
        targetRecordsMap.put('Account', new EM005_AccountEntity().getByIds(targetIdToLeadRtIdMap.get('Account').keySet(), targetFields));
        targetRecordsMap.put('Contact', new EM011_ContactEntity().getByIds(targetIdToLeadRtIdMap.get('Contact').keySet(), targetFields));
        
        Id tmpLeadRecordTypeId;
        String tmpLeadRecordTypeName;
        String tmpTargetRecordTypeName;
        Id tmpTargetId;
        List<SObject> recordsToUpdate = new List<SObject>();
        for(String eachObjectName : targetRecordsMap.keySet()){
            for(SObject eachRecord : targetRecordsMap.get(eachObjectName)){
                tmpLeadRecordTypeId = targetIdToLeadRtIdMap.get(eachObjectName).get(eachRecord.Id);
                tmpLeadRecordTypeName = leadRTIdToName.get(tmpLeadRecordTypeId);
                tmpTargetRecordTypeName = leadRtToTargetRtMap.get(eachObjectName).get(tmpLeadRecordTypeName);
                tmpTargetId = rtNamesToIdsMap.get(eachObjectName).get(tmpTargetRecordTypeName);
                eachRecord.put('RecordTypeId', tmpTargetId);
            }
            recordsToUpdate.addAll(targetRecordsMap.get(eachObjectName));
        }
        update recordsToUpdate;
        
    }
    
    /* 
public static void syncOppRecordType(String leadRecordTypeName, String oppRecordTypeName, List<Lead> leadsList){
Id leadRecordTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Lead',leadRecordTypeName);
Id opportunityRecordTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Opportunity', oppRecordTypeName);
Set<Id> oppsIdsToSync = new Set<Id>();
for(Lead eachLead : leadsList){
if(eachLead.recordTypeId != null && (''+eachLead.recordTypeId).equals(''+leadRecordTypeId)){
oppsIdsToSync.add(eachLead.convertedOpportunityId);
}
}
Set<String> oppFields = new Set<String>();
oppFields.add('RecordTypeId');
List<Opportunity> oppsToSync = new EM004_OpportunityEntity().getByIds(oppsIdsToSync, oppFields);
for(Opportunity eachOpp : oppsToSync){
eachOpp.RecordTypeId = opportunityRecordTypeId;
}
update oppsToSync;
}
public static void syncRecordTypeWithLead(String sObjectAPIName, String leadRecordTypeName, String targetRecordTypeName, List<Lead> leadsList){
Id leadRecordTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Lead',leadRecordTypeName);
Id targetRecordTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(sObjectAPIName, targetRecordTypeName);
EM001_AbstractObjectEntity objectEntity;
String targetReferenceField;
switch on sObjectAPIName{
when 'Opportunity'{
objectEntity  =  new EM004_OpportunityEntity();
targetReferenceField =  'convertedOpportunityId';
}
when 'Account'{
objectEntity  =  new EM005_AccountEntity();
targetReferenceField =  'convertedAccountId';

}
when 'Contact'{
objectEntity  =  new EM011_ContactEntity();
targetReferenceField =  'convertedContactId';            
}
}
Set<Id> targetIdsToSync = new Set<Id>();
for(Lead eachLead : leadsList){
if(eachLead.recordTypeId != null && (''+eachLead.recordTypeId).equals(''+leadRecordTypeId)){
targetIdsToSync.add((Id) eachLead.get(targetReferenceField));
}
}
Set<String> oppFields = new Set<String>();
oppFields.add('RecordTypeId');

List<SObject> recordsToSync = objectEntity.getByIds(targetIdsToSync, oppFields);
for(SObject eachRecord : recordsToSync){
eachRecord.put('RecordTypeId', targetRecordTypeId);
}
update recordsToSync;
}
*/
    
    public static void linkStructureAOsToOpps(List<Lead> convertedLeadsList){
        Id aoPublicReservationRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Lead', 'AO_PublicReservation');
        Id aoPublicDSPRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Lead', 'AO_PublicDSP');
        
        Map<Id, Lead> wantedLeadsMap = new Map<Id, Lead>();
        for(Lead eachLead : convertedLeadsList){
            if(!String.isEmpty(eachLead.recordTypeId) && (eachLead.recordTypeId.equals(aoPublicReservationRT) || eachLead.recordTypeId.equals(aoPublicDSPRT))){
                wantedLeadsMap.put(eachLead.id, eachLead);
            }
        }
        List<LPCR_Structure_AO__c> aoStructures = EM009_StructureAOEntity.getStructuresAOByLeads(wantedLeadsMap.keySet());
        for(LPCR_Structure_AO__c eachStructureAO : aoStructures){
            eachStructureAO.opportunite__c = wantedLeadsMap.get(eachStructureAO.LPCR_Lead__c).convertedOpportunityId;
        }
        update aoStructures;
    }
}