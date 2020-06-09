trigger ContractTrigger on Contract (before insert,before update) {
    new TM009_ContractTrigger().run();
}