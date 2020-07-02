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
        public String fromEmail;
        @InvocableVariable(required=true)
        public String toEmail;
        @InvocableVariable(required=true)
        public String subject;
        @InvocableVariable(required=true)
        public String body;
    }
    @InvocableMethod(label='Presinscription Send Email API' 
                     description='Presinscription Send Email'
                     category='PresinscriptionCategory')
    public static void presinscriptionSendEmail(PresinscriptionParameter[] presinscriptionParameters) {    
        PAD.log('SM020_PresinscriptionInvocableService', 'presinscriptionSendEmail', 'Presinscription Send Email');
        PresinscriptionParameter param = presinscriptionParameters.get(0);
        LPCR_Preinscription__c preinscription = [SELECT Id, Name, LPCR_Creche__c FROM LPCR_Preinscription__c WHERE Id =: param.presinscriptionId];
        if(preinscription.LPCR_Creche__c != null){
            SM019_DocumentList_Callout.DocumentListFullResponse fullResponse1 = SM019_DocumentList_Callout.getDocumentListCallout(preinscription.LPCR_Creche__c, 'Calendrier Congés');
            Set<String> docTmp = new Set<String>();
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
            
            if(docTmp.size() > 0){
                HttpResponse response = SM016_SendMail_Callout.sendMailCallout(param.fromEmail, param.toEmail, param.subject, param.body, docTmp);
                if(response.getStatusCode() == 200){
                    PAD.log('SM020_PresinscriptionInvocableService', 'presinscriptionSendEmail', 'SM016_SendMail_Callout');
                }
            }
           
        }                
    }
}