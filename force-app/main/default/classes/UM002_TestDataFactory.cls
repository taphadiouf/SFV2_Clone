/**
* @author Erwan Yhuellou
* @date 20/01/2020
* @description TestDataFactory - Unit Test Management Refactoring
*/
//@isTest
public with sharing class UM002_TestDataFactory {
    
    //public AccountContactRelationTdf accountContactRelationTdf;
    public AccountTdf accountTdf;
    public CaseTdf caseTdf;
    public OpportunityTdf opportunityTdf;
    public ContactTdf contactTdf;
    public UserTdf userTdf;
    
    public UM002_TestDataFactory() {
        
        //accountContactRelationTdf = new AccountContactRelationTdf();
        accountTdf = new accountTdf();
        caseTdf = new CaseTdf();
        opportunityTdf = new OpportunityTdf();
        contactTdf = new ContactTdf();
        userTdf = new UserTdf();
    }
    
    public class AccountTdf {
        public Account create(String accountName){           
            Account c = new Account(Name = accountName);
            return c;
        }
        
    }
    
    public class CaseTdf {
        public Case create(Id accountId, Id contactId){           
            Case c = new Case(ContactId= contactId, AccountId=accountId);
            return c;
        }
        
    }
    
    public class OpportunityTdf {
        
        public Opportunity create(Account acc) {
            Opportunity opp = new Opportunity(AccountId = acc.Id,
                                              CloseDate = Date.today().addDays(15),
                                              StageName = 'CreationProgress',
                                              Name = 'Test opp');
            return opp;
        }
    }
    
    public class ContactTdf{
        
        public Contact create(String lastName, String firstName, Account acc){
            Contact cont = new Contact();  
            cont.Account = acc;      
            cont.LastName = lastName;
            cont.FirstName = firstName;
            cont.Salutation = 'M.';
            cont.MobilePhone = '+33610918171';
            cont.MailingStreet ='12 rue de paris';
            cont.MailingPostalCode ='75002';
            cont.MailingCity ='Paris';
            cont.Email = 'contact@contact.com';
            cont.Phone = '0987654321';
            cont.MailingStreet = 'Rue de Paris';
            cont.MailingCity = 'Paris';
            cont.MailingPostalCode = '75010';
            return cont;
        }
    }
    
    public class UserTdf {
        public User create() {
            
            User me;
            /*
User me = EM001_User.dataManager.getListByIdsWithRoleAndProfile(new Set<Id>{UserInfo.getUserId()}).get(0);

String s = ((Datetime.now()+'').replace(' ','')).replace(':','');
Datetime dt = Datetime.now();
User newMe = me.clone();
newMe.userName = 'mail'+s+'@me.fr';
newMe.CommunityNickname = dt.format();
newMe.FederationIdentifier = null;
*/
            return me;
            
        }
        
    }
    //This part of code is added by hanae on the 12/02/2020
    //it's a class that permit to add a list of leads/Tasks/Events/ Users
    
    public static User createUser(){
        User usr = null;
        try{
           usr=  [SELECT Id, Name,Alias FROM User Where Alias = 'testusr' limit 1];
        }
        catch(Exception e){
           usr = null; 
        }
        
        if(usr==null){
            Profile prof = [SELECT Id, Name FROM Profile Where UserType = 'Standard' AND PermissionsCustomizeApplication = true limit 1].get(0);
            
            String uniqueUserName = 'standarduser' + DateTime.now().millisecond() + '@testorg.com';
            usr = new User(Alias = 'testusr', Email = uniqueUserName,
                                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                                LocaleSidKey = 'en_US', ProfileId = prof.Id,
                                TimeZoneSidKey = 'America/Los_Angeles',
                                UserName = uniqueUserName);
            insert usr;
        }
        
        
        return usr;
    }
    
    
    public static List<Lead> createLeads(Integer numLeads, String recTypeId, String lastName, String company, String status,String Email){
        List<Lead> leads = new List<Lead>();
        for(Integer i=0;i<numLeads;i++){
            Lead l= new Lead(RecordTypeId = recTypeId, LastName=lastName,Company=company ,Status = status, Email=email);
            leads.add(l);
        }
        return leads;
    }
    
    public static List<Task> createTasks(Set<Id> whoIds ){
        List<Task> tasks = new List<Task>();
        for(Id eachId : whoIds){
            Task t= new Task(WhoId = eachId);
            tasks.add(t);
        }
        return tasks;
    }
    
    public static List<Event> createEvents(Set<Id> whoIds, Integer min, DateTime theDate ){
        List<Event> events = new List<Event>();
        for(Id eachId : whoIds){
            Event t= new Event(WhoId = eachId, DurationInMinutes = min, ActivityDateTime = theDate);
            events.add(t);
        }
        return events;
    }
    public static List<Opportunity> createOpportunities(Integer numOpps, String name, String stageName){
        List<Opportunity> opps = new List<Opportunity>();
        Opportunity tempOpp;
        for(Integer i = 0; i<numOpps; i++){
            tempOpp = new Opportunity(Name = name, StageName = stageName, CloseDate = Date.today());
            opps.add(tempOpp);
        }
        return opps;
    }
    public static List<Account> createAccounts(Integer numAccs, String name){
        List<Account> accounts = new List<Account>();
        Account tempAcc;
        for(Integer i = 0; i<numAccs; i++){
            tempAcc = new Account(Name = name);
            accounts.add(tempAcc);
        }
        return accounts;
    }
    public static List<SBQQ__Quote__c> createQuotes(Integer numRecs, List<Account> accs, List<Opportunity> opps){
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c tempQuote;
        for(Integer i = 0; i<numRecs; i++){
            tempQuote = new SBQQ__Quote__c(
                SBQQ__Opportunity2__c = opps.get(i).Id,
                SBQQ__Account__c = accs.get(i).Id
            );
            quotes.add(tempQuote);
        }
        return quotes;
    }
    public static List<Lead> createLe(Integer numLeads, String recTypeId, String lastName,String PrenomCoDemandeur,String company, String status,String Email, String NomCoDemandeur, Date DateNaissance1, String EmailCoDemandeur, String Phone, String CiviliteCoDemandeur){
        List<Lead> leads = new List<Lead>();
        for(Integer i=0;i<numLeads;i++){
            Lead l= new Lead(RecordTypeId = recTypeId, LastName=lastName, LPCR_PrenomCoDemandeur__c =PrenomCoDemandeur,Company=company ,Status = status, Email=email, LPCR_NomCoDemandeur__c= NomCoDemandeur,  LPCR_DateNaissance1__c= DateNaissance1 , LPCR_EmailCoDemandeur__c =EmailCoDemandeur, Phone=Phone, LPCR_CiviliteCoDemandeur__c = CiviliteCoDemandeur);
            leads.add(l);
        }
        return leads;
    }
    public static Account createAcc(String name, Id recId){
        return new Account(Name = name,
                           RecordTypeId = recId);
        
    }
    
    
    public static List<Lead> createLeadsWithAllFields(Integer numLeads, String recTypeId, String lastName,String firstName, String PrenomCoDemandeur,String company, String status,String Email, String NomCoDemandeur, Date DateNaissance1, String EmailCoDemandeur, String Phone, String CiviliteCoDemandeur){
        List<Lead> leads = new List<Lead>();
        for(Integer i=0;i<numLeads;i++){
            Lead l= new Lead(RecordTypeId = recTypeId, LastName=lastName, FirstName=firstName, LPCR_PrenomCoDemandeur__c =PrenomCoDemandeur,Company=company ,Status = status, Email=email, LPCR_NomCoDemandeur__c= NomCoDemandeur,  LPCR_DateNaissance1__c= DateNaissance1 , LPCR_EmailCoDemandeur__c =EmailCoDemandeur, Phone=Phone, LPCR_CiviliteCoDemandeur__c = CiviliteCoDemandeur);
            leads.add(l);
        }
        return leads;
    }
    public static Account createAccByRT(String name, Id recId){
        return new Account(Name = name,
                           RecordTypeId = recId);
    }
    
    // End of part added by hanae on the same day
    // Added By Ayoub 	
    public static LPCR_Preinscription__c createPreinscription(String nomEnfant, String prenomEnfant,Id compteFamilleId,Id contactId){	
        LPCR_Preinscription__c  preinsciption = new LPCR_Preinscription__c (LPCR_CompteFamille__c=compteFamilleId,	
                                                                            LPCR_PrenomEnfant__c=prenomEnfant,	
                                                                            NomEnfant__c=nomEnfant,	
                                                                            LPCR_ContactEnfant__c=contactId);	
        return preinsciption;	
    }
    public static Account createAccount(String name){	
        Account  acc = new Account(Name = name);	
        return acc;	
    }	
    
    public static List<LPCR_ParametrageScore__c> createParametrageScores(Id accId){
        List<LPCR_ParametrageScore__c> listParams =new List<LPCR_ParametrageScore__c>();
        listParams.add( new LPCR_ParametrageScore__c(LPCR_Account__c  =accId, LPCR_Anciennete__c =1,LPCR_Score__c=100));
        listParams.add( new LPCR_ParametrageScore__c(LPCR_Account__c  =accId,LPCR_Anciennete__c =5,LPCR_Score__c=300));
        listParams.add(new LPCR_ParametrageScore__c(LPCR_Account__c  =accId,LPCR_Anciennete__c =10,LPCR_Score__c=500));
        
        listParams.add(new LPCR_ParametrageScore__c(LPCR_Account__c  =accId,LPCR_NbJourGarde__c =1,LPCR_Score__c=20));
        listParams.add(new LPCR_ParametrageScore__c(LPCR_Account__c  =accId,LPCR_NbJourGarde__c =2,LPCR_Score__c=30));
        listParams.add(new LPCR_ParametrageScore__c(LPCR_Account__c  =accId,LPCR_NbJourGarde__c =3,LPCR_Score__c=50));
        listParams.add(new LPCR_ParametrageScore__c(LPCR_Account__c  =accId,LPCR_NbJourGarde__c =4,LPCR_Score__c=60));
        listParams.add(new LPCR_ParametrageScore__c(LPCR_Account__c  =accId,LPCR_NbJourGarde__c =5,LPCR_Score__c=100));
        
        listParams.add(new LPCR_ParametrageScore__c(LPCR_Account__c  =accId,LPCR_Revenu__c  =1000,LPCR_Score__c=10));
        listParams.add(new LPCR_ParametrageScore__c(LPCR_Account__c  =accId,LPCR_Revenu__c  =10000,LPCR_Score__c=100));
        listParams.add(new LPCR_ParametrageScore__c(LPCR_Account__c  =accId,LPCR_Revenu__c  =100000,LPCR_Score__c=500));
        
        listParams.add(new LPCR_ParametrageScore__c(LPCR_Account__c  =accId,LPCR_ReponseCrecheMunicipale__c=true,LPCR_Score__c=20));        
        listParams.add(new LPCR_ParametrageScore__c(LPCR_Account__c  =accId,LPCR_ReponseCrecheMunicipale__c=False,LPCR_Score__c=50));
        
        listParams.add(new LPCR_ParametrageScore__c(LPCR_Account__c  =accId,LPCR_DateEntree__c=Date.newInstance(2019,12,31),LPCR_Score__c=100));
        listParams.add(new LPCR_ParametrageScore__c(LPCR_Account__c  =accId,LPCR_DateEntree__c=Date.newInstance(2020,12,31),LPCR_Score__c=10));
          
        
        return listParams;
        
    }
    
    //--- End Ayoub's Part

    //This part of code is added by hanae on the 09/03/2020
    public static List<LPCR_Preinscription__c> createPreinscription(Integer numPrei, String nomEnfant, String prenomEnfant,String statut,Id compteFamilleId,Id contactId){	
        List<LPCR_Preinscription__c> preinscriptions = new List<LPCR_Preinscription__c>();
        for(Integer i=0;i<numPrei;i++){
            LPCR_Preinscription__c  pre = new LPCR_Preinscription__c (LPCR_CompteFamille__c=compteFamilleId,	
                                                                            LPCR_PrenomEnfant__c=prenomEnfant,	
                                                                            NomEnfant__c=nomEnfant,	
                                                                            LPCR_Statut__c = statut,
                                                                            LPCR_ContactEnfant__c=contactId);	
            preinscriptions.add(pre);
        }
        
        return preinscriptions;	
    }

    //--- End of Hanae's part

    
    public static List<LPCR_Preinscription__c> createPreinscriptions(Integer numPrei, String nomEnfant, String prenomEnfant,String statut,Id compteFamilleId,Id contactId){	
        List<LPCR_Preinscription__c> preinscriptions = new List<LPCR_Preinscription__c>();
        for(Integer i=0;i<numPrei;i++){
            LPCR_Preinscription__c  pre = new LPCR_Preinscription__c(      LPCR_CompteFamille__c=compteFamilleId,	
                                                                            LPCR_PrenomEnfant__c=prenomEnfant,	
                                                                            NomEnfant__c=nomEnfant,	
                                                                            LPCR_Statut__c = statut,
                                                                            LPCR_ContactEnfant__c=contactId);	
            preinscriptions.add(pre);
        }
        
        return preinscriptions;	
    }
    
    public static EmailTemplate createEmailTemplate(String name, String developerName, String templateType){
        return new EmailTemplate(Name = name,
                        DeveloperName = developerName,
                         TemplateType =templateType,
                         FolderId = UserInfo.getUserId());
    }
    //This part of code is added by hanae on the 28/02/2020 to create Attachments and LPCR_Log__c records
    public static List<Attachment> createAttachements(Integer numAtts, String name,String body,String parentId){
        List<Attachment> atts = new List<Attachment>();
        for(Integer i=0;i<numAtts;i++){
            Attachment a = new Attachment();
            a.Name = name;
            Blob bodyBlob = Blob.valueOf(body);
            a.body = bodyBlob;
            a.ParentId = parentId;
            atts.add(a);
        }
        return atts;
    }
    
    public static List<LPCR_Log__c> createLogsFromAttachments( String name,String result, String typ,List<Attachment> attsList){
        List<LPCR_Log__c> logsList = new List<LPCR_Log__c>();
        LPCR_Log__c tempLog;
        for(Attachment eachAtt : attsList){
            tempLog = new LPCR_Log__c();
            tempLog.Name = name;
            tempLog.LPCR_TargetObject__c = '' + eachAtt.Id;
            tempLog.LPCR_Result__c = result;
            tempLog.LPCR_Type__c = typ;
            logsList.add(tempLog);
        }
        return logsList;
    }
    
    
    
    
    
    //End of the part on the same day
    
    


    // This part is added by hanae on the 12/03/2020


    public static LPCR_Preinscription__c createPreinscription(String nomEnfant, String prenomEnfant, String typePreinscription,Id compteFamilleId,Id contactId){	
        LPCR_Preinscription__c  preinsciption = new LPCR_Preinscription__c (LPCR_CompteFamille__c=compteFamilleId,	
                                                                            LPCR_PrenomEnfant__c=prenomEnfant,
                                                                            LPCR_TypePreinscription__c=typePreinscription,	
                                                                            NomEnfant__c=nomEnfant,	
                                                                            LPCR_ContactEnfant__c=contactId);	
        return preinsciption;	
    }

    //End of the part on the same day





    /*
public class AccountContactRelationTdf {

public AccountContactRelation create(Id accountId, Id contactId) {
AccountContactRelation acr = new AccountContactRelation();
acr.ContactId = contactId;
acr.AccountId = accountId;

return acr;
}

public AccountContactRelation create(Id accountId, Id contactId, List<String> roles) {
AccountContactRelation acr = new AccountContactRelation();
acr.ContactId = contactId;
acr.AccountId = accountId;
acr.Roles = String.join(roles, ';');

return acr;
}

public AccountContactRelation create(Id accountId, Id contactId, List<String> roles, String fonction) {
AccountContactRelation acr = new AccountContactRelation();
acr.ContactId = contactId;
acr.AccountId = accountId;
acr.Roles = String.join(roles, ';');
acr.Function__c = fonction;

return acr;
}
}
*/
    
}