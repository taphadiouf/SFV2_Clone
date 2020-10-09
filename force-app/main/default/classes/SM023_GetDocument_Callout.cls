/**
* @author Achraf ABOUL (aaboul@salesforce.com)
* @date 26/07/2020
* @Description Get One Document external service callout
*/
public with sharing class SM023_GetDocument_Callout {

    @AuraEnabled(Cacheable = true)
    public static String getDocumentBySFIdCallout(String docId, String ownerId) {
        DocumentWrapper docWrp;
        String errorMsg;
        String statusCode;
        HttpResponse response;
        final String WS_NOM_SERVICE  = 'LPCR_RECUPERATION_DOCUMENT';
        try {
            docWrp = new DocumentWrapper();
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            LPCR_Environnement__c envCS = LPCR_Environnement__c.getInstance();

            if('UAT'.equals(envCS.Nom__c)){
                request.setEndpoint('callout:UAT_GET_DOCUMENT'+ '/' + docId);
            }
            else if('PROD'.equals(envCS.Nom__c)){
                request.setEndpoint('callout:PROD_GET_DOCUMENT'+ '/' + docId);
            }
            else{
                request.setEndpoint('callout:DEV_GET_DOCUMENT'+ '/' + docId);
            }
        
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            response = http.send(request);
            statusCode = response.getStatusCode()+'';


        }catch(System.CalloutException e) {
            errorMsg = String.valueOf(e);
        }
        finally {
            if (errorMsg != '') {
                UM001_LogManager.writeLogActivity(UM010_Constant.LOG_REF_DOC_REC,'SM023_GetDocument_Callout', 'Callout', null,  'Apex Callout Exception:' + errorMsg, UM010_Constant.ERROR);
            }
            if (statusCode=='200') {
                UM001_LogManager.writeLogActivity(UM010_Constant.LOG_REF_DOC_REC, 'SM023_GetDocument_Callout', 'Callout', ownerId, 'statusCode:' + statusCode + ' - docId:' + docId, UM010_Constant.SUCCESS);  
                docWrp = (DocumentWrapper) JSON.deserialize(response.getBody(), DocumentWrapper.class);
            } 
            else {
                UM001_LogManager.writeLogActivity(UM010_Constant.LOG_REF_DOC_REC, 'SM023_GetDocument_Callout', 'Callout', ownerId,  'Exception:' + statusCode + ' - statusCode:' + statusCode + ' - ownerId:' + ownerId + ' - docId:' + docId, UM010_Constant.ERROR);  
                
                LPCR_AppelServiceExterne__mdt appelServiceExterne = [SELECT LPCR_CodeRetour__c ,LPCR_MessageRetour__c , LPCR_NomService__c  
                                                                     FROM LPCR_AppelServiceExterne__mdt  
                                                                     WHERE LPCR_CodeRetour__c = :statusCode AND LPCR_NomService__c = :WS_NOM_SERVICE ];
                throw new AuraHandledException(appelServiceExterne.LPCR_MessageRetour__c);
            }
            
        }
        
        
        return docWrp.binaryDocument;
    }

    public class DocumentWrapper{
        public String binaryDocument;
    }
}
