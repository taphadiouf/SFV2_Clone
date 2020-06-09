/**
* @author Ayoub Ouarti
* @date 08/06/2020
* @Description Testt class for APB008_ResetStartEndDatesOnContract
*/
@isTest
public class APB008_ResetStartEndDatesOnContract_Test {
    private static final Id B2B_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Entreprise);
	private static final Date todayDate = Date.toDay();
    private static final String methodeRenouvellementValue='Tacite';
    @testsetup
    static void setup() {
        
        
        Map<String, Object> defaultVal = new Map<String, Object> {
            'RecordTypeId' => B2B_RT_ID,
            'Name' => 'Test-B2B',
            'SBQQ__RenewalModel__c' => 'Contract Based'
        };
        Account b2bAccount = (Account) UM002_TestDataFactory.createSObject('Account', defaultVal);
        insert b2bAccount;

        Contract contract = UM002_TestDataFactory.createContract(b2bAccount.Id);
        contract.LPCR_MethodeRenouvellement__c=methodeRenouvellementValue;
        contract.LPCR_DateFin__c=todayDate;
        contract.LPCR_DureeContratJour__c=100;
        insert contract;
       
    }
    
    @isTest
    private static void testAPB008ResetStartEndDatesOnContract(){
        System.runAs(UM002_TestDataFactory.createUser()){
           
            Account acc = [SELECT Id, name from Account where name ='Test-B2B' LIMIT 1];
           
            Contract contract = [SELECT Id, LPCR_DureeContratJour__c ,LPCR_DateFin__c ,LPCR_DateDebut__c ,LPCR_MethodeRenouvellement__c, Account.RecordTypeId FROM Contract
                                 WHERE AccountId =:acc.Id ];
           
            Test.startTest();
            APB008_ResetStartEndDatesOnContract resetStartEndDatesOnContract = new APB008_ResetStartEndDatesOnContract();
            resetStartEndDatesOnContract.execute(null);
           
            Test.stopTest();
            contract = [SELECT Id, LPCR_DureeContratJour__c ,LPCR_DateFin__c ,LPCR_DateDebut__c ,LPCR_MethodeRenouvellement__c, Account.RecordTypeId FROM Contract
                                 WHERE AccountId =:acc.Id ];
           System.assertEquals(todayDate.addDays(1), contract.LPCR_DateDebut__c,'LPCR_DateDebut__c is not today');
           System.assertEquals(contract.LPCR_DateDebut__c.addDays(Integer.valueOf(contract.LPCR_DureeContratJour__c)), contract.LPCR_DateFin__c,'LPCR_DateFin__c is not LPCR_DateDebut__c +LPCR_DureeContratJour__c ');
           
        }
    }
}