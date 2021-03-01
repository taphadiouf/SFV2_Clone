/**
* @author Erwan Yhuellou
* @date 30/01/2021
* @Description Batch for filling the "commentaire" field each time the button "A envoyer" is clicked in the invoice
*/
global class APB020_UpdateInvoiceEnvoye implements Database.Batchable<sObject>,Schedulable {
    
    String query;
    final String ClassName = APB020_UpdateInvoiceEnvoye.class.getName();
    Set<Id> invoiceScopeId = new Set<Id>();

    global APB020_UpdateInvoiceEnvoye() {
        
    }

    global APB020_UpdateInvoiceEnvoye(Set<Id> tmpSet) {
        this.invoiceScopeId = tmpSet;
    }

    
    global Database.QueryLocator start(Database.BatchableContext BC) {

        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'start', 'Batch' , null, 'Starting Batch', UM010_Constant.SUCCESS);
        return Database.getQueryLocator([SELECT Id, LPCR_StatutFacture__c from blng__Invoice__c where id in :this.invoiceScopeId]);
    }

    global void execute(Database.BatchableContext BC, List<blng__Invoice__c> scope) {

        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'execute', 'Batch' , null, 'Scope size : '  + scope.size(), UM010_Constant.SUCCESS); 
        
        List<blng__Invoice__c> invoiceToUpdate = new List<blng__Invoice__c>();
        List<Exception> errors = new List<Exception>();

        try {

            PAD.log('APB020_UpdateInvoiceEnvoye','execute','scope to execute : ' + scope);
            
            for(blng__Invoice__c eachInvoice: scope){

                blng__Invoice__c tmpInvoice = eachInvoice;

                if(!Label.LPCR_PretAValider.equals(eachInvoice.LPCR_StatutFacture__c)  && !Label.LPCR_AEnvoyer.equals(eachInvoice.LPCR_StatutFacture__c)){
                    tmpInvoice.LPCR_Commentaire__c = Label.LPCR_commentaireStatut;
                }
                else if(Label.LPCR_PretAValider.equals(eachInvoice.LPCR_StatutFacture__c)){
                    tmpInvoice.LPCR_StatutFacture__c = Label.LPCR_AEnvoyer;
                }
                invoiceToUpdate.add(eachInvoice);
            }
            String ErrMsg;
            try {
                update invoiceToUpdate;
                PAD.log('APB020_UpdateInvoiceEnvoye','execute','Invoices Update success. list : ' + invoiceToUpdate);
                UM001_LogManager.writeLogActivityWithoutFuture(ClassName, 'execute', 'Batch' , null, 'Successfully updated invoices list : ' + String.valueOf(invoiceToUpdate),  UM010_Constant.SUCCESS);     
            } catch (Exception e) {
                ErrMsg = e.getMessage();
            } finally {
                if(ErrMsg != null && String.isNotBlank(ErrMsg)){
                    UM001_LogManager.writeLogActivityWithoutFuture(ClassName, 'execute', 'Batch' , null,'Error while updating invoices list. Error : ' + ErrMsg, UM010_Constant.ERROR);              
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
        
         
        
    } 
    
}