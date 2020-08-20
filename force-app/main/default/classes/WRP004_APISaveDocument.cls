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
    
    public WRP004_APISaveDocument(String OwnerSfId, String DocSfID, String Name, String BinaryDocument){
        Attachment att = [SELECT Name FROM Attachment WHERE Id = :DocSfID];
        
        if(Name.contains('Facture')){
            this.FileType = getFileType(att.Name);
            this.DocumentStatus = 'Validé';
            this.DocumentType = 'Facture';
        }else if(Name.contains('Pièce justificative')){
            this.FileType = getFileType(att.Name);
            this.DocumentStatus = 'None';
            this.DocumentType = 'PJ';
        }else if(Name.contains('Contrat')){
            this.FileType = getFileType(att.Name);
            this.DocumentStatus = 'Validé';
            this.DocumentType = 'Contrat';
        }
        else if(Name.contains('Autre')){
            this.FileType = getFileType(att.Name);
            this.DocumentStatus = 'None';
            this.DocumentType = 'Autre';
        }
        this.OwnerSfId = OwnerSfId;
        this.DocSfID = DocSfID;
        this.Name = Name;
        this.BinaryDocument = BinaryDocument;
        
    }
    
    public string getFileType(string attName){
        if(attName.contains('.docx_SYNC')){
            return 'docx';
        }
        else if(attName.contains('.doc_SYNC')){
            return 'doc';
        }
        else if(attName.contains('.xls_SYNC')){
            return 'xls';
        }
        else if(attName.contains('.xlsx_SYNC')){
            return 'xlsx';
        }
        else if(attName.contains('.txt_SYNC')){
            return 'txt';
        }
        
        else{
            return 'PDF';
        }
    }
}