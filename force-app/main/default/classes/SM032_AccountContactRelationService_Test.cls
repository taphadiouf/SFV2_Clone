/**
 * @author PRA
 * @created 11/11/2021
 * @description Test class for SM032_AccountContactRelationService 
 */
@isTest
public class SM032_AccountContactRelationService_Test {
    public static Id conCollabRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contact,Label.LPCR_ContactColl);
    public static Id accCrecheRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account,Label.LPCR_Creche);
    
    @testSetup 
    static void testSetup(){
        List<Account> lstAcc=new  List<Account>();
    	List<Contact> lstCon=new  List<Contact>();	
        UserRole roleAdv;
        UserRole roleFamille;
        User usrResponsableAdv;
        User usrResponsableServiceFamille;
        System.runAs(UM002_TestDataFactory.createUser()){
            roleAdv = [select id,name,developername from userrole where developername like 'LPCR_ResponsableADV'];
            roleFamille = [select id,name,developername from userrole where developername like 'LPCR_ChargeRelationFamillesInscriptions'];
            usrResponsableAdv = UM002_TestDataFactory.createUser(roleAdv.Id);    
            usrResponsableServiceFamille = UM002_TestDataFactory.createUser(roleFamille.Id); 
        }
        
        Map<String, Object> defaultVal1 = new Map<String, Object> {
            	'RecordTypeId' => accCrecheRecTypeId,
                'Name' => 'Compte creche',
                'LPCR_IdExterne_Compte__c'=>'2345',
                'LPCR_ResponsableADV__c'=>usrResponsableAdv.id,
                'LPCR_ResponsableServiceFamille__c'=>usrResponsableServiceFamille.id
                };
        Account acc1 =(Account) UM002_TestDataFactory.createSObject('Account', defaultVal1);
        lstAcc.add(acc1);
        Map<String, Object> defaultVal2 = new Map<String, Object> {
            	'RecordTypeId' => accCrecheRecTypeId,
                'Name' => 'Compte creche',
                'LPCR_IdExterne_Compte__c'=>'1234',
                'LPCR_ResponsableADV__c'=>usrResponsableAdv.id,
                'LPCR_ResponsableServiceFamille__c'=>usrResponsableServiceFamille.id
                };
        Account acc2 =(Account) UM002_TestDataFactory.createSObject('Account', defaultVal2);
        lstAcc.add(acc2);
        insert lstAcc;
        System.debug('PRA lstAcc '+lstAcc);
        Map<String, Object> defaultVal3= new Map<String, Object> {
            	'RecordTypeId' => conCollabRecTypeId,
                'FirstName' => 'FirstName',
                'Lastname' => 'Lastname',
                'AccountId' => acc1.id,
                'Email' => 'last@gmail.com',
                'LPCR_ContactAEnvoyer__c' => false,
                'LPCR_IdExterne_Contact__c'=>'3030'
                };
        Contact con1= (Contact) UM002_TestDataFactory.createSObject('Contact', defaultVal3);
        lstCon.add(con1);                                             
		Map<String, Object> defaultVal4 =new Map<String, Object> {
            	'RecordTypeId' => conCollabRecTypeId,
                'FirstName' => 'FirstName',
                'Lastname' => 'Lastname',
                'AccountId' => acc1.id,
                'Email' => 'last@gmail.com',
                'LPCR_ContactAEnvoyer__c' => false,
                'LPCR_IdExterne_Contact__c'=>'C1234'
                };
        Contact con2 = (Contact) UM002_TestDataFactory.createSObject('Contact', defaultVal4);
		lstCon.add(con2);
        insert lstCon;
        System.debug('PRA lstCon '+lstCon);
    }
    
	@isTest
    private static void setIdSalesforceAccountContact_test(){ 
        List<AccountContactRelation>  accConRel = new List<AccountContactRelation>();
        Test.startTest();
            accConRel.add(new AccountContactRelation(LPCR_AccountIdExterne__c='1234',LPCR_IdExterne_Contact__c='3030'));
            accConRel.add(new AccountContactRelation(LPCR_AccountIdExterne__c='1234',LPCR_IdExterne_Contact__c='C1234'));
            insert accConRel;  
            Account acc =[SELECT id,LPCR_IdExterne_Compte__c,recordtypeId FROM Account WHERE LPCR_IdExterne_Compte__c ='1234' LIMIT 1];
            Contact con =[SELECT id,LPCR_IdExterne_Contact__c,recordtypeId FROM Contact WHERE LPCR_IdExterne_Contact__c ='3030' LIMIT 1];
            AccountContactRelation accCon = [SELECT accountid,contactid FROM AccountContactRelation WHERE LPCR_AccountIdExterne__c ='1234' and LPCR_IdExterne_Contact__c ='3030'LIMIT 1];
                
            System.assertEquals(accCon.accountid, acc.id);
            System.assertEquals(accCon.contactid, con.id);
        Test.stopTest();
        
    }
}