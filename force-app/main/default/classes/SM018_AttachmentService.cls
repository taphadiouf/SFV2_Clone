/**
* @author Saurabh
* @date 30/06/2020
* @description Service class for SM018_AttachmentService
*/
public with sharing class SM018_AttachmentService {
    public static void sendLPCRDocumentByCallout(List<Attachment> newAttachmentList){
        for(Attachment eachAttachment : newAttachmentList){
            SM017_SendDocument_Callout.sendDocumentCallout(eachAttachment.Description, eachAttachment.ParentId , 'Validé', eachAttachment.Name , 'PDF');
        }
    }
}