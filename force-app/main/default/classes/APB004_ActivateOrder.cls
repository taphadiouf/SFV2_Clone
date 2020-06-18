/**
* @author Ayoub Ouarti
* @date 18/03/2020
* @Description Batch for Activating the order
*/
global class APB004_ActivateOrder  implements Database.Batchable<sObject>,Schedulable {
    String query;
    
    global APB004_ActivateOrder() {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        query = 'SELECT Id,Status FROM Order WHERE Status =\'Draft\'';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Order> scope) {
        System.debug('scope to execute : '+scope);
        
        Set<Id> orderIds = UM003_TypeManager.getIdsOfListObjects(scope);
        List<Order> listOforder = [SELECT Id,Status FROM Order WHERE Id in :orderIds ];   
        for (Order eachOrder : listOforder) {
            eachOrder.status ='Activated';
            System.debug('Updating order '+eachOrder.status );
        }
        
        update listOforder;    

        Set<Id> orderItemId = UM003_TypeManager.getIdsOfListObjects(listOforder);
        Integer typeMensualisation = 11;
        String billingFrequency = 'Invoice Plan';
        Map<Id,OrderItem> orderItemMap = new Map<Id,OrderItem>([SELECT Id,OrderItemNumber,LPCR_Creche__r.LPCR_TypeMensualisation__c,
        SBQQ__BillingFrequency__c,TotalPrice,ServiceDate,EndDate FROM OrderItem 
        WHERE LPCR_Creche__r.LPCR_TypeMensualisation__c =:typeMensualisation
        AND  SBQQ__BillingFrequency__c = :billingFrequency
        AND Activated ='Yes'] );
    

        List<blng__BillingSchedule__c> listOfBillingSchedule = new List<blng__BillingSchedule__c>();
        List<blng__BillingTransaction__c> listOfBillingTransaction = new List<blng__BillingTransaction__c>();

        for( OrderItem eachOrderItem : orderItemMap.values()){

            blng__BillingSchedule__c billingSchedule = new blng__BillingSchedule__c(Name ='BS-'+eachOrderItem.OrderItemNumber ,
                                                                            blng_Amount_c=eachOrderItem.TotalPrice,
                                                                            blng_OrderProduct_c=eachOrderItem.Id);
            listOfBillingSchedule.add(billingSchedule);
           }
           insert listOfBillingSchedule;
           for(blng__BillingSchedule__c eachBS : listOfBillingSchedule){
            // insert the Billing Transactions
            Date startDate = orderItemMap.get(eachBS.blng_OrderProduct_c).ServiceDate;
            Date endDate = orderItemMap.get(eachBS.blng_OrderProduct_c).EndDate;
            Integer monthsBetween = startDate.monthsBetween(endDate);
            monthsBetween=endDate.day() > startDate.day()? ++monthsBetween:monthsBetween;

            Integer StartDateMonth = orderItemMap.get(eachBS.blng_OrderProduct_c).ServiceDate.month();
            if(StartDateMonth != 8) {
            for(integer i =1;i <= monthsBetween;i++) {
                blng__BillingTransaction__c billingTransaction =new blng__BillingTransaction__c(
                                                            blng__BillingSchedule__c=eachBS.Id,
                                                            blng_Amount_c =orderItemMap.get(eachBS.blng_OrderProduct_c).TotalPrice,
                                                            Name = +StartDateMonth,
                                                            blng_Status_c ='Pending',
                                                            blng__BillingTargetDate__c= (i==1 && orderItemMap.get(eachBS.blng_OrderProduct_c).ServiceDate.day() > 5)? Date.newInstance(5,StartDateMonth+1,Date.today().Year()):Date.newInstance(5,StartDateMonth,Date.today().Year()),
                                                            blng_Quantity_c = 1,
                                                            blng__ServicePeriodStart__c=(i==1 && blng_ServicePeriodStart_c == null)? orderItemMap.get(eachBS.blng_OrderProduct_c).ServiceDate : Date.newInstance(1,StartDateMonth,Date.today().Year()),
                                                            blng__ServicePeriodEnd__c= UM005_DateUtility.lastDateOfMonth(StartDateMonth));

            listOfBillingTransaction.add(billingTransaction);
            }
            StartDateMonth++;

        } 
        
    }
    insert listOfBillingTransaction;


    }
    
    global void finish(Database.BatchableContext BC) {
    }
    
    global void execute(SchedulableContext sc) {
        
        APB004_ActivateOrder sc1 = new APB004_ActivateOrder();
        
        // schedule the apex class only if their is not existing job running
        boolean isBatchJobRunning = UM004_BatchUtility.isBatchJobRunning('APB003_CreateOrderFromorder');
        
        // check if there is any open place to schedule the class
        boolean isJobQueueFull = UM004_BatchUtility.isBatchJobQueueFull();
        
        if(isBatchJobRunning == UM004_BatchUtility.BOOLEAN_FALSE){
            if (isJobQueueFull == UM004_BatchUtility.BOOLEAN_FALSE) {
                sc1 = new APB004_ActivateOrder();
                Database.executeBatch(this, 1);
            } else {
                //schedule this same schedulable class again in 30 mins
                sc1 = new APB004_ActivateOrder();
                Datetime dt = Datetime.now().addMinutes(30);  // i.e. 30 mins
                String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
                Id schedId = System.Schedule('APB004_ActivateOrder'+timeForScheduler,timeForScheduler,sc1);
            }
        }  
        
    } 
}