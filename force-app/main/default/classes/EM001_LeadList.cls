/**
   * @author Hanae Makboub
   * @date 11/02/2020
    * @description Process the Task in parameters
    */
public with sharing class EM001_LeadList {
    public static List<Lead> getNewLead() {
        List<Lead> pisteList = new List<Lead>([Select Id, Status from Lead Where Id In :Trigger.Old and Status='Nouveau']);
    }
}
