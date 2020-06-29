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
}