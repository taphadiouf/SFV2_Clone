/**
* @author Fowdar Akshaye
* @created 02/06/2020
* @description Trigger actions on Order Object
*/
trigger OrderTrigger on Order (before insert) {
    //The handler will manage all the processes
    new TM013_OrderTrigger().run();
}