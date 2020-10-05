/**
* @author Saurabh
* @date 30/06/2020
* @description Service class for SM018_AttachmentService
*/
public with sharing class SM018_AttachmentService {
    
    public static void sendLPCRDocumentByCallout(List<Attachment> newAttachmentList){
        
        Set<String> parentIds = UM003_TypeManager.getFieldsOfListObjects(newAttachmentList, 'ParentId');
        Map<String, String> invoiceAccountMap = new Map<String, String>();
        
        Map<Id, blng__Invoice__c> invoiceCreatedByMap = new Map<Id, blng__Invoice__c>();
        Map<Id,blng__Invoice__c> invoiceToUpdate = new Map<Id,blng__Invoice__c>();
        for(blng__Invoice__c invoice : [select id, blng__Account__r.Email__c, CreatedBy.Name, LPCR_StatutFacture__c  from blng__Invoice__c where id in: parentIds]){
            invoiceAccountMap.put(invoice.id, invoice.blng__Account__r.Email__c);
            invoiceCreatedByMap.put(invoice.id, invoice);
        }
        
        for(Attachment eachAttachment : newAttachmentList){
            
            blng__Invoice__c invoice;
            String Description = eachAttachment.Description;
            
            PAD.log('SM018_AttachmentService', 'sendLPCRDocumentByCallout', 'eachAttachment:' + eachAttachment);   
            
            if (!objectTypeAuthorizedToBeSentToLPCR(eachAttachment.ParentId)) {
                PAD.log('SM018_AttachmentService', 'sendLPCRDocumentByCallout', 'Adobe temporary attachment not to be sent to LPCR GED');   
                continue;
            }
            PAD.log('SM018_AttachmentService', 'sendLPCRDocumentByCallout', 'continuing...');   
            if(invoiceCreatedByMap.containsKey(eachAttachment.ParentId)){  
                invoice = invoiceCreatedByMap.get(eachAttachment.ParentId);
            }
            
            if(!(invoice != null && invoice.CreatedBy.Name.contains('Migration'))){
                
                // In Sync mode (attachment inserted from LWC) do nothing
                // In Async mode (insertion called from Conga or Adobe)
                // Send Doc to LPCR GED
                // If Document is related to an invoice, send it to customer
                
                if(!eachAttachment.Name.contains('_SYNC')){
                    
                    SM017_SendDocument_Callout.sendDocumentCallout(eachAttachment.ParentId, eachAttachment.Id, eachAttachment.Name, EncodingUtil.base64Encode(eachAttachment.Body));
                    
                    if(invoice != null){
                        
                        invoice.LPCR_StatutFacture__c = 'Envoyée';
                        invoiceToUpdate.put(invoice.id,invoice);
                        
                        // Retrieve Again list and Send an Email to Customer :
                        SM019_DocumentList_Callout.getDocumentListFutureCallout(eachAttachment.ParentId, 'Facture',invoiceAccountMap.get(eachAttachment.ParentId));                 
                    }   
                }
            }
            
        }
        if(invoiceToUpdate.size() !=0 ){
            update invoiceToUpdate.values();
        }
    }
    
    static private Boolean objectTypeAuthorizedToBeSentToLPCR(Id tmpId) {
        
        if ((String.valueOf(tmpId.getsobjecttype()) == 'SBQQ__Quote__c') || 
            (String.valueOf(tmpId.getsobjecttype()) == 'blng__Invoice__c') || 
            (String.valueOf(tmpId.getsobjecttype()) == 'Account') || 
            (String.valueOf(tmpId.getsobjecttype()) == 'Lead') || 
            (String.valueOf(tmpId.getsobjecttype()) == 'Opportunity') || 
            (String.valueOf(tmpId.getsobjecttype()) == 'LPCR_Preinscription__c') || 
            (String.valueOf(tmpId.getsobjecttype()) == 'Contract') || 
            (String.valueOf(tmpId.getsobjecttype()) == 'Contact')
           ) {
               return true;
           }
        return false;
    } 
    
}