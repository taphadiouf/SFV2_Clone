/**
* @author Hanae Makboub
* @date 04/10/2020
* @Description test class: Batch for Automation of "ressource famille" before B2C MAC renewals
*/

@isTest
public class APB019_AutomateRessourceFamille_Test {
	
    private static final Id ACC_B2C_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Famille);
    private static final Id CONTACT_ENFANT_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contact, Label.LPCR_Enfant);
    private static final Id CONTRACT_ACCUEIL_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract, Label.LPCR_ContratA);
    private static final Id ACC_CRECHE_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Creche);

    private static final Date todayDate = Date.toDay();
    
    @testsetup
    static void setup() {
        
        Map<String, Object> defaultVal = new Map<String, Object> {
            'RecordTypeId' => ACC_B2C_RT_ID,
                'Name' => 'FAMILLE'
                };
                    Account account =(Account) UM002_TestDataFactory.createSObject('Account', defaultVal);
        insert account;
        
        defaultVal = new Map<String, Object> {
            'RecordTypeId' => ACC_CRECHE_RT_ID,
                'Name' => 'CRECHE'
                };
                    Account creche =(Account) UM002_TestDataFactory.createSObject('Account', defaultVal);
        insert creche;

        defaultVal = new Map<String, Object> {
            'RecordTypeId' => CONTACT_ENFANT_RT_ID,
                'Name' => 'ENFANT'
                };
                    Contact contact =(Contact) UM002_TestDataFactory.createSObject('Contact', defaultVal);
        insert contact;
        
        defaultVal = new Map<String, Object> {
            'RecordTypeId' => CONTRACT_ACCUEIL_RT_ID,
                'AccountId' => account.id,
                'LPCR_ContactEnfant__c' => contact.id,
                'LPCR_TypeCreche__c' => 'MAC',
                'Status' => 'Draft',
                'LPCR_RenouvellementAutomatique__c' => true,
                'SBQQ__RenewalQuoted__c' => false,
                'LPCR_TypeFacturation__c' => 'Advance',
                'EndDate' => System.today().addDays(-1)
                };
                    Contract contract =(Contract) UM002_TestDataFactory.createSObject('Contract', defaultVal);
        insert contract;
        
        defaultVal = new Map<String, Object> {
            'LPCR_CompteFamille__c' => account.id,
                'LPCR_ContactEnfant__c' => contact.id,
                'LPCR_RevenusFamille__c' => 123,
                'LPCR_NombreEnfantHandicape__c' => 0,
                'LPCR_NombreEnfants__c' => 2,
                'LPCR_AnneeRevenu__c' => 2018,
                'LPCR_creche__c' => creche.id,
                'LPCR_DateDebut__c' => System.today()
                };
                    LPCR_RessourceFamille__c ressourceFamille1 =(LPCR_RessourceFamille__c) UM002_TestDataFactory.createSObject('LPCR_RessourceFamille__c', defaultVal);
        
        			LPCR_RessourceFamille__c ressourceFamille2 =(LPCR_RessourceFamille__c) UM002_TestDataFactory.createSObject('LPCR_RessourceFamille__c', defaultVal);
        
        			LPCR_RessourceFamille__c ressourceFamille3 =(LPCR_RessourceFamille__c) UM002_TestDataFactory.createSObject('LPCR_RessourceFamille__c', defaultVal);
        
        insert new List<LPCR_RessourceFamille__c>{ressourceFamille1,ressourceFamille2,ressourceFamille3};
        
        
    }
    
    
    @isTest
    private static void testAPB019_AutomateRessourceFamille(){
        
        System.runAs(UM002_TestDataFactory.createUser()){
            
            Date endYear = Date.newInstance(System.today().Year(), 12, 31);
            
            Account acountFamille = [SELECT Id, Name  FROM Account WHERE Name = 'FAMILLE'];
            
            Contact contactEnfant = [SELECT Id, Name  FROM Contact];
            
            Contract contractAcc = [SELECT Id,Status FROM Contract WHERE AccountId =: acountFamille.Id AND LPCR_ContactEnfant__c=: contactEnfant.Id ];
            
            contractAcc.Status = 'Activated';
        	update contractAcc ;
            
            List<LPCR_RessourceFamille__c> ressourceFamilleList = [SELECT Id, LPCR_CompteFamille__c, LPCR_ContactEnfant__c, LPCR_DateFin__c, LPCR_DateDebut__c,LPCR_BaremeCaf__c , LPCR_TauxEffort__c 
                                                                   FROM LPCR_RessourceFamille__c
                                                                   WHERE LPCR_CompteFamille__c =: acountFamille.Id 
                                                                   AND LPCR_ContactEnfant__c =: contactEnfant.Id];
            
            Test.startTest();
            
            APB019_AutomateRessourceFamille resFammileAutomationBatch = new APB019_AutomateRessourceFamille();
            resFammileAutomationBatch.execute(null);
            
            Test.stopTest();
            
            List<LPCR_RessourceFamille__c> listRessourceInactive = [SELECT Id, LPCR_CompteFamille__c, LPCR_ContactEnfant__c, LPCR_DateFin__c, LPCR_DateDebut__c,LPCR_BaremeCaf__c , LPCR_TauxEffort__c,LPCR_creche__c,LPCR_AnneeRevenu__c,LPCR_NombreEnfants__c,LPCR_RevenusFamille__c,LPCR_NombreEnfantHandicape__c
                                               						FROM LPCR_RessourceFamille__c WHERE LPCR_DateFin__c =: endYear];
                                                                       
                                                                       
            List<LPCR_RessourceFamille__c> listRessourceactive = [SELECT Id, LPCR_CompteFamille__c, LPCR_ContactEnfant__c, LPCR_DateFin__c, LPCR_DateDebut__c,LPCR_BaremeCaf__c , LPCR_TauxEffort__c,LPCR_creche__c,LPCR_AnneeRevenu__c,LPCR_NombreEnfants__c,LPCR_RevenusFamille__c,LPCR_NombreEnfantHandicape__c 
                                               					  FROM LPCR_RessourceFamille__c
                                               				      WHERE LPCR_DateFin__c = null];
            
            System.assertEquals(3, listRessourceInactive.size(), 'Error in setting ressource Famille to inactive ');
            System.assertEquals(3, listRessourceactive.size(), ' Error in clonning active ressource famille');
            
            //Check Mapping from old to new ones
            if(listRessourceInactive.size()>0){
                LPCR_RessourceFamille__c oldRess = listRessourceInactive.get(0);
                for(LPCR_RessourceFamille__c ress : listRessourceactive){
                    System.assertEquals(oldRess.LPCR_creche__c, ress.LPCR_creche__c,'LPCR_creche__c not mapped correctly');
                    System.assertEquals(oldRess.LPCR_AnneeRevenu__c, ress.LPCR_AnneeRevenu__c,'LPCR_AnneeRevenu__c not mapped correctly');
                    System.assertEquals(oldRess.LPCR_NombreEnfants__c, ress.LPCR_NombreEnfants__c,'LPCR_NombreEnfants__c not mapped correctly');
                    System.assertEquals(oldRess.LPCR_RevenusFamille__c, ress.LPCR_RevenusFamille__c,'LPCR_RevenusFamille__c not mapped correctly');
                    System.assertEquals(oldRess.LPCR_NombreEnfantHandicape__c, ress.LPCR_NombreEnfantHandicape__c,'LPCR_NombreEnfantHandicape__c not mapped correctly');
                }
            }
        }
    }
}