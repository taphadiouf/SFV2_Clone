/**
 * @author Hanae Makboub
 * @created 12/02/2020
 * @description Trigger action handler on Event Object
 */

public with sharing class TM002_EventTrigger extends TM000_TriggerHandler{

    private Map<Id, Event> newEventsMap;
    private Map<Id, Event> oldEventsMap;
    private List<Event> newEventsList;

    public TM002_EventTrigger() {
        newEventsMap = (Map<Id, Event>) Trigger.newMap;
        oldEventsMap = (Map<Id, Event>) Trigger.oldMap;
        newEventsList = (List<Event>) Trigger.new;
    }

    protected override void afterInsert() {

        if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex')){
            SM002_EventServices.updateLeadsWithNewEvents(newEventsList);
        }
    }
}
