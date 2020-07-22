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

        //Start of the call of the service to save the document
        //sendDocumentCallout(idParent, att.Id, att.Name, FileType, DocumentStatus, description, BinaryDocument);
        return att;
    }
    public static void sendDocumentCallout(String OwnerSfId, String DocSfID, String Name,  String FileType, String DocumentStatus, String DocumentType, byte[] BinaryDocument){
        final String WS_NOM_SERVICE  = 'LPCR_ENVOIE_DOCUMENT';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:LPCR_API_SaveDocument');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        DocumentBodyStructureWrp documentBodyStructure = new DocumentBodyStructureWrp(OwnerSfId,  DocSfID,  Name,   FileType,  DocumentStatus,  DocumentType, BinaryDocument);
        request.setBody(JSON.serialize(documentBodyStructure));
        HttpResponse response = http.send(request);
        // Parse the JSON response
        String statusCode = response.getStatusCode()+'';
        UM001_LogManager.writeLogActivity('Appel Service Externe REF DOC RECUP', '', 'Appel Externe', (Id) OwnerSfId, response.getBody(), (statusCode.equals('200') ? 'SUCCESS' : 'ERROR'));
        if (statusCode.equals('200')) {
            //documentListFullResponse = (DocumentListFullResponse) JSON.deserialize(response.getBody(), DocumentListFullResponse.class);
        } else {
            //documentListFullResponse = (DocumentListFullResponse) JSON.deserialize(response.getBody(), DocumentListFullResponse.class);
        LPCR_AppelServiceExterne__mdt appelServiceExterne = [SELECT LPCR_CodeRetour__c ,LPCR_MessageRetour__c , LPCR_NomService__c  
                                                             FROM LPCR_AppelServiceExterne__mdt  
                                                             WHERE LPCR_CodeRetour__c = :statusCode AND LPCR_NomService__c = :WS_NOM_SERVICE ];
            throw new AuraHandledException(appelServiceExterne.LPCR_MessageRetour__c);
        }
    }
     @AuraEnabled
    public static List<Attachment>  getAllAttachments() {
       
        return [SELECT Id,Name,Description ,CreatedDate from Attachment Order By CreatedDate Desc];
    }

    public class DocumentBodyStructureWrp{
        public String OwnerSfId; //Mandatory
        public String DocSfID; //Mandatory
        public String Name;  //Mandatory
        public String FileType; //Mandatory
        public String DocumentStatus; //Mandatory
        public String DocumentType;
        //Need to choose the right type
        //public byte[] BinaryDocument; //Mandatory
        public DocumentBodyStructureWrp(String OwnerSfId, String DocSfID, String Name,  String FileType, String DocumentStatus, String DocumentType,/* byte[] BinaryDocument*/){
            this.OwnerSfId = OwnerSfId;
            this.DocSfID = DocSfID;
            this.Name = Name;
            this.FileType = FileType;
            this.DocumentStatus = DocumentStatus;
            this.DocumentType = DocumentType;
            //this.BinaryDocument = BinaryDocument;
        }
    }

}