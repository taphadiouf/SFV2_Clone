/**
* @author Ayoub Ouarti
* @date 03/03/2020
* @Description Queries about Attachment
*/
public with sharing class APC002_AttachmentController {

     @AuraEnabled
    public static Attachment save(Id idParent, String strFileName, String base64Data,String description) {
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
        att.Name = strFileName;
        att.ParentId = idParent;
        att.body = EncodingUtil.base64Decode(base64Data);
        att.Description = description;
        insert att;
        return att;
    }

     @AuraEnabled
    public static List<Attachment>  getAllAttachments() {
       
        return [SELECT Id,Name,Description ,CreatedDate from Attachment Order By CreatedDate Desc];
    }

   

}