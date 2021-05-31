/**
* @author Houssam ADIB
* @created 26/11/2020
* @description Service class for Contact Object
*/

public with sharing class SM024_ContactServices {
    
    public static void prepareContactsToBeSent(List<Contact> contacts){
        
        //Gather Entreprise accounts of the contacts
        Id entrepriseRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Entreprise);
        Set<Id> accountIds = new Set<Id>();
        for(Contact c : contacts){
            accountIds.add(c.AccountId);
        }
        List<Account> accounts = [SELECT id,RecordTypeid FROM Account WHERE id IN :accountIds AND RecordTypeId=:entrepriseRecTypeId];
        
        // Filter the contacts and only send those who have entreprise account (selection above)
        List<Contact> fitlredContacts = new List<Contact>();
        for (Contact c : contacts){
            for(Account a : accounts){
                if(c.AccountId == a.id){
                    c.LPCR_ContactAEnvoyer__c = true;
                    break;
                }
            }
        }
    }

    public static void sendContacts(List<Contact> contacts) {
        SM025_SendContact_Callout.sendContactsCallout();
    }
    //method to initialise variable on lead conversion to synch record types
    public static void initialiseVariableLeadConversion(Map<Id, Contact> newContactsMap){
        SM007_LeadServices.contactsIds = new Set<Id>(newContactsMap.keySet());
    }
}
