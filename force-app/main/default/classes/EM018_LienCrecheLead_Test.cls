@isTest
public class EM018_LienCrecheLead_Test {
    @isTest
    static void EM018_LienCrecheLead_Test() {
        EM018_LienCrecheLead lc = new EM018_LienCrecheLead();
        System.assertEquals('LPCR_LienCrecheLead__c',lc.getObjectName());
        System.assertEquals('EM018_LienCrecheLead',lc.getDataManagerClassName());
    }
}