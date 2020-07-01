/**
* @author Saurabh
* @date 30/06/2020
* @Description Document List external service callout
*/
public with sharing class SM019_DocumentList_Callout {
    public static HttpResponse getDocumentListCallout(String ownerid, String doc_type) {
        
        DocumentListFullResponse documentListFullResponse = new DocumentListFullResponse();
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:LPCR_API_DocList');
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        DocumentListStructureWrapper docListStructure = new DocumentListStructureWrapper(ownerid, doc_type);
        request.setBody(JSON.serialize(docListStructure));
        HttpResponse response = http.send(request);
        // Parse the JSON response
        if (response.getStatusCode() == 200) {
            System.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
                documentListFullResponse = (DocumentListFullResponse) JSON.deserialize(response.getBody(), DocumentListFullResponse.class);
        } else {
            System.debug(response.getBody());
        }
        return response;
    }

    public class DocumentListStructureWrapper{
        public String ownerid; // obligatoitre
        public String doc_type;
        public DocumentListStructureWrapper(String ownerid, String doc_type){
            this.ownerid = ownerid;
            this.doc_type = doc_type;      
        }
    }
    public class DocumentListFullResponse{
        public String result;
        public List<DocumentListResponse> response;
    }
    public class DocumentListResponse{
        public String id;
        public String doc_type;
    }


}