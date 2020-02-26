/**
* @author Achraf ABOUL
* @date 11/02/2020
* @SOQL Queries on RecordTypes
*/
public with sharing class EM003_RecordTypeEntity {
    public static Id getRecTypeIdByObjectAndName(String SobjectType, String Name) {
        return [SELECT Id FROM RecordType WHERE Name = :Name AND SObjectType = :SobjectType].Id;
    }
     
}