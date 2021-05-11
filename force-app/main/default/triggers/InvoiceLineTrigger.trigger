/**
* @author  PDO
* @created 09/04/2021
* @description Trigger on Invoice Line Object
*/
trigger InvoiceLineTrigger on blng__InvoiceLine__c (after insert) {
    new TM024_InvoiceLineTrigger().run();
}