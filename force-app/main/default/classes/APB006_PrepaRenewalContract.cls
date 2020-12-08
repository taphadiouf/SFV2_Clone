/**
* @author Dario Correnti
* @date 05/05/2020
* @Description Batch to bulk process Order and prepare them for execution of APB002_RenewalContract.
*/
global class APB006_PrepaRenewalContract implements Database.Batchable<sObject>, Database.Stateful, Schedulable {

    final String ClassName = APB006_PrepaRenewalContract.class.getName();
    
    public static final String CONTRACT_TO_RENEW_BASE_QUERY = 'SELECT Id, AccountId, Account.RecordTypeId, LPCR_Creche__c, Name, ' + 
        ' EndDate, LPCR_RenouvellementAutomatique__c, SBQQ__RenewalQuoted__c, LPCR_JoursAvance__c ' +
        ' FROM Contract WHERE Status =\'Activated\' AND LPCR_RenouvellementAutomatique__c = true AND ' + 
        ' LPCR_DateRenouvellement__c <= :today AND (SBQQ__RenewalQuoted__c = false OR SBQQ__RenewalForecast__c = false)';
    
    Set<String> setContractKeyAccountAndNursery;

    global APB006_PrepaRenewalContract () {
        setContractKeyAccountAndNursery = new Set<String> ();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'start', 'Batch' , null, 'Starting Batch', UM010_Constant.SUCCESS);
        PAD.log(ClassName, 'start', 'START');
        Date today = date.today();

        String query = CONTRACT_TO_RENEW_BASE_QUERY + ' AND AccountId != null AND LPCR_Creche__c != null';
        PAD.log(ClassName, 'start', 'running query ' + query);

        return Database.getQueryLocator(query);
    }
    
    /*
	*	@description : this execute method simply flg contract (TECH_AjoutFraisGestion__c) to add the registration fee just to one contract in case of several contracts are renewd in parallell for the same customer / nurserey (for instance in case of renewal 2 children).
	*	@param List<Contract> scope to process
    *	@returns void
    */
    global void execute (Database.BatchableContext BC, List<Contract> scope) {
        
        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'execute', 'Batch' , null, 'Scope size : '  + scope.size(), UM010_Constant.SUCCESS); 
        
        List<Exception> errors = new List<Exception>();

        try {
            
            PAD.log(ClassName, 'execute', 'scope size: ' + scope.size());
            PAD.log(ClassName, 'execute', 'setContractKeyAccountAndNursery size: ' + setContractKeyAccountAndNursery.size());

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
            PAD.log(ClassName, 'execute', 'updating listContractToUpdate recods: ' + listContractToUpdate.size());
            String ErrMsg;
            try {
                update listContractToUpdate; 
                UM001_LogManager.writeLogActivityWithoutFuture( 'Batch to bulk process Order and prepare them for exec of APB002',
                                                                ClassName, 'Batch' , null,
                                                                'Successfully updated list of contracts : ' + String.valueOf(listContractToUpdate), 
                                                                UM010_Constant.SUCCESS);          
            } catch (Exception e) {
                ErrMsg = e.getMessage();
            } finally {
                if(ErrMsg != null && String.isNotBlank(ErrMsg)){
                    UM001_LogManager.writeLogActivityWithoutFuture( 'Batch to bulk process Order and prepare them for exec of APB002',ClassName, 'Batch' , null,'Error while updating the contracts : ' + ErrMsg, UM010_Constant.ERROR);              
                }
            }
        } catch(Exception e) {
            errors.add(e);
        }
        
        if (!errors.isEmpty()) {
            UM001_LogManager.writeLogActivityWithoutFuture(ClassName, 'execute', 'Batch' , null,'Processing with errors occurred : ' + errors, UM010_Constant.ERROR);
        }
    }
    
    global void finish (Database.BatchableContext BC) {
        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'finish', 'Batch' , null, 'Finished Batch Processing', UM010_Constant.SUCCESS);
        PAD.log(ClassName, 'finish', 'Start finish method');
        // schedule the apex class only if their is not existing job running
        boolean isBatchJobRunning = UM004_BatchUtility.isBatchJobRunning('APB002_RenewalContract');
        // check if there is any open place to schedule the class
        boolean isJobQueueFull = UM004_BatchUtility.isBatchJobQueueFull();
        if(!isBatchJobRunning && !isJobQueueFull && !Test.isRunningTest()) {
            PAD.log(ClassName, 'finish', 'launching APB002_RenewalContract');
            Database.executeBatch(new APB002_RenewalContract(), 1);
        }
    }
    
    global void execute(SchedulableContext sc) {
        // schedule the apex class only if their is not existing job running
        boolean isBatchJobRunning = UM004_BatchUtility.isBatchJobRunning(ClassName);
        APB006_PrepaRenewalContract sc1 = new APB006_PrepaRenewalContract();
        Datetime dt = Datetime.now().addMinutes(30);  // i.e. 30 mins
        String formatString = 's m H d M \'?\' yyyy';
        String timeForScheduler = dt.format(formatString);
        // check if there is any open place to schedule the class
        boolean isJobQueueFull = UM004_BatchUtility.isBatchJobQueueFull();
        
        if(!isBatchJobRunning) {
            if (!isJobQueueFull) {Database.executeBatch(sc1, 2000);}
            else { Id schedId = System.Schedule(ClassName + timeForScheduler, timeForScheduler, sc1);}
        }  
    }
} 
