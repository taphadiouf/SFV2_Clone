@isTest
public with sharing class EM005_AccountEntity_Test {
    @isTest
    static void EM005_AccountEntity_Test() {

        EM005_AccountEntity ent = new EM005_AccountEntity();
        System.assertEquals('EM005_AccountEntity', ent.getDataManagerClassName());
        System.assertEquals('Account', ent.getObjectName());

        Account acc = UM002_TestDataFactory.createAccount('test');
        insert acc;
        List<Account> res = EM005_AccountEntity.getAccsByIds(new Set<Id>{acc.id});
        System.assertEquals(1, res.size());
        
    }
}