/**
* @author Ayoub Ouarti
* @created 15/07/2020
* @description Test class for SM021_CreditNoteServices 
*/
@isTest
public class SM021_CreditNoteServices_Test {
    private static final Id B2B_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Entreprise);
	
    
    
    @isTest
    private static void setContractFieldsTest(){        
        System.runAs(UM002_TestDataFactory.createUser()){
                Test.startTest();  
        Map<String, Object> defaultVal = new Map<String, Object> {
            'RecordTypeId' => B2B_RT_ID,
            'Name' => 'Test-B2B',
            'SBQQ__RenewalModel__c' => 'Contract Based'
        };
        Account b2bAccount = (Account) UM002_TestDataFactory.createSObject('Account', defaultVal);
        insert b2bAccount;
            
           defaultVal = new Map<String, Object> {
            'blng__Account__c' => b2bAccount.Id};
            blng__CreditNote__c b2bCreditNote = (blng__CreditNote__c) UM002_TestDataFactory.createSObject('blng__CreditNote__c', defaultVal);
            insert b2bCreditNote;
            
            Test.stopTest();
            b2bAccount = [SELECT Id,LPCR_ProcessRevenuCascade__c from Account where name ='Test-B2B' ];
            
            System.assertEquals(true, b2bAccount.LPCR_ProcessRevenuCascade__c ,'Account.LPCR_ProcessRevenuCascade__c is false');

            
        }
    }
    
    
    
}