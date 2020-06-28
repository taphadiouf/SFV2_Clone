/**
* @author Achraf ABOUL
* @date 26/06/2020
* @Description SendMail external service callout
*/
public with sharing class SM016_SendMail_Callout {

    public static HttpResponse sendMailCallout(String from1, String to, String subject, String body, Integer[] docsId) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:SendMailService');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        EmailStructureWrapper emailStructure = new EmailStructureWrapper(from1, to, subject, body, docsId);
        request.setBody(JSON.serialize(emailStructure));
        HttpResponse response = http.send(request);
        // Parse the JSON response
        if (response.getStatusCode() == 200) {
            System.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
        } else {
            System.debug(response.getBody());
        }
        return response;
    }
    public class EmailStructureWrapper{
        private String from1;
        private String to;
        private String subject;
        private String body;
        private Integer[] docsId;
        public EmailStructureWrapper(String from1, String to, String subject, String body, Integer[] docsId){
            this.from1 = from1;
            this.to = to;
            this.subject = subject;
            this.body = body;
            this.docsId = docsId;       
        }
    }
}
