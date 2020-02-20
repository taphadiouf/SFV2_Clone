/**
   * @author Hanae Makboub
   * @date 11/02/2020
    * @SOQL Query to get leads by ID
    */
public with sharing class EM002_LeadEntity {
    public static List<Lead> getLeadByListId(set<Id> setLeadIds) {
        return [SELECT Id, Status,RecordType.Name ,LPCR_DatePriseEnChargeCommercial__c
                                FROM Lead 
                                WHERE Id In :setLeadIds 
                                AND RecordType.Name='Famille' 
                                AND Status ='Nouveau'];
    }

}
