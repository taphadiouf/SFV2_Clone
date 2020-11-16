/**
* @author Saurabh
* @date 26/08/2020
* @Description Batch for QuoteReCalculateProcess call from APB014_TraitementModificationEntrante
*/

global class APB016_QuoteReCalculateProcess implements Database.Batchable<sObject>,Schedulable,Database.Stateful,Database.AllowsCallouts{
    String query;
    global Set<Id> quoteIds = new Set<Id>();  // quoteIds set populate from APB014_TraitementModificationEntrante
    
    global APB016_QuoteReCalculateProcess() {
        
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {    
        PAD.log('APB016_QuoteReCalculateProcess', 'start','quoteIds : '+quoteIds );    
        return Database.getQueryLocator([select id,LPCR_Quote_Recalculated__c from SBQQ__QuoteLine__c where SBQQ__Quote__c IN : quoteIds]);
    }
    
    global void execute(Database.BatchableContext BC, List<SBQQ__QuoteLine__c > scope) {

        PAD.log('APB016_QuoteReCalculateProcess', 'execute','scope to execute : '+scope );
        
        List<SBQQ__QuoteLine__c> updateQLIList = new List<SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c eachQLI : scope){
            eachQLI.LPCR_Quote_Recalculated__c = true;   
            updateQLIList.add(eachQLI);
        }
        String ErrMsg;
        try {
            // update QLI for autometiclly perform re-calculation
            update updateQLIList;
            UM001_LogManager.writeLogActivityWithoutFuture( 'Batch for QuoteReCalculateProcess call from APB014',
                                                            'APB016_QuoteReCalculateProcess', 'Batch' , null,
                                                            'Successfully updated list of quotes liens : ' + String.valueOf(updateQLIList), 
                                                            UM010_Constant.SUCCESS); 
            PAD.log('APB016_QuoteReCalculateProcess', 'execute','Update success of Quote lines list : ' + updateQLIList );
        } catch (Exception e) {
            ErrMsg = e.getMessage();
        } finally {
            if(ErrMsg != null && String.isNotBlank(ErrMsg)){
                UM001_LogManager.writeLogActivityWithoutFuture( 'Batch for QuoteReCalculateProcess call from APB014','APB013_ProcessYearlyOrderProduct', 'Batch' , null,'Error while updating the quote lines. Error : ' + ErrMsg, UM010_Constant.ERROR);              
            }
        }     
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    
    global void execute(SchedulableContext sc) {
        
        Datetime dtime = Datetime.now().addMinutes(2);
        String format = 's m H d M \'?\' yyyy';
        String timeForScheduler = dtime.format(format);

        APB016_QuoteReCalculateProcess sc1 = new APB016_QuoteReCalculateProcess();
        
        // schedule the apex class only if their is not existing job running
        boolean isBatchJobRunning = UM004_BatchUtility.isBatchJobRunning('APB016_QuoteReCalculateProcess');
                // check if there is any open place to schedule the class
        boolean isJobQueueFull = UM004_BatchUtility.isBatchJobQueueFull();
        
        if(isBatchJobRunning == UM004_BatchUtility.BOOLEAN_FALSE){
            if (isJobQueueFull == UM004_BatchUtility.BOOLEAN_FALSE) {
                sc1 = new APB016_QuoteReCalculateProcess();
                Database.executeBatch(this, 1);
            } else {
                //schedule this same schedulable class again in 2 mins
                Id schedId = System.Schedule('APB016_QuoteReCalculateProcess'+timeForScheduler,timeForScheduler,new APB016_QuoteReCalculateProcess());
            }
        }  
        
    }
    
}