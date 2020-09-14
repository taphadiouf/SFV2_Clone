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
        if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex')){
            SM010_ContractServices.setContractFields(newContractList);
        }
    }
    
    protected override void afterInsert() {
        if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex')){ 
           SM010_ContractServices.afterInsertUpdateContractFields(newContractList);
        }
    }

    protected override void beforeUpdate() {
        if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex')){
            SM010_ContractServices.setContractFields(oldContractMap,newContractMap);
        }
    }

    protected override void afterUpdate(){
        if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex')){
            SM010_ContractServices.setOrderFields(this.newContractMap,this.oldContractMap);
            SM010_ContractServices.setOrderItemFields(this.newContractMap,this.oldContractMap);
        }
    }
}