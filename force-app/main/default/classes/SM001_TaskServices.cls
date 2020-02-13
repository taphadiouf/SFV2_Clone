/**
   * @author Hanae Makboub
   * @date 11/02/2020
    * @set the staus of leads to "En cours" whenever a task is created and the old status is new by 
    */

public with sharing class SM001_TaskServices {
    public static List<Task> LEAD_RG03_IS250(list<Task> newTasksList) {
        
        set<Id> setLeadIds = new set<Id> ();

        for(Task ta:newTasksList){
            setLeadIds.add(ta.WhoId);
        }
        List<Lead> listLead = new List<Lead>([SELECT Id, Status,RecordType.Name 
                                    FROM Lead 
                                    WHERE Id In :setLeadIds 
                                    AND RecordType.Name='Famille' 
                                    AND Status ='Nouveau']);
        for(Lead le: listLead){
            le.status ='En Cours';
        }
        update listLead;
        }

}
        