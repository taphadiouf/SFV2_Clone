/**
 * @author Erwan Yhuellou
 * @created 26/01/2020
 * @description Covering UM002_TestDataFactory Class
 */
 @isTest
private class UM002_TestDataFactory_Test {

    @testSetup static void setup() {
        
        // Create Factory
        UM002_TestDataFactory tdf = new UM002_TestDataFactory();

        Account a = tdf.AccountTdf.create('Account Test');
        insert a;

        Contact co = tdf.ContactTdf.create('Account', 'Test', a);
        insert co;

        Case ca = tdf.CaseTdf.create(a.Id, co.Id);
        insert ca;

        Opportunity o = tdf.OpportunityTdf.create(a);
        insert o;
    }

    static testMethod void validateTestDataFactory() {

        Account tmpAcc = [Select Id from Account where name like 'Account Test'];
        Contact tmpCon = [Select Id from Contact where Lastname like 'Account'];
        Case tmpCase = [Select Id from Case where ContactId =: tmpCon.Id];
        Opportunity tmpOpp = [Select Id from Opportunity where AccountId =: tmpAcc.Id];

        System.AssertNotEquals(tmpAcc, null, 'Account not created');
        System.AssertNotEquals(tmpCon, null, 'Contact not created');
        System.AssertNotEquals(tmpCase, null, 'Case not created');
        System.AssertNotEquals(tmpOpp, null, 'Opportunity not created');
        
    }

    static {
        UM002_TestDataFactory.FillAllFields = true; // increase test coverage without creating custom objects
    }  

    static testMethod void createsSingleObjectWithSingleRequiredStringField() {
        Account account = (Account)UM002_TestDataFactory.createSObject('Account');
        insert account;
        System.assert(account.Id != null);
        System.assert(account.Name != null);
    }
    
    static testMethod void createsUser() {
        User u = (User)UM002_TestDataFactory.createSObject('User');
        insert u;
        System.assert(u.Id != null);
    }
/*
    static testMethod void createsObjectWithCascadeSetsLookupField() {
        Contact contact = (Contact)UM002_TestDataFactory.createSObject('Contact', true);
        insert contact;
        System.assert(contact.Id != null);
        System.assert(contact.AccountId != null);
    }
    
    static testMethod void createsObjectWithoutCascadeDoesNotSetLookupField() {
        Contact contact = (Contact)UM002_TestDataFactory.createSObject('Contact', false);
        insert contact;
        System.assert(contact.AccountId == null);
    }
    
    static testMethod void createObjectWithUnsupportedTypeThrowsException() {
        try {
            UM002_TestDataFactory.createSObject('Unsupported');
            System.assert(false);
        } catch (CMN_UnsupportedObjectTypeException ex) {
            System.assert(true);
        }
    }
    */
    
    static testMethod void loadTestWith100PlusAccountNContacts() {
        for (Integer idx = 0; idx <= 101; idx++)
            Account account = (Account)UM002_TestDataFactory.createSObject('Account');
        for (Integer idx = 0; idx <= 101; idx++)
            Contact cont = (Contact)UM002_TestDataFactory.createSObject('Contact');         
    }

    static testMethod void creatingRecordsWithSpecificDefaults() {

        Map<String, Object> defaults = new Map<String, Object>{
            'Birthdate' => Date.newInstance(1980, 1, 1),          // all records will get this date
            'Department' => new List<String>{'Dept 1', 'Dept 2'},  // half will get the first value, half the second
            'LastName' => 'contactLname'
        };

        List<SObject> contactsAsSObjects = UM002_TestDataFactory.createSObjectList('Contact', 20, defaults);
        insert contactsAsSObjects;
        for (SObject s : contactsAsSObjects)
        {
            Contact c = (Contact) s;
            System.assert(c.Id != null);
            System.assert(c.Department.startsWith('Dept'));
            System.assertEquals(Date.newInstance(1980, 1, 1), c.Birthdate);
        }
        PAD.log('UM002_TestDataFactory_Test','creatingRecordsWithSpecificDefaults','loggingLevel'+loggingLevel.WARN, (Contact)(contactsAsSObjects[0]));
    }  

    static testMethod void creatingRecordsForSpecificParentId() {
        Account account = (Account)UM002_TestDataFactory.createSObject('Account');
        insert account;

        // create 20 contacts in that account
        List<Contact> contactsAsSObjects = (List<Contact>)(UM002_TestDataFactory.createSObjectList(
            'Contact', 20, new Map<String, Object>{'AccountId' => account.Id}));
        insert contactsAsSObjects;

        for (Contact c : contactsAsSObjects)
        {
            System.assert(c.Id != null);
            System.assert(c.AccountId == account.Id);
        }
    }  

    static testMethod void creatingRecordsForSpecificParentObject() {
        Account account = (Account)UM002_TestDataFactory.createSObject('Account');
        insert account;

        // create 20 contacts in that account
        List<SObject> contactsAsSObjects = 
            UM002_TestDataFactory.createSObjectList('Contact', 20, new Map<String, Object>{'AccountId' => account});
        insert contactsAsSObjects;

        for (SObject s : contactsAsSObjects)
        {
            Contact c = (Contact) s;
            System.assert(c.Id != null);
            System.assert(c.AccountId == account.Id);
        }
    }  

    static testMethod void creatingRecordsWithListOfDefaultParents() {

        // create 5 accounts
        list<Account> accountList = (list<Account>)(UM002_TestDataFactory.createSObjectList('Account', 5));
        insert accountList;

        // each account gets 4 contacts
        List<SObject> contactsAsSObjects = UM002_TestDataFactory.createSObjectList('Contact', 20, new Map<String, Object>{'AccountId' => accountList});
        insert contactsAsSObjects;

        Id acctId = accountList[0].Id;
        list<Contact> contactCount = [select id from contact where accountId = : acctId ]; 
        system.assertEquals(4, contactCount.size());
    }

}