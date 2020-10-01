/**
* @author Achraf ABOUL (aaboul@salesforce.com)
* @date 26/07/2020
* @Description Get One Document external service callout
*/
public with sharing class SM002_GetDocument_Callout {
    @AuraEnabled(Cacheable = true)
    public static String getDocumentBySFIdCallout(String docId, String ownerId) {
        final String WS_NOM_SERVICE  = 'LPCR_RECUPERATION_DOCUMENT';
        DocumentWrapper docWrp = new DocumentWrapper();
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
        
        System.debug('awesome url : ' + request.getEndpoint());
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        HttpResponse response = http.send(request);
        // Parse the JSON response
        String statusCode = response.getStatusCode()+'';
        if (statusCode.equals('200')) {
            UM001_LogManager.writeLogActivity(UM010_Constant.LOG_REF_DOC_REC, 'SM002_GetDocument_Callout', 'Callout', ownerId, 'statusCode:' + statusCode + ' - docId:' + docId, 'Success');  
            System.debug('response.getBody()' + response.getBody());
            docWrp = (DocumentWrapper) JSON.deserialize(response.getBody(), DocumentWrapper.class);
        } else {
            UM001_LogManager.writeLogActivity(UM010_Constant.LOG_REF_DOC_REC, 'SM002_GetDocument_Callout', 'Callout', ownerId,  'Exception:' + statusCode + ' - statusCode:' + statusCode + ' - ownerId:' + ownerId + ' - docId:' + docId, 'Error');  
            //documentListFullResponse = (DocumentListFullResponse) JSON.deserialize(response.getBody(), DocumentListFullResponse.class);
            System.debug('awesome statusCode' + statusCode);
            System.debug('awesome WS_NOM_SERVICE' + WS_NOM_SERVICE);
            
        LPCR_AppelServiceExterne__mdt appelServiceExterne = [SELECT LPCR_CodeRetour__c ,LPCR_MessageRetour__c , LPCR_NomService__c  
                                                             FROM LPCR_AppelServiceExterne__mdt  
                                                             WHERE LPCR_CodeRetour__c = :statusCode AND LPCR_NomService__c = :WS_NOM_SERVICE ];
            throw new AuraHandledException(appelServiceExterne.LPCR_MessageRetour__c);
        }
        return docWrp.binaryDocument;
    }

    public class DocumentWrapper{
        public String binaryDocument;
    }
}
