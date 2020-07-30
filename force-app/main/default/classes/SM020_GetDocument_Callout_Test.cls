/**
* @author Achraf ABOUL(aaboul@salesforce.com)
* @date 30/06/2020
* @description Test class for SM020_GetDocument_Callout
*/
@isTest
public with sharing class SM020_GetDocument_Callout_Test {
    public SM020_GetDocument_Callout_Test() {

    }
    @isTest
    static void getDocumentBySFIdCallout1_Test(){
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MCK001_LPCRHttpCalloutMockImpl());
      	String documentString = SM020_GetDocument_Callout.getDocumentBySFIdCallout('000000000000000', '000000000000000');
        // Verify mock response is not null
        System.assertNotEquals(null, documentString, 'The callout result returned is null.');
        System.assertNotEquals('',documentString, 'The callout result returned is empty.'); 
        Test.stopTest();
              
    }
    @isTest
    static void getDocumentBySFIdCallout2_Test(){
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MCK001_LPCRHttpCalloutMockImpl());
        try{
          String documentString = SM020_GetDocument_Callout.getDocumentBySFIdCallout('', '000000000000000');
        }
        catch(Exception e){
          // Verify mock response is not null
          System.assertNotEquals(null, e, 'The callout response status is not 500.');
        }
        
             
              
    }
}
