trigger ContractTrigger on Contract (before insert,before update,after update) {
    new TM009_ContractTrigger().run();
}