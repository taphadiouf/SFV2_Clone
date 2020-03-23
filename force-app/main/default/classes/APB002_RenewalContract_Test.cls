/**
* @author Ayoub Ouarti
* @date 18/03/2020
* @Description Testt class for PB002_RenewalContract 
*/
@isTest
public class APB002_RenewalContract_Test {
    @testsetup
    static void setup() {
        Date lastMonth=  Date.newInstance(System.today().Year(), System.today().month() - 1, System.today().day()+1) ;
        
        Account acc = UM002_TestDataFactory.createAccount('test');
        insert acc;
        Contract contract = UM002_TestDataFactory.createContract(acc.Id);
        
        contract.LPCR_RenouvellementAutomatique__c=true;
        contract.StartDate=lastMonth;
        contract.ContractTerm =1;
        contract.SBQQ__RenewalQuoted__c=false;
        insert contract;
    }
    @isTest
    private static void testAPB002RenewalContract(){
        System.runAs(UM002_TestDataFactory.createUser()){
            
            Account acc = [SELECT Id, name from Account where name ='test' ];
            
            
            Contract contract = [SELECT Id,Status,AccountId,EndDate,LPCR_DateRenouvellement__c,LPCR_RenouvellementAutomatique__c, SBQQ__RenewalQuoted__c,LPCR_JoursAvance__c FROM Contract 
                                 WHERE AccountId =:acc.Id ]; 
            contract.Status='Activated';
            update contract;
            
            Test.startTest();
            APB002_RenewalContract renewalContractBatch = new APB002_RenewalContract();
            renewalContractBatch.execute(null);
            
            Test.stopTest();
            contract = [SELECT Id,AccountId,Name,Status,StartDate,EndDate,LPCR_DateRenouvellement__c,LPCR_RenouvellementAutomatique__c, SBQQ__RenewalQuoted__c,LPCR_JoursAvance__c FROM Contract 
                        WHERE AccountId =:acc.Id ];
            System.assertEquals(true, contract.SBQQ__RenewalQuoted__c,'RenewalQuoted is false');
            
        }
    }
}