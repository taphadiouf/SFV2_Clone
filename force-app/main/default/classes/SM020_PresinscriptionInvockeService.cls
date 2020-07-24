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
        LPCR_Preinscription__c preinscription = [SELECT Id, Name, LPCR_Creche__c, LPCR_ContactParent__c, LPCR_ContactParent__r.email FROM LPCR_Preinscription__c WHERE Id =: param.presinscriptionId];
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
            
            HttpResponse response = SM016_SendMail_Callout.sendMailCallout(UserInfo.getUserEmail(), preinscription.LPCR_ContactParent__r.email, template.body, template.subject, docTmp);
            if(response.getStatusCode() == 200){
                PAD.log('SM020_PresinscriptionInvocableService', 'presinscriptionSendEmail', 'SM016_SendMail_Callout');
            }
            
        }
        
    }
    
    
}