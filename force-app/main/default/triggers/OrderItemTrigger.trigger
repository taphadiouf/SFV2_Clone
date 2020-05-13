/**
* @author Ayoub Ouarti
* @created 26/03/2020
* @description Trigger actions on OrderItem Object
*/
trigger OrderItemTrigger on OrderItem (after insert,after update, before update) {
  
    new TM011_OrderItemTrigger().run();

}