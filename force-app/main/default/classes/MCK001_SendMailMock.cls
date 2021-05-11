/**
* @author Achraf ABOUL
* @date 28/03/2020
* @Description Mock of external WebService For sending email
*/
@isTest
global with sharing class MCK001_SendMailMock implements HttpCalloutMock{
    
    private HttpResponse response;
    global MCK001_SendMailMock(){
        this.response = new HttpResponse();
    }
    global HTTPResponse respond(HTTPRequest request) {
        this.response.setHeader('Content-Type', 'application/json');
        this.response.setBody('"customreponse : "this is a custom response');
        return this.response; 
    }
    global void setStatusCode(Integer statusNumber){
        this.response.setStatusCode(statusNumber);
    }
}