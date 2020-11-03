@isTest
public class VFC002_AEnvoyerBatchButton_Test {
 
    public static testMethod void testMyController() {
        PageReference pageRef = Page.VFP002_AEnvoyerBatchButton;
        Test.setCurrentPage(pageRef);
        blng__InvoiceRun__c i = new blng__InvoiceRun__c();
        i.name='testingInvoice'; 
        i.blng__TargetDate__c = Date.newInstance(2020, 12, 17);
        insert i;     
        String expected = '/' + i.id;
        expected = expected.substring(0, expected.length() - 3);
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(i);
        VFC002_AEnvoyerBatchButton controller = new VFC002_AEnvoyerBatchButton(sc);
        String actual = controller.runBatch().getUrl();
        Test.stopTest();

        System.assertEquals(expected, actual);
    }
}
