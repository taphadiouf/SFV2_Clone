/**
* @author Achraf ABOUL
* @date 26/06/2020
* @Description SendMail external service callout
*/
public with sharing class SM016_SendMail_Callout {
    
    public static HttpResponse sendMailCallout(String from1, String to, String subject, String body, Set<String> docsId) {
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
        System.debug('##D: '+ docsId );
        if(docsId != null){
            for(String DocId: docsId){
                docsIdSet.add(Integer.valueOf(DocId));
            }
        }
        
        EmailStructureWrapper emailStructure = new EmailStructureWrapper(from1, to, subject, body, docsIdSet);
        String bodyJSON = JSON.serialize(emailStructure);
        bodyJSON = bodyJson.replace('from1', 'From');

        System.debug(bodyJSON);
        req.setBody(bodyJSON);
        
        System.Debug('>> - LOG - req:' + req);
        System.Debug('>> - LOG - h:' + h);
        
        HttpResponse res = h.send(req);
        String result = res.getBody();
        
        // Parse the JSON response
        if (res.getStatusCode() == 200) {
            System.debug('The status code returned was not expected: ' +
                         res.getStatusCode() + ' ' + res.getStatus());
        } else {
            System.debug(res.getBody());
        }
        
        return res;
        
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