/**
* @author Saurabh
* @date 30/06/2020
* @description Service class for SM018_AttachmentService
*/
public with sharing class SM018_AttachmentService {
    public static void sendLPCRDocumentByCallout(List<Attachment> newAttachmentList){
        Set<String> parentIds = UM003_TypeManager.getFieldsOfListObjects(newAttachmentList, 'ParentId');
        Map<String, String> invoiceAccountMap = new Map<String, String>();
        
        for(blng__Invoice__c invoice : [select id, blng__Account__r.Email__c from blng__Invoice__c where id in: parentIds]){
            invoiceAccountMap.put(invoice.id, invoice.blng__Account__r.Email__c);
        }
        
        for(Attachment eachAttachment : newAttachmentList){
            if(eachAttachment.name.contains('Facture Famille') && invoiceAccountMap.containsKey(eachAttachment.ParentId)){
                SM019_DocumentList_Callout.getDocumentListFutureCallout(eachAttachment.ParentId, 'Facture',invoiceAccountMap.get(eachAttachment.ParentId));                 
            }
            if(!eachAttachment.Name.contains('SYNC')){
                SM017_SendDocument_Callout.sendDocumentCallout(eachAttachment.ParentId, eachAttachment.Id, eachAttachment.Description, EncodingUtil.base64Encode(eachAttachment.Body));
            }
        }
    }
}