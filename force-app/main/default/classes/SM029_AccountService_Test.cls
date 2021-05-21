@isTest
public  class SM029_AccountService_Test {
    public static Id entrepriseRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account,Label.LPCR_Entreprise);
    public static List<Account> lstAccount=new List<Account>();
    public static Id famRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account,Label.LPCR_Famille);
    
    @testSetup 
    static void testSetup(){
        blng__LegalEntity__c socFac=new blng__LegalEntity__c(Name='LPCR GROUPE');
        insert socFac;
        Account acc= new Account(Name='test',RecordTypeId=famRecTypeId,LPCR_IDSage__c ='4110000001',LPCR_PasDeSIRET__c=true);
        lstAccount.add(acc);
        insert lstAccount;
    }
    @isTest
    public static void insertAccounts_Test(){
        Account acc= new Account(Name='test1',RecordTypeId=entrepriseRecTypeId,LPCR_PasDeSIRET__c=true,LPCR_IDSage__c ='4110000003');
        lstAccount.add(acc);

        insert lstAccount;
        Test.startTest();
        Test.stopTest();
        List<Account> lstAccountUp=[Select id,LPCR_IDSage__c  from Account where id=:lstAccount[0].id];
        System.assertNotEquals(null, lstAccountUp[0].LPCR_IDSage__c , 'Error in Ctnum');
    }
    
}