/**
* @author Achraf ABOUL
* @created 25/02/2020
* @description Trigger actions on Contract Object
*/
trigger ContractTrigger on Contract (before update) {
    new TM005_ContractTrigger().run();
}