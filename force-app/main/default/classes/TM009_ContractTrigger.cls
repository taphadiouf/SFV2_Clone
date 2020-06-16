/**
* @author Ayoub Ouarti
* @created 23/03/2020
* @description Trigger  handler on Contract Object
*/
public class TM009_ContractTrigger extends TM000_TriggerHandler{
    private Map<Id, Contract> newContractMap;
    private Map<Id, Contract> oldContractMap;
    private List<Contract> newContractList;
    
    public TM009_ContractTrigger() {
        this.newContractMap = (Map<Id, Contract>) Trigger.newMap;
        this.oldContractMap = (Map<Id, Contract>) Trigger.oldMap;
        this.newContractList = (List<Contract>) Trigger.new;
    }
   
    protected override void beforeInsert() {
        if (PAD.canTrigger('SM001_TestIfByPassed')) SM001_TestIfByPassed.executeMethod();
        SM010_ContractServices.setContractFields(newContractList);
        SM010_ContractServices.setTypeEnregistrement(newContractList);
    }
     
     
    protected override void beforeUpdate() {
        if (PAD.canTrigger('SM001_TestIfByPassed')) SM001_TestIfByPassed.executeMethod();
        SM010_ContractServices.setContractFields(oldContractMap,newContractMap);
    }
    //added by Akshaye
    protected override void afterUpdate(){
        if (PAD.canTrigger('SM001_TestIfByPassed')) SM001_TestIfByPassed.executeMethod();
        SM010_ContractServices.setOrderFields(this.newContractMap,this.oldContractMap);
    }
}