/**
* @author Ayoub Ouarti
* @date 03/03/2020
* @Description Queries about Attachment
*/
public with sharing class APC002_AttachmentController {
     @AuraEnabled
    public static Attachment save(Id idParent, String strFileName, String base64Data,String description, String contentType) {
        // Decoding base64Data
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        boolean isvalid = true;
        String errMsg = 'Veuillez  ';
        if(idParent == Null){
            isvalid = False ;
            errMsg += 'attacher le fichier à un enregistrement père ';     
        }
        if(strFileName == Null){
            isvalid = False ;
            errMsg += 'saisir le nom du fichier '; 
        }
        if(!isvalid){
            throw new AuraHandledException(errMsg);
        }

        // inserting file
        Attachment att = new Attachment();
        att.Name = strFileName + '_SYNC';
        att.ParentId = idParent;
        att.body = EncodingUtil.base64Decode(base64Data);
        att.Description = description;
        att.ContentType = contentType;
        insert att;
        return att;
    }
    @AuraEnabled
    public static void sendDocument(Id attachmentId) {
        Attachment att = [SELECT ParentId, Description, Body FROM Attachment WHERE Id = :attachmentId];
        SM017_SendDocument_Callout.sendDocumentCallout_SYNC(att.ParentId, att.Id, att.Description, EncodingUtil.base64Encode(att.Body));
        removeNameSuffix(attachmentId);
    }
    public static void removeNameSuffix(Id attachmentId){
        string suffix = '_SYNC';
        Attachment att = [SELECT name from Attachment where id=:attachmentId];
        if(att.name.endsWithIgnoreCase(suffix)){
            att.name  = att.name.removeEnd(suffix);
            update att;
        }
    }
}