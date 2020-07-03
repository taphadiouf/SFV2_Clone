/**
* @author Saurabh
* @created 30/06/2020
* @description Trigger actions on Attachment Object
*/
trigger AttachmentTrigger on Attachment (after insert) {
	new TM015_AttachmentTrigger().run();
}