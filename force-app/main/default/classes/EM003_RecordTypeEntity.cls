/**
* @author Achraf ABOUL
* @date 11/02/2020
* @SOQL Queries on RecordTypes
*/
public with sharing class EM003_RecordTypeEntity {
    public static Id getRecTypeIdByObjectAndName(String SobjectType, String developerName) {
        Id result = String.isNotBlank(SobjectType) && String.isNotBlank(developerName)
            ? Schema.getGlobalDescribe().get(SobjectType).getDescribe().getRecordTypeInfosByDeveloperName().get(developerName).getRecordTypeId()
            : null;
        
        return result;
    }
}