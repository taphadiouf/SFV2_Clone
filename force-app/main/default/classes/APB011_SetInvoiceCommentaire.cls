/**
* @author Hanae Makboub
* @date 26/06/2020
* @Description Batch for filling the "commentaire" field each time the button "A envoyer" is clicked
*/
global class APB011_SetInvoiceCommentaire implements Database.Batchable<sObject>,Schedulable {
    String query;
    
    global APB011_SetInvoiceCommentaire(String query) {
        this.query = query;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<blng__InvoiceRun__c> scope) {
       	PAD.log('APB011_SetInvoiceCommentaire','execute','scope to execute : '+scope);
        Set<Id> invoiceRunIds = UM003_TypeManager.getIdsOfListObjects(scope);
        List<blng__Invoice__c> lstOfInvoices = EM017_FactureEntity.lstPostedInvoices(invoiceRunIds);
        for(blng__Invoice__c eachInvoice: lstOfInvoices){
            if(!Label.LPCR_PretAValider.equals(eachInvoice.LPCR_StatutFacture__c)  && !Label.LPCR_AEnvoyer.equals(eachInvoice.LPCR_StatutFacture__c)){
                eachInvoice.LPCR_Commentaire__c = Label.LPCR_commentaireStatut;
            }
            else if(Label.LPCR_PretAValider.equals(eachInvoice.LPCR_StatutFacture__c)){
                eachInvoice.LPCR_StatutFacture__c = Label.LPCR_AEnvoyer;
            }
        }
        update lstOfInvoices;
        for(blng__InvoiceRun__c eachInvoiceRun : scope){
            eachInvoiceRun.LPCR_EnvoyerFaitPar__c = eachInvoiceRun.OwnerId;
        }
        update scope;
    }
    global void finish(Database.BatchableContext BC) {
    }
    global void execute(SchedulableContext sc) {
        
        APB011_SetInvoiceCommentaire sc1 = new APB011_SetInvoiceCommentaire(query);
       
        // schedule the apex class only if their is not existing job running
        boolean isBatchJobRunning = UM004_BatchUtility.isBatchJobRunning('APB011_SetInvoiceCommentaire');
        
        // check if there is any open place to schedule the class
        boolean isJobQueueFull = UM004_BatchUtility.isBatchJobQueueFull();
        
        if(isBatchJobRunning == UM004_BatchUtility.BOOLEAN_FALSE){
            if (isJobQueueFull == UM004_BatchUtility.BOOLEAN_FALSE) {
                sc1 = new APB011_SetInvoiceCommentaire(query);
                Database.executeBatch(this, 1);
            } else {
                //schedule this same schedulable class again in 30 mins
                sc1 = new APB011_SetInvoiceCommentaire(query);
                Datetime dt = Datetime.now().addMinutes(30);  // i.e. 30 mins
                String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
                Id schedId = System.Schedule('APB011_SetInvoiceCommentaire'+timeForScheduler,timeForScheduler,sc1);
            }
        }  
        
    } 
    
}