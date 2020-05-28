/**
 * @author Erwan Yhuellou
 * @created 13/01/2020
 * @description Trigger actions on Account Object
 */
trigger AccountTrigger on Account ( before insert, after insert,
									before update, after update,
									before delete, after delete ) {
	//The handler will manage all the processes
	new TM001_AccountTriggerHandler().run();
}