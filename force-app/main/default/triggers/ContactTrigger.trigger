/**
* @author Achraf ABOUL
* @created 26/03/2020
* @description Trigger actions on Contact Object
*/
trigger ContactTrigger on Contact (before insert,after insert) {

    new TM005_ContactTrigger().run();
}