/**
* @author Achraf ABOUL
* @created 26/03/2020
* @description Trigger actions on Contact Object
*/
trigger ContactTrigger on Contact (after insert) {

    new TM005_ContactTrigger().run();
}