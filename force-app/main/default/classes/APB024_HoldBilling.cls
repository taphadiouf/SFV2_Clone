global with sharing class APB024_HoldBilling implements Database.Batchable<sObject>,Database.AllowsCallouts,Schedulable{
    String query;
    final String ClassName = APB023_CreateIndexationAmendment.class.getName();
    global APB024_HoldBilling() {
        
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {

        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'start', 'Batch' , null, 'Starting Batch', UM010_Constant.SUCCESS);
        //select Contract for which amendement indexation needs to be created
        return Database.getQueryLocator([Select id ,LPCR_IndexationConvenue__c,LPCR_DateRevisionPrix__c,LPCR_InitAutoAvecDateDebut__c,SBQQ__RenewalUpliftRate__c,SBQQ__Order__c From Contract where  LPCR_DateRevisionPrix__c=TODAY and LPCR_IndexationConvenue__c='Non' and SBQQ__RenewalUpliftRate__c=null] );
                                        
    }
    public void execute(Database.BatchableContext BC, list<Contract> scope){
        List<Id> lstOrderId=new List<Id>();
        List<OrderItem> lstOrderItemUpdt=new List<OrderItem>();
        for(Contract con : scope){ 
            lstOrderId.add(con.SBQQ__Order__c);
            
        }
        for(OrderItem orderitem : [SELECT Id ,OrderId FROM OrderItem where OrderId IN:lstOrderId]){
            orderitem.blng__HoldBilling__c ='Yes';
            lstOrderItemUpdt.add(orderitem );
        }
          
        if(lstOrderItemUpdt.size() > 0){
            update lstOrderItemUpdt;
        }
        //indexation pas convenue , order item ( hold billing blng__HoldBilling__c on OrderItem):another batch 
        
        
        
    }
    public void finish(Database.BatchableContext BC){
        
    }
    global void execute(SchedulableContext sc) {
    }
}
