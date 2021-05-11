/**
* @author Achraf ABOUL
* @date 28/03/2020
* @Description Test for SM016_SendMail_Callout
*/
@isTest
public with sharing class SM016_SendMail_Callout_Test {
    private final static String from1;
    private final static String to;
    private final static String subject;
    private final static String body;
    private final static Set<String> docsId;

    @isTest static void sendMailCallout_200_Test() {
        MCK001_SendMailMock sendMailMock = new MCK001_SendMailMock();
        sendMailMock.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, sendMailMock);
        HttpResponse result = SM016_SendMail_Callout.sendMailCallout(from1, to, subject, body, docsId);
        
        // Verify mock response is not null
        System.assertNotEquals(null, result, 'The callout result returned is null.');
        // Verify status code
        System.assertEquals(200,result.getStatusCode(), 'The status code is not 200.');      
    } 

    @isTest static void sendMailCallout_400_Test() {
        MCK001_SendMailMock sendMailMock = new MCK001_SendMailMock();
        sendMailMock.setStatusCode(400);

        Test.setMock(HttpCalloutMock.class, sendMailMock);
        HttpResponse result = SM016_SendMail_Callout.sendMailCallout(from1, to, subject, body, docsId);
        
        // Verify mock response is not null
        System.assertNotEquals(null, result, 'The callout result returned is null.');
        // Verify status code
        System.assertEquals(400,result.getStatusCode(), 'The status code is not 400.');      
    } 
    @isTest static void sendMailCallout_500_Test() {
        MCK001_SendMailMock sendMailMock = new MCK001_SendMailMock();
        sendMailMock.setStatusCode(500);

        Test.setMock(HttpCalloutMock.class, sendMailMock);
        HttpResponse result = SM016_SendMail_Callout.sendMailCallout(from1, to, subject, body, docsId);
        
        // Verify mock response is not null
        System.assertNotEquals(null, result, 'The callout result returned is null.');
        // Verify status code
        System.assertEquals(500, result.getStatusCode(), 'The status code is not 500.');    
    } 
}