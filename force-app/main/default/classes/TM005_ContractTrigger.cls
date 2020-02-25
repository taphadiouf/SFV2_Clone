/**
* @author Achraf ABOUL
* @created 25/02/2020
* @description Trigger action handler on Contract Object
*/
public class TM005_ContractTrigger extends TM000_TriggerHandler{
    
    private Map<Id, Contract> newContractsMap;
    private Map<Id, Contract> oldContractsMap;
    private List<Contract> newContractsList;
    
    public TM005_ContractTrigger() {
        this.newContractsMap = (Map<Id, Contract>) Trigger.newMap;
        this.oldContractsMap = (Map<Id, Contract>) Trigger.oldMap;
        this.newContractsList = (List<Contract>) Trigger.new;
    }
    protected override void beforeUpdate() {
        if (PAD.canTrigger('SM001_TestIfByPassed')) SM001_TestIfByPassed.executeMethod();
        SM005_ContractServices.syncAccountsOnContracts(this.newContractsMap);
        SM005_ContractServices.syncOpportunitiesOnContracts(this.newContractsMap);
    }
}