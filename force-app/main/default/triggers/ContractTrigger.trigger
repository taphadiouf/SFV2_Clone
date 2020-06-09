trigger ContractTrigger on Contract (before insert, after update) {
    new TM009_ContractTrigger().run();
}