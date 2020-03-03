public with sharing class EM005_AccountEntity {
    public static Account getAccountsById() {
        return [SELECT Id FROM Account Limit 1];
                
    }
}