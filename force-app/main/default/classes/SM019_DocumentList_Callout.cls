/**
* @author Saurabh
* @date 30/06/2020
* @Description Document List external service callout
*/
public with sharing class SM019_DocumentList_Callout {
    
    static String errMsg;
    static String className = SM019_DocumentList_Callout.class.getName();
  
    @AuraEnabled
    public static DocumentListFullResponse getDocumentListCallout(List<String> ownerids) {

        PAD.log(className, 'getDocumentListCallout', 'ownerids:' + ownerids);

        errMsg = '';
        DocumentListFullResponse fullResponse = new DocumentListFullResponse();
        String statusCode;
        HttpResponse response;
        final String WS_NOM_SERVICE  = 'LPCR_RECUPERATION_DOCUMENT';
        DocumentListStructureWrapper docListStructure;

        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            LPCR_Environnement__c envCS = LPCR_Environnement__c.getInstance();

            if('UAT'.equals(envCS.Nom__c)){
                request.setEndpoint('callout:LPCR_UAT_DOCUMENT_LIST');
            }
            else if('PROD'.equals(envCS.Nom__c)){
                request.setEndpoint('callout:LPCR_PRO_DOCUMENT_LIST');
            }
            else{
                request.setEndpoint('callout:LPCR_DEV_DOCUMENT_LIST');
            }
            request.setHeader('Authorization', 'Bearer {!$Credential.Password}');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setMethod('POST');

            docListStructure = new DocumentListStructureWrapper(ownerids);
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
                    fullResponse = (DocumentListFullResponse) JSON.deserialize(response.getBody(), DocumentListFullResponse.class);
                    // UM001_LogManager.writeLogActivityWithoutFuture(className, 'getDocumentListCallout', 'Callout', ownerids[0], 'getDocumentListCallout - Body : ' + JSON.serialize(docListStructure) + ' - statusCode:' + '200' + ' - OwnerId:' + ownerids[0], UM010_Constant.SUCCESS);  
                } 
            }
            else if(errMsg != '' || !statusCode.equals('200')){ // ERROR

                UM001_LogManager.writeLogActivityWithoutFuture(className, 'getDocumentListCallout', 'Callout', null,  'getDocumentListCallout - Body : ' + JSON.serialize(docListStructure) + ' - Apex Callout Exception:' + errMsg + ' - Response : ' + response + ' - statusCode:' + statusCode, UM010_Constant.ERROR);
            }
        }
        
        
        return fullResponse;
    }

    public class DocumentListStructureWrapper{
        public List<String> owners;
        public DocumentListStructureWrapper(List<String>  ownerSfId){
            this.owners = ownerSfId;   
        }
    }
    // Objet
    public class DocumentListFullResponse {
        @AuraEnabled
        public Integer totalResultSize; 
        @AuraEnabled
        public List<pageResultWrapper> pageResult; 
    }

    public class VersionWrapper{
        @AuraEnabled
        public String blobGUID; 
        @AuraEnabled
        public String fileExtension;
        @AuraEnabled 
        public String fileSize; 
        @AuraEnabled 
        public String date1; 
        @AuraEnabled 
        public String checksum; 
        @AuraEnabled 
        public String modifiedBy; 
    }

    public class pageResultWrapper{
        @AuraEnabled
        public String guid; 
        @AuraEnabled
        public List<String> owners;
        @AuraEnabled 
        public String fileName; 
        @AuraEnabled 
        public String fileCategory; 
        @AuraEnabled
        public List<VersionWrapper> versions; 
    }
}