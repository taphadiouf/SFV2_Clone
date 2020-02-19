/**
   * @author Hanae Makboub
   * @date 11/02/2020
    * @set the staus of leads to "En cours" whenever a task is created and the old status is new by 
    */

public with sharing class SM003_TaskServices {
    public static List<Lead> LEAD_RG03_IS250(list<Task> newTasksList) {
        
        set<Id> setLeadIds = new set<Id> ();

        for(Task ta:newTasksList){
            setLeadIds.add(ta.WhoId);
        }
        List<Lead> listLead = EM002_LeadEntity.getLeadByListId(setLeadIds);
        for(Lead le: listLead){
            le.status ='En cours';
        }
        update listLead;
        return listLead;
        }

}