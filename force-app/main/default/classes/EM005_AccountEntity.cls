/**
* @author Achraf ABOUL
* @date 25/02/2020
* @SOQL Queries about Account
*/
public with sharing class EM005_AccountEntity {
    public static List<Account> getAccsByIds(Set<Id> accsIds){
        return [SELECT Id FROM Account WHERE Id IN :accsIds];
    }
}