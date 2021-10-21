/**
 * @auteur  SC (PRA)
 * @depuis  12/10/2021
 * @description Test class for SM031_DocumentDownload_Callout.
 *
 * -- Historique de maintenance: 
 * --
 * -- Date         Nom   Version  Commentaire 
 * -- -----------  ----  -------  ------------------------
 * -- 12-10-2021   	PRA     1.0     Version initiale
*/
@isTest
public class SM031_DocumentDownload_Callout_Test {
    @isTest
    static void downloadDocument_1_Test(){
		Test.startTest();
          Test.setMock(HttpCalloutMock.class, new MCK001_LPCRHttpCalloutMockImpl());
          Blob documentDownloaded = SM031_DocumentDownload_Callout.downloadDocument('000000000000000','d6511858-ad20-4e25-9d08-6154851659e7');
          // Verify mock response is not null
          System.assertNotEquals(null, documentDownloaded, 'The callout result returned is null.');
          // Verify status code
          //System.assertEquals('200',documentListFullResponse.result, 'The status code is not 200.'); 
      Test.stopTest();
              
    }
}