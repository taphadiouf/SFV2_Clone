@isTest
public with sharing class EM017_FactureEntity_Test {
    @isTest
    static void EM017_FactureEntity_Test() {
        Account acc = UM002_TestDataFactory.createAccount('testAccount');
        insert acc;
        List<blng__InvoiceRun__c> invoiceRunsList = UM002_TestDataFactory.createInvoiceRuns(1,'Execution de Facture',date.newInstance(System.Today().year(), 10, 02));
        insert invoiceRunsList;
        Set<Id> invoiceRunIds = (new Map<Id,blng__InvoiceRun__c>(invoiceRunsList)).keySet();

        blng__InvoiceRun__c invoiceRun = invoiceRunsList.get(0);
        List<blng__Invoice__c> invoicesList = UM002_TestDataFactory.createInvoices(10,acc.id,invoiceRun.id,'Posted','Brouillon' );
        insert invoicesList;
        
        List<blng__Invoice__c> pretInvoicesList = UM002_TestDataFactory.createInvoices(10,acc.id,invoiceRun.id,'Posted','A Envoyer' );
        insert pretInvoicesList;

        EM017_FactureEntity fe = new EM017_FactureEntity();
        List<blng__Invoice__c> invoices = EM017_FactureEntity.lstPostedInvoices(invoiceRunIds);
        System.assertEquals(20, invoices.size());


    }
}