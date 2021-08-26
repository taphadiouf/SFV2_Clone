public with sharing class APC012_CreateAvoir {

    @AuraEnabled(Cacheable=true)
    public static List<String> getPicklistvalues(){
    
    List<String> lstPicklistValue = new List<String>();
    Schema.DescribeFieldResult describeFieldRslt = LPCR_Avoir__c.LPCR_NatureAvoirFacture__c.getDescribe();
    List<Schema.PicklistEntry> pickListEntries = describeFieldRslt.getPicklistValues();
    
    for(Schema.PicklistEntry eachEntry : pickListEntries ) {
        lstPicklistValue.add(eachEntry.getValue());
    }
   
    return lstPicklistValue;
    
    }

    @AuraEnabled(cacheable=true)
    public static String getLigneFacture(Id invId){
        List<LigneFactureWrapper> ligneFactureWrapperList = new List<LigneFactureWrapper>();
        for( blng__InvoiceLine__c ligneFacture :  [SELECT Id,Name, LPCR_MontantAvoirLigneFacture__c,blng__Invoice__r.LPCR_SocieteFacturante__c,blng__Invoice__r.blng__Account__r.LPCR_IDSage__c,blng__Invoice__r.blng__Order__r.SBQQ__Quote__r.LPCR_SocieteFacturante__r.Name, blng__EndDate__c, blng__StartDate__c  FROM blng__InvoiceLine__c where blng__Invoice__c  =:invId]){
                ligneFactureWrapperList.add(new LigneFactureWrapper(
                    ligneFacture.Id,
                    ligneFacture.Name,    
                    ligneFacture.LPCR_MontantAvoirLigneFacture__c ,ligneFacture.blng__Invoice__r.blng__Order__r.SBQQ__Quote__r.LPCR_SocieteFacturante__r.Name,ligneFacture.blng__Invoice__r.blng__Account__r.LPCR_IDSage__c));
        }
        return JSON.serialize(ligneFactureWrapperList);
    }
    public class LigneFactureWrapper{
        private String recId;
        private String name;
        private Decimal Montant;
        private String socfac;
        private String ctNum;

       
        LigneFactureWrapper(String recId,String name, Decimal Montant,String socfac,String ctNum){
          this.recId = recId;
          this.name = name;
          this.Montant = Montant;
          this.socfac=socfac;
          this.ctNum=ctNum;

        }
    }
    @AuraEnabled 
    public static Map<String,Object>  saveAvoir(String resp){
        String errorMsg='';
        Map<String,Object> mapReturn = new Map<String,Object>();
        List<LPCR_Avoir__c> lstavoirInsert=new List<LPCR_Avoir__c> ();
        List<LPCR_Avoir__c> lstavoirInsertTotal=new List<LPCR_Avoir__c> ();

        List<blng__Invoice__c> lstfacture=new List<blng__Invoice__c> ();

        Date datedebut;
        Date dateFin;
        Boolean applytoAllLines=false;
        Decimal sommePartiel=0;
        Boolean containsAvoirTotal=false;
        Boolean containsAvoirPartiel=false;
        Decimal montantFacture=0;
        Decimal sommePartielCustom=0;
        Map<String,Object> mapSrtr=(Map<String, Object>)JSON.deserializeUntyped(resp);
        applytoAllLines=mapSrtr.containsKey('checkboxApplyAll')?(Boolean)mapSrtr.get('checkboxApplyAll'):false;
        List<Object> lstObj=mapSrtr.containsKey('LineList')?(List<Object>)mapSrtr.get('LineList'):(List<Object>)new List<Object>();
        Id invID=mapSrtr.containsKey('invoiceID')? (ID)mapSrtr.get('invoiceID'):null;
        String typeAvoir=mapSrtr.containsKey('TypeAvoir')? (String)mapSrtr.get('TypeAvoir'):'';
        //get facture details

        for(blng__Invoice__c inv :[SELECT Id,blng__TotalAmount__c FROM blng__Invoice__c where id=:invID] ){
            montantFacture=inv.blng__TotalAmount__c;
        }
        for(LPCR_Avoir__c avoir :[SELECT Id, LPCR_TypeAvoir__c,LPCR_Facture__c,LPCR_Facture__r.blng__TotalAmount__c,LPCR_Montant__c FROM LPCR_Avoir__c where LPCR_Facture__c=:invID ] ){
            
            if(avoir.LPCR_TypeAvoir__c =='Avoir total'){
                containsAvoirTotal=true;
            }
            if(avoir.LPCR_TypeAvoir__c =='Avoir partiel' && avoir.LPCR_Montant__c != null ){
                containsAvoirPartiel=true;
                sommePartiel+=avoir.LPCR_Montant__c ;
            }
        }
        if(containsAvoirTotal && typeAvoir =='Avoir total' ){
            mapReturn.put('errorMessage','contient deja un avoir total');
            return mapReturn;
        }
        if(containsAvoirTotal && typeAvoir =='Avoir partiel' ){
            mapReturn.put('errorMessage','contient deja un avoir total');
            return mapReturn;
        }
        if(containsAvoirPartiel &&   typeAvoir =='Avoir total'){
            mapReturn.put('errorMessage','contient deja un avoir partiel');
            return mapReturn;
        }
        if(mapSrtr.containsKey('datedebut')){
            String dateDebutAvoir=mapSrtr.containsKey('datedebut')?(String)mapSrtr.get('datedebut'):'';
            if(!String.isBlank(dateDebutAvoir)){
                List<String> lstDebut=dateDebutAvoir.split('-');
                datedebut=Date.newInstance(Integer.valueOf(lstDebut[0]),Integer.valueOf(lstDebut[1]),Integer.valueOf(lstDebut[2]));
            }
            
        }
        if(mapSrtr.containsKey('datefin')){
            String dateDebutAvoir=mapSrtr.containsKey('datefin')?(String)mapSrtr.get('datefin'):'';
            if(!String.isBlank(dateDebutAvoir)){
                List<String> lstDebut=dateDebutAvoir.split('-');
                dateFin=Date.newInstance(Integer.valueOf(lstDebut[0]),Integer.valueOf(lstDebut[1]),Integer.valueOf(lstDebut[2]));
            }
        }
        //if not apply to all lines 
        
        if(!applytoAllLines && typeAvoir=='Avoir partiel'){
            for(Object obj : lstObj){
                Map<String,Object> mapObjet=(Map<String,Object>)obj;
                if(mapSrtr.containsKey('avoirmontant')){
                sommePartielCustom+=Decimal.valueof((string)mapSrtr.get('avoirmontant'));
                }

                LPCR_Avoir__c avoir=new LPCR_Avoir__c(LPCR_Facture__c=mapSrtr.containsKey('invoiceID')?(ID)mapSrtr.get('invoiceID'):null,LPCR_DateFacture__c=datedebut,LPCR_DateFinAvoir__c=dateFin,LPCR_Description__c=mapSrtr.containsKey('descavoir')?(String)mapSrtr.get('descavoir'):'',LPCR_Montant__c=mapSrtr.containsKey('avoirmontant')?Decimal.valueof((string)mapSrtr.get('avoirmontant')):0,LPCR_LigneFacture__c=(Id)mapObjet.get('recId'),LPCR_TypeAvoir__c =(String)mapSrtr.get('TypeAvoir'),LPCR_NatureAvoirFacture__c =mapSrtr.containsKey('NatureAvoir')?(String)mapSrtr.get('NatureAvoir'):null);

        
                if(typeAvoir=='Avoir partiel'){
                    lstavoirInsert.add(avoir);
                }
            }
        }
        if(applytoAllLines || typeAvoir=='Avoir total' ){
            //lop in all lignes factures 
            for(blng__InvoiceLine__c invLine :[SELECT Id, blng__Invoice__c,blng__EndDate__c, blng__StartDate__c,blng__Subtotal__c FROM blng__InvoiceLine__c where blng__Invoice__c=:invID]){
                if(mapSrtr.containsKey('avoirmontant')){
                    sommePartielCustom+=Decimal.valueof((string)mapSrtr.get('avoirmontant'));
                }
                

                LPCR_Avoir__c avoir=new LPCR_Avoir__c(LPCR_Facture__c=mapSrtr.containsKey('invoiceID')?(ID)mapSrtr.get('invoiceID'):null,LPCR_Description__c=mapSrtr.containsKey('descavoir')?(String)mapSrtr.get('descavoir'):'',LPCR_LigneFacture__c=invLine.Id,LPCR_TypeAvoir__c =(String)mapSrtr.get('TypeAvoir'),LPCR_NatureAvoirFacture__c =mapSrtr.containsKey('NatureAvoir')?(String)mapSrtr.get('NatureAvoir'):null);

                if(typeAvoir=='Avoir partiel'){
                    avoir.LPCR_DateFacture__c=datedebut;
                    avoir.LPCR_DateFinAvoir__c=dateFin;
                    avoir.LPCR_Montant__c=Decimal.valueof((string)mapSrtr.get('avoirmontant'));
                    lstavoirInsert.add(avoir);
                }
                if(typeAvoir=='Avoir total'){
                    avoir.LPCR_DateFacture__c=invLine.blng__StartDate__c;
                    avoir.LPCR_DateFinAvoir__c=invLine.blng__EndDate__c;
                    avoir.LPCR_Montant__c=invLine.blng__Subtotal__c > 0 ?invLine.blng__Subtotal__c*-1:invLine.blng__Subtotal__c;
                    lstavoirInsertTotal.add(avoir);
                }
                
            }
        }
        
        if(typeAvoir =='Avoir total'){
            LPCR_Avoir__c avoir=new LPCR_Avoir__c(LPCR_Facture__c=(ID)mapSrtr.get('invoiceID'),LPCR_DateFacture__c=datedebut,LPCR_DateFinAvoir__c=dateFin,LPCR_Description__c=(String)mapSrtr.get('descavoir'),LPCR_Montant__c=montantFacture,LPCR_TypeAvoir__c =(String)mapSrtr.get('TypeAvoir'));
           // lstavoirInsertTotal.add(avoir);
        }
        if((sommePartiel.abs()+sommePartielCustom.abs()) > montantFacture){
            errorMsg='Montant excedant le montant facture';
        }
        if(containsAvoirTotal && lstavoirInsert.size() > 0 ){
             errorMsg='Facture contient deja un avoir total';
        }
        if(containsAvoirPartiel && lstavoirInsertTotal.size() > 0 ){
            errorMsg='Facture contient deja un avoir partiel';
        }
        mapReturn.put('errorMessage',errorMsg);

        //update total field on invoice 
        if(String.isEmpty(errorMsg) && typeAvoir=='Avoir partiel'){
            Decimal totalPartiel=sommePartiel+sommePartielCustom;
            lstfacture.add(new blng__Invoice__c(Id=invID,LPCR_MontantAvoirFacture__c=totalPartiel));
        }
        try{
            if(lstfacture.size() >0 )update lstfacture;

            if(lstavoirInsert.size() > 0 && errorMsg==''  ) insert lstavoirInsert;
            if(lstavoirInsertTotal.size() > 0 && errorMsg==''  ) insert lstavoirInsertTotal;
        }catch(DmlException e) {
            mapReturn.put('errorMessage',e.getMessage());
            errorMsg=e.getMessage();
        }
        return mapReturn;
    }
   
    
    
}