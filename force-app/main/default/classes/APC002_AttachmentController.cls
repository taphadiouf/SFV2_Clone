/**
* @author Ayoub Ouarti
* @date 03/03/2020
* @Description Queries about Attachment
*/
public with sharing class APC002_AttachmentController {

    public static List<Attachment> saveOrUpdte(List<Attachment> attachments){
        if(UM003_TypeManager.isNotNullAndNotEmpty(attachments) ){
            upsert attachments;
        }
     return  attachments; 
    }

    public static Attachment saveOrUpdte(Attachment attachment){
        if(UM003_TypeManager.isNotNull(attachment)){
            upsert attachment;
        }
     return  attachment; 
    }


     @AuraEnabled
    public static Attachment save(Id idParent, String strFileName, String base64Data,String description) {
        // Decoding base64Data
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        // inserting file
        Attachment att = new Attachment();
        att.Name = strFileName;
        att.ParentId = idParent;
        att.body = EncodingUtil.base64Decode(base64Data);
        att.Description = description;
        insert att;
        return att;
    }

    

}