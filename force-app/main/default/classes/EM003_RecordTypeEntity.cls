/**
* @author Achraf ABOUL
* @date 11/02/2020
* @SOQL Queries on RecordTypes
*/
public with sharing class EM003_RecordTypeEntity {
    public static Id getRecTypeIdByObjectAndName(String SobjectType, String Name) {
        return [SELECT Id FROM RecordType WHERE SObjectType = :SobjectType AND DeveloperName = :Name].Id;
    }
    
     public static Id getRecTypeIdByObjectAndDeveloperName(String SobjectType, String developerName) {
        return [SELECT Id FROM RecordType WHERE DeveloperName = :developerName AND SObjectType = :SobjectType].Id;
    }
    
    
     
}