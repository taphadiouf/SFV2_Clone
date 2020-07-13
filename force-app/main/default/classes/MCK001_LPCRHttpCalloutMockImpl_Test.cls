/**
* @author Saurabh
* @created 27/06/2020
* @description Test Class of MCK001_LPCRHttpCalloutMockImpl.
*/
@isTest
public class MCK001_LPCRHttpCalloutMockImpl_Test {
	@isTest
    static void SaveDocumentCallout_1_Test(){
        Test.setMock(HttpCalloutMock.class, new MCK001_LPCRHttpCalloutMockImpl());
        WRP004_APISaveDocument data = new WRP004_APISaveDocument('Facture','000000000000000000','Validé','Test','PDF');  
             
        String body = JSON.serialize(data);
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:LPCR_API_SaveDocument');
        req.setMethod('POST');
        req.setBody(body);
        req.setTimeout(30000);
        HttpResponse res = http.send(req);
        System.assertEquals(503, res.getStatusCode(), 'SaveDocumentCallout_1_Test callout status code not correct');
    }
    
    @isTest
    static void SaveDocumentCallout_2_Test(){
        Test.setMock(HttpCalloutMock.class, new MCK001_LPCRHttpCalloutMockImpl());
        WRP004_APISaveDocument data = new WRP004_APISaveDocument('Test','000000000000000000','Validé','Test','PDF');        
        String body = JSON.serialize(data);
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:LPCR_API_SaveDocument');
        req.setMethod('POST');
        req.setBody(body);
        req.setTimeout(30000);
        
        HttpResponse res = http.send(req);
        System.assertEquals(503, res.getStatusCode(), 'SaveDocumentCallout_2_Test callout status code not correct');
    }
    @isTest
    static void GetBySfId_1_Test(){
        Test.setMock(HttpCalloutMock.class, new MCK001_LPCRHttpCalloutMockImpl());
        WRP005_APIGetBySfId data = new WRP005_APIGetBySfId();
        data.Sfid = '000000000000000000';       
        String body = JSON.serialize(data);
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:LPCR_API_GetBySfId/'+data.Sfid);
        req.setMethod('POST');
        req.setBody(body);
        req.setTimeout(30000);
        
        HttpResponse res = http.send(req);
        System.assertEquals(503, res.getStatusCode(), 'GetBySfId_1_Test callout status code not correct');
    }
    @isTest
    static void GetBySfId_2_Test(){
        Test.setMock(HttpCalloutMock.class, new MCK001_LPCRHttpCalloutMockImpl());
        WRP005_APIGetBySfId data = new WRP005_APIGetBySfId();
        data.Sfid = '';       
        String body = JSON.serialize(data);
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:LPCR_API_GetBySfId/'+data.Sfid);
        req.setMethod('POST');
        req.setBody(body);
        req.setTimeout(30000);
        
        HttpResponse res = http.send(req);
        System.assertEquals(503, res.getStatusCode(), 'GetBySfId_2_Test callout status code not correct');
    }
}