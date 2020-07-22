public with sharing class EM018_LienCrecheLead extends DM000_SObject {
    @TestVisible
    protected override String getDataManagerClassName() {
        return EM018_LienCrecheLead.class.getName();
    }

   
    @TestVisible
    protected override String getObjectName() {
        return Schema.sObjectType.LPCR_LienCrecheLead__c.name;
    }
   	public EM018_LienCrecheLead(){
        super('LPCR_LienCrecheLead__c');
    }
}