/**
 * @description       : 
 * @author            : Widaad Papauretty
 * @group             : 
 * @last modified on  : 11-16-2021
 * @last modified by  : Widaad Papauretty
**/
global class APB025_MAJChampAmendment implements Database.Batchable<sObject>,Database.AllowsCallouts,Schedulable {
    //Batch to be executed for update of Date amendement for uplift to be included in desired date 
    String query;
    final String ClassName = APB025_MAJChampAmendment.class.getName();
    global APB025_MAJChampAmendment() {
        
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {

        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'start', 'Batch' , null, 'Starting Batch', UM010_Constant.SUCCESS);
        Id contratResaID  = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract, Label.LPCR_Reservataire);
        //select Contract for which amendement indexation needs to be created
        List<Contract> lstContracts = [Select id ,LPCR_IndexationConvenue__c,LPCR_DateRevisionPrix__c,LPCR_InitAutoAvecDateDebut__c,SBQQ__RenewalUpliftRate__c,SBQQ__Order__c From Contract where  LPCR_DateRevisionPrix__c !=null  and RecordTypeId =:contratResaID];
        
        System.debug('lstContracts: '+lstContracts);
        return Database.getQueryLocator([Select id ,LPCR_IndexationConvenue__c,LPCR_DateRevisionPrix__c,LPCR_InitAutoAvecDateDebut__c,SBQQ__RenewalUpliftRate__c,SBQQ__Order__c From Contract where  LPCR_DateRevisionPrix__c !=null  and RecordTypeId =:contratResaID]);
                                        
    }
    public void execute(Database.BatchableContext BC, list<Contract> scope){
        List<Contract> lstContractUpd= new List<Contract>();
        List<LPCR_Log__c> listOfLog = new List<LPCR_Log__c>();
		for(Contract tmpContract : scope){
			tmpContract.SBQQ__AmendmentStartDate__c=tmpContract.LPCR_DateRevisionPrix__c;
           	lstContractUpd.add(tmpContract);
            listOfLog.add(UM001_LogManager.getWriteLogActivityForBulkInsert('', ClassName, 'Batch', String.valueOf(tmpContract.Id), '', 'SUCCESS'));             
           
        }
       
        String ErrMsg;
        try {
            Database.SaveResult[] srList = Database.update(lstContractUpd,false);
            
            for (Integer i = 0; i < lstContractUpd.size(); i++){
        
                Database.SaveResult s = srList[i];
                Contract tmpContrat = lstContractUpd[i];
        
                if (s.isSuccess()){
                    
                    listOfLog.add(UM001_LogManager.getWriteLogActivityForBulkInsert(ClassName,'APB025 MAJ Date Amendement Indexation',  'Batch', 'Success : ' + tmpContrat.Id, tmpContrat.Id, 'SUCCESS'));
            
                } else {
        
                    for(Database.Error err : s.getErrors()) {
                        String tmpErr = '';
                        tmpErr += 'The following error has occurred.\n';                    
                        tmpErr += err.getStatusCode() + ': ' + err.getMessage();
                        listOfLog.add(UM001_LogManager.getWriteLogActivityForBulkInsert(ClassName,'APB025 MAJ Date Amendement Indexation',  'Batch', tmpContrat.Id, tmpErr, 'ERROR'));
                    }
                 }
            }
        
        } catch (Exception e) {
            ErrMsg = e.getMessage();
        } finally {
            if(ErrMsg != null && String.isNotBlank(ErrMsg)){
                UM001_LogManager.writeLogActivityWithoutFuture(ClassName, 'APB025 MAJ Date Amendement Indexation', 'Batch' , null,'Error while updating the contracts : ' + ErrMsg, UM010_Constant.ERROR);              
            }
        }
        
        ErrMsg = null ;
        try {
            insert listOfLog;
                     
        } catch (Exception e) {
            ErrMsg = e.getMessage();
        } finally {
            if(ErrMsg != null && String.isNotBlank(ErrMsg)){
                UM001_LogManager.writeLogActivityWithoutFuture(ClassName, 'APB025 MAJ Date Amendement Indexation' , 'Batch' , null,'Error while inserting the logs : ' + ErrMsg, UM010_Constant.ERROR);              
            }
        }
        
        
    }
    public void finish(Database.BatchableContext BC){
        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'finish', 'Batch' , null, 'Finished Batch Processing', UM010_Constant.SUCCESS);
        PAD.log(ClassName, 'finish', 'Start finish method');
        // schedule the apex class only if their is not existing job running
        boolean isBatchJobRunning = UM004_BatchUtility.isBatchJobRunning('APB023_CreateIndexationAmendment');
        // check if there is any open place to schedule the class
        boolean isJobQueueFull = UM004_BatchUtility.isBatchJobQueueFull();
        if(!isBatchJobRunning && !isJobQueueFull || !Test.isRunningTest()) {
            PAD.log(ClassName, 'finish', 'launching APB023_CreateIndexationAmendment');
		    Database.executeBatch(new APB023_CreateIndexationAmendment(), 1);
        }
    }
    global void execute(SchedulableContext sc) {
    }
}