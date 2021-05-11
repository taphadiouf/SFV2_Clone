@isTest
public class SM024_ContactServices_Test {
    @isTest
    static void SM024_ContactServices_Test() {

        Id entrepriseRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Entreprise);
        Id FamilleRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Famille);

        //Positive Case : Acc RT == Entreprise
        Account  acc1 = new Account(Name = 'name1z',recordtypeid=entrepriseRecTypeId,LPCR_PASDESIRET__C=true);
        insert acc1;
        Contact c1 = new Contact(    FirstName = 'firstname',
                                    Lastname = 'lastname',
                                    AccountId = acc1.id,
                                    Email = 'last@gmail.com',
                                    LPCR_ContactAEnvoyer__c = false);
        
        //Negative Case : Acc RT != Entreprise
        Account  acc2 = new Account(Name = 'name1z',recordtypeid=FamilleRecTypeId);
        insert acc2;
        Contact c2 = new Contact(    FirstName = 'first',
                                    Lastname = 'last',
                                    AccountId = acc2.id,
                                    Email = 'second@gmail.com',
                                    LPCR_ContactAEnvoyer__c = false);
   
        //Contacts should not be inserted (method : prepareContactsToBeSent act before inserting a contact)
        List<Contact> contacts =  new List<Contact>{c1,c2};
        SM024_ContactServices.prepareContactsToBeSent(contacts);
        // Only Contacts that have entreprise account should be prepared to be sent.
        System.assertEquals(c1.LPCR_ContactAEnvoyer__c, true);
        System.assertEquals(c2.LPCR_ContactAEnvoyer__c, false);

    }
}