/**
* @author Hanae Makboub
* @date 26/06/2020
* @Description Batch for filling the "commentaire" field each time the button "A envoyer" is clicked
*/
global class APB011_SetInvoiceCommentaire implements Database.Batchable<sObject>,Schedulable, Database.Stateful {
    String query;
    final String ClassName = APB011_SetInvoiceCommentaire.class.getName();
    global Set<Id> invoiceIds = new Set<Id>();

    global APB011_SetInvoiceCommentaire() {
        
    }

    global APB011_SetInvoiceCommentaire(String query) {
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {

        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'start', 'Batch' , null, 'Starting Batch', UM010_Constant.SUCCESS);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<blng__InvoiceRun__c> scope) {

        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'execute', 'Batch' , null, 'Scope size : '  + scope.size(), UM010_Constant.SUCCESS); 
        String ErrMsg;

        List<Exception> errors = new List<Exception>();

        try {

            PAD.log('APB011_SetInvoiceCommentaire','execute','scope to execute : '+scope);

            Set<Id> invoiceRunIds = UM003_TypeManager.getIdsOfListObjects(scope);
            List<blng__Invoice__c> lstOfInvoices = EM017_FactureEntity.lstPostedInvoices(invoiceRunIds);
            
            PAD.log('APB011_SetInvoiceCommentaire','execute','here : ' + UM003_TypeManager.getIdsOfListObjects(lstOfInvoices));

            for (Id tmpId : UM003_TypeManager.getIdsOfListObjects(lstOfInvoices)) {
                this.invoiceIds.add(tmpId);
            }
            //this.invoiceIds.addAll(new Set<Id>(UM003_TypeManager.getIdsOfListObjects(lstOfInvoices)));

            for(blng__InvoiceRun__c eachInvoiceRun : scope){
                eachInvoiceRun.LPCR_EnvoyerFaitPar__c = eachInvoiceRun.OwnerId;
            }
            ErrMsg = null;
            try {
                update scope;
                PAD.log('APB011_SetInvoiceCommentaire','execute','Invoice Runs Update success. list : ' + scope);
                UM001_LogManager.writeLogActivityWithoutFuture(ClassName, 'execute', 'Batch' , null, 'Successfully updated invoices run list : ' + String.valueOf(scope), 
                                                                UM010_Constant.SUCCESS);     
            } catch (Exception e) {
                ErrMsg = e.getMessage();
            } finally {
                if(ErrMsg != null && String.isNotBlank(ErrMsg)){
                    UM001_LogManager.writeLogActivityWithoutFuture(ClassName, 'execute', 'Batch' , null,'Error while updating invoices run list. Error : ' + ErrMsg, UM010_Constant.ERROR);              
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

        PAD.log('APB011_SetInvoiceCommentaire','finish','this.invoiceIds : ' + this.invoiceIds);
        Database.executeBatch(new APB020_UpdateInvoiceEnvoye(this.invoiceIds), 500);

        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'finish', 'Batch' , null, 'Finished Batch Processing', UM010_Constant.SUCCESS);
    }
    global void execute(SchedulableContext sc) {
        
        APB011_SetInvoiceCommentaire sc1 = new APB011_SetInvoiceCommentaire(query);
        Datetime dt = Datetime.now().addMinutes(30);  // i.e. 30 mins
        String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
        // schedule the apex class only if their is not existing job running
        boolean isBatchJobRunning = UM004_BatchUtility.isBatchJobRunning(ClassName);
        
        // check if there is any open place to schedule the class
        boolean isJobQueueFull = UM004_BatchUtility.isBatchJobQueueFull();
        
        if(isBatchJobRunning == UM004_BatchUtility.BOOLEAN_FALSE){
            if (isJobQueueFull == UM004_BatchUtility.BOOLEAN_FALSE) {
                sc1 = new APB011_SetInvoiceCommentaire(query);
                Database.executeBatch(this, 1);
            } else {
                //schedule this same schedulable class again in 30 mins
                Id schedId = System.Schedule(ClassName+timeForScheduler,timeForScheduler,new APB011_SetInvoiceCommentaire(query));
            }
        }  
        
    } 
    
}