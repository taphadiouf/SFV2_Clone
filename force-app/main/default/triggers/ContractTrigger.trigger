trigger ContractTrigger on Contract (before insert) {
    new TM009_ContractTrigger().run();
}