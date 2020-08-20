public String DocumentType;  // obligatoitre


    public WRP004_APISaveDocument(String OwnerSfId, String DocSfID, String Name, String BinaryDocument){	    public WRP004_APISaveDocument(String OwnerSfId, String DocSfID, String Name, String BinaryDocument){
        Attachment att = [SELECT Name FROM Attachment WHERE Id = :DocSfID];

        if(Name.contains('Facture')){	        if(Name.contains('Facture')){
            this.FileType = 'PDF';	            this.FileType = getFileType(att.Name);
            this.DocumentStatus = 'Validé';	            this.DocumentStatus = 'Validé';
            this.DocumentType = 'Facture';	            this.DocumentType = 'Facture';
        }else if(Name.contains('Pièce justificative')){	        }else if(Name.contains('Pièce justificative')){
            this.FileType = 'PDF';	            this.FileType = getFileType(att.Name);
            this.DocumentStatus = 'None';	            this.DocumentStatus = 'None';
            this.DocumentType = 'PJ';	            this.DocumentType = 'PJ';
        }else if(Name.contains('Contrat')){	        }else if(Name.contains('Contrat')){
            this.FileType = 'PDF';	            this.FileType = getFileType(att.Name);
            this.DocumentStatus = 'Validé';	            this.DocumentStatus = 'Validé';
            this.DocumentType = 'Contrat';	            this.DocumentType = 'Contrat';
        }	        }
        else if(Name.contains('Autre')){	        else if(Name.contains('Autre')){
            this.FileType = 'PDF';	            this.FileType = getFileType(att.Name);
            this.DocumentStatus = 'None';	            this.DocumentStatus = 'None';
            this.DocumentType = 'Autre';	            this.DocumentType = 'Autre';
        }	        }
@@ -37,4 +39,26 @@ public class WRP004_APISaveDocument {
        this.BinaryDocument = BinaryDocument;	        this.BinaryDocument = BinaryDocument;


    }	    }

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
}	}