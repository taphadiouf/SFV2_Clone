/**
* @author Saurabh
* @date 30/06/2020
* @Description Document List external service callout
*/
public with sharing class SM019_DocumentList_Callout {
    public static DocumentListFullResponse getDocumentListCallout(String ownerid, String doc_type) {
        
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
            documentListFullResponse = (DocumentListFullResponse) JSON.deserialize(response.getBody(), DocumentListFullResponse.class);
        } else {
            documentListFullResponse = (DocumentListFullResponse) JSON.deserialize(response.getBody(), DocumentListFullResponse.class);
        }
        return documentListFullResponse;
    }

    @future(callout=true)
    public static void getDocumentListFutureCallout(String ownerid, String doc_type, String email) {
        DocumentListFullResponse documentListFullResponse = getDocumentListCallout(ownerid, doc_type);  
        Set<String> docTmp = new Set<String>();
        if (documentListFullResponse.result == '200') {
            System.debug('**** documentListFullResponse');
            System.debug(documentListFullResponse);
            for(DocumentListResponse eachDoc : documentListFullResponse.response){
                docTmp.add(eachDoc.id);
            }	
            SM016_SendMail_Callout.sendMailCallout('lpcr@lpcr.fr', email, 'LPCR : Facture', 'Bonjour, Voici votre facture ci-joint. Cordialement, LPCR', docTmp);
        }
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