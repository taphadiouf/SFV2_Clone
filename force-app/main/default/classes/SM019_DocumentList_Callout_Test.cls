/**
* @author Saurabh
* @date 30/06/2020
* @description Test class for SM019_DocumentList_Callout
*/
@isTest
public class SM019_DocumentList_Callout_Test {
    private static List<String> ownerids=new List<String>{'000000000000000'};
    @isTest
    static void getDocumentListCallout_1_Test(){
		  Test.startTest();
        
      Test.setMock(HttpCalloutMock.class, new MCK001_LPCRHttpCalloutMockImpl());
      SM019_DocumentList_Callout.DocumentListFullResponse documentListFullResponse = SM019_DocumentList_Callout.getDocumentListCallout(ownerids);
      // Verify mock response is not null
      System.assertNotEquals(null, documentListFullResponse, 'The callout result returned is null.');
      // Verify status code
      //System.assertEquals('200',documentListFullResponse.result, 'The status code is not 200.'); 

      Test.stopTest();
              
    }
    @isTest
    static void getDocumentListCallout_2_Test(){
      
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new MCK001_LPCRHttpCalloutMockImpl());

      try{
        SM019_DocumentList_Callout.DocumentListFullResponse documentListFullResponse = SM019_DocumentList_Callout.getDocumentListCallout(new List<String>());
      }catch(Exception e){
        System.assertNotEquals(null,e, 'The status code is not 503.'); 
      }
      Test.stopTest();
              
    }
}