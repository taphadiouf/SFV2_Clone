/**
* @author Achraf ABOUL
* @date 28/03/2020
* @Description Test for SM016_SendMail_Callout
*/
@isTest
public with sharing class SM016_SendMail_Callout_Test {
    private final static String from1 = 'user@user.com';
    private final static String to = 'user@usercom';
    private final static String subject= 'Test';
    private final static String body = 'test body';
    private static List<SM016_SendMail_Callout.Document> lstDoc = new List<SM016_SendMail_Callout.Document>(); 

    @isTest static void sendMailCallout_200_Test() {
        MCK001_SendMailMock sendMailMock = new MCK001_SendMailMock();
        sendMailMock.setStatusCode(200);

        lstDoc.add(new SM016_SendMail_Callout.Document('filename','filetype','ZDY1MTE4NTgtYWQyMC00ZTI1LTlkMDgtNjE1NDg1MTY1OWU3DiyVXGD0KaEvfl2BA5sg+Ti0PB8D7qu7heC/aQd1PfI='));
        Test.setMock(HttpCalloutMock.class, sendMailMock);
        HttpResponse result = SM016_SendMail_Callout.sendMailCallout(from1, to, subject, body, lstDoc);
        
        // Verify mock response is not null
        System.assertNotEquals(null, result, 'The callout result returned is null.');
        // Verify status code
        System.assertEquals(200,result.getStatusCode(), 'The status code is not 200.');      
    } 

    @isTest static void sendMailCallout_400_Test() {
        MCK001_SendMailMock sendMailMock = new MCK001_SendMailMock();
        sendMailMock.setStatusCode(400);

        lstDoc.add(new SM016_SendMail_Callout.Document('filename','filetype','contentdoc'));
        Test.setMock(HttpCalloutMock.class, sendMailMock);
        HttpResponse result = SM016_SendMail_Callout.sendMailCallout(from1, to, subject, body, lstDoc);
        
        // Verify mock response is not null
        System.assertNotEquals(null, result, 'The callout result returned is null.');
        // Verify status code
        System.assertEquals(400,result.getStatusCode(), 'The status code is not 400.');      
    } 
    @isTest static void sendMailCallout_500_Test() {
        MCK001_SendMailMock sendMailMock = new MCK001_SendMailMock();
        sendMailMock.setStatusCode(500);

        lstDoc.add(new SM016_SendMail_Callout.Document('filename','filetype','contentdoc'));
        Test.setMock(HttpCalloutMock.class, sendMailMock);
        HttpResponse result = SM016_SendMail_Callout.sendMailCallout(from1, to, subject, body, lstDoc);
        
        // Verify mock response is not null
        System.assertNotEquals(null, result, 'The callout result returned is null.');
        // Verify status code
        System.assertEquals(500, result.getStatusCode(), 'The status code is not 500.');    
    } 
}