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
       
        Id familleAccountRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Famille);
        Account acc = UM002_TestDataFactory.createAccount('test', familleAccountRT);
        insert acc;
        Contract contract = UM002_TestDataFactory.createContract(acc.Id);
       
        contract.LPCR_RenouvellementAutomatique__c=true;
        contract.StartDate=lastMonth;
         if(Date.today().addMonths(-1).Month()==2){
             contract.ContractTerm =2;
         }else{
             contract.ContractTerm =1;
         }
        Id ReservataireRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract,Label.LPCR_Reservataire);
        contract.recordTypeId = ReservataireRT;
        contract.SBQQ__RenewalQuoted__c=false;
        contract.LPCR_TypeFacturation__c = 'Advance';
        contract.EndDate = System.today().addDays(-1);
        insert contract;
       
    }
    @isTest
    private static void testAPB002RenewalContract(){
        System.runAs(UM002_TestDataFactory.createUser()){
           
            Account acc = [SELECT Id, name from Account where name ='test' ];
           
           
            Contract contract = [SELECT Id,LPCR_TypeFacturation__c,Status,AccountId,EndDate,LPCR_DateRenouvellement__c,
                                        LPCR_RenouvellementAutomatique__c, SBQQ__RenewalQuoted__c,LPCR_JoursAvance__c,
                                        recordtypeid 
                                        FROM Contract
                                 WHERE AccountId =:acc.Id ];
            System.debug('before contract:' + contract);
            contract.Status='Activated';
            update contract;
            System.debug('after contract:' + contract);
            
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