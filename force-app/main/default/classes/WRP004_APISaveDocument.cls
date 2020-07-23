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
        if(Name.contains('Facture')){
            this.FileType = 'PDF';
            this.DocumentStatus = 'Validé';
            this.DocumentType = 'Facture';
        }else if(Name.contains('Pièce Justificative')){
            this.FileType = 'PDF';
            this.DocumentStatus = 'None';
            this.DocumentType = 'PJ';
        }else if(Name.contains('Contrat')){
            this.FileType = 'PDF';
            this.DocumentStatus = 'Validé';
            this.DocumentType = 'Contrat';
        }
        else if(Name.contains('Autre')){
            this.FileType = 'PDF';
            this.DocumentStatus = 'None';
            this.DocumentType = 'Autre';
        }
        this.OwnerSfId = OwnerSfId;
        this.DocSfID = DocSfID;
        this.Name = Name;
        this.BinaryDocument = BinaryDocument;
        
    }
}