/**
* @author Achraf ABOUL
* @date 28/02/2020
* @SOQL Queries about Opportunity
*/
public class EM004_OpportunityEntity {
    
    public static List<Opportunity> getOppsByIds(Set<Id> oppsIds) {
        return [SELECT Id, RecordTypeId FROM Opportunity WHERE Id IN :oppsIds];
    }
}