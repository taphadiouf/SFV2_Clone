/**
* @author E.Yhuellou
* @date 31/01/2021
* @Description Class allowing to get document list from LPCR GED
*/
public with sharing class QA002_CalloutListeDocumentGED implements Queueable,Database.AllowsCallouts {

    public String className = QA002_CalloutListeDocumentGED.class.getName();
    private Id ownerId;
    private String type;
    private String emailTo;
    private String emailFrom;
    private String emailSubject;
    private String emailBody;
    private String mode;
    private String errMsg;
    private String currentParentObjectId;

    // tmpOwnerId : Owner Id of the Document we want to retrieve
    // tmpType : Type of Document ('Contrat', 'Facture', 'PJ', 'Autre', ...)
    // tmpEmail : adress mail to be sent
    // tmpMode : information to let know in case of conga facture to chain an email 
    public QA002_CalloutListeDocumentGED(Id tmpOwnerId, String tmpType, String tmpEmailTo, String tmpEmailFrom, String tmpSubject, String tmpBody, String tmpMode) {

        this.ownerId = tmpOwnerId;
        this.type = tmpType;
        this.emailTo = tmpEmailTo;
        //this.emailFrom = tmpEmailFrom;
        this.emailFrom = 'eyhuellou-ext@lpcr.fr';
        //this.emailSubject = tmpSubject;
        this.emailSubject = 'Facture Client';
        //this.emailBody = tmpBody;
        this.emailBody = 'Bonjour, Merci de trouver votre facture ci-joint. Cordialement';
        this.mode = tmpMode;
        this.currentParentObjectId = tmpOwnerId;
    }

    public void execute(QueueableContext context) {

        PAD.log(className, 'getDocumentListFutureCallout', 'tmpOwnerId:' + this.ownerId );
        PAD.log(className, 'getDocumentListFutureCallout', 'this.type:' + this.type);
        PAD.log(className, 'getDocumentListFutureCallout', 'this.emailTo:' + this.emailTo);

        final String WS_NOM_SERVICE  = 'LPCR_RECUPERATION_DOCUMENT';
        
        DocumentListFullResponse documentListFullResponse = getDocumentListCallout(this.ownerId , this.type);  
        	
        
    }

    public  DocumentListFullResponse getDocumentListCallout(String ownerid, String doc_type) {

        PAD.log(className, 'getDocumentListCallout', 'ownerid:' + ownerid);
        PAD.log(className, 'getDocumentListCallout', 'doc_type:' + doc_type);

        DocumentListFullResponse documentListFullResponse;
        errMsg = '';
        
        String statusCode;
        HttpResponse response;
        final String WS_NOM_SERVICE  = 'LPCR_RECUPERATION_DOCUMENT';
        DocumentListStructureWrapper docListStructure;

        try {
            documentListFullResponse = new DocumentListFullResponse();
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            LPCR_Environnement__c envCS = LPCR_Environnement__c.getInstance();

            if('UAT'.equals(envCS.Nom__c)){
                request.setEndpoint('callout:UAT_DOCUMENT_LISTE');
            }
            else if('PROD'.equals(envCS.Nom__c)){
                request.setEndpoint('callout:PROD_DOCUMENT_LISTE');
            }
            else{
                request.setEndpoint('callout:DEV_DOCUMENT_LISTE');
            }
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setTimeout(2000);

            docListStructure = new DocumentListStructureWrapper(ownerid);

            if(!String.isBlank(doc_type)){
                docListStructure.DocType = doc_type;
            }

            request.setBody(JSON.serialize(docListStructure));
            response = http.send(request);
            statusCode = String.valueOf(response.getStatusCode());
            
        }  catch(System.CalloutException e) {
            errMsg = '-- errMsg:' + e.getMessage() + '| Line:' + e.getLineNumber();
            throw e;
        } 
        finally { 

            if(statusCode != null){

                if (statusCode.equals('200')) { // SUCCESS

                    Set<String> docTmp = new Set<String>();

                    documentListFullResponse.response = (List<DocumentListResponse>) JSON.deserialize(response.getBody(), List<DocumentListResponse>.class);
                    documentListFullResponse.result = '200';

                    PAD.log(className, 'getDocumentListCallout', 'documentListFullResponse' + documentListFullResponse);

                    if (documentListFullResponse.response != null) {
                        for(DocumentListResponse eachDoc : documentListFullResponse.response) {
                            docTmp.add(eachDoc.id);
                        }
                    }
    
                    if ((this.mode == 'FACTURE_CONGA' || this.mode == 'ENVOIE_REGLE_FONCTIONNEMENT_CRECHE')  && docTmp.size() > 0) { // Chain Email sending for conga invoice generation
                        QA003_CalloutEnvoieMail envoieMailJob = new QA003_CalloutEnvoieMail(this.currentParentObjectId, this.emailFrom, this.emailTo, this.emailSubject, this.emailBody, docTmp, 'FACTURE_CONGA');
                        ID jobID = System.enqueueJob(envoieMailJob);
                    }
                    
                    UM001_LogManager.writeLogActivityWithoutFuture(UM010_Constant.LOG_LIST_DOC, className, 'Callout', this.currentParentObjectId, 'getDocumentListCallout - Body : ' + JSON.serialize(docListStructure) + ' - statusCode:' + documentListFullResponse.result + ' - OwnerId:' + this.ownerid, UM010_Constant.SUCCESS);  
                } 
                else { // ERROR
                    UM001_LogManager.writeLogActivityWithoutFuture(UM010_Constant.LOG_LIST_DOC, className, 'Callout', this.currentParentObjectId ,  'getDocumentListFutureCallout - Exception:' + documentListFullResponse.result + ' - statusCode:' + statusCode + ' - this.ownerId :' + this.ownerId  + ' - OwnerSfId:' + this.ownerId , UM010_Constant.ERROR);  
                }
            }
            else if(errMsg != '') { // ERROR

                UM001_LogManager.writeLogActivityWithoutFuture(UM010_Constant.LOG_LIST_DOC,className, 'Callout', this.currentParentObjectId,  'getDocumentListCallout - Body : ' + JSON.serialize(docListStructure) + ' - Apex Callout Exception:' + errMsg + ' - Response : ' + response, UM010_Constant.ERROR);
            }
        }
        
        
        return documentListFullResponse;
    }

    public class DocumentListStructureWrapper{
        public String OwnerSfId; // obligatoitre
        public String DocType;
        public DocumentListStructureWrapper(String OwnerSfId){
            this.OwnerSfId = OwnerSfId;   
        }
    }
    public class DocumentListFullResponse {
        @AuraEnabled
        public String result {get;set;} 
        @AuraEnabled
        public List<DocumentListResponse> response {get;set;} 
    }
    public class DocumentListResponse {
        @AuraEnabled
        public String id {get;set;} 
        @AuraEnabled
        public String documentType {get;set;}
        @AuraEnabled 
        public String ownerSfId {get;set;} 
        @AuraEnabled 
        public String docSfID {get;set;} 
        @AuraEnabled
        public String documentStatus {get;set;} 
        @AuraEnabled
        public String name {get;set;} 
        @AuraEnabled
        public String fileType{get;set;} 
    }
}






