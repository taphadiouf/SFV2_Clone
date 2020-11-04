/**
* @author Dario Correnti
* @date 05/05/2020
* @Description Batch to bulk process Order and prepare them for execution of APB002_RenewalContract.
*/
global class APB006_PrepaRenewalContract implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    public static final String CONTRACT_TO_RENEW_BASE_QUERY = 'SELECT Id, AccountId, Account.RecordTypeId, LPCR_Creche__c, Name, ' + 
        ' EndDate, LPCR_RenouvellementAutomatique__c, SBQQ__RenewalQuoted__c, LPCR_JoursAvance__c ' +
        ' FROM Contract WHERE Status =\'Activated\' AND LPCR_RenouvellementAutomatique__c = true AND ' + 
        ' LPCR_DateRenouvellement__c <= :today AND (SBQQ__RenewalQuoted__c = false OR SBQQ__RenewalForecast__c = false)';
    
    Set<String> setContractKeyAccountAndNursery;

    global APB006_PrepaRenewalContract () {
        setContractKeyAccountAndNursery = new Set<String> ();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        PAD.log('APB006_PrepaRenewalContract', 'start', 'START');
        Date today = date.today();

        String query = CONTRACT_TO_RENEW_BASE_QUERY + ' AND AccountId != null AND LPCR_Creche__c != null';
        PAD.log('APB006_PrepaRenewalContract', 'start', 'running query ' + query);

        return Database.getQueryLocator(query);
    }
    
    /*
	*	@description : this execute method simply flg contract (TECH_AjoutFraisGestion__c) to add the registration fee just to one contract in case of several contracts are renewd in parallell for the same customer / nurserey (for instance in case of renewal 2 children).
	*	@param List<Contract> scope to process
    *	@returns void
    */
    global void execute (Database.BatchableContext BC, List<Contract> scope) {
        PAD.log('APB006_PrepaRenewalContract', 'execute', 'scope size: ' + scope.size());
        PAD.log('APB006_PrepaRenewalContract', 'execute', 'setContractKeyAccountAndNursery size: ' + setContractKeyAccountAndNursery.size());

        Id accountEntrepriseRTId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Entreprise);
        Id accountFamilleRTId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Famille);
        List<Contract> listContractToUpdate = new List<Contract>();

        for (Contract item : scope) {
            if (item.Account.RecordTypeId == accountEntrepriseRTId || item.Account.RecordTypeId == accountFamilleRTId) {
                String tmpContractKey = item.AccountId + '-' + item.LPCR_Creche__c;    
                if (!setContractKeyAccountAndNursery.contains(tmpContractKey)) {
                    setContractKeyAccountAndNursery.add(tmpContractKey);
                    listContractToUpdate.add(new Contract(Id = item.Id, TECH_AjoutFraisGestion__c = true));
                }
            }
        }
        PAD.log('APB006_PrepaRenewalContract', 'execute', 'updating listContractToUpdate recods: ' + listContractToUpdate.size());
        
        update listContractToUpdate;        
    }
    
    global void finish (Database.BatchableContext BC) {
        PAD.log('APB006_PrepaRenewalContract', 'finish', 'Start finish method');
        // schedule the apex class only if their is not existing job running
        boolean isBatchJobRunning = UM004_BatchUtility.isBatchJobRunning('APB002_RenewalContract');
        // check if there is any open place to schedule the class
        boolean isJobQueueFull = UM004_BatchUtility.isBatchJobQueueFull();
        if(!isBatchJobRunning && !isJobQueueFull && !Test.isRunningTest()) {
            PAD.log('APB006_PrepaRenewalContract', 'finish', 'launching APB002_RenewalContract');
            Database.executeBatch(new APB002_RenewalContract(), 1);
        }
    }
    
    global void execute(SchedulableContext sc) {
        // schedule the apex class only if their is not existing job running
        boolean isBatchJobRunning = UM004_BatchUtility.isBatchJobRunning('APB006_PrepaRenewalContract');
        APB006_PrepaRenewalContract sc1 = new APB006_PrepaRenewalContract();
        Datetime dt = Datetime.now().addMinutes(30);  // i.e. 30 mins
        String formatString = 's m H d M \'?\' yyyy';
        String timeForScheduler = dt.format(formatString);
        // check if there is any open place to schedule the class
        boolean isJobQueueFull = UM004_BatchUtility.isBatchJobQueueFull();
        
        if(!isBatchJobRunning) {
            if (!isJobQueueFull) {Database.executeBatch(sc1, 2000);}
            else { Id schedId = System.Schedule('APB006_PrepaRenewalContract' + timeForScheduler, timeForScheduler, sc1);PAD.log('APB006_PrepaRenewalContract', 'execute', 'scheduling in 30minutes : ' + timeForScheduler);}
        }  
    }
} 
