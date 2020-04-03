/**
* @author Achraf ABOUL
* @date 25/02/2020
* @SOQL Queries about Account
*/
public with sharing class EM005_AccountEntity extends EM001_AbstractObjectEntity{
    public EM005_AccountEntity(){
        super('Account');
    }
    public static List<Account> getAccsByIds(Set<Id> accsIds){
        return [SELECT Id FROM Account WHERE Id IN :accsIds];
    }
    public static List<Account> getCrecheAccs(){
        return [SELECT Id,Name,RecordType.Name,LPCR_NombreContrat__c FROM Account WHERE RecordType.Name='Crèche' ];
    }
}