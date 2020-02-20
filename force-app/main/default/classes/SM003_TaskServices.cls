/**
   * @author Hanae Makboub
   * @date 11/02/2020
   * @set the staus of leads to "En cours"  whenever a task is created and the old status is new by 
    +@set the  LPCR_DatePriseEnChargeCommercial__c in the releated Lead to today  whenever a task is created
*/

public with sharing class SM003_TaskServices {
    public static List<Lead> LEAD_RG03_IS250(list<Task> newTasksList) {
        
        set<Id> setLeadIds = new set<Id> ();

        for(Task eachTask:newTasksList){
            setLeadIds.add(eachTask.WhoId);
        }
        List<Lead> listLead = EM002_LeadEntity.getLeadByListId(setLeadIds);
        if(UM003_ListManager.isNotNullAndNotEmpty(listLead)){
            for(Lead eachLead: listLead){
            eachLead.status ='En cours';
            eachLead.LPCR_DatePriseEnChargeCommercial__c=Date.today();
        }
        update listLead;
        }
        
        return listLead;
        }

}