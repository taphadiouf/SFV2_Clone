/**
 * @author Erwan Yhuellou
 * @date 20/01/2020
 * @description TestDataFactory - Unit Test Management Refactoring
 */
@isTest
public with sharing class UM002_TestDataFactory {

    //public AccountContactRelationTdf accountContactRelationTdf;
    public CaseTdf caseTdf;
    public OpportunityTdf opportunityTdf;
    public ContactTdf contactTdf;
    //public UserTdf userTdf;
    
    public UM002_TestDataFactory() {
        //accountContactRelationTdf = new AccountContactRelationTdf();
        caseTdf = new CaseTdf();
        opportunityTdf = new OpportunityTdf();
        contactTdf = new ContactTdf();
        //userTdf = new UserTdf();
    }

    public class CaseTdf {
        public Case create(Id accountId, Id contactId){           
            Case c = new Case(ContactId= contactId, AccountId=accountId);
            return c;
        }
        
    }
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
    public class OpportunityTdf {

        public Opportunity create(Account acc) {
            Opportunity opp = new Opportunity(AccountId = acc.Id,
                    CloseDate = Date.today().addDays(15),
                    StageName = 'CreationProgress',
                    Name = 'Test opp');
            return opp;
        }

        public Opportunity create(Account acc, Contact signatoryContact) {
            Opportunity opp = new Opportunity(AccountId = acc.Id,
                    CloseDate = Date.today().addDays(15),
                    StageName = 'CreationProgress',
                    Name = 'Test opp');
            return opp;
        }

        public Opportunity create(Account acc, Case subscriptionCase) {
            Opportunity opp = new Opportunity(AccountId = acc.Id,
                    CloseDate = Date.today().addDays(15),
                    StageName = 'CreationProgress',
                    Name = 'Test opp');


            return opp;
        }
    }

    /*
    public class UserTdf {
        public User create() {
            
           User me = EM001_User.dataManager.getListByIdsWithRoleAndProfile(new Set<Id>{UserInfo.getUserId()}).get(0);

           String s = ((Datetime.now()+'').replace(' ','')).replace(':','');
           Datetime dt = Datetime.now();
           User newMe = me.clone();
           newMe.userName = 'mail'+s+'@me.fr';
           newMe.CommunityNickname = dt.format();
           newMe.FederationIdentifier = null;
           
           return newMe;
           
        }
        
    }*/
    
    //
    

    
    public class ContactTdf{

        public Contact create(String lastName, String firstName, String contactExternalId, String accountExternalId){
            Contact cont = new Contact();  
            cont.Account = new Account();      
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

        public Contact createContactWithoutAccount(String lastName, String firstName, String contactExternalId){
            Contact cont = new Contact();  
            cont.LastName = lastName;
            cont.FirstName = firstName;
            cont.Salutation = 'M.';
            cont.MobilePhone = '+33755729173';
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
    

}