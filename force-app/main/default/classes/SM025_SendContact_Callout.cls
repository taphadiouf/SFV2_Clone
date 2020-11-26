/**
* @author Houssam ADIB
* @date 26/11/2020
* @Description Contact external service callout
*/

public class SM025_SendContact_Callout {

    @future(callout=true)
    public static void sendContactsCallout(){
        String errorMsg;
        HttpResponse res = new HttpResponse();
        List<Contact> contacts = [SELECT id,firstName,lastName,AccountId,email FROM contact WHERE LPCR_ContactAEnvoyer__c=true];
        System.debug('starting the sending with this list : '+ contacts);
        List<Contact> processedContacts = new List<Contact>();
        
        List<LPCR_Log__c> listOfLog = new List<LPCR_Log__c>();
        for(Contact con : contacts ){
            try {
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                LPCR_Environnement__c envCS = LPCR_Environnement__c.getInstance();
                if('UAT'.equals(envCS.Nom__c)){
                    req.setEndpoint('callout:UAT_ENVOIE_CONTACT_ENTREPRISE');
                }
                else if('PROD'.equals(envCS.Nom__c)){
                    req.setEndpoint('callout:PROD_ENVOIE_CONTACT_ENTREPRISE');
                }
                else{
                    req.setEndpoint('callout:DEV_ENVOIE_CONTACT_ENTREPRISE');
                }
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json; utf-8');

                ContactWrapper tempWrapper = new ContactWrapper(con.AccountId,con.FirstName,con.Lastname,con.Email);
                String bodyJSON = JSON.serialize(tempWrapper);
                System.debug('bodyJSON:' + bodyJSON);
                req.setBody(bodyJSON);
                
                //Sending . . .
                res = h.send(req);

                //Reading result :
                String result = res.getBody();
                system.debug('the reponse Code : ' + res.getStatusCode());
                system.debug('the reponse : ' + result);

                listOfLog.add(UM001_LogManager.getWriteLogActivityForBulkInsert('Sending Contact via web service', 'SM025_SendContact_Callout', 'Callout',String.valueOf(con.Id), 'Contact Id :' + String.valueOf(con.Id) + '|Status:' + res.getStatusCode() +'|Response:' + result, UM010_Constant.SUCCESS));
            }catch (System.CalloutException e){ 
                system.debug('the response error : ' + e.getMessage() + '|Line : ' + e.getLineNumber());
                
                listOfLog.add(UM001_LogManager.getWriteLogActivityForBulkInsert('Sending Contact via web service', 'SM025_SendContact_Callout', 'Callout', String.valueOf(con.Id), 'Contact Id :' + String.valueOf(con.Id) + '|Error:' + e.getMessage() + '|Line:'+e.getLineNumber(), UM010_Constant.ERROR));
            }
            processedContacts.add(con);
        }
        
        //Insert logs
        String ErrMsg;
        try {
            insert listOfLog;
        } catch (Exception e) {
            ErrMsg = e.getMessage() + '|Line:' + e.getLineNumber();
        } finally {
            if(ErrMsg != null && String.isNotBlank(ErrMsg)){
                UM001_LogManager.writeLogActivityWithoutFuture( 'Write logs of sending contacts via web service','SM025_SendContact_Callout', 'Callout' , null,'Error while inserting the logs : ' + ErrMsg, UM010_Constant.ERROR);              
            }
        }

        for(Contact con : processedContacts){
            con.LPCR_ContactAEnvoyer__c = false;
        }

        //Update processed contacts
        ErrMsg = null;
        if(UM003_TypeManager.isNotNullAndNotEmpty(processedContacts)){
            try {
                update processedContacts;
            } catch (Exception e) {
                ErrMsg = e.getMessage() + '|Line:' + e.getLineNumber();
            } finally {
                if(ErrMsg != null && String.isNotBlank(ErrMsg)){
                    UM001_LogManager.writeLogActivityWithoutFuture( 'Update processed contacts after being sent','SM025_SendContact_Callout', 'Callout' , null,'Error while updating the contacts : ' + ErrMsg, UM010_Constant.ERROR);              
                }
            }
        }
    }

    public class ContactWrapper{
        public String accountSfId;
        public String nom;
        public String prenom;
        public String login;
        public ContactWrapper(String accountSfId, String nom, String prenom, String email){
            this.accountSfId = accountSfId;
            this.prenom =  prenom;
            this.nom    =   (nom    != null && !String.isBlank(nom))    ?   nom     : 'null';
            this.login  =   (email  != null && !String.isBlank(email))  ?   email   : 'null@null.com';
        }
    }
}
