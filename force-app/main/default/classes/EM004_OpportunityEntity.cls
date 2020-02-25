/**
* @author Achraf ABOUL
* @date 25/02/2020
* @SOQL Queries about Opportunity
*/
public class EM004_OpportunityEntity {

    public static List<Opportunity> getOppsByIds(Set<Id> oppsIds){
        return [SELECT Id FROM Opportunity WHERE Id IN :oppsIds];
    }
}