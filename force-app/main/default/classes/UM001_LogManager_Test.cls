/**
 * @author Erwan Yhuellou
 * @created 26/01/2020
 * @description Covering UM001_LogManager Class
 */
 @isTest
private class UM001_LogManager_Test {

    @testSetup static void setup() {
        
        // Create common test accounts
        UM002_TestDataFactory tdf = new UM002_TestDataFactory();
        Account a = tdf.AccountTdf.create('Account Test');
        insert a;
    }

    static testMethod void validatePAD() {

        Account tmp = [Select Id, Name from Account where name like 'Account Test'];
        UM001_LogManager.writeLogActivity('Test Log', 'BR Insert', '', tmp.Id, 'Fake BR Logged', 'Success');

        // Assert cannot be placed as UM001_LogManager.writeLogActivity is a futur method

        
    }

}