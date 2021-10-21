/**
 * @auteur  SC (PRA)
 * @depuis  12/10/2021
 * @description Document DOWNLOAD external service callout.
 *
 * -- Historique de maintenance: 
 * --
 * -- Date         Nom   Version  Commentaire 
 * -- -----------  ----  -------  ------------------------
 * -- 12-10-2021   	PRA     1.0     Version initiale
 */
public with sharing class SM031_DocumentDownload_Callout {
    @AuraEnabled
    public static Blob downloadDocument(String ownerId,String blobguid) {
        String errorMsg;
        HttpResponse res = new HttpResponse();
        Blob blobDoc ; 
        
        try {
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            LPCR_Environnement__c envCS = LPCR_Environnement__c.getInstance();
            String parametre = '?blobGUID='+blobguid+'&userSfid='+ownerId;

    
            if('UAT'.equals(envCS.Nom__c)){
                req.setEndpoint('callout:LPCR_UAT_DOCUMENT_DOWNLOAD'+parametre);
            }
            else if('PROD'.equals(envCS.Nom__c)){
                req.setEndpoint('callout:LPCR_PRO_DOCUMENT_DOWNLOAD'+parametre);
            }
            else{
                req.setEndpoint('callout:LPCR_DEV_DOCUMENT_DOWNLOAD'+parametre);
            }

            req.setHeader('Authorization', 'Bearer {!$Credential.Password}');
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json; utf-8');
            res = h.send(req);

            String result = res.getBody();
            blobDoc = Blob.valueof(result);              
        }catch (System.CalloutException e){ 
    		errorMsg = String.valueOf(e);
            System.debug('PRA errorMsg '+errorMsg);
        }
        finally {
            if (String.isNotBlank(errorMsg)) {
                UM001_LogManager.writeLogActivityWithoutFuture('SM031_DocumentDownload_Callout', 'documentDownload', 'Callout', null,  'documentDownload - Body :  - Apex Callout Exception:' + errorMsg + ' - res' + res, UM010_Constant.ERROR);  
            }
            if (res.getStatusCode() == 200) {
                // UM001_LogManager.writeLogActivityWithoutFuture('SM031_DocumentDownload_Callout', 'documentDownload', 'Callout', null, 'documentDownload - Body : statusCode:' + res.getStatusCode() , UM010_Constant.SUCCESS);           
            } else {
                UM001_LogManager.writeLogActivityWithoutFuture('SM031_DocumentDownload_Callout', 'documentDownload', 'Callout', null,  'documentDownload - Body : Exception:' + res.getStatusCode() + ' - statusCode:' + res.getStatusCode() + ' - res' + res,  UM010_Constant.ERROR);
            }        
        }

        return blobDoc;
    }
}