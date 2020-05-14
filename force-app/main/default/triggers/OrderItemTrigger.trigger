/**
* @author Ayoub Ouarti
* @created 26/03/2020
* @description Trigger actions on OrderItem Object
*/
trigger OrderItemTrigger on OrderItem (before insert, after insert, before update, after update) {
  
    new TM011_OrderItemTrigger().run();

}