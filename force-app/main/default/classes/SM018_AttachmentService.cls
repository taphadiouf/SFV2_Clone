/**
* @date 30/06/2020
* @description Service class for SM018_AttachmentService :
*
    - In Sync mode (attachment inserted from LWC) do nothing (whole logic embedded by APC002_AttachmentController)

    - In Async mode (insertion called from Conga or Adobe) logic will be performed by chaining callouts with queueable class
        - 1) Send each inserted document to LPCR GED by enqueuing  QA001
        - If Document is related to an invoice, 
            - 2) Get reference from GED by enqueuing QA002
            - 3) send it to customer by enqueuing QA003
*/

public with sharing class SM018_AttachmentService {

    public static void sendLPCRDocumentByCallout(List<Attachment> newAttachmentList){
        
        String className = SM018_AttachmentService.class.getName();

        Set<String> parentIds = UM003_TypeManager.getFieldsOfListObjects(newAttachmentList, 'ParentId');
        Map<String, String> invoiceAccountMap = new Map<String, String>();
        
        Map<Id, blng__Invoice__c> invoiceCreatedByMap = new Map<Id, blng__Invoice__c>();
        Map<Id,blng__Invoice__c> invoiceToUpdate = new Map<Id,blng__Invoice__c>();
        for(blng__Invoice__c invoice : [select id, blng__Account__r.Email__c, CreatedBy.Name, LPCR_StatutFacture__c, LPCR_Creche__c  from blng__Invoice__c where id in: parentIds]){
            invoiceAccountMap.put(invoice.id, invoice.blng__Account__r.Email__c);
            invoiceCreatedByMap.put(invoice.id, invoice);
        }
        
        for(Attachment eachAttachment : newAttachmentList){
            
            blng__Invoice__c invoice;
            String Description = eachAttachment.Description;
            
            PAD.log(className, 'sendLPCRDocumentByCallout', 'eachAttachment:' + eachAttachment);   
            
            if (!objectTypeAuthorizedToBeSentToLPCR(eachAttachment.ParentId)) {
                PAD.log(className, 'sendLPCRDocumentByCallout', 'Adobe temporary attachment not to be sent to LPCR GED');   
                continue;
            }
            PAD.log(className, 'sendLPCRDocumentByCallout', 'continuing...');   
            if(invoiceCreatedByMap.containsKey(eachAttachment.ParentId)){  
                invoice = invoiceCreatedByMap.get(eachAttachment.ParentId);
            }
            
            if(!(invoice != null && invoice.CreatedBy.Name.contains('Migration'))){
                
                if(!eachAttachment.Name.contains('_SYNC')){ // By Pass this logic if called from APC002 Controller
                    
                    QA001_CalloutEnvoieDocumentGED sendDoc = new QA001_CalloutEnvoieDocumentGED(String.valueOf(eachAttachment.ParentId), 
                                                                                                String.valueOf(eachAttachment.Id), 
                                                                                                eachAttachment.Name, 
                                                                                                EncodingUtil.base64Encode(eachAttachment.Body), 
                                                                                                invoice, 
                                                                                                invoiceAccountMap.get(eachAttachment.ParentId));
                    ID jobIdSendDoc = System.enqueueJob(sendDoc); 
                }
            }
        }
        if(invoiceToUpdate.size() !=0 ){
            update invoiceToUpdate.values();
        }
    }
    
    static private Boolean objectTypeAuthorizedToBeSentToLPCR(Id tmpId) {
        
        if ((String.valueOf(tmpId.getsobjecttype()) == 'SBQQ__Quote__c') || 
            (String.valueOf(tmpId.getsobjecttype()) == 'echosign_dev1__SIGN_Agreement__c') || 
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