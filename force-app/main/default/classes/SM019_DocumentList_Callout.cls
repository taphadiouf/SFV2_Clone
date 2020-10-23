/**
* @author Saurabh
* @date 30/06/2020
* @Description Document List external service callout
*/
public with sharing class SM019_DocumentList_Callout {
            
    @AuraEnabled
    public static DocumentListFullResponse getDocumentListCallout(String ownerid, String doc_type) {
        DocumentListFullResponse documentListFullResponse;
        String errorMsg;
        String statusCode;
        HttpResponse response;
        final String WS_NOM_SERVICE  = 'LPCR_RECUPERATION_DOCUMENT';
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

            DocumentListStructureWrapper docListStructure = new DocumentListStructureWrapper(ownerid);

            if(!String.isBlank(doc_type)){
                docListStructure.DocType = doc_type;
            }

            request.setBody(JSON.serialize(docListStructure));
            response = http.send(request);
            statusCode = String.valueOf(response.getStatusCode());
            
            
        }catch(System.CalloutException e) {
            errorMsg = String.valueOf(e);
        }
        finally { 
            if (errorMsg != '') {
                UM001_LogManager.writeLogActivity(UM010_Constant.LOG_LIST_DOC,'SM019_DocumentList_Callout', 'Callout', null,  'Apex Callout Exception:' + errorMsg, UM010_Constant.ERROR);
            }
            if (statusCode.equals('200')) {
                documentListFullResponse.response = (List<DocumentListResponse>) JSON.deserialize(response.getBody(), List<DocumentListResponse>.class);
                documentListFullResponse.result = '200';
                UM001_LogManager.writeLogActivity(UM010_Constant.LOG_LIST_DOC, 'SM019_DocumentList_Callout', 'Callout', ownerid, 'statusCode:' + statusCode + ' - OwnerId:' + ownerid, UM010_Constant.SUCCESS);  
            } 
            else {
                UM001_LogManager.writeLogActivity(UM010_Constant.LOG_LIST_DOC, 'SM019_DocumentList_Callout', 'Callout', ownerid,  'Exception:' + statusCode + ' - statusCode:' + statusCode + ' - OwnerId:' + ownerid + ' - OwnerSfId:' + ownerid, UM010_Constant.ERROR);  
                LPCR_AppelServiceExterne__mdt appelServiceExterne = [SELECT LPCR_CodeRetour__c ,LPCR_MessageRetour__c , LPCR_NomService__c  
                                                                     FROM LPCR_AppelServiceExterne__mdt  
                                                                     WHERE LPCR_CodeRetour__c = :statusCode AND LPCR_NomService__c = :WS_NOM_SERVICE ];
                throw new AuraHandledException(appelServiceExterne.LPCR_MessageRetour__c);
            }
            
        }
        
        
        return documentListFullResponse;
    }

    @future(callout=true)
    public static void getDocumentListFutureCallout(String fromEmail,String toEmail,String subject, String emailBody,String ownerid, String doc_type) {

        DocumentListFullResponse documentListFullResponse = getDocumentListCallout(ownerid, doc_type);  
        Set<String> docTmp = new Set<String>();

        if (documentListFullResponse.result == '200') {
            
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
            
            for(DocumentListResponse eachDoc : documentListFullResponse.response){
                docTmp.add(eachDoc.id);
            }	
            SM016_SendMail_Callout.sendMailCallout('e.yhuellou-ext@lpcr.fr', email, 'Facture Client', 'Bonjour, Merci de trouver votre facture ci-joint. Cordialement', docTmp);
        }
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