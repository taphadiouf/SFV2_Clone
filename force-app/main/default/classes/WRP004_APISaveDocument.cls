/**
* @author Saurabh
* @created 27/06/2020
* @description Wrapper class for Named Credentials WRP004_APISaveDocument.
*/
public class WRP004_APISaveDocument {
    public String OwnerSfId; // obligatoitre
    public String DocSfID; 
    public String Name; // obligatoitre
    public String BinaryDocument;  
    public String FileType; // obligatoitre    
    public String DocumentStatus; // obligatoitre
    public String DocumentType;  // obligatoitre
    public String CrecheSfId;
    
    public WRP004_APISaveDocument(String OwnerSfId, String DocSfID, String Name, String BinaryDocument, String CrecheSfId){
        
        Attachment att = [SELECT Name FROM Attachment WHERE Id = :DocSfID];

        if(Name.contains('Facture')) {
            this.FileType = getFileType(att.Name);
            this.DocumentStatus = 'Validé';
            this.DocumentType = 'Facture';
            this.CrecheSfId = CrecheSfId;
        } else if(Name.contains('Pièce justificative')) {
            this.FileType = getFileType(att.Name);
            this.DocumentStatus = 'None';
            this.DocumentType = 'PJ';
        } else if(Name.contains('Contrat')) {
            this.FileType = getFileType(att.Name);
            this.DocumentStatus = 'Validé';
            this.DocumentType = 'Contrat';
            this.CrecheSfId = CrecheSfId;
        } else { //if(Name.contains('Autre')) {
            this.FileType = getFileType(att.Name);
            this.DocumentStatus = 'None';
            this.DocumentType = 'Autre';
        }

        this.OwnerSfId = OwnerSfId;
        this.DocSfID = DocSfID;
        this.Name = Name;
        this.BinaryDocument = BinaryDocument;
        this.CrecheSfId = (CrecheSfId == null ? 'null' : CrecheSfId);
        
    }

    public string getFileType(string attName){
        
        String fileType = '';
        
        if(String.isNotBlank(attName)){
        
            Integer lastIndexOfPoint = attName.lastIndexOf('.');
            fileType = attName.substring(lastIndexOfPoint + 1);
        }
        
        return fileType;
    }
}