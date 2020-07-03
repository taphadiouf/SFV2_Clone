/**
* @author Saurabh
* @created 27/06/2020
* @description Wrapper class for Named Credentials WRP004_APISaveDocument.
*/
public class WRP004_APISaveDocument {
    public string doc_sf_id; 
    public string doc_type;  // obligatoitre
    public string doc_owner_sf_id; // obligatoitre
    public DateTime doc_creation_date; 
    public DateTime doc_last_modified_date; 
    public DateTime doc_notification_email_date; 
    public DateTime doc_lasttime_read; 
    public blob doc_content;  
    public string doc_entity_type; 
    public string doc_status; // obligatoitre
    public string doc_name; // obligatoitre
    public string doc_file_type; // obligatoitre    
    
    public WRP004_APISaveDocument(String doc_type, String doc_owner_sf_id, String doc_status, String doc_name, String doc_file_type ){
        if(doc_type.contains('Facture')){
           this.doc_type = 'Facture';
        }else if(doc_type.contains('Contrat')){
            this.doc_type = 'Contrat';
        }else if(doc_type.contains('Pièce')){
            this.doc_type = 'PJ';
        }
        this.doc_status = doc_status;
        this.doc_owner_sf_id = doc_owner_sf_id;
        this.doc_name = doc_name;
        this.doc_file_type = doc_file_type;
    }
}