/**
* @author Achraf ABOUL
* @date 26/06/2020
* @Description SendMail external service callout
*/
public with sharing class SM016_SendMail_Callout {
    public static HttpResponse sendMailCallout(String from1, String to, String subject, String body, List<Document> lstDoc) {
        String errorMsg;
        HttpResponse res = new HttpResponse();
        String bodyJSON;
        
        try {
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            LPCR_Environnement__c envCS = LPCR_Environnement__c.getInstance();
    
            if('UAT'.equals(envCS.Nom__c)){
                req.setEndpoint('callout:LPCR_UAT_SEND_MAIL');
            }
            else if('PROD'.equals(envCS.Nom__c)){
                req.setEndpoint('callout:LPCR_PRO_SEND_MAIL');
            }
            else{
                req.setEndpoint('callout:LPCR_DEV_SEND_MAIL');
            }
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json; utf-8');


            EmailInfo mailInfo = new EmailInfo(from1,from1,to,to,subject,body);
            EmailStructureWrapper emailStructure = new EmailStructureWrapper(mailInfo,lstDoc);

            bodyJSON = JSON.serialize(emailStructure);
            bodyJSON = bodyJson.replace('from1', 'from');

            req.setBody(bodyJSON);
        
            res = h.send(req);
            String result = res.getBody();
            

                        
        }catch (System.CalloutException e){ 
    		errorMsg = String.valueOf(e);
        }
        finally {
            if (String.isNotBlank(errorMsg)) {
                UM001_LogManager.writeLogActivityWithoutFuture('SM016_SendMail_Callout', 'sendMailCallout', 'Callout', null,  'sendMailCallout - Body :' + bodyJSON + ' - Apex Callout Exception:' + errorMsg + ' - res' + res, UM010_Constant.ERROR);  
            }
            if (res.getStatusCode() == 200) {
                UM001_LogManager.writeLogActivityWithoutFuture('SM016_SendMail_Callout', 'sendMailCallout', 'Callout', null, 'sendMailCallout - Body :' + bodyJSON + 'statusCode:' + res.getStatusCode() + ' - From:' + from1 + ' - To:' + to + ' - Subject:' + subject , UM010_Constant.SUCCESS);           
            } else {
                UM001_LogManager.writeLogActivityWithoutFuture('SM016_SendMail_Callout', 'sendMailCallout', 'Callout', null,  'sendMailCallout - Body :' + bodyJSON + 'Exception:' + res.getStatusCode() + ' - statusCode:' + res.getStatusCode() + ' - From:' + from1 + ' - To:' + to + ' - Subject:' + subject + ' - res' + res,  UM010_Constant.ERROR);
            }
            
        }

        return res;
        
    }
     
    public class EmailStructureWrapper{
        public EmailInfo Infos;
        public List<Document> Documents;
        public EmailStructureWrapper(EmailInfo info,List<Document> Documents){
            this.Infos=info;
            this.Documents=Documents;
        }
    }
    public class EmailInfo{
        public String fromName;
        public String from1;
        public String toName;
        public String to;
        public String subject;
        public String body;
        public EmailInfo(String fromName,String from1,String toName,String to,String subject,String body){
            this.fromName=fromName;
            this.from1=from1;
            this.toName=toName;
            this.to=to;
            this.subject=subject;
            this.body=body;
        }
    }
    public class Document{
        public String name;
        public String fileType;
        public String Content;
        public Document(String name,String fileType,String Content){
            this.name=name;
            this.fileType=fileType;
            this.Content=Content;
        }
    }
}