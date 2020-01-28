/**
 * @author Erwan Yhuellou
 * @created 26/01/2020
 * @description Covering PAD Class
 */
 @isTest
private class PAD_Test {

    @testSetup static void setup() {
        
        // init data
    }

    static testMethod void validatePAD() {

        PAD.log('PAD_Test', 'validatePAD', 'starting test method'); 
        
        System.AssertEquals(PAD.canTrigger('SM001_TestIfByPassed'), true, 'User can by Pass SM001_TestIfByPassed');
        
        PAD.log('PAD_Test', 'validatePAD', 'starting test method', 'ok');

        UM002_TestDataFactory tdf = new UM002_TestDataFactory();
        Account a = tdf.AccountTdf.create('Account Test');
        PAD.log('PAD_Test', 'validatePAD', 'a:' , (SObject)a);
        
        PAD.limits();
        
    }

}