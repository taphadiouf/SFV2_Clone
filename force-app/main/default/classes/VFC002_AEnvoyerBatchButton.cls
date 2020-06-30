/**
* @author Hanae Makboub
* @date 29/06/2020
* @Description Class to link the VF page for the 'A Envoyer' Button to the Batch APB011_SetInvoiceCommentaire
*/
public class VFC002_AEnvoyerBatchButton {

    public  id invoiceRunId{get;set;}
    public VFC002_AEnvoyerBatchButton(ApexPages.StandardController controller)
    {
        blng__InvoiceRun__c currentRec= (blng__InvoiceRun__c)controller.getRecord();
        if(currentRec !=null)       
            invoiceRunId = currentRec.id;
    }
    
    
    
    public PageReference runBatch() {
        //run your batch here with set of ids you have
        blng__InvoiceRun__c currentinvoiceRun = [Select Id, Name From blng__InvoiceRun__c Where Id =:invoiceRunId limit 1 ];
        Database.executeBatch(new APB011_SetInvoiceCommentaire('SELECT Id, Name FROM blng__InvoiceRun__c  WHERE Id =\'' + invoiceRunId + '\''), 20);
        return new ApexPages.StandardController(currentinvoiceRun).view();

    } 
}