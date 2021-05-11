/**
* @author Achraf ABOUL
* @date 24/03/2020
* @SOQL  Entity layer for Contact
*/
public with sharing class EM011_ContactEntity extends DM000_SObject{
    
    @TestVisible
    protected override String getDataManagerClassName() {
        return EM011_ContactEntity.class.getName();
    }
    
    
    @TestVisible
    protected override String getObjectName() {
        return Schema.sObjectType.Contact.name;
    }
    public EM011_ContactEntity(){
        super('Contact');
    }
}