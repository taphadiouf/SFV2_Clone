/*
@Author : Erwan Yhuellou
@Date : 13/01/2020
@Descr : Method used to log critical information. Can be used by critical apex business rules, callin, callout, etc.
*/
public with sharing class UM001_LogManager {
    
    // Method used to trace activty 
    
    @future
    public static void writeLogActivity(String title, String callIdentifier, String typeOfInfo, String parentObjectId, String content, String result) {
         
        LPCR_Log__c tmpLog = new LPCR_Log__c();
        tmpLog.Name = title;
        tmpLog.LPCR_ActionName__c = callIdentifier;
        tmpLog.LPCR_Message__c = content!= null ? content.Left(130000): '';
        tmpLog.LPCR_TargetObject__c = parentObjectId;
        tmpLog.LPCR_Type__c = typeOfInfo;
        tmpLog.LPCR_Result__c = result;
        insert tmpLog;
    }
    public static void writeLogActivityWithoutFuture(String title, String callIdentifier, String typeOfInfo, String parentObjectId, String content, String result) {
         
        LPCR_Log__c tmpLog = new LPCR_Log__c();
        tmpLog.Name = title;
        tmpLog.LPCR_ActionName__c = callIdentifier;
        tmpLog.LPCR_Message__c = content!= null ? content.Left(130000): '';
        tmpLog.LPCR_TargetObject__c = parentObjectId;
        tmpLog.LPCR_Type__c = typeOfInfo;
        tmpLog.LPCR_Result__c = result;
        insert tmpLog;
    }
    // added by Saurabh
    public static void writeLogActivityNow(String title, String callIdentifier, String typeOfInfo, Id parentObjectId, String content, String result) {
         
        LPCR_Log__c tmpLog = new LPCR_Log__c();
        tmpLog.Name = title;
        tmpLog.LPCR_ActionName__c = callIdentifier;
        tmpLog.LPCR_Message__c = content!= null ? content.Left(130000): '';
        tmpLog.LPCR_TargetObject__c = parentObjectId;
        tmpLog.LPCR_Type__c = typeOfInfo;
        tmpLog.LPCR_Result__c = result;
        insert tmpLog;
    }
    
}
