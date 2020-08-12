/**
* @author Hanae Makboub
* @date 11/02/2020
* @set the staus of leads to "En cours"  whenever a task is created and the old status is new by 
* @set the  LPCR_DatePriseEnChargeCommercial__c in the releated Lead to today  whenever a task is created
**/

public with sharing class SM003_TaskServices {
    public static List<Lead> updateLeadsWithNewTasks(list<Task> newTasksList) {
        
        set<Id> setLeadIds = new set<Id> ();
        
        for(Task eachTask:newTasksList){
            setLeadIds.add(eachTask.WhoId);
        }
        
        List<Lead> listLeadNouveau = EM002_LeadEntity.getLeadsByIdsAndStatus(setLeadIds, System.Label.LPCR_Nouveau);
        if(UM003_TypeManager.isNotNullAndNotEmpty(listLeadNouveau)){
        	for(Lead le: listLeadNouveau){
            	le.status = Label.LPCR_EnCours;
                if(Label.LPCR_Famille.equals(le.RecordType.DeveloperName)){
                    le.LPCR_DatePriseEnChargeCommercial__c=Date.today();
                }
            }
            update listLeadNouveau;
        }
        
        /*List<Lead> listLead = EM002_LeadEntity.getLeadsBy(setLeadIds,System.Label.LPCR_Famille); commented in the context of bug/IS-1294
        if(UM003_TypeManager.isNotNullAndNotEmpty(listLead)){
            for(Lead eachLead: listLead){
                if(Label.LPCR_Nouveau.equals(eachLead.status)){
                    eachLead.status =Label.LPCR_EnCours;
                }
                eachLead.LPCR_DatePriseEnChargeCommercial__c=Date.today();
            }
            update listLead;
        }
        */
        return listLeadNouveau;
    }
    
}