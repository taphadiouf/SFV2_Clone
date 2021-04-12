/**
* @author E.Yhuellou
* @date 31/01/2021
* @Description Class allowing to get document list from LPCR GED
*/
public with sharing class QA003_CalloutEnvoieMail implements Queueable,Database.AllowsCallouts {

    private String className = QA003_CalloutEnvoieMail.class.getName();
    private String mailFrom;
    private String mailTo;
    private String subject;
    private String content;
    private Set<String> docSet;
    private String mode;
    private String currentParentObjectId;

    public QA003_CalloutEnvoieMail(String tmpOwnerId, String tmpMailFrom, String tmpMailTo, String tmpSubject, String tmpContent, Set<String> tmpSet, String tmpMode) {

        this.mailFrom = tmpMailFrom;
        this.mailTo = tmpMailTo;
        this.subject = tmpSubject;
        this.content = tmpContent;
        this.docSet = tmpSet;
        this.mode = tmpMode;
        this.currentParentObjectId = tmpOwnerId;
    }

    public void execute(QueueableContext context) {

        String errorMsg;
        HttpResponse res = new HttpResponse();
        String bodyJSON;
        
        try {
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            LPCR_Environnement__c envCS = LPCR_Environnement__c.getInstance();
    
            if('UAT'.equals(envCS.Nom__c)){
                req.setEndpoint('callout:UAT_SEND_MAIL');
            }
            else if('PROD'.equals(envCS.Nom__c)){
                req.setEndpoint('callout:PROD_SEND_MAIL');
            }
            else{
                req.setEndpoint('callout:DEV_SEND_MAIL');
            }
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json; utf-8');
        
            Set<Integer> docsIdSet = new Set<Integer>();

            if(this.docSet != null){
                for(String DocId : this.docSet){
                    docsIdSet.add(Integer.valueOf(DocId));
                }
            }
        
            EmailStructureWrapper emailStructure = new EmailStructureWrapper(this.mailFrom, this.mailTo, this.subject, this.content, docsIdSet);

            bodyJSON = JSON.serialize(emailStructure);
            bodyJSON = bodyJson.replace('this.mailFrom', 'From');
            req.setBody(bodyJSON);
        
            res = h.send(req);
            String result = res.getBody();
                
        } catch (System.CalloutException e){ 
    		errorMsg = String.valueOf(e);
        }
        finally {
            
            if (res.getStatusCode() == 200) { //SUCCESS
                UM001_LogManager.writeLogActivityWithoutFuture(className, 'execute', 'Callout', this.currentParentObjectId, 'sendMailCallout - Body :' + bodyJSON + 'statusCode:' + res.getStatusCode() + ' - From:' + this.mailFrom + ' - this.mailTo:' + this.mailTo + ' - this.subject:' + this.subject , UM010_Constant.SUCCESS);           
            } 
            else if (res != null && res.getStatusCode() != null && res.getStatusCode() != 200) { //ERROR
                UM001_LogManager.writeLogActivityWithoutFuture(className, 'execute', 'Callout', this.currentParentObjectId,  'sendMailCallout - Body :' + bodyJSON + 'Exception:' + res.getStatusCode() + ' - statusCode:' + res.getStatusCode() + ' - From:' + this.mailFrom + ' - this.mailTo:' + this.mailTo + ' - this.subject:' + this.subject + ' - res' + res,  UM010_Constant.ERROR);
            }
            else { // ERROR
                UM001_LogManager.writeLogActivityWithoutFuture(className, 'execute', 'Callout', this.currentParentObjectId,  'sendMailCallout - Body :' + bodyJSON + ' - Apex Callout Exception:' + errorMsg + ' - res' + res, UM010_Constant.ERROR);  
            }
        }
    }

    public class EmailStructureWrapper{
        private String from1;
        private String To;
        private String Subject;
        private String Body;
        private Set<Integer> Docsid;
        public EmailStructureWrapper(String from1, String To, String Subject, String Body, Set<Integer> Docsid){
            this.from1 = from1;
            this.To = To;
            this.Subject = Subject;
            this.Body = Body;
            this.Docsid = Docsid;       
        }
    }
}




