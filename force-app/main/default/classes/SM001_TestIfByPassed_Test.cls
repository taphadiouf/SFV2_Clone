/**
 * @author Erwan Yhuellou
 * @created 26/01/2020
 * @description Covering SM001_TestIfByPassed Class
 */
 @isTest
private class SM001_TestIfByPassed_Test {

    @testSetup static void setup() {
        
        // Create common test accounts
        UM002_TestDataFactory tdf = new UM002_TestDataFactory();
        Account a = tdf.AccountTdf.create('Account Test');
        insert a;
    }

    static testMethod void validatePAD() {

        Account tmp = [Select Id, Name from Account where name like 'Account Test'];
        System.AssertNotEquals(tmp, null, 'Account not created');

        tmp.Name = 'Modified';
        update tmp;
        tmp = [Select Id, Name from Account where name like 'Modified'];
        System.AssertNotEquals(tmp, null, 'Account not updated');

        delete tmp;
        List<Account> tmpList = [Select Id, Name from Account where name like 'Modified'];
        System.AssertEquals(tmpList.size(), 0, 'Account should be deleted');
        
        SM001_TestIfByPassed.executeMethod();
    }

}