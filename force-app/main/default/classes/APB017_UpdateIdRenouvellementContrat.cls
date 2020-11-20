/**
* @author Saurabh Singh
* @date 29/10/2020
* @Description Task IS-1848
*/
global class APB017_UpdateIdRenouvellementContrat implements Database.Batchable<sObject>,Schedulable {
    final String ClassName = APB017_UpdateIdRenouvellementContrat.class.getName();
    private static final Id CONTRACT_ACCUEIL_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract, Label.LPCR_ContratA);
    
    global APB017_UpdateIdRenouvellementContrat() {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'start', 'Batch' , null, 'Starting Batch', UM010_Constant.SUCCESS);
        String query = 'SELECT Id,SBQQ__Quote__r.SBQQ__Opportunity2__r.SBQQ__RenewedContract__c,LPCR_ProcessIdRenouvellementContrat__c FROM Contract WHERE LPCR_ProcessIdRenouvellementContrat__c = true AND SBQQ__Quote__r.SBQQ__Opportunity2__r.SBQQ__RenewedContract__c != null ';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contract> scope) {
        
        List<Exception> errors = new List<Exception>();

        try {

            PAD.log(ClassName,'execute','scope to execute : '+scope);        
            
            List<Contract> updateContractB2C = new List<Contract>();
            List<Contract> updateContractB2B = new List<Contract>();
            
            Map<String, String> b2bContractIdsMap = new Map<String, String>();
            Map<String, Contract> b2bUpdateContractMap = new Map<String, Contract>();
            List<LPCR_Log__c> listOfLog = new List<LPCR_Log__c>();
            
            for(Contract eachContract : scope){
                b2bContractIdsMap.put(eachContract.SBQQ__Quote__r.SBQQ__Opportunity2__r.SBQQ__RenewedContract__c,eachContract.id);
                b2bUpdateContractMap.put(eachContract.SBQQ__Quote__r.SBQQ__Opportunity2__r.SBQQ__RenewedContract__c,eachContract);
            }
            
            PAD.log(ClassName,'execute','b2bContractIdsMap : '+b2bContractIdsMap);
            
            // Query B2C Contract (Contract.RecordType = 'Accueil')
            for(Contract eachB2CContract : [SELECT Id,LPCR_ContractEntreprise__c FROM Contract WHERE LPCR_ContractEntreprise__c IN : b2bContractIdsMap.keySet() AND recordtypeid =: CONTRACT_ACCUEIL_RT_ID ]){
                PAD.log(ClassName,'execute','before eachB2CContract : '+eachB2CContract);
                if(b2bContractIdsMap.keyset().contains(eachB2CContract.LPCR_ContractEntreprise__c)){
                    b2bUpdateContractMap.get(eachB2CContract.LPCR_ContractEntreprise__c).LPCR_ProcessIdRenouvellementContrat__c = false;
                    eachB2CContract.LPCR_ContractEntreprise__c = b2bContractIdsMap.get(eachB2CContract.LPCR_ContractEntreprise__c);                 
                    updateContractB2C.add(eachB2CContract);
                }
                listOfLog.add(UM001_LogManager.getWriteLogActivityForBulkInsert('Update Contract Entreprise', ClassName, 'Batch', String.valueOf(eachB2CContract.Id), '', 'SUCCESS'));  
            }        
            
            // update B2C and B2B contract records
            if(updateContractB2C.size() > 0){
                try{
                    update updateContractB2C;
                    update b2bUpdateContractMap.values();
                    insert listOfLog;
                }catch(Exception ex){
                    PAD.log(ClassName,'execute','Exception : '+ex.getMessage());
                }
            }
        

        } catch(Exception e) {
            errors.add(e);
        }
        
        if (!errors.isEmpty()) {
            UM001_LogManager.writeLogActivityWithoutFuture(ClassName, 'execute', 'Batch' , null,'Processing with errors occurred : ' + errors, UM010_Constant.ERROR);
        }
    
    }
    
    global void finish(Database.BatchableContext BC) {
        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'finish', 'Batch' , null, 'Finished Batch Processing', UM010_Constant.SUCCESS);
    }
    
    global void execute(SchedulableContext sc) {
        PAD.log(ClassName,'execute','sc');
        APB017_UpdateIdRenouvellementContrat sc1 = new APB017_UpdateIdRenouvellementContrat();
        
        // schedule the apex class only if their is not existing job running
        boolean isBatchJobRunning = UM004_BatchUtility.isBatchJobRunning(ClassName);
        
        // check if there is any open place to schedule the class
        boolean isJobQueueFull = UM004_BatchUtility.isBatchJobQueueFull();
        
        if(isBatchJobRunning == UM004_BatchUtility.BOOLEAN_FALSE){
            if (isJobQueueFull == UM004_BatchUtility.BOOLEAN_FALSE) {
                sc1 = new APB017_UpdateIdRenouvellementContrat();
                Database.executeBatch(this, 1);
            } else {
                //schedule this same schedulable class again in 30 mins
                sc1 = new APB017_UpdateIdRenouvellementContrat();
                Datetime dt = Datetime.now().addMinutes(30);  // i.e. 30 mins
                String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
                Id schedId = System.Schedule(ClassName+timeForScheduler,timeForScheduler,sc1);
            }
        }  
        
    } 
    
}