/**
* @author Ayoub Ouarti
* @date 25/02/2020
* @Description Queries about Opportunity
*/
public with sharing class EM004_OpportunityEntity {

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