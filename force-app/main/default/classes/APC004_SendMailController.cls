/**
* @author Achraf ABOUL
* @date 06/03/2020
* @Description SendMail component controller
*/
public class APC004_SendMailController {
    
    @AuraEnabled(Cacheable=true)
    public static List<EmailTemplate> getAllMailTemplates(){
        return EM008_EmailTemplateEntity.getAllEmailTemplates();
    }
    @AuraEnabled
    public static void sendMail(String subject, String body, List<Id> preInscriptionIds){
        List<string> toAddress = new List<string>();
        for(LPCR_Preinscription__c eachPreInsc : [SELECT Id,LPCR_ContactParent__r.Email FROM LPCR_Preinscription__c WHERE Id IN :preInscriptionIds]){
            toAddress.add(eachPreInsc.LPCR_ContactParent__r.Email);
        }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddress);
        mail.setSubject(subject);
        mail.setHTMLBody(body);
        mail.setSaveAsActivity(false);
        mail.setUseSignature(false);
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        allmsg.add(mail);
        Messaging.sendEmail(allmsg,false);
    }
    
}