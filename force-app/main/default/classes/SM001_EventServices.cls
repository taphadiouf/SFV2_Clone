/**
   * @author Hanae Makboub
   * @date 12/02/2020
    * @set the staus of leads to "En cours" whenever an Event is created and the old status is new 
    */

public with sharing class SM001_EventServices {
    public static List<Lead> LEAD_RG03_IS250(list<Event> newEventsList) {
        
        set<Id> setLeadIds = new set<Id> ();

        for(Event ta:newEventsList){
            setLeadIds.add(ta.WhoId);
        }
        List<Lead> listLead = new List<Lead>([SELECT Id, Status,RecordType.Name 
                                    FROM Lead 
                                    WHERE Id In :setLeadIds 
                                    AND RecordType.Name='Famille' 
                                    AND Status ='Nouveau']);
        for(Lead le: listLead){
            le.status ='En cours';
        }
        update listLead;
        return listLead;
        }

}