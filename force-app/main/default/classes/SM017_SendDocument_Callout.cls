/**
* @author Saurabh
* @date 30/06/2020
* @Description SendDocument external service callout
*/

public with sharing class SM017_SendDocument_Callout {
    @future(callout=true)
	public static void sendDocumentCallout(String doc_type, String doc_owner_sf_id,String doc_status, String doc_name, String doc_file_type) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:LPCR_API_SaveDocument');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        WRP004_APISaveDocument data = new WRP004_APISaveDocument(doc_type, doc_owner_sf_id, doc_status, doc_name, doc_file_type);
        request.setBody(JSON.serialize(data));
        HttpResponse response = http.send(request);
        // Parse the JSON response
        if (response.getStatusCode() == 200) {
            UM001_LogManager.writeLogActivityNow(doc_name, 'Envoie de document', 'Appel Externe', doc_owner_sf_id, '', 'Success');
        } else {
            System.debug(response.getBody());
            UM001_LogManager.writeLogActivityNow(doc_name, 'Envoie de document', 'Appel Externe', doc_owner_sf_id, '', 'Error');
        }
    }
    
}