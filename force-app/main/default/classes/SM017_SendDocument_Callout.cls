/**
* @author Saurabh
* @date 30/06/2020
* @Description SendDocument external service callout
*/
public with sharing class SM017_SendDocument_Callout {
    
    @future(callout=true)
    public static void sendDocumentCallout(String OwnerSfId, String DocSfID, String Name, String BinaryDocument){
        
        executeSendDocumentCallout(OwnerSfId, DocSfID, Name, BinaryDocument, false);
    }
    
    public static void sendDocumentCallout_SYNC(String OwnerSfId, String DocSfID, String Name, String BinaryDocument){
        
        executeSendDocumentCallout(OwnerSfId, DocSfID, Name, BinaryDocument, true);
    }
    
    public static void executeSendDocumentCallout(String OwnerSfId, String DocSfID, String Name, String BinaryDocument, Boolean syncMode){
        String errorMsg;
        HttpResponse response;
        final String WS_NOM_SERVICE  = 'LPCR_ENVOIE_DOCUMENT';
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            LPCR_Environnement__c envCS = LPCR_Environnement__c.getInstance();
        
            request.setEndpoint('callout:DEV_SEND_DOCUMENT');
            if('UAT'.equals(envCS.Nom__c)) request.setEndpoint('callout:UAT_SEND_DOCUMENT');
            if('PROD'.equals(envCS.Nom__c)) request.setEndpoint('callout:PROD_SEND_DOCUMENT');
        
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        
            WRP004_APISaveDocument data = new WRP004_APISaveDocument(OwnerSfId, DocSfID, Name, BinaryDocument);
            request.setBody(JSON.serialize(data));
            
            response = http.send(request);
        
            
        }catch(System.CalloutException e){ 
            errorMsg = String.valueOf(e);
        }
        finally {
            if (errorMsg != '') {
                UM001_LogManager.writeLogActivity(UM010_Constant.LOG_SEND_DOC_TO_GED,'SM017_SendDocument_Callout', 'Callout', null,  'Apex Callout Exception:' + errorMsg, UM010_Constant.ERROR);  
            }
            if (syncMode == true) {
                
                if (String.valueOf(response.getStatusCode()).equals('200')) {
                    
                    UM001_LogManager.writeLogActivityWithoutFuture(UM010_Constant.LOG_SEND_DOC_TO_GED, 'SM017_SendDocument_Callout', 'Callout', DocSfID, 'statusCode:' + String.valueOf(response.getStatusCode()) + ' - OwnerSfId:' + OwnerSfId, UM010_Constant.SUCCESS);  
                } else {
                    
                    List<LPCR_AppelServiceExterne__mdt> appelServiceExterne = [SELECT LPCR_CodeRetour__c ,LPCR_MessageRetour__c , LPCR_NomService__c  
                                                                               FROM LPCR_AppelServiceExterne__mdt  
                                                                               WHERE LPCR_CodeRetour__c = : String.valueOf(response.getStatusCode()) AND LPCR_NomService__c = :WS_NOM_SERVICE ];
                    
                    if(appelServiceExterne != null && appelServiceExterne.size()>0){
                        throw new AuraHandledException(appelServiceExterne[0].LPCR_MessageRetour__c);
                    }
                    else{
                        throw new AuraHandledException('Response status is not 200');
                    }
                }
            
            }
            else {
            
                if (String.valueOf(response.getStatusCode()).equals('200')) {
                    UM001_LogManager.writeLogActivityWithoutFuture(UM010_Constant.LOG_SEND_DOC_TO_GED, 'SM017_SendDocument_Callout', 'Callout', DocSfID, 'statusCode:' + String.valueOf(response.getStatusCode()) + ' - OwnerSfId:' + OwnerSfId, UM010_Constant.SUCCESS);  
                
                } else {
                    UM001_LogManager.writeLogActivityWithoutFuture(UM010_Constant.LOG_SEND_DOC_TO_GED, 'SM017_SendDocument_Callout', 'Callout', DocSfID,  'Exception:' + String.valueOf(response.getStatusCode()) + ' - statusCode:' + String.valueOf(response.getStatusCode()) + ' - Attachment.Id:' + DocSfID + ' - OwnerSfId:' + OwnerSfId, UM010_Constant.ERROR);  
                }
            
            }
        }
        
    }
}