/**
* @author Hanae Makboub
* @date 29/06/2020
* @SOQL Queries about Invoice
*/
public with sharing class EM017_FactureEntity extends EM001_AbstractObjectEntity {
	public EM017_FactureEntity(){
        super('blng__Invoice__c');
    }
    
    public static List<blng__Invoice__c> lstPostedInvoices(Set<Id> invoiceRunIds){
        return [select Id, blng__InvoiceStatus__c,LPCR_Commentaire__c ,blng__InvoiceRunCreatedBy__c , Name , LPCR_StatutFacture__c from blng__Invoice__c 
               	Where blng__InvoiceStatus__c = 'Posted' AND blng__InvoiceRunCreatedBy__c In: invoiceRunIds ];
         
    }
}