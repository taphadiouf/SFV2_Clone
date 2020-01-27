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

}