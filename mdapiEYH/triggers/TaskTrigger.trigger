/**
 * @author Hanae Makboub
 * @created 11/02/2020
 * @description Trigger actions on Task Object
 */
trigger TaskTrigger on Task (after insert) {
    //The handler will manage all the processes
	new TM003_TaskTrigger().run();
}