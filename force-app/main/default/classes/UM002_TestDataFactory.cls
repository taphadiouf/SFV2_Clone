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
            Profile prof = [SELECT Id FROM Profile WHERE Name = 'System Administrator' limit 1].get(0);
        
        String uniqueUserName = 'standarduser' + DateTime.now().millisecond() + '@testorg.com';
        User usr = new User(Alias = 'testusr', Email = uniqueUserName,
                            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                            LocaleSidKey = 'en_US', ProfileId = prof.Id,
                            TimeZoneSidKey = 'America/Los_Angeles',
                            UserName = uniqueUserName);
        insert usr;
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
    
    // End of part added by hanae on the same day
    
    
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
    //--- End Ayoub's Part
}