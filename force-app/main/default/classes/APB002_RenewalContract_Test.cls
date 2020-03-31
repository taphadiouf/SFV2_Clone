/**
* @author Ayoub Ouarti
* @date 18/03/2020
* @Description Testt class for PB002_RenewalContract
*/
@isTest
public class APB002_RenewalContract_Test {
    @testsetup
    static void setup() {
         Date lastMonth=null;
        if(Date.today().addMonths(-1).Month()==2){
            lastMonth= System.today().addDays(-59) ;
        }else{
            lastMonth= System.today().addDays(-30) ;
        }
       
      system.debug(System.today()+' ===== lastMonth ====== '+lastMonth);
        Account acc = UM002_TestDataFactory.createAccount('test');
        insert acc;
        Contract contract = UM002_TestDataFactory.createContract(acc.Id);
       
        contract.LPCR_RenouvellementAutomatique__c=true;
        contract.StartDate=lastMonth;
         if(Date.today().addMonths(-1).Month()==2){
             contract.ContractTerm =2;
         }else{
             contract.ContractTerm =1;
         }
       
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
