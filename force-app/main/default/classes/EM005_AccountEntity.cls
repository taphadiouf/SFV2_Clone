/**
* @author Achraf ABOUL
* @date 25/02/2020
* @SOQL Queries about Account
*/
public with sharing class EM005_AccountEntity extends DM000_SObject{
    
    @TestVisible
    protected override String getDataManagerClassName() {
        return EM005_AccountEntity.class.getName();
    }
    
    
    @TestVisible
    protected override String getObjectName() {
        return Schema.sObjectType.Account.name;
    }
    public EM005_AccountEntity(){
        super('Account');
    }
    public static List<Account> getAccsByIds(Set<Id> accsIds){
        return [SELECT Id FROM Account WHERE Id IN :accsIds];
    }
   
}