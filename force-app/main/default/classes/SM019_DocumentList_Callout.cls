/**
* @author Saurabh
* @date 30/06/2020
* @Description Document List external service callout
*/
public with sharing class SM019_DocumentList_Callout {
            
    @AuraEnabled(Cacheable = true)
    public static DocumentListFullResponse getDocumentListCallout(String ownerid, String doc_type) {
        final String WS_NOM_SERVICE  = 'LPCR_RECUPERATION_DOCUMENT';
        DocumentListFullResponse documentListFullResponse = new DocumentListFullResponse();
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:LPCR_API_DocList');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        DocumentListStructureWrapper docListStructure = new DocumentListStructureWrapper(ownerid, doc_type);
        request.setBody(JSON.serialize(docListStructure));
        HttpResponse response = http.send(request);
        // Parse the JSON response
        String statusCode = response.getStatusCode()+'';
        UM001_LogManager.writeLogActivity('Appel Service Externe REF DOC LIST', '', 'Appel Externe', (Id) ownerid, response.getBody(), (statusCode.equals('200') ? 'SUCCESS' : 'ERROR'));
        if (statusCode.equals('200')) {
            System.debug('response.getBody()' + response.getBody());
            documentListFullResponse.response = (List<DocumentListResponse>) JSON.deserialize(response.getBody(), List<DocumentListResponse>.class);
            documentListFullResponse.result = '200';
        } else {
            //documentListFullResponse = (DocumentListFullResponse) JSON.deserialize(response.getBody(), DocumentListFullResponse.class);
        LPCR_AppelServiceExterne__mdt appelServiceExterne = [SELECT LPCR_CodeRetour__c ,LPCR_MessageRetour__c , LPCR_NomService__c  
                                                             FROM LPCR_AppelServiceExterne__mdt  
                                                             WHERE LPCR_CodeRetour__c = :statusCode AND LPCR_NomService__c = :WS_NOM_SERVICE ];
            throw new AuraHandledException(appelServiceExterne.LPCR_MessageRetour__c);
        }
        return documentListFullResponse;
    }

    @future(callout=true)
    public static void getDocumentListFutureCallout(String fromEmail,String toEmail,String subject, String emailBody,String ownerid, String doc_type) {
        DocumentListFullResponse documentListFullResponse = getDocumentListCallout(ownerid, doc_type);  
        Set<String> docTmp = new Set<String>();
        if (documentListFullResponse.result == '200') {
            System.debug('$$$'+documentListFullResponse.response);
            for(DocumentListResponse eachDoc : documentListFullResponse.response){
                docTmp.add(eachDoc.id);
            }	
            SM016_SendMail_Callout.sendMailCallout(fromEmail, toEmail, subject, emailBody, docTmp);
        }
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
        public String OwnerSfId; // obligatoitre
        public String DocType;
        public DocumentListStructureWrapper(String OwnerSfId, String DocType){
            this.OwnerSfId = OwnerSfId;
            this.DocType = DocType;      
        }
    }
    public class DocumentListFullResponse {
        @AuraEnabled
        public String result {get;set;} 
        @AuraEnabled
        public List<DocumentListResponse> response {get;set;} 
    }
    public class DocumentListResponse {
        @AuraEnabled
        public String id {get;set;} 
        @AuraEnabled
        public String documentType {get;set;}
        @AuraEnabled 
        public DateTime doc_creation_date {get;set;} 
        @AuraEnabled
        public String documentStatus {get;set;} 
        @AuraEnabled
        public String name {get;set;} 
        @AuraEnabled
        public String fileType{get;set;} 
    }


}