/**
* @author Achraf ABOUL
* @date 25/02/2020
* @description SOQL Queries about Opportunity
*/
public with sharing class EM004_OpportunityEntity extends DM000_SObject{
    
    @TestVisible
    protected override String getDataManagerClassName() {
        return EM004_OpportunityEntity.class.getName();
    }
    
    @TestVisible
    protected override String getObjectName() {
        return Schema.sObjectType.Opportunity.name;
    }

    public EM004_OpportunityEntity(){
        super('Opportunity');
    }
    
    public static List<Opportunity> getOppsByIds(Set<Id> oppsIds) {
        return [SELECT Id, RecordTypeId FROM Opportunity WHERE Id IN :oppsIds];
    }

    public static List<Opportunity> saveOrUpdte(List<Opportunity> oppties){
        if(UM003_TypeManager.isNotNullAndNotEmpty(oppties) ){
            upsert oppties;
        }
        return  oppties; 
    }

    public static Opportunity saveOrUpdte(Opportunity oppty){
        if(UM003_TypeManager.isNotNull(oppty)){
            upsert oppty;
        }
        return  oppty; 
    }

}


