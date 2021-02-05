/**
* @author Saurabh
* @date 30/06/2020
* @Description Document List external service callout
*/
public with sharing class SM019_DocumentList_Callout {
    
    static String errMsg;
    static String className = SM019_DocumentList_Callout.class.getName();
  
    @AuraEnabled
    public static DocumentListFullResponse getDocumentListCallout(String ownerid, String doc_type) {

        PAD.log(className, 'getDocumentListCallout', 'ownerid:' + ownerid);
        PAD.log(className, 'getDocumentListCallout', 'doc_type:' + doc_type);

        DocumentListFullResponse documentListFullResponse;
        errMsg = '';
        
        String statusCode;
        HttpResponse response;
        final String WS_NOM_SERVICE  = 'LPCR_RECUPERATION_DOCUMENT';
        DocumentListStructureWrapper docListStructure;

        try {
            documentListFullResponse = new DocumentListFullResponse();
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            LPCR_Environnement__c envCS = LPCR_Environnement__c.getInstance();

            if('UAT'.equals(envCS.Nom__c)){
                request.setEndpoint('callout:UAT_DOCUMENT_LISTE');
            }
            else if('PROD'.equals(envCS.Nom__c)){
                request.setEndpoint('callout:PROD_DOCUMENT_LISTE');
            }
            else{
                request.setEndpoint('callout:DEV_DOCUMENT_LISTE');
            }
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setTimeout(2000);

            docListStructure = new DocumentListStructureWrapper(ownerid);

            if(!String.isBlank(doc_type)){
                docListStructure.DocType = doc_type;
            }

            request.setBody(JSON.serialize(docListStructure));

            PAD.log(className, 'getDocumentListCallout', 'JSON.serialize(docListStructure):' + JSON.serialize(docListStructure));

            response = http.send(request);
            statusCode = String.valueOf(response.getStatusCode());

        }  catch(System.CalloutException e) {
            errMsg = '-- errMsg:' + e.getMessage() + ' | Line:' + e.getLineNumber();
            throw e;
        }
        finally { 

            if(statusCode != null) {

                if (statusCode.equals('200')) { // SUCCESS

                    documentListFullResponse.response = (List<DocumentListResponse>) JSON.deserialize(response.getBody(), List<DocumentListResponse>.class);
                    documentListFullResponse.result = '200';
                    UM001_LogManager.writeLogActivityWithoutFuture(UM010_Constant.LOG_LIST_DOC, className, 'Callout', ownerid, 'getDocumentListCallout - Body : ' + JSON.serialize(docListStructure) + ' - statusCode:' + documentListFullResponse.result + ' - OwnerId:' + ownerid, UM010_Constant.SUCCESS);  
                } 
            }
            else if(errMsg != '' || !statusCode.equals('200')){ // ERROR

                UM001_LogManager.writeLogActivityWithoutFuture(UM010_Constant.LOG_LIST_DOC,className, 'Callout', null,  'getDocumentListCallout - Body : ' + JSON.serialize(docListStructure) + ' - Apex Callout Exception:' + errMsg + ' - Response : ' + response + ' - statusCode:' + statusCode, UM010_Constant.ERROR);
            }
        }
        
        
        return documentListFullResponse;
    }

    public class DocumentListStructureWrapper{
        public String OwnerSfId; // obligatoitre
        public String DocType;
        public DocumentListStructureWrapper(String OwnerSfId){
            this.OwnerSfId = OwnerSfId;   
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
        public String ownerSfId {get;set;} 
        @AuraEnabled 
        public String docSfID {get;set;} 
        @AuraEnabled
        public String documentStatus {get;set;} 
        @AuraEnabled
        public String name {get;set;} 
        @AuraEnabled
        public String fileType{get;set;} 
    }


}