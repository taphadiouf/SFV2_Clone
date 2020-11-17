/* 
    Class build by Salesforce CPQ Services. Dt : 1st Aug, 2019
    Class Used by Approval Process to submit for Approval, Demote to Draft
    This class will call standard CPQ methods to submit for approval and move to draft status
*/
public with sharing class APC010_AmendLexContractController {
    
    @AuraEnabled
    public static string getContractDetails(Id contractId) {
        Contract contractRec = [SELECT Id, SBQQ__AmendmentStartDate__c
                                FROM Contract 
                                WHERE Id =: contractId];
        
        string errorMessage = null;
        if(contractRec.SBQQ__AmendmentStartDate__c == null) {
            errorMessage = System.Label.LPCR_AmendLexError;  
            
        } 
        
        return errorMessage;
    }
}