/**
 * @author PRA
 * @created 11/11/2021
 * @description Trigger actions on AccountContactRelation Object
 */
trigger AccountContactRelationTrigger on AccountContactRelation (before insert, after insert,before update, after update,before delete, after delete ) {
    //The handler will manage all the processes
    if(!PAD.byPassTriggerAccContRel){
        new TM026_AccContRelTriggerHandler().run();
    }
}