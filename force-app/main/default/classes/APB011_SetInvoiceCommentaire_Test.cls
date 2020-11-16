/**
* @author Hanae Makboub
* @date 29/06/2020
* @Description test class for Batch for filling the "commentaire" field each time the button "A envoyer" is clicked
*/
@isTest
public class APB011_SetInvoiceCommentaire_Test {
	@testsetup
    static void setup() {
        Account acc = UM002_TestDataFactory.createAccount('testAccount');
        insert acc;
        List<blng__InvoiceRun__c> invoiceRunsList = UM002_TestDataFactory.createInvoiceRuns(1,'Execution de Facture',date.newInstance(System.Today().year(), 10, 02));
        insert invoiceRunsList;
        blng__InvoiceRun__c invoiceRun = invoiceRunsList.get(0);
        List<blng__Invoice__c> invoicesList = UM002_TestDataFactory.createInvoices(10,acc.id,invoiceRun.id,'Posted','Brouillon' );
        insert invoicesList;
        List<blng__Invoice__c> pretInvoicesList = UM002_TestDataFactory.createInvoices(10,acc.id,invoiceRun.id,'Posted','A Envoyer' );
        insert pretInvoicesList;
    }
    
    @isTest
    private static void testAPB011_SetInvoiceCommentaire(){
        System.runAs(UM002_TestDataFactory.createUser()){
            Test.startTest();
            APB011_SetInvoiceCommentaire InvoiceRunBatch0 = new APB011_SetInvoiceCommentaire();
            APB011_SetInvoiceCommentaire InvoiceRunBatch = new APB011_SetInvoiceCommentaire('SELECT Id, Name, OwnerId, LPCR_EnvoyerFaitPar__c FROM blng__InvoiceRun__c');
            InvoiceRunBatch.execute(null);
            Test.stopTest();
            List<blng__Invoice__c> invoices = [SELECT Id, blng__InvoiceStatus__c,LPCR_Commentaire__c ,blng__InvoiceRunCreatedBy__c , Name , LPCR_StatutFacture__c FROM blng__Invoice__c 
                                                WHERE blng__InvoiceStatus__c = 'Posted' AND LPCR_StatutFacture__c = 'Brouillon' ];
            for(blng__Invoice__c eachInvoice : invoices){
            	System.assertEquals(eachInvoice.LPCR_Commentaire__c, 'Le statut des factures devrait être Prêt à valider pour pouvoir les envoyer', 'Le commentaire est incorrecte');
            }
            List<blng__Invoice__c> pretInvoices = [SELECT Id, blng__InvoiceStatus__c,LPCR_Commentaire__c ,blng__InvoiceRunCreatedBy__c , Name , LPCR_StatutFacture__c FROM blng__Invoice__c 
                                                WHERE blng__InvoiceStatus__c = 'Posted' AND LPCR_StatutFacture__c = 'Prêt à valider' ];
            for(blng__Invoice__c eachInvoice : pretInvoices){
            	System.assertEquals(eachInvoice.LPCR_StatutFacture__c, 'A Envoyer', 'le statut de la facture ne change pas');
            }
            
        }
        
    }
}