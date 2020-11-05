/**
* @author Ayoub Ouarti
* @date 08/06/2020
* @Description Reset the custom start and end date on the contract
*/
global class APB008_ResetStartEndDatesOnContract implements Database.Batchable<sObject>,Schedulable {
    
    global APB008_ResetStartEndDatesOnContract() {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date today = date.today();
        Id accountEntrepriseRTId  = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Entreprise);
        String methodeRenouvellementValue='Tacite';
        String query = 'SELECT Id, LPCR_DateFin__c ,LPCR_DureeContratJour__c ,LPCR_DateDebut__c ,LPCR_MethodeRenouvellement__c, Account.RecordTypeId  FROM Contract WHERE Account.RecordTypeId = :accountEntrepriseRTId AND LPCR_MethodeRenouvellement__c = :methodeRenouvellementValue AND LPCR_DateFin__c  =:today';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contract> scope) {
        PAD.log('APB008_ResetStartEndDatesOnContract','execute','scope to execute : '+scope);
        
        UM001_LogManager.writeLogActivityWithoutFuture( 'Reset the custom start and end date on the contract',
                                                        'APB008_ResetStartEndDatesOnContract', 'Batch' , null,
                                                        'Execute method started with scope : ' + String.valueOf(scope), 
                                                        UM010_Constant.SUCCESS);
        Set<Id> contractIds = UM003_TypeManager.getIdsOfListObjects(scope);
        List<Contract> listOfContract = [SELECT Id, LPCR_DureeContratJour__c ,LPCR_DateFin__c ,LPCR_DateDebut__c ,LPCR_MethodeRenouvellement__c, Account.RecordTypeId FROM Contract 
                                         WHERE Id in :contractIds ];   
        for (Contract eachContract : listOfContract) {
            eachContract.LPCR_DateDebut__c =eachContract.LPCR_DateFin__c.addDays(1);
            eachContract.LPCR_DateFin__c=eachContract.LPCR_DateDebut__c.addDays(Integer.valueOf(eachContract.LPCR_DureeContratJour__c)); 
            PAD.log('APB008_ResetStartEndDatesOnContract','execute','set LPCR_DateDebut__c value to ' + eachContract.LPCR_DateDebut__c + ' for contract ' + eachContract);
            PAD.log('APB008_ResetStartEndDatesOnContract','execute','set LPCR_DateFin__c value to ' + eachContract.LPCR_DateFin__c + ' for contract ' + eachContract);
        }
        
        String ErrMsg;
        try {
            update listOfContract;  
            UM001_LogManager.writeLogActivityWithoutFuture( 'Reset the custom start and end date on the contract',
                                                            'APB008_ResetStartEndDatesOnContract', 'Batch' , null,
                                                            'Successfully updated list of contracts : ' + String.valueOf(listOfContract), 
                                                            UM010_Constant.SUCCESS);          
        } catch (Exception e) {
            ErrMsg = e.getMessage();
        } finally {
            if(ErrMsg != null && String.isNotBlank(ErrMsg)){
                UM001_LogManager.writeLogActivityWithoutFuture( 'Reset the custom start and end date on the contract','APB008_ResetStartEndDatesOnContract', 'Batch' , null,'Error while updating the contracts. Error : ' + ErrMsg, UM010_Constant.ERROR);              
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    
    global void execute(SchedulableContext sc) {
        PAD.log('APB008_ResetStartEndDatesOnContract','execute','sc');
        APB008_ResetStartEndDatesOnContract sc1 = new APB008_ResetStartEndDatesOnContract();
        String timeForScheduler = Datetime.now().addMinutes(30).format('s m H d M \'?\' yyyy');// i.e. 30 mins
        // schedule the apex class only if their is not existing job running
        boolean isBatchJobRunning = UM004_BatchUtility.isBatchJobRunning('APB008_ResetStartEndDatesOnContract');
        
        // check if there is any open place to schedule the class
        boolean isJobQueueFull = UM004_BatchUtility.isBatchJobQueueFull();
        
        if(isBatchJobRunning == UM004_BatchUtility.BOOLEAN_FALSE){
            if (isJobQueueFull == UM004_BatchUtility.BOOLEAN_FALSE) {
                sc1 = new APB008_ResetStartEndDatesOnContract();
                Database.executeBatch(this, 1);
            } else {
                //schedule this same schedulable class again in 30 mins
                
                Id schedId = System.Schedule('APB008_ResetStartEndDatesOnContract'+timeForScheduler,timeForScheduler,new APB008_ResetStartEndDatesOnContract());
            }
        }  
        
    } 
}