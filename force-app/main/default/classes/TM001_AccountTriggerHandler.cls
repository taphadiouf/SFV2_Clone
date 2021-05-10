/**
 * @author Erwan Yhuelllou
 * @created 13/01/2020
 * @description Trigger action handler on Account Object
 */
public without sharing class TM001_AccountTriggerHandler extends TM000_TriggerHandler {

    private Map<Id, Account> newAccountsMap;
    private Map<Id, Account> oldAccountsMap;
    private List<Account> newAccountsList;

    public TM001_AccountTriggerHandler() {
        newAccountsMap = (Map<Id, Account>) Trigger.newMap;
        oldAccountsMap = (Map<Id, Account>) Trigger.oldMap;
        newAccountsList = (List<Account>) Trigger.new;
    }
    
    protected override void afterInsert() {

        if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex')){
            SM029_AccountService.defautCounterCTNum(newAccountsMap);
        }
    }
    
}