/**
* @author Saurabh
* @date 02/07/2020
* @description Invocable Apex class SM020_PresinscriptionInvockeService
*/
public class SM020_PresinscriptionInvockeService {
    public class PresinscriptionParameter{
        @InvocableVariable(required=true)
        public Id presinscriptionId;
        @InvocableVariable(required=true)
        public String emailTemplate;
        @InvocableVariable(required=true)
        public Boolean flagDocuments;
    }
    //modified by Akshaye
    @InvocableMethod(label='Presinscription Send Email API' 
                     description='Presinscription Send Email'
                     category='PresinscriptionCategory')
    public static void presinscriptionSendEmail(PresinscriptionParameter[] presinscriptionParameters) {    
        PAD.log('SM020_PresinscriptionInvocableService', 'presinscriptionSendEmail', 'Presinscription Send Email');
        Set<String> docTmp = new Set<String>();
        docTmp = null;
        
        PresinscriptionParameter param = presinscriptionParameters.get(0);
        LPCR_Preinscription__c preinscription = [SELECT Id, Name, LPCR_Creche__r.Name,LPCR_CompteEntreprise__r.Name, LPCR_Creche__c,LPCR_CompteEntreprise__c,LPCR_DateEntreeCreche__c, LPCR_ContactParent__c, LPCR_ContactParent__r.email FROM LPCR_Preinscription__c WHERE Id =: param.presinscriptionId];
        EmailTemplate template = [select id, name, body, subject from EmailTemplate where developername = : param.emailTemplate];
        
        //send email using template
        if(template.id != null && preinscription.LPCR_ContactParent__c != null){
            
            
            //set documents as attachments
            if(param.flagDocuments == true){
                SM019_DocumentList_Callout.DocumentListFullResponse fullResponse1 = SM019_DocumentList_Callout.getDocumentListCallout(preinscription.LPCR_Creche__c, 'Calendrier Congés');
                if(fullResponse1.result == '200') {
                    for(SM019_DocumentList_Callout.DocumentListResponse eachDoc : fullResponse1.response){
                        docTmp.add(eachDoc.id);
                    }                
                }
                
                SM019_DocumentList_Callout.DocumentListFullResponse fullResponse2 = SM019_DocumentList_Callout.getDocumentListCallout(preinscription.LPCR_Creche__c, 'Règle de fonctionnement');
                if(fullResponse2.result == '200') {
                    for(SM019_DocumentList_Callout.DocumentListResponse eachDoc : fullResponse2.response){
                        docTmp.add(eachDoc.id);
                    }
                }
            }
            
            User conUser = [select id,FirstName, LastName, Title, CompanyName, city, country, Address, PostalCode     from user where id =: UserInfo.getUserId() limit 1] ;    
            
            string body = template.body;
            if(preinscription.LPCR_Creche__c != null) body = body.replace('{!LPCR_Preinscription__c.LPCR_Creche__c}', preinscription.LPCR_Creche__r.Name);
            if(preinscription.LPCR_CompteEntreprise__c  != null ) body = body.replace('{!LPCR_Preinscription__c.LPCR_CompteEntreprise__c}', preinscription.LPCR_CompteEntreprise__r.Name);
            if(preinscription.LPCR_DateEntreeCreche__c  != null) body = body.replace('{!LPCR_Preinscription__c.LPCR_DateEntreeCreche__c}', string.valueOf(preinscription.LPCR_DateEntreeCreche__c));
            if(conUser.FirstName != null) body = body.replace('{!User.FirstName}', conUser.FirstName);
            body = body.replace('{!User.LastName}', conUser.LastName);
            if(conUser.Title != null)  body = body.replace('{!User.Title}', conUser.Title);
            if(conUser.CompanyName != null) body = body.replace('{!User.CompanyName}', conUser.CompanyName);
            if(conUser.city != null && conUser.Country != null) body = body.replace('{!User.Address}', conUser.city + ' ' + conUser.Country);
            if(conUser.PostalCode != null) body = body.replace('{!User.PostalCode}', conUser.PostalCode);
            body = body.replace('{!User.FirstName}', '');
            body = body.replace('{!User.Title}', '');
            body = body.replace('{!User.CompanyName}', '');
            body = body.replace('{!User.Address}', '');
            body = body.replace('{!User.PostalCode}', '');
            body = body.replace('{!LPCR_Preinscription__c.LPCR_Creche__c}', '');
            body = body.replace('{!LPCR_Preinscription__c.LPCR_CompteEntreprise__c}', '');
            body = body.replace('{!LPCR_Preinscription__c.LPCR_DateEntreeCreche__c}', '');
            
            callout(UserInfo.getUserEmail(), preinscription.LPCR_ContactParent__r.email, body, template.subject, docTmp);
        }
        
    }
    
    @future(callout = true)
    public static void callout(string fromemail, string to, string body, string template, Set<String> docTmp){
        HttpResponse response = SM016_SendMail_Callout.sendMailCallout(fromemail, to, body, template, docTmp);
        if(response.getStatusCode() == 200){
            PAD.log('SM020_PresinscriptionInvocableService', 'presinscriptionSendEmail', 'SM016_SendMail_Callout');
        }
    }
    
}