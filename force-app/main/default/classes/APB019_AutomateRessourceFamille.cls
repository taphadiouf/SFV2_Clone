/**
* @author Hanae Makboub
* @date 04/10/2020
* @Description Batch for Automation of "ressource famille" before B2C MAC renewals
*/
global class APB019_AutomateRessourceFamille implements Database.Batchable<sObject>,Schedulable {
    String query;
    public static Id accueilRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Contract',Label.LPCR_ContratA);
    global APB019_AutomateRessourceFamille() {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        Date today = date.today();
        
        query = 'SELECT Id, AccountId, LPCR_ContactEnfant__c FROM Contract WHERE RecordTypeId =: accueilRecTypeId AND LPCR_TypeCreche__c = \'MAC\' AND  Status =\'Activated\' AND LPCR_RenouvellementAutomatique__c = true AND  LPCR_DateRenouvellement__c <= :today AND LPCR_DateRenouvellement__c != null AND (SBQQ__RenewalQuoted__c = false OR SBQQ__RenewalForecast__c = false) ';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contract> scope) {
        
        PAd.log('APB019_AutomateRessourceFamille', 'execute', 'scope to execute : '+scope);
        
        string errorMsg;
        
        set<String> accFamilleIds = UM003_TypeManager.getFieldsOfListObjects(scope,'AccountId');
        
        set<String> contractEnfantIds = UM003_TypeManager.getFieldsOfListObjects(scope,'LPCR_ContactEnfant__c');
        
        List<LPCR_RessourceFamille__c> ressourceFamilleList = [SELECT id,name,recordtypeid,lpcr_active__c,lpcr_anneerevenu__c,lpcr_baremecaf__c,lpcr_commentaire__c,lpcr_comptefamille__c,lpcr_contactenfant__c,lpcr_datedebut__c,lpcr_datefin__c,lpcr_dureecontratjour__c,lpcr_estmigre__c,lpcr_fincontrat__c,lpcr_idexterne_baremecaf__c,lpcr_idexterne_comptefamille__c,lpcr_idexterne_contactenfant__c,lpcr_idexterne_creche__c,lpcr_nombreenfanthandicape__c,lpcr_nombreenfants__c,lpcr_ressourceplafond__c,lpcr_ressourcesprixplancher__c,lpcr_revenusfamille__c,lpcr_sourcedonnees__c,lpcr_statutvalidation__c,lpcr_tauxeffort__c,lpcr_typecreche__c,lpcr_typemensualisation__c,lpcr_typeplanning__c,lpcr_creche__c
        
                                                                FROM LPCR_RessourceFamille__c 
                                                                WHERE   LPCR_CompteFamille__c       IN : accFamilleIds 
                                                                        AND 
                                                                        LPCR_ContactEnfant__c   IN : contractEnfantIds 
                                                                        AND 
                                                                        LPCR_Active__c          = true];
        
        List<LPCR_Log__c> listOfLog = new List<LPCR_Log__c>();
        
        List<LPCR_RessourceFamille__c> newactiveList = new List<LPCR_RessourceFamille__c>();
        
        for(LPCR_RessourceFamille__c eachResFamille : ressourceFamilleList){
            LPCR_RessourceFamille__c tempRessFamille = new LPCR_RessourceFamille__c();
            tempRessFamille = eachResFamille.clone(false, false, false, false);//Take all the fields but the 4 below
            tempRessFamille.LPCR_DateDebut__c  = date.newInstance(eachResFamille.LPCR_DateDebut__c.year()+1, 01, 01);
            tempRessFamille.LPCR_DateFin__c = null;
            tempRessFamille.LPCR_BaremeCaf__c = null;
            tempRessFamille.LPCR_TauxEffort__c = null;
            
            newactiveList.add(tempRessFamille);

            eachResFamille.LPCR_DateFin__c = date.newInstance(eachResFamille.LPCR_DateDebut__c.year(), 12, 31);

            listOfLog.add(UM001_LogManager.getWriteLogActivityForBulkInsert('Automating Ressource Famille', 'APB019_AutomateRessourceFamille', 'Batch', String.valueOf(eachResFamille.Id), '', 'SUCCESS'));  
            
        }
        
        try{
            update ressourceFamilleList;
            
            insert newactiveList;
            
        }catch(Exception ex){
            
            PAD.log('APB019_AutomateRessourceFamille','execute','Exception : '+ex.getMessage());
            errorMsg = String.valueOf(ex);
        }
        finally {
            
            if (String.isNotBlank(errorMsg)) {
                UM001_LogManager.writeLogActivityWithoutFuture('Automating Ressource Famille', 'APB019_AutomateRessourceFamille', 'Batch', '',  'Error:' + errorMsg, UM010_Constant.ERROR);  
            }
            else {
                insert listOfLog;
            }
            
        }
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    
    global void execute(SchedulableContext sc) {
        Datetime dt = Datetime.now().addMinutes(30);  // i.e. 30 mins
        String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
        
        APB019_AutomateRessourceFamille sc1 = new APB019_AutomateRessourceFamille();
        
        // schedule the apex class only if their is not existing job running
        boolean isBatchJobRunning = UM004_BatchUtility.isBatchJobRunning('APB019_AutomateRessourceFamille');
        
        // check if there is any open place to schedule the class
        boolean isJobQueueFull = UM004_BatchUtility.isBatchJobQueueFull();
        
        if(isBatchJobRunning == UM004_BatchUtility.BOOLEAN_FALSE){
            if (isJobQueueFull == UM004_BatchUtility.BOOLEAN_FALSE) {
                sc1 = new APB019_AutomateRessourceFamille();
                Database.executeBatch(this, 1);
            } else {
                //schedule this same schedulable class again in 30 mins
                Id schedId = System.Schedule('APB019_AutomateRessourceFamille'+timeForScheduler,timeForScheduler,new APB019_AutomateRessourceFamille());
            }
        }  
        
    } 
}