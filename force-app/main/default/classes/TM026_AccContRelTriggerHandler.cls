/**
 * @author PRA
 * @created 11/11/2021
 * @description Trigger action handler on AccountContactRelation Object
 */
public with sharing class TM026_AccContRelTriggerHandler extends TM000_TriggerHandler{
    private Map<Id, AccountContactRelation> newAccountContactRelationsMap;
    private Map<Id, AccountContactRelation> oldAccountContactRelationsMap;
    private List<AccountContactRelation> newAccountContactRelationsList;

    public TM026_AccContRelTriggerHandler() {
        newAccountContactRelationsMap = (Map<Id, AccountContactRelation>) Trigger.newMap;
        oldAccountContactRelationsMap = (Map<Id, AccountContactRelation>) Trigger.oldMap;
        newAccountContactRelationsList = (List<AccountContactRelation>) Trigger.new;
    }

    
    protected override void beforeInsert() {

        if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex')){
            SM032_AccountContactRelationService.setIdSalesforceAccountContact(newAccountContactRelationsList);
        }
    }
}