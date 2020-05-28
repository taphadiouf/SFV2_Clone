/**
* @author Hanae Makboub
* @date 12/02/2020
* @set the staus of leads to "En cours" whenever an Event is created and the old status is new 
*/

public with sharing class SM002_EventServices {
    public static List<Lead> LEAD_RG03_IS250(list<Event> newEventsList) {
        
        set<Id> setLeadIds = new set<Id> ();
        
        for(Event ta:newEventsList){
            setLeadIds.add(ta.WhoId);
        }
        List<Lead> listLead = EM002_LeadEntity.getLeadsBy(setLeadIds,System.Label.LPCR_Famille,System.Label.LPCR_Nouveau);
        for(Lead le: listLead){
            le.status =Label.LPCR_EnCours;
        }
        update listLead;
        return listLead;
    }
    
}