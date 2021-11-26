public with sharing class APC011_GenererAvoir {
    public Id AvoirID {get;set;}
    public string urlFB {get;set;}
    public string urlIn {get;set;}
    public string urlInsta {get;set;}
    public string urlJoin {get;set;}
    public string urlTwitter {get;set;}
    public string urlYoutube {get;set;}
    public string urlUpper {get;set;}
    public Map<String,String> mapCompanyDets {get;set;}
    public Map<String,String> mapAvoirDets {get;set;}
    public Date periodAvoir {get;set;}
    public Date periodAvoirFin {get;set;}
    public Decimal montantAvoir {get;set;}
    public APC011_GenererAvoir(ApexPages.StandardController sc){
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        String orgId=UserInfo.getOrganizationId();
        AvoirID=sc.getId();
       
        List<Document> lstDocHead=[Select id,Name from Document where Name IN ('LCPR_AvoirFb','LPCR_AvoirYoutube','LCPR_AvoirTwitter','LCPR_AvoirIn','LCPR_AvoirJoinus','LCPR_AvoirInsta','LPCR_Upper') order by Name asc ];

        //fb
        urlFB=Test.isRunningTest()?'': baseUrl+'/servlet/servlet.ImageServer?id='+lstDocHead[0].id+'&oid='+orgId;
        //linkedin
        urlIn=Test.isRunningTest()?'': baseUrl+'/servlet/servlet.ImageServer?id='+lstDocHead[1].id+'&oid='+orgId;
        //insta
        urlInsta=Test.isRunningTest()?'': baseUrl+'/servlet/servlet.ImageServer?id='+lstDocHead[2].id+'&oid='+orgId;
        //joinus
        urlJoin=Test.isRunningTest()?'': baseUrl+'/servlet/servlet.ImageServer?id='+lstDocHead[3].id+'&oid='+orgId;
        //twitter
        urlTwitter=Test.isRunningTest()?'': baseUrl+'/servlet/servlet.ImageServer?id='+lstDocHead[4].id+'&oid='+orgId;
        //youtube
        urlYoutube=Test.isRunningTest()?'': baseUrl+'/servlet/servlet.ImageServer?id='+lstDocHead[5].id+'&oid='+orgId;
        urlUpper=Test.isRunningTest()?'': baseUrl+'/servlet/servlet.ImageServer?id='+lstDocHead[6].id+'&oid='+orgId;
        //company dets
        //mapCompanyDets=new  Map<String,String> ();
        //mapCompanyDets.put('hu','pari');
        for(LPCR_Avoir__c avoir : [SELECT LPCR_CompteClient__c,LPCR_DateFinAvoir__c, LPCR_CompteClient__r.Name,LPCR_CompteClient__r.LPCR_IdSage__c,LPCR_CompteClient__r.LPCR_NumeroAllocataire__c,LPCR_CompteClient__r.Owner.FirstName,LPCR_CompteClient__r.Owner.LastName,LPCR_CompteClient__r.LPCR_ResponsableADV__r.LastName,LPCR_CompteClient__r.LPCR_ResponsableADV__r.FirstName,LPCR_CompteClient__r.BillingCity, LPCR_CompteClient__r.BillingCountry,LPCR_CompteClient__r.BillingState, LPCR_CompteClient__r.BillingStreet,LPCR_CompteClient__r.BillingPostalCode ,Name,LPCR_NomSociete__r.Name,LPCR_Description__c ,LPCR_DateFacture__c ,LPCR_Montant__c ,LPCR_CompteClient__r.LPCR_SocieteFacturanteCompte__c ,LPCR_CompteClient__r.LPCR_SocieteFacturanteCompte__r.Name from LPCR_Avoir__c where ID=:AvoirID]){
            String addCompteClient='';
            if(avoir.LPCR_CompteClient__r.BillingStreet != null){
                addCompteClient=addCompteClient+avoir.LPCR_CompteClient__r.BillingStreet;
            }
            if(avoir.LPCR_CompteClient__r.BillingPostalCode != null ){
                addCompteClient=addCompteClient+' '+avoir.LPCR_CompteClient__r.BillingPostalCode;
            }
            if(avoir.LPCR_CompteClient__r.BillingCity != null ){
                addCompteClient=addCompteClient+' '+avoir.LPCR_CompteClient__r.BillingCity;
            }
            if(avoir.LPCR_CompteClient__c == null){
                mapCompanyDets=new  Map<String,String>{'compteclien' => ' ','name'=>' ' ,'address'=>' ','owner'=>' ','adv'=>' ','nomsociete'=>' ' ,'socfac' =>' '};
            }else{
                mapCompanyDets=new  Map<String,String>{'compteclien' => avoir.LPCR_CompteClient__r.LPCR_IDSage__c != null? avoir.LPCR_CompteClient__r.LPCR_IDSage__c: '','name'=>avoir.LPCR_CompteClient__r.Name != null ?avoir.LPCR_CompteClient__r.Name :'' ,'address'=>addCompteClient,'owner'=>avoir.LPCR_CompteClient__r.Owner.FirstName != null ?avoir.LPCR_CompteClient__r.Owner.FirstName :'' +' '+avoir.LPCR_CompteClient__r.Owner.LastName != null ? avoir.LPCR_CompteClient__r.Owner.LastName :'','adv'=>avoir.LPCR_CompteClient__r.LPCR_ResponsableADV__r.FirstName != null ? avoir.LPCR_CompteClient__r.LPCR_ResponsableADV__r.FirstName : ''+' '+avoir.LPCR_CompteClient__r.LPCR_ResponsableADV__r.LastName != null ?avoir.LPCR_CompteClient__r.LPCR_ResponsableADV__r.LastName:'' ,'nomsociete'=>avoir.LPCR_NomSociete__c!= null ?avoir.LPCR_NomSociete__r.Name  :'','socfac' =>avoir.LPCR_CompteClient__r.LPCR_SocieteFacturanteCompte__c != null ?avoir.LPCR_CompteClient__r.LPCR_SocieteFacturanteCompte__r.Name :''};
            }
            
            
            mapAvoirDets= new  Map<String,String>{'avoirName'=>avoir.Name != null ?avoir.Name :'' ,'datetoday'=> System.now().format('dd/MM/yyyy'),'description'=>avoir.LPCR_Description__c!= null ? avoir.LPCR_Description__c:'' };
            periodAvoir=avoir.LPCR_DateFacture__c;
            periodAvoirFin=avoir.LPCR_DateFinAvoir__c;
            montantAvoir=avoir.LPCR_Montant__c;
        }
        


    }
    @AuraEnabled
    public static String GenererAvoir(Id AccountID) {
        String filename = 'AvoirDirect';
        PageReference pdf = Page.VFP003_GenererAvoir;
        System.debug('##pdo this is acc '+AccountID);
        pdf.getParameters().put('id',AccountID);
        ContentVersion conVersion = new ContentVersion();
        conVersion.ContentLocation = 'S';
        conVersion.PathOnClient = filename+'.pdf';
        conVersion.Title = filename;
        if(Test.isRunningTest()){
            conVersion.VersionData = blob.valueOf('Unit.Test');
        }else{
            conVersion.VersionData = pdf.getContentAsPDF();
        }
        //get accountID 
        List<LPCR_Avoir__c> lstAcc=[SELECT Id, LPCR_NomSociete__c, LPCR_CompteClient__c, LPCR_Description__c, LPCR_Montant__c FROM LPCR_Avoir__c where id=:AccountID ];
        try{
            insert conVersion;
            ContentDocumentLink cdl = createContentLink(conVersion.Id, lstAcc[0].LPCR_CompteClient__c);
           
            return null;
        }catch(Exception e ){
            return e.getMessage();
        }
        
    }
    private static ContentDocumentLink createContentLink(String contentVersionId, ID recordId) {
        if (contentVersionId == null || recordId == null) { return null; }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id =: contentVersionId
        ].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        // ShareType is either 'V', 'C', or 'I'
        // V = Viewer, C = Collaborator, I = Inferred
        cdl.ShareType = 'V';
        try {
            insert cdl;
            return cdl;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }

}