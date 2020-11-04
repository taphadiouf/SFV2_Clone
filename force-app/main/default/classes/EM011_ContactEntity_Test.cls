@isTest
public with sharing class EM011_ContactEntity_Test {
    @isTest
    public static void test() {
        EM011_ContactEntity contactEntity = new EM011_ContactEntity();
        system.assertEquals('Contact', contactEntity.getObjectName());
        system.assertEquals('EM011_ContactEntity', contactEntity.getDataManagerClassName());
    }
}
