/**
* @author Saurabh
* @date 30/06/2020
* @description Test class for SM019_DocumentList_Callout
*/
@isTest
public class SM019_DocumentList_Callout_Test {
    
    @isTest
    static void getDocumentListCallout_1_Test(){
		Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MCK001_LPCRHttpCalloutMockImpl());
      	HttpResponse result = SM019_DocumentList_Callout.getDocumentListCallout('000000000000000', 'Facture');
        // Verify mock response is not null
        System.assertNotEquals(null, result, 'The callout result returned is null.');
        // Verify status code
        System.assertEquals(200,result.getStatusCode(), 'The status code is not 200.'); 
        Test.stopTest();
              
    }
    @isTest
    static void getDocumentListCallout_2_Test(){
		Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MCK001_LPCRHttpCalloutMockImpl());
      	HttpResponse result = SM019_DocumentList_Callout.getDocumentListCallout('', 'Facture');
        // Verify mock response is not null
        System.assertNotEquals(null, result, 'The callout result returned is null.');
        // Verify status code
        System.assertEquals(400,result.getStatusCode(), 'The status code is not 400.'); 
        Test.stopTest();
              
    }

}