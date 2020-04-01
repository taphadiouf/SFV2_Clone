/**
 * @author Achraf ABOUL
 * @created 26/02/2020
 * @description Trigger actions on Lead Object
 */
trigger LeadTrigger on Lead (before update, after insert) {
    new TM007_LeadTrigger().run();	
}