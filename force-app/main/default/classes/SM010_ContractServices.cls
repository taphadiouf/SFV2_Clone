/**
* @author Ayoub Ouarti
* @created 23/03/2020
* @description Service class for Contract Object
* @Updated By Achraf ABOUL(aaboul@salesforce.com) 08/05/2020
*/
public class SM010_ContractServices {
    
    public static void setContractFields(List<Contract> contracts){
        Set<String> quoteIds = UM003_TypeManager.getFieldsOfListObjects(contracts,'SBQQ__Quote__c');
        Set<String> orderIds = UM003_TypeManager.getFieldsOfListObjects(contracts,'SBQQ__Order__c');
        Map<Id,SBQQ__Quote__c> quoteMap = new  Map<Id,SBQQ__Quote__c>([SELECT Id,LPCR_DureeContratJour__c,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c,LPCR_IndexationConvenue__c,LPCR_MasterDevis__c,LPCR_RenouvellementConvenu__c,LPCR_DateDebut__c,LPCR_DateFin__c,LPCR_ChiffreAffaire__c, LPCR_MethodeRenouvellement__c,SBQQ__RenewalUpliftRate__c,LPCR_TypeEntreprise__c, LPCR_ContratEntreprise__c , recordtype.name, LPCR_PlanningEnfant__c  from SBQQ__Quote__c WHERE Id in :quoteIds]);
        Map<Id,Order> orderMap = new  Map<Id,Order>([SELECT id,SBQQ__Quote__c,SBQQ__Quote__r.LPCR_BatchCommande__c from Order WHERE Id in :orderIds]);
        Id B2B_RT_ID = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contrat, Label.LPCR_Contrat_B2B);

        for (Contract eachContract : contracts){
            if(orderMap.containsKey(eachContract.SBQQ__Order__c)){
                if(orderMap.get(eachContract.SBQQ__Order__c).SBQQ__Quote__c != null && orderMap.get(eachContract.SBQQ__Order__c).SBQQ__Quote__r.LPCR_BatchCommande__c != null ){
                    eachContract.LPCR_BatchCommande__c = orderMap.get(eachContract.SBQQ__Order__c).SBQQ__Quote__r.LPCR_BatchCommande__c;
                }
            }

            if(quoteMap.containsKey(eachContract.SBQQ__Quote__c)){
                eachContract.LPCR_IndexationConvenue__c = quoteMap.get(eachContract.SBQQ__Quote__c).LPCR_IndexationConvenue__c;
                
                eachContract.LPCR_TypeFacturation__c = quoteMap.get(eachContract.SBQQ__Quote__c).LPCR_TypeFacturation__c;
                
                eachContract.LPCR_BillingFrequency__c = quoteMap.get(eachContract.SBQQ__Quote__c).SBQQ__BillingFrequency__c;
                
                eachContract.LPCR_MasterDevis__c = quoteMap.get(eachContract.SBQQ__Quote__c).LPCR_MasterDevis__c;
                
                eachContract.LPCR_RenouvellementConvenu__c = quoteMap.get(eachContract.SBQQ__Quote__c).LPCR_RenouvellementConvenu__c;
                
                eachContract.LPCR_DateDebut__c = quoteMap.get(eachContract.SBQQ__Quote__c).LPCR_DateDebut__c;
                
                eachContract.LPCR_DateFin__c = quoteMap.get(eachContract.SBQQ__Quote__c).LPCR_DateFin__c;
                
                eachContract.LPCR_ChiffreAffaire__c = quoteMap.get(eachContract.SBQQ__Quote__c).LPCR_ChiffreAffaire__c;
                
                eachContract.LPCR_PlanningEnfant__c = quoteMap.get(eachContract.SBQQ__Quote__c).LPCR_PlanningEnfant__c;
                
                eachContract.LPCR_MethodeRenouvellement__c = quoteMap.get(eachContract.SBQQ__Quote__c).LPCR_MethodeRenouvellement__c;
                
                eachContract.LPCR_RenouvellementAutomatique__c = quoteMap.get(eachContract.SBQQ__Quote__c).SBQQ__RenewalUpliftRate__c == null ? false : true;
                
                eachContract.LPCR_DureeContratJour__c = quoteMap.get(eachContract.SBQQ__Quote__c).LPCR_DureeContratJour__c;

                if(quoteMap.get(eachContract.SBQQ__Quote__c).recordtype.name == Label.LPCR_Contrat_B2B) {
                    eachContract.LPCR_MasterDevis__c = quoteMap.get(eachContract.SBQQ__Quote__c).LPCR_MasterDevis__c;
                }

                if(quoteMap.get(eachContract.SBQQ__Quote__c).recordtype.name == Label.LPCR_ContratA) {
                    eachContract.LPCR_ContratEntreprise__c = quoteMap.get(eachContract.SBQQ__Quote__c).LPCR_ContratEntreprise__c;
                }
            }
        }
    }

    public static void setOrderFields(Map<Id, Contract> newContractMap, Map<Id, Contract> oldContractMap){
        Map<Id,Contract> contractMap = new Map<Id,Contract>();
        Set<Id> orderIds = new Set<Id>();
        List<Order> orderList = new List<Order>();
        for(Contract eachNewContract : newContractMap.values()){ //get all contracts where LPCR_batchCommande is changed
            if(eachNewContract.LPCR_BatchCommande__c != oldContractMap.get(eachNewContract.Id).LPCR_BatchCommande__c) {
                contractMap.put(eachNewContract.Id, eachNewContract);
            }
        }
        //get order items and create a list of orders to be updated
        for(OrderItem orderItem:[Select id, orderId, SBQQ__Contract__c from orderItem where SBQQ__Contract__c in:contractMap.keyset()]){
            if(!OrderIds.contains(orderItem.OrderId)){
                Order order= new Order(Id = orderItem.OrderId);
                order.blng__InvoiceBatch__c = contractMap.get(orderItem.SBQQ__Contract__c).LPCR_BatchCommande__c;
                orderList.add(order);
            }
        }

        if(orderList.size()>0){
            update orderList;
        }

    }

}