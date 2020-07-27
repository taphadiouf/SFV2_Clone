/**
* @author Saurabh
* @date 30/06/2020
* @Description SendDocument external service callout
*/

public with sharing class SM017_SendDocument_Callout {
    /*
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
    */
    @future(callout=true)
    public static void sendDocumentCallout(String OwnerSfId, String DocSfID, String Name, String BinaryDocument){
        
        final String WS_NOM_SERVICE  = 'LPCR_ENVOIE_DOCUMENT';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        LPCR_Environnement__c envCS = LPCR_Environnement__c.getInstance();
        if('DEV'.equals(envCS.Nom__c)){
            request.setEndpoint('callout:DEV_SEND_DOCUMENT');
        }
        else if('UAT'.equals(envCS.Nom__c)){
            request.setEndpoint('callout:UAT_SEND_DOCUMENT');
        }
        else if('PROD'.equals(envCS.Nom__c)){
            request.setEndpoint('callout:PROD_SEND_DOCUMENT');
        }
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        WRP004_APISaveDocument data = new WRP004_APISaveDocument(OwnerSfId, DocSfID, Name, BinaryDocument);
        request.setBody(JSON.serialize(data));
        HttpResponse response = http.send(request);
        // Parse the JSON response
        String statusCode = response.getStatusCode()+'';
        UM001_LogManager.writeLogActivityWithoutFuture('Appel Service Externe REF DOC RECUP', '', 'Appel Externe', '' + OwnerSfId, response.getBody(), (statusCode.equals('200') ? 'SUCCESS' : 'ERROR'));
        if (statusCode.equals('200')) {
            //documentListFullResponse = (DocumentListFullResponse) JSON.deserialize(response.getBody(), DocumentListFullResponse.class);
        } else {
            //documentListFullResponse = (DocumentListFullResponse) JSON.deserialize(response.getBody(), DocumentListFullResponse.class);
        LPCR_AppelServiceExterne__mdt appelServiceExterne = [SELECT LPCR_CodeRetour__c ,LPCR_MessageRetour__c , LPCR_NomService__c  
                                                             FROM LPCR_AppelServiceExterne__mdt  
                                                             WHERE LPCR_CodeRetour__c = :statusCode AND LPCR_NomService__c = :WS_NOM_SERVICE ];
            throw new AuraHandledException(appelServiceExterne.LPCR_MessageRetour__c);
        }     
    }
}