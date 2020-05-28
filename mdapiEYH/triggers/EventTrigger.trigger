/**
 * @author Hanae Makboub
 * @created 12/02/2020
 * @description Trigger actions on Task Object
 */
trigger EventTrigger on Event (after insert) {
    //The handler will manage all the processes
	new TM002_EventTrigger().run();
}