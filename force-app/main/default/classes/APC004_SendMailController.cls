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
        boolean isvalid = true;
        String errMsg = 'Veuillez saisir  ';
        List<string> toAddress = new List<string>();
        for(LPCR_Preinscription__c eachPreInsc : [SELECT Id,LPCR_ContactParent__r.Email FROM LPCR_Preinscription__c WHERE Id IN :preInscriptionIds]){
            if(eachPreInsc.LPCR_ContactParent__r.Email != Null){
                toAddress.add(eachPreInsc.LPCR_ContactParent__r.Email);
            }else{
                isvalid = False ;
                errMsg += 'le champ Email du contact parent, ';
            }
            
        }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddress);
        mail.setSubject(subject);
        if(body  != NULL){
            mail.setHTMLBody(body);
        }else{
            isvalid = False ;
            errMsg += 'le message';
        }
        if(!isvalid){
            throw new AuraHandledException(errMsg);
        }
        mail.setSaveAsActivity(false);
        mail.setUseSignature(false);
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        allmsg.add(mail);
        Messaging.sendEmail(allmsg,false);
    }
    
}