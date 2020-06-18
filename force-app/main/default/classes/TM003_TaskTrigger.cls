/**
 * @author Hanae Makboub
 * @created 11/02/2020
 * @description Trigger action handler on Task Object
 */

public with sharing class TM003_TaskTrigger extends TM000_TriggerHandler{

    private Map<Id, Task> newTasksMap;
    private Map<Id, Task> oldTasksMap;
    private List<Task> newTasksList;

    public TM003_TaskTrigger() {
        newTasksMap = (Map<Id, Task>) Trigger.newMap;
        oldTasksMap = (Map<Id, Task>) Trigger.oldMap;
        newTasksList = (List<Task>) Trigger.new;
    }

    protected override void afterInsert() {

        if (PAD.canTrigger('SM001_TestIfByPassed')) SM001_TestIfByPassed.executeMethod();
        SM003_TaskServices.updateLeadsWithNewTasks(newTasksList);
    }
}
