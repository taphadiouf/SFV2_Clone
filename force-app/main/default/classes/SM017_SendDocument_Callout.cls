/**
* @author Saurabh
* @date 30/06/2020
* @Description SendDocument external service callout
*/
public with sharing class SM017_SendDocument_Callout {
    
    static String className = SM017_SendDocument_Callout.class.getName();

    public static Id getB2CFactureCrecheID(String OwnerSfId){

        Id factureCrecheId;
        Id accueilRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account,Label.LPCR_Famille);

        blng__Invoice__c tmpFacture = [SELECT Id,LPCR_Creche__c,blng__Account__c FROM blng__Invoice__c WHERE blng__Account__r.RecordTypeId =: accueilRecTypeId AND ID =: OwnerSfId order by createdDAte desc limit 1];
        
        if (tmpFacture != null) {
            factureCrecheId = tmpFacture.LPCR_Creche__c;
        }

        return factureCrecheId;
    }
    
    
    public static Id getB2CContractCrecheID(String OwnerSfId){

        String errorMsg = '';
        Id contractCrecheId;
        try {
            Id acceuilRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote,Label.LPCR_ContratA);
            Id acceuilApprRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote,Label.LPCR_Accueil_Approuve);

            Id acceuilDevisId = [SELECT Id,LPCR_Devis__c FROM echosign_dev1__SIGN_Agreement__c WHERE 
                (LPCR_Devis__r.RecordTypeId =: acceuilRecTypeId OR 
                LPCR_Devis__r.RecordTypeId =: acceuilApprRecTypeId) 
                AND 
                ID =: OwnerSfId].LPCR_Devis__c;
            
            List<SBQQ__QuoteLine__c> relatedQuoteLignes = [SELECT Id, SBQQ__Quote__c  FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: acceuilDevisId];
            
            Set<Id> quoteLigneIds = UM003_TypeManager.getIdsOfListObjects(relatedQuoteLignes);
            
            List<OrderItem> relatedOrderItems = [SELECT Id, SBQQ__QuoteLine__c, SBQQ__Contract__c FROM OrderItem WHERE SBQQ__QuoteLine__c IN: quoteLigneIds ];
            
            Id relatedContractId = relatedOrderItems.get(0).SBQQ__Contract__c;
            
            contractCrecheId = [SELECT Id, LPCR_Creche__c  FROM COntract WHERE Id=: relatedContractId ].LPCR_Creche__c;
            
        } catch (Exception e ) {
            errorMsg = e.getMessage();
        } finally {
            if (errorMsg != '') { // ERROR
                UM001_LogManager.writeLogActivityWithoutFuture(className, 'getB2CContractCrecheID', 'Callout', null,  'Apex Callout Exception:' + errorMsg, UM010_Constant.ERROR);  
            }
            
        }
        
        return contractCrecheId;
    }

    
    public static void executeSendDocumentCallout(String OwnerSfId, String DocSfID, String Name, String BinaryDocument){
        
        String errorMsg = '';
        HttpResponse response;
        final String WS_NOM_SERVICE  = 'LPCR_ENVOIE_DOCUMENT';
        Id CrecheSfId;
        
        PAD.Log(className, 'executeSendDocumentCallout', 'LPCR_ENVOIE_DOCUMENT');
        
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            LPCR_Environnement__c envCS = LPCR_Environnement__c.getInstance();
        
            request.setEndpoint('callout:DEV_SEND_DOCUMENT');
            if('UAT'.equals(envCS.Nom__c)) request.setEndpoint('callout:UAT_SEND_DOCUMENT');
            if('PROD'.equals(envCS.Nom__c)) request.setEndpoint('callout:PROD_SEND_DOCUMENT');
        
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            
            if(Name.contains('Facture')) {
                 CrecheSfId = SM017_SendDocument_Callout.getB2CFactureCrecheID(OwnerSfId);
            }
            if(Name.contains('Contrat')) {
                 CrecheSfId = SM017_SendDocument_Callout.getB2CContractCrecheID(OwnerSfId);
            }
        
            WRP004_APISaveDocument data = new WRP004_APISaveDocument(OwnerSfId, DocSfID, Name, BinaryDocument,CrecheSfId);
            request.setBody(JSON.serialize(data));
            
            response = http.send(request);
        
            PAD.Log(className, 'executeSendDocumentCallout', 'Doc Sent by Callout...');
            
        }catch(System.CalloutException e){ 
            PAD.Log(className, 'executeSendDocumentCallout', 'In catch');
            errorMsg = String.valueOf(e);
        }
        finally {

            PAD.Log(className, 'executeSendDocumentCallout', 'errorMsg:' + errorMsg);

            if (response != null && response.getStatusCode() != null) {
                
                if (String.valueOf(response.getStatusCode()).equals('200')) { // SUCCESS
                    
                    UM001_LogManager.writeLogActivityWithoutFuture(className, 'executeSendDocumentCallout', 'Callout', DocSfID, 'statusCode:' + String.valueOf(response.getStatusCode()) + ' - OwnerSfId:' + OwnerSfId, UM010_Constant.SUCCESS);  
                } 
                else if (String.valueOf(response.getStatusCode()) != '200'){ // ERROR with different status code
                    
                    List<LPCR_AppelServiceExterne__mdt> appelServiceExterne = [SELECT LPCR_CodeRetour__c ,LPCR_MessageRetour__c , LPCR_NomService__c  
                                                                               FROM LPCR_AppelServiceExterne__mdt  
                                                                               WHERE LPCR_CodeRetour__c = : String.valueOf(response.getStatusCode()) AND LPCR_NomService__c = :WS_NOM_SERVICE ];
                    
                    if(appelServiceExterne != null && appelServiceExterne.size() > 0) {

                        throw new AuraHandledException('Error - ' + appelServiceExterne[0].LPCR_MessageRetour__c);
                    }
                    else {
                        throw new AuraHandledException('Error - Response status :' + String.valueOf(response.getStatusCode()));
                    }
                }
            
            }
            else if (errorMsg != '') { // ERROR
                UM001_LogManager.writeLogActivityWithoutFuture(className, 'executeSendDocumentCallout', 'Callout', null,  'Apex Callout Exception:' + errorMsg, UM010_Constant.ERROR);  
            }
            else { // ERROR
                UM001_LogManager.writeLogActivityWithoutFuture(className, 'executeSendDocumentCallout', 'Callout', DocSfID,  'Exception: Internal Error. Response is null! - Attachment.Id:' + DocSfID + ' - OwnerSfId:' + OwnerSfId, UM010_Constant.ERROR);  
            }
        }
        
    }
}