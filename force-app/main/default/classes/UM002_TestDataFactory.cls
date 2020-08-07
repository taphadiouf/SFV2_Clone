/**
* @author Erwan Yhuellou
* @date 20/01/2020
* @description TestDataFactory - Unit Test Management Refactoring
*/
//@isTest
public with sharing class UM002_TestDataFactory {
    //public AccountContactRelationTdf accountContactRelationTdf;
    public AccountTdf accountTdf;
    public CaseTdf caseTdf;
    public OpportunityTdf opportunityTdf;
    public ContactTdf contactTdf;
    public UserTdf userTdf;

    public static boolean FillAllFields = false;
    public static Profile userProfile = [SELECT Id FROM Profile WHERE UserType = 'Standard' AND PermissionsCustomizeApplication = true LIMIT 1];
    private static final Map<String, String> DefaultPicklistValue = new Map<String, String>();
    
    private static final Map<String, Map<String, Schema.SObjectField>> FieldMapCache = new Map<String, Map<String, Schema.SObjectField>>();
	private static final Map<String, Id> defaultRecTypeCache = new Map<String, Id>();
	private static final Map<String, Id> referenceObjectCache = new Map<String, Id>();
    private static final Map<String, Schema.SObjectType> GlobalDescribe = Schema.getGlobalDescribe();
    
    public static map<String, set<String>> ExcludedFields = new map<String, set<String>>{
		'All' => new set<String>{'OwnerId', 'LastModifiedById', 'CreatedById', 'LastModifiedDate', 'CreatedDate'},
		'Account' => new set<String>{'LPCR_Garde__c', 'FirstName', 'LastName', 'BillingStateCode', 'BillingCountryCode', 'ShippingStateCode', 'ShippingCountryCode', 'OtherStateCode', 'OtherCountryCode', 'BillingState', 'BillingCountry', 'ShippingState', 'ShippingCountry', 'OtherState', 'OtherCountry'},
        'Contact' => new set<String>{'RecordTypeId', 'MailingStateCode', 'MailingCountryCode', 'MailingState', 'MailingCountry', 'OtherStateCode', 'OtherCountryCode', 'OtherState', 'OtherCountry'},
        'User' => new set<String>{'IsActive','DelegatedApproverId','CallCenterId','ContactId','DelegatedApproverId','ManagerId','UserRoleId','FederationIdentifier', 'State', 'StateCode', 'Country', 'CountryCode'}
	};

	// to fill nillable fields, specify them here
	public static map<String, set<String>> IncludedFields = new map<String, set<String>>{
		'Case' => new set<String>{'Description', 'Subject', 'Origin'},
        'User' => new set<String>{'Username','LastName','Email','Alias','TimeZoneSidKey','LocaleSidKey','EmailEncodingKey','ProfileId','LanguageLocaleKey'},
        'Contact' => new set<String>{'LastName'},
        'Account' => new set<String>{'Name'}
    };
    
    public UM002_TestDataFactory() {
        
        //accountContactRelationTdf = new AccountContactRelationTdf();
        accountTdf = new accountTdf();
        caseTdf = new CaseTdf();
        opportunityTdf = new OpportunityTdf();
        contactTdf = new ContactTdf();
        userTdf = new UserTdf();
    }

    // various simplified signatures for flexibility and backward compatibility
    public static SObject createSObject(String objectType) {
		return createSObject(objectType, null);
	}
    

    /*
    * @description generic test data factory method with default value
    * various simplified signatures for flexibility and backward compatibility 
    *
    * Refer SM013_QuoteLineServices_Test for usage example
    * Refer the original version for additional info / features : https://github.com/SalesforceFoundation/SmartFactory
    */
	public static SObject createSObject(String objectType, Map<String, Object> fieldValues) {
		return createSObject(objectType, 1, fieldValues);
    }

    // various simplified signatures for flexibility and backward compatibility
    public static List<SObject> createSObjectList(String objectType, Integer numberOfObjects) {
		return createSObjectList(objectType, numberOfObjects, null);
	}
    

    /*
    * @description generic test data factory method with default value
    * main method to create a list of object
    * fieldValues here work as above, but can optionally be a list of objects, in which case they will each be used 
    *
    * Refer SM013_QuoteLineServices_Test for usage example
    * Refer the original version for additional info / features : https://github.com/SalesforceFoundation/SmartFactory
    */
	public static List<SObject> createSObjectList(String objectType, Integer numberOfObjects, Map<String, Object> fieldValues) {
		List<SObject> soList = new List<SObject>();
		for (Integer i = 0; i < numberOfObjects; i++) {
            soList.add(createSObject(objectType, i, fieldValues));
        }
		return soList;  
	}
    
    /*
    * @description generic test data factory method with default value
    * full service signature
	* by passing in fieldValues, you can set defaults for any fields you like (data types must match)
	* for reference fields, fieldValues can optionally be actual parent objects to which you want the new objects to be related
    *
    * Refer SM013_QuoteLineServices_Test for usage example
    * Refer the original version for additional info / features : https://github.com/SalesforceFoundation/SmartFactory
    */
    public static SObject createSObject(String objectType, Integer counter, Map<String, Object> fieldValues) {
		SObject obj = GlobalDescribe.get(objectType).newSObject();

		set<String> exclude = new set<String>(); 
		if (ExcludedFields.get('All') != null)
			exclude.addAll(ExcludedFields.get('All'));
		if (ExcludedFields.get(objectType) != null)
			exclude.addAll(ExcludedFields.get(objectType));
		set<String> include = new set<String>(); 
		if (IncludedFields.get(objectType) != null)
			include.addAll(IncludedFields.get(objectType));		
		if (fieldValues != null)
			include.addAll(fieldValues.keyset());		

		for (Schema.SObjectField field : fieldMapFor(objectType).values()) {
			setFieldValue(obj, field, counter, include, exclude, fieldValues);
		}
		return obj;
    }
    
    /*
    * @description set field value based on the default provided by fieldValues map
	*
    * Refer SM013_QuoteLineServices_Test for usage example
    * Refer the original version for additional info / features : https://github.com/SalesforceFoundation/SmartFactory
    */
    static void setFieldValue(SObject obj, Schema.SObjectField field, Integer counter, Set<String> include, Set<String> exclude, Map<String, Object> fieldValues) {
		Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
		Schema.DisplayType ft = fieldDescribe.getType();
		String fn = fieldDescribe.getName();
		//System.debug('### Excluding exclude: ' + exclude);
		if (fieldDescribe.isCreateable() && 
				(
					(
						!exclude.contains(fn) &&
						(!fieldDescribe.isNillable() || FillAllFields || (ft == Schema.DisplayType.Reference))
                    ) 
				|| include.contains(fn))
			) {

			//System.debug(LOGGINGLEVEL.warn, obj.getSObjectType().getDescribe().getName() + '.' + fn + ': ' + ft.name());

			// look for a default value provided for this field
			if (fieldValues != null && fieldValues.containsKey(fn)) {

				// set the field to the default provided, whether it is a value or a list of values
				// also supports getting the Id of an sobject if that is what is provided as a default
				setFieldOverrideValue( obj, field, fieldValues.get(fn), counter );

			}  else if (ft == Schema.DisplayType.String) {
				if (fn == 'CommunityNickname') { 
					obj.put(field, 't'+ string.valueof(math.roundtolong(math.random()*1000000)) ); 
				} else if (fn == 'Username') { 
					obj.put(field, 'test'+ string.valueof(Userinfo.getOrganizationId())+ string.valueof(math.roundtolong(math.random()*1000000))+ string.valueof(Datetime.now()).replace('-','').replace(':','').replace(' ','')+'@test.com'); // was a@a.com
				} else {
					String s = (fn + counter.format());
					obj.put(field, (fieldDescribe.getLength() > s.length()) ? s : counter.format()); 
				}
			} else if (ft == Schema.DisplayType.Picklist) {
				obj.put(field, getDefaultPicklistValue(obj, fieldDescribe));
			} else if (ft == Schema.DisplayType.Integer) {
				obj.put(field, counter);
			} else if (ft == Schema.DisplayType.Boolean) {
				obj.put(field, false);
			} else if (ft == Schema.DisplayType.Currency) {
				obj.put(field, counter);
			} else if (ft == Schema.DisplayType.Date) {
				obj.put(field, Date.today().addDays(-1));
			} else if (ft == Schema.DisplayType.DateTime) {
				obj.put(field, DateTime.now());
			} else if (ft == Schema.DisplayType.Double) {
				obj.put(field, counter);
			} else if (ft == Schema.DisplayType.Email) {
				obj.put(field, 'test' + counter.format() + '@test.com');
			} else if (ft == Schema.DisplayType.TextArea) {
				obj.put(field, fn + counter.format()); 
			} else if (ft == Schema.DisplayType.Reference) {
				String objName = obj.getSObjectType().getDescribe().getName();
				String referenceObjectType = fieldDescribe.getReferenceTo()[0].getDescribe().getName();

				if (referenceObjectType == 'RecordType') {
					setRecordType(obj);
				} else if (referenceObjectType == 'Profile') { 
					obj.put(field, userProfile.Id);
				} else if (referenceObjectType == 'User') { 
					obj.put(field, UserInfo.getUserId());
				} /* else if (cascade && referenceObjectType != objName) {
					// TODO avoid infinite loop for same-type references
					//System.debug(LOGGINGLEVEL.warn, 'Creating reference to ' + referenceObjectType + ' for field ' + objName + '.' + fn);
					if (referenceObjectCache.containsKey(referenceObjectType)) {
						obj.put(field, referenceObjectCache.get(referenceObjectType));
					} else {
						SObject reference = createSObject(referenceObjectType, fieldValues);
						insert reference;
						obj.put(field, reference.Id);
						referenceObjectCache.put(referenceObjectType, reference.Id);
					}
				} */
			} else if (ft == Schema.DisplayType.MultiPicklist) {
				obj.put(field, getDefaultPicklistValue(obj, fieldDescribe));
			} else if (ft == Schema.DisplayType.Percent) {
				obj.put(field, counter);
			} else if (ft == Schema.DisplayType.Phone) {
				obj.put(field, '(123) 456-7890');
			} else if (ft == Schema.DisplayType.Combobox) {
				obj.put(field, counter.format());
			} else if (ft == Schema.DisplayType.EncryptedString) {
				obj.put(field, 's');
			} else if (ft == Schema.DisplayType.Time) {
				obj.put(field, Time.newInstance(0, 0, 0, 0)); 
			} else if (ft == Schema.DisplayType.URL) {
				obj.put(field, 'http://test' + counter + '.com'); 
			} else if (ft == Schema.DisplayType.base64) {
				obj.put(field, blob.valueOf(counter.format()));
			//} else if (ft == Schema.DisplayType.Id) {
				//System.debug('Id field ' + fn);
			} else {
                PAD.log('UM002_TestDataFactory','setFieldValue','Unhandled field type ' + ft);
            }
		}	
    }
    
    static void setFieldOverrideValue( SObject obj, Schema.SObjectField field, Object v, Integer counter ) {

		// first try to cast the object to a list of objects and use the right one
		// failing that, assume it is a single object or value
		try { 
			list<Object> oo = (list<Object>)(v);
			Integer i = (counter < oo.size()) ? counter : Math.mod(counter, oo.size());
			try { 
				obj.put(field, oo[i]);
			} catch (Exception ex1) {
				// if it isn't a value, try it as an sObject
				obj.put(field, ((sObject)(oo[i])).get('Id'));
			}
		} catch (Exception ex) {
			try { 
				// try the sObject first
				obj.put(field, ((sObject)(v)).get('Id'));
			} catch (Exception ex2) {
				// finally the object itself - this will throw an error if the datatype doesn't match
				obj.put(field, v);
			}
		}	
    }
    
    /*
	*	Returns a field map for a given sobject. 
	*	Note : this method is kept public for Test cases to share the same field map info, without requiring a field desribe.
	*	@param objectType sobject api name for ex. Account
    *	@returns FieldMap [Key:FieldName,Value:Schema.SObjectField]
    
    * Refer the original version for additional info / features : https://github.com/SalesforceFoundation/SmartFactory
    */
    public static  Map<String, Schema.SObjectField> fieldMapFor(String objectType) {
		Map<String, Schema.SObjectField> fieldMap = null;
		String normalizedObjectType = objectType.toLowerCase();

		if (FieldMapCache.containsKey(normalizedObjectType)) {
			fieldMap = FieldMapCache.get(normalizedObjectType);
		} else {
			fieldMap = GlobalDescribe.get(objectType).getDescribe().fields.getMap();
			//System.debug('### fieldMap: ' + fieldMap);
			// cache it for next use
			FieldMapCache.put(normalizedObjectType, fieldMap);
		}

		return fieldMap;
	}

    static String getDefaultPicklistValue(SObject obj, Schema.DescribeFieldResult fieldDescribe) {
        String key = obj.getSObjectType() + '.' + fieldDescribe.getName();

        if (!DefaultPicklistValue.containsKey(key)) {
            List<Schema.PicklistEntry> entries = fieldDescribe.getPicklistValues();
            String value = entries.size() > 0 ? entries[0].getValue() : null;
            DefaultPicklistValue.put(key, value);
        }
        DefaultPicklistValue.put('Account.SBQQ__RenewalModel__c', 'Contract Based');
        DefaultPicklistValue.put('Account.LPCR_Garde__c', 'Contract Based');

        /*
        DefaultPicklistValue.put('Account.BillingStateCode', null); //'AL');
        DefaultPicklistValue.put('Account.BillingCountryCode', null); //,'US');
        DefaultPicklistValue.put('Account.ShippingStateCode', null); //,'AL');
        DefaultPicklistValue.put('Account.ShippingCountryCode', null); //,'US');
        DefaultPicklistValue.put('Account.OtherStateCode', null); //,'AL');
        DefaultPicklistValue.put('Account.OtherCountryCode', null); //,'US');

        DefaultPicklistValue.put('Contact.MailingStateCode', null); //,'AL');
        DefaultPicklistValue.put('Contact.MailingCountryCode', null); //,'US');
        DefaultPicklistValue.put('Contact.OtherStateCode', null); //,'AL');
        DefaultPicklistValue.put('Contact.OtherCountryCode', null); //,'US');
        */
        return DefaultPicklistValue.get(key);
    }
    
    static void setRecordType(SObject obj) {
        Schema.DescribeSObjectResult objDR = obj.getSObjectType().getDescribe();
        String otn = objDR.getName();

        List<Schema.RecordTypeInfo> recordTypes;
        if (defaultRecTypeCache.containsKey( otn )) {
            obj.put('RecordTypeId', defaultRecTypeCache.get( otn ));
        } else {
            recordTypes = objDR.getRecordTypeInfos();
            if (recordTypes.size() > 1) { // all objects have default Master type
                for (Schema.RecordTypeInfo recordType : recordTypes) {
                    if (recordType.isAvailable() && recordType.isDefaultRecordTypeMapping()) {
                        obj.put('RecordTypeId', recordType.getRecordTypeId());
                        defaultRecTypeCache.put( otn, recordType.getRecordTypeId() );
                        break;
                    }
                }
            }
        }
    }
    
    public class AccountTdf {
        public Account create(String accountName){           
            Account c = new Account(Name = accountName);
            return c;
        }
        
    }
    
    public class CaseTdf {
        public Case create(Id accountId, Id contactId){           
            Case c = new Case(ContactId= contactId, AccountId=accountId);
            return c;
        }
        
    }
    
    public class OpportunityTdf {
        
        public Opportunity create(Account acc) {
            Opportunity opp = new Opportunity(AccountId = acc.Id,
                                              CloseDate = Date.today().addDays(15),
                                              StageName = 'CreationProgress',
                                              Name = 'Test opp');
            return opp;
        }
    }
    
    public class ContactTdf{
        
        public Contact create(String lastName, String firstName, Account acc){
            Contact cont = new Contact();  
            cont.Account = acc;      
            cont.LastName = lastName;
            cont.FirstName = firstName;
            cont.Salutation = 'M.';
            cont.MobilePhone = '+33610918171';
            cont.MailingStreet ='12 rue de paris';
            cont.MailingPostalCode ='75002';
            cont.MailingCity ='Paris';
            cont.Email = 'contact@contact.com';
            cont.Phone = '0987654321';
            cont.MailingStreet = 'Rue de Paris';
            cont.MailingCity = 'Paris';
            cont.MailingPostalCode = '75010';
            return cont;
        }
    }
    
    public class UserTdf {
        public User create() {
            
            User me;
            /*
User me = EM001_User.dataManager.getListByIdsWithRoleAndProfile(new Set<Id>{UserInfo.getUserId()}).get(0);

String s = ((Datetime.now()+'').replace(' ','')).replace(':','');
Datetime dt = Datetime.now();
User newMe = me.clone();
newMe.userName = 'mail'+s+'@me.fr';
newMe.CommunityNickname = dt.format();
newMe.FederationIdentifier = null;
*/
            return me;
            
        }
        
    }
    //This part of code is added by hanae on the 12/02/2020
    //it's a class that permit to add a list of leads/Tasks/Events/ Users
    
    public static User createUser(){
        //added by ayoub  to check first the user in DB.
        User usr = null;
        try{
            usr=  [SELECT Id, Name,Alias FROM User Where Alias = 'testusr' limit 1];
        }
        catch(Exception e){
            usr = null; 
        }
        
        if(usr==null){
            Profile prof = [SELECT Id, Name FROM Profile Where UserType = 'Standard' AND PermissionsCustomizeApplication = true limit 1].get(0);
            
            String uniqueUserName = 'standarduser' +Integer.valueof((Math.random() * 10000))+ DateTime.now().millisecond() + '@testorg.com';            
            usr = new User(Alias = 'testusr', Email = uniqueUserName,
                           EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                           LocaleSidKey = 'en_US', ProfileId = prof.Id,
                           TimeZoneSidKey = 'America/Los_Angeles',
                           UserName = uniqueUserName);
            insert usr;
        }
        
        
        return usr;
    }
    public static List<Lead> createLeads(Integer numLeads, String recTypeId, String lastName, String company,String Email){
        List<Lead> leads = new List<Lead>();
        for(Integer i=0;i<numLeads;i++){
            leads.add(new Lead(RecordTypeId = recTypeId, LastName=lastName,Company=company, Email=email));
        }
        return leads;
    }
    public static List<Lead> createLeads(Integer numLeads, String recTypeId, String lastName, String company, String status,String Email){
        List<Lead> leads = new List<Lead>();
        for(Integer i=0;i<numLeads;i++){
            leads.add(new Lead(RecordTypeId = recTypeId, LastName=lastName,Company=company ,Status = status, Email=email, LPCR_PasDeSIRET__c = true));
        }
        return leads;
    }
    public static List<Lead> createLeads(Integer numLeads, Map<String, Object> fieldsMap){
        List<Lead> leads = new List<Lead>();
        for(Integer i=0; i<numLeads; i++){
            Lead l= new Lead(LPCR_PasDeSIRET__c = true);
            for(String eachFieldName : fieldsMap.keySet()){
                l.put(eachFieldName, fieldsMap.get(eachFieldName));
            }
            leads.add(l);
        }
        return leads;
    }
    public static List<Lead> createLeadsWithCrecheLink(Integer numLeads, String lastName, String company, String status,String Email, Id crecheId, String crecheNumber){
        List<Lead> leads = new List<Lead>();
        for(Integer i=0;i<numLeads;i++){
            Lead l= new Lead(LastName=lastName,Company=company ,Status = status, Email=email, LPCR_PasDeSIRET__c = true);
            if(crecheNumber.equals('1')){
                l.LPCR_CodeCreche1__c = crecheId;
            }
            if(crecheNumber.equals('2')){
                l.LPCR_CodeCreche2__c = crecheId;
            }
            if(crecheNumber.equals('3')){
                l.LPCR_CodeCreche3__c = crecheId;
            }
            leads.add(l);
        }
        return leads;
    }
    public static List<LPCR_Structure_AO__c> createStructuresAOFromLeads(Integer numStructuresPerLead, List<Lead> leadsList){
        List<LPCR_Structure_AO__c> structures = new List<LPCR_Structure_AO__c>();
        for(Lead eachLead : leadsList){
            for(Integer i = 0; i<numStructuresPerLead; i++){
                structures.add(new LPCR_Structure_AO__c(LPCR_Lead__c = eachLead.Id));
            }
        }
        return structures;
    }
    
    public static List<Task> createTasks(Set<Id> whoIds ){
        List<Task> tasks = new List<Task>();
        for(Id eachId : whoIds){
            Task t= new Task(WhoId = eachId);
            tasks.add(t);
        }
        return tasks;
    }
    
    public static List<Event> createEvents(Set<Id> whoIds, Integer min, DateTime theDate ){
        List<Event> events = new List<Event>();
        for(Id eachId : whoIds){
            Event t= new Event(WhoId = eachId, DurationInMinutes = min, ActivityDateTime = theDate);
            events.add(t);
        }
        return events;
    }
    public static List<Opportunity> createOpportunities(Integer numOpps, String name, String stageName){
        List<Opportunity> opps = new List<Opportunity>();
        Opportunity tempOpp;
        for(Integer i = 0; i<numOpps; i++){
            tempOpp = new Opportunity(Name = name, StageName = stageName, CloseDate = Date.today());
            opps.add(tempOpp);
        }
        return opps;
    }
    public static List<Account> createAccounts(Integer numAccs, String name){
        List<Account> accounts = new List<Account>();
        Account tempAcc;
        for(Integer i = 0; i<numAccs; i++){
            tempAcc = new Account(Name = name);
            accounts.add(tempAcc);
        }
        return accounts;
    }
    public static List<SBQQ__Quote__c> createQuotes(Integer numRecs, List<Account> accs, List<Opportunity> opps){
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c tempQuote;
        for(Integer i = 0; i<numRecs; i++){
            tempQuote = new SBQQ__Quote__c(
                SBQQ__Opportunity2__c = opps.get(i).Id,
                SBQQ__Account__c = accs.get(i).Id,
                SBQQ__PriceBook__c = Test.getStandardPricebookId(),
                SBQQ__StartDate__c = date.today()
            );
            quotes.add(tempQuote);
        }
        return quotes;
    }
    public static List<Lead> createLe(Integer numLeads, String recTypeId, String lastName,String PrenomCoDemandeur,String company, String status,String Email, String NomCoDemandeur, Date DateNaissance1, String EmailCoDemandeur, String Phone, String CiviliteCoDemandeur){
        List<Lead> leads = new List<Lead>();
        for(Integer i=0;i<numLeads;i++){
            Lead l= new Lead(RecordTypeId = recTypeId, LastName=lastName, LPCR_PrenomCoDemandeur__c =PrenomCoDemandeur,Company=company ,Status = status, Email=email, LPCR_NomCoDemandeur__c= NomCoDemandeur,  LPCR_DateNaissance1__c= DateNaissance1 , LPCR_EmailCoDemandeur__c =EmailCoDemandeur, Phone=Phone, LPCR_CiviliteCoDemandeur__c = CiviliteCoDemandeur);
            leads.add(l);
        }
        return leads;
    }
    public static Account createAcc(String name, Id recId){
        return new Account(Name = name,
                           RecordTypeId = recId);
        
    }
    
    
    public static List<Lead> createLeadsWithAllFields(Integer numLeads, String recTypeId, String lastName,String firstName, String PrenomCoDemandeur,String company, String status,String Email, String NomCoDemandeur, Date DateNaissance1, String EmailCoDemandeur, String Phone, String CiviliteCoDemandeur){
        List<Lead> leads = new List<Lead>();
        for(Integer i=0;i<numLeads;i++){
            Lead l= new Lead(RecordTypeId = recTypeId, LastName=lastName, FirstName=firstName, LPCR_PrenomCoDemandeur__c =PrenomCoDemandeur,Company=company ,Status = status, Email=email, LPCR_NomCoDemandeur__c= NomCoDemandeur,  LPCR_DateNaissance1__c= DateNaissance1 , LPCR_EmailCoDemandeur__c =EmailCoDemandeur, Phone=Phone, LPCR_CiviliteCoDemandeur__c = CiviliteCoDemandeur, LPCR_PasDeSIRET__c = true);
            leads.add(l);
        }
        return leads;
    }
    
    public static Account createAccByRT(String name, Id recId){
        return new Account(Name = name,
                           RecordTypeId = recId);
    }
    
    // End of part added by hanae on the same day
    // Added By Ayoub 	
    public static LPCR_Preinscription__c createPreinscription(String nomEnfant, String prenomEnfant,Id compteFamilleId,Id contactId){	
        LPCR_Preinscription__c  preinsciption = new LPCR_Preinscription__c (LPCR_CompteFamille__c=compteFamilleId,	
                                                                            LPCR_PrenomEnfant__c=prenomEnfant,	
                                                                            NomEnfant__c=nomEnfant,	
                                                                            LPCR_ContactEnfant__c=contactId);	
        return preinsciption;	
    }
    public static Account createAccount(String name){	
        Account  acc = new Account(Name = name);	
        return acc;	
    }	
    
    public static Account createAccount(String name, Id recId){	
        Account  acc = new Account(Name = name,
                                   RecordTypeId = recId);	
        return acc;	
    }
    
    public static List<LPCR_ParametrageScore__c> createParametrageScores(Id accId){
        List<LPCR_ParametrageScore__c> listParams =new List<LPCR_ParametrageScore__c>();
        listParams.add( new LPCR_ParametrageScore__c(LPCR_Account__c  =accId, LPCR_ApiFieldName__c ='LPCR_Anciennete__c',LPCR_Format__c='Nombre',LPCR_Valeur__c = '1', LPCR_Score__c = 100));
        listParams.add( new LPCR_ParametrageScore__c(LPCR_Account__c  =accId, LPCR_ApiFieldName__c ='LPCR_Anciennete__c',LPCR_Format__c='Nombre',LPCR_Valeur__c = '2', LPCR_Score__c = 200));
        listParams.add( new LPCR_ParametrageScore__c(LPCR_Account__c  =accId, LPCR_ApiFieldName__c ='LPCR_Anciennete__c',LPCR_Format__c='Nombre',LPCR_Valeur__c = '3', LPCR_Score__c = 300));
        listParams.add( new LPCR_ParametrageScore__c(LPCR_Account__c  =accId, LPCR_ApiFieldName__c ='LPCR_Anciennete__c',LPCR_Format__c='Nombre',LPCR_Valeur__c = '4', LPCR_Score__c = 400));
        
        listParams.add( new LPCR_ParametrageScore__c(LPCR_Account__c  =accId, LPCR_ApiFieldName__c ='LPCR_NombreJours__c',LPCR_Format__c='Nombre',LPCR_Valeur__c = '3', LPCR_Score__c = 300));
        listParams.add( new LPCR_ParametrageScore__c(LPCR_Account__c  =accId, LPCR_ApiFieldName__c ='LPCR_NombreJours__c',LPCR_Format__c='Nombre',LPCR_Valeur__c = '4', LPCR_Score__c = 400));
        
        listParams.add( new LPCR_ParametrageScore__c(LPCR_Account__c  =accId, LPCR_ApiFieldName__c ='LPCR_DateEntreeCreche__c',LPCR_Format__c='Date',LPCR_Valeur__c = '31/12/2019', LPCR_Score__c = 100));
        listParams.add( new LPCR_ParametrageScore__c(LPCR_Account__c  =accId, LPCR_ApiFieldName__c ='LPCR_DateEntreeCreche__c',LPCR_Format__c='Date',LPCR_Valeur__c = '01/08/2020', LPCR_Score__c = 550));
        listParams.add( new LPCR_ParametrageScore__c(LPCR_Account__c  =accId, LPCR_ApiFieldName__c ='LPCR_DateEntreeCreche__c',LPCR_Format__c='Date',LPCR_Valeur__c = '04/03/2021', LPCR_Score__c = 600));
        
        listParams.add( new LPCR_ParametrageScore__c(LPCR_Account__c  =accId, LPCR_ApiFieldName__c ='LPCR_ReponseCrecheMunicipale__c',LPCR_Format__c='Texte',LPCR_Valeur__c = 'Autre', LPCR_Score__c = 225));
        listParams.add( new LPCR_ParametrageScore__c(LPCR_Account__c  =accId, LPCR_ApiFieldName__c ='LPCR_InteretConfirme__c',LPCR_Format__c='Texte',LPCR_Valeur__c = 'True', LPCR_Score__c = 1000));

        

        return listParams;
        
    }
    
    public static LPCR_RessourceFamille__c createRessourceFamille(Id productId, Id userId, Decimal price) {
        return new LPCR_RessourceFamille__c(   LPCR_DateDebut__c = date.today(),
                                            LPCR_CompteFamille__c=userId);
    } 
    public static LPCR_RessourceFamille__c createRessourceFamille(Date debutDate, Id userId, Id contId) {
        return new LPCR_RessourceFamille__c(   LPCR_DateDebut__c = debutDate,
                                            LPCR_CompteFamille__c=userId,
                                            LPCR_ContactEnfant__c= contId);
    }
    public static List<LPCR_RessourceFamille__c> createRessourceFamille(Integer nbr,Id productId, Id userId,Decimal price,List<Date> listStartDate,List<Decimal> listNbrEnfant,List<Decimal> listNbrEnfantHandicape){
        List<LPCR_RessourceFamille__c> listRessourceFamille = new List<LPCR_RessourceFamille__c>();
        for(Integer i=0;i<nbr;i++){
            listRessourceFamille.add(new LPCR_RessourceFamille__c(
                LPCR_CompteFamille__c=userId,
                //LPCR_Produit__c=productId,
                //LPCR_TauxMensuel__c=price,
                LPCR_DateDebut__c =listStartDate.get(i),
                LPCR_NombreEnfants__c=listNbrEnfant.get(i),
                LPCR_NombreEnfantHandicape__c=listNbrEnfantHandicape.get(i)));
        }
        return listRessourceFamille;
    } 
    
    
    public static Contract createContract(Id accountID){	
        Contract  contract = new Contract(AccountID = accountID);	
        return contract;	
    }	
    
    public static Contract createContract(Id accountID,Id quoteId, Id orderId){	
        Contract  contract = new Contract(AccountID = accountID,SBQQ__Quote__c=quoteId,SBQQ__Order__c =orderId);	
        return contract;	
    }	
    public static Contract createContract(Id accountID, Id orderId){	
        Contract  contract = new Contract(AccountID = accountID,SBQQ__Order__c =orderId);	
        return contract;	
    }	
    public static Contract createContract(Id accountID,Id quoteId, Id opportunityId, Date dateFin){	
        Contract  contract = new Contract(AccountID = accountID,SBQQ__Quote__c = quoteId,SBQQ__Opportunity__c = opportunityId,
                                        StartDate =System.today(),ContractTerm = 12,LPCR_DateDebut__c = System.today(),
                                        LPCR_DateFin__c = dateFin,LPCR_MethodeRenouvellement__c = 'Express' );	
        return contract;	
    }

    public static Order createOrder(Id accountID,Id contractID,Date orderStartDate,String name ,String status,String billindDayOfMonth){	
        Order  order = new Order(blng__BillingDayOfMonth__c = billindDayOfMonth,AccountID = accountID,ContractId =contractID,EffectiveDate=orderStartDate,Status=status,Name=name);	
        return order;	
    }	
    
    public static PricebookEntry createPricebookEntry(Id pricebookId, Id productId){
        PricebookEntry pbe = new PricebookEntry();
        pbe.isActive = true;
        pbe.UnitPrice = 100;
        pbe.Product2Id = productId;
        pbe.Pricebook2Id = pricebookId;
        return pbe;
    }
    public static Product2 createProduct(String name, Id billingRuleId,Id revenueRecognitionRuleId,Id taxeRuleId ){
        Product2 prod = new Product2();
        prod.isActive = true;
        prod.Name = name;
        prod.blng__BillingRule__c =billingRuleId;
        prod.blng__RevenueRecognitionRule__c  =revenueRecognitionRuleId ;
        prod.blng__TaxRule__c =taxeRuleId;
        return prod;
    }

        public static Product2 createProduct(String name){
        Product2 prod = new Product2();
        prod.isActive = true;
        prod.Name = name;
        return prod;
    }

    public static Product2 createFixedPriceProduct(String name, Id billingRuleId,Id revenueRecognitionRuleId,Id taxeRuleId ){
        Product2 prod = new Product2();
        prod.isActive = true;
        prod.Name = name;
        prod.blng__BillingRule__c =billingRuleId;
        prod.blng__RevenueRecognitionRule__c  =revenueRecognitionRuleId ;
        prod.blng__TaxRule__c =taxeRuleId;
        prod.SBQQ__SubscriptionPricing__c ='Fixed Price';
        prod.SBQQ__BillingFrequency__c = 'Monthly';
        prod.SBQQ__BillingType__c = 'Advance';
        prod.SBQQ__ChargeType__c = 'Recurring';
        prod.SBQQ__SubscriptionTerm__c = 12;
        prod.SBQQ__SubscriptionType__c = 'Renewable';
        return prod;
    }
    public static OrderItem createOrderProduct(Id standardPricebookId,ID orderID, Id productId,String chargeType,Decimal unitPrice ){
        OrderItem orderItem = new OrderItem();
        orderItem.OrderId = orderID;
        orderItem.Product2ID = productId;
        orderItem.PricebookEntryId=standardPricebookId;
        orderItem.SBQQ__ChargeType__c =chargeType;
        orderItem.UnitPrice =unitPrice;
        return orderItem;
    }
    public static OrderItem createOrderProduct(Id standardPricebookId,ID orderID, Id productId,String chargeType,String billingFrequency, Decimal unitPrice ){
        OrderItem orderItem = new OrderItem();
        orderItem.OrderId = orderID;
        orderItem.Product2ID = productId;
        orderItem.PricebookEntryId=standardPricebookId;
        orderItem.SBQQ__ChargeType__c =chargeType;
        orderItem.SBQQ__BillingFrequency__c = billingFrequency;
        orderItem.SBQQ__BillingType__c = 'Advance';
        orderItem.Quantity = 1;
        orderItem.SBQQ__SubscriptionTerm__c = 12;
        orderItem.SBQQ__DefaultSubscriptionTerm__c = 12;
        orderItem.UnitPrice =unitPrice;
        return orderItem;
    }
    public static void insertBillingCustomSettings() {
        
        List<blng__BillingConfig__c> listofConfiguration = new List<blng__BillingConfig__c>();
        List<blng__TaxConfig__c> listofTaxConfig = new List<blng__TaxConfig__c>();
        blng__BillingConfig__c advancedARApplication = new blng__BillingConfig__c(Name = 'ADVANCED_AR_APPLICATION',
                                                                                  blng__StringValue__c = '',
                                                                                  blng__FieldType__c = 'Boolean',
                                                                                  blng__Description__c = 'Advanced AR application',
                                                                                  blng__PicklistIndicator__c ='',
                                                                                  blng__Category__c ='Invoice',
                                                                                  blng__Sequence__c = 2,
                                                                                  blng__BooleanValue__c = true);
        listofConfiguration.add(advancedARApplication);
        blng__BillingConfig__c taxCalculationBasedOn = new blng__BillingConfig__c(Name = 'TAX_CALCULATION_BASED_ON',
                                                                                  blng__StringValue__c = 'Order: Account Billing Address',
                                                                                  blng__FieldType__c = 'Picklist',
                                                                                  blng__Description__c = 'Tax calculation is based on?',
                                                                                  blng__PicklistIndicator__c ='TaxcCalculationList',
                                                                                  blng__Category__c ='General',
                                                                                  blng__Sequence__c = 3);
        listofConfiguration.add(taxCalculationBasedOn);
        blng__BillingConfig__c alignBilling = new blng__BillingConfig__c(Name = 'ALIGN_BILLDAYOFMONTH_TO_ORDERSTARTDATE',
                                                                         blng__StringValue__c = '',
                                                                         blng__FieldType__c = 'Boolean',
                                                                         blng__Description__c = 'Align Billing day of month to Order start date',
                                                                         blng__PicklistIndicator__c ='',
                                                                         blng__Category__c ='General',
                                                                         blng__Sequence__c = 3,
                                                                         blng__BooleanValue__c = true);
        listofConfiguration.add(alignBilling);
        blng__BillingConfig__c calculationProrationType = new blng__BillingConfig__c(Name = 'PRORATION_TYPE',
                                                                                     blng__StringValue__c = 'Calendar Days',
                                                                                     blng__FieldType__c = 'Picklist',
                                                                                     blng__Description__c = 'Proration type.',
                                                                                     blng__PicklistIndicator__c ='CalendarDaysList',
                                                                                     blng__Category__c ='Invoice',
                                                                                     blng__Sequence__c = 3);
        listofConfiguration.add(calculationProrationType);
        
        blng__BillingConfig__c PartialProrationType = new blng__BillingConfig__c(Name = 'PARTIAL_PERIOD_BILLING_PRORATION',
                                                                                 blng__StringValue__c = 'Month + Daily',
                                                                                 blng__FieldType__c = 'Picklist',
                                                                                 blng__Description__c = 'Partial Proration Type',
                                                                                 blng__PicklistIndicator__c ='PartialProrationTypeList',
                                                                                 blng__Category__c ='Invoice',
                                                                                 blng__Sequence__c = 3);
        listofConfiguration.add(PartialProrationType);
        blng__BillingConfig__c invoiceTobeChargedOn = new blng__BillingConfig__c(Name = 'INVOICE_TO_BE_CHARGED_ON',
                                                                                 blng__StringValue__c = 'Due Date',
                                                                                 blng__FieldType__c = 'Picklist',
                                                                                 blng__Description__c = 'Payment Scheduler to pickup unpaid invoices on OR after',
                                                                                 blng__PicklistIndicator__c ='PaymentSchedulerList',
                                                                                 blng__Category__c ='Invoice',
                                                                                 blng__Sequence__c = 2,
                                                                                 blng__BooleanValue__c = false);
        listofConfiguration.add(invoiceTobeChargedOn);  
        blng__BillingConfig__c periodPriceRounding = new blng__BillingConfig__c(Name = 'PERIOD_PRICE_ROUNDING',
                                                                                blng__StringValue__c = 'HALF_UP',
                                                                                blng__FieldType__c = 'Picklist',
                                                                                blng__Description__c = 'Billable Unit Price Rounding',
                                                                                blng__PicklistIndicator__c ='PeriodPriceRoundingList',
                                                                                blng__Category__c ='General',
                                                                                blng__Sequence__c = 8,
                                                                                blng__BooleanValue__c = false);
        listofConfiguration.add(periodPriceRounding);  
        
        blng__BillingConfig__c usageRatingProcess = new blng__BillingConfig__c(Name = 'USAGE_RATING_PROCESS',
                                                                               blng__StringValue__c = 'On Trigger',
                                                                               blng__FieldType__c = 'Picklist',
                                                                               blng__Description__c = 'Usage Rating Process based on',
                                                                               blng__PicklistIndicator__c ='UsageRatingProcessList',
                                                                               blng__Category__c ='General',
                                                                               blng__Sequence__c = 9,
                                                                               blng__BooleanValue__c = false);
        listofConfiguration.add(usageRatingProcess);    
        
        blng__BillingConfig__c billingRemainderProcessing = new blng__BillingConfig__c(Name = 'BILLING_REMAINDER_PROCESS',
                                                                                       blng__StringValue__c = 'Last Period',
                                                                                       blng__FieldType__c = 'Picklist',
                                                                                       blng__Description__c = 'Billing Remainder Process',
                                                                                       blng__PicklistIndicator__c ='billingRemainderProcessList',
                                                                                       blng__Category__c ='Invoice',
                                                                                       blng__Sequence__c = 5,
                                                                                       blng__BooleanValue__c = false);
        listofConfiguration.add(billingRemainderProcessing);
        
        blng__BillingConfig__c revenueRemainderProcessing = new blng__BillingConfig__c(Name = 'REVENUE_REMAINDER_PROCESS',
                                                                                       blng__StringValue__c = 'Last Period',
                                                                                       blng__FieldType__c = 'Picklist',
                                                                                       blng__Description__c = 'Revenue Remainder Process',
                                                                                       blng__PicklistIndicator__c ='RevenueRemainderProcessList',
                                                                                       blng__Category__c ='Invoice',
                                                                                       blng__Sequence__c = 6,
                                                                                       blng__BooleanValue__c = false);
        listofConfiguration.add(revenueRemainderProcessing);
        
        blng__BillingConfig__c saveCreditCardBetails = new blng__BillingConfig__c(Name = 'SAVE_CREDIT_CARD_ON_PAYMENT_PAGE',
                                                                                  blng__StringValue__c = '',
                                                                                  blng__FieldType__c = 'Boolean',
                                                                                  blng__Description__c = 'Save credit card details',
                                                                                  blng__PicklistIndicator__c ='',
                                                                                  blng__Category__c ='General',
                                                                                  blng__Sequence__c = 6,
                                                                                  blng__BooleanValue__c = false);
        listofConfiguration.add(saveCreditCardBetails);
        
        blng__BillingConfig__c enableStateAndCountryPicklist = new blng__BillingConfig__c(Name = 'ENABLE_STATE_AND_COUNTRY_PICKLIST',
                                                                                          blng__StringValue__c = '',
                                                                                          blng__FieldType__c = 'Boolean',
                                                                                          blng__Description__c = 'Enable state and country picklist in Site Page and Virtual Terminal(works when state and country feature is enabled in Salesforce)',
                                                                                          blng__PicklistIndicator__c ='',
                                                                                          blng__Category__c ='General',
                                                                                          blng__Sequence__c = 6,
                                                                                          blng__BooleanValue__c = false);
        listofConfiguration.add(enableStateAndCountryPicklist);
        
        
        blng__BillingConfig__c sampledata = new blng__BillingConfig__c(Name = 'INSERT_SAMPLE_DATA',
                                                                       blng__StringValue__c = '',
                                                                       blng__FieldType__c = 'Boolean',
                                                                       blng__Description__c = 'Insert Sample Data',
                                                                       blng__PicklistIndicator__c ='',
                                                                       blng__BooleanValue__c = false);
        listofConfiguration.add(sampledata);
        
        //Added by DL,W-4000272, In-order to make Tax Engine name dynamic
        blng__BillingConfig__c taxEngineName = new blng__BillingConfig__c(Name = 'AVALARA_AVATAX',
                                                                          blng__StringValue__c = 'Avalara AvaTax',
                                                                          blng__FieldType__c = '',
                                                                          blng__Description__c = '',
                                                                          blng__PicklistIndicator__c ='',
                                                                          blng__Category__c ='Tax',
                                                                          blng__BooleanValue__c = false);
        listofConfiguration.add(taxEngineName);
        
        insert listofConfiguration;        
        
    }  
    
    public static blng__LegalEntity__c setupLegalEntity() {
        blng__LegalEntity__c legalEntity = new blng__LegalEntity__c(blng__Active__c=true, blng__Country__c='USA');
        insert legalEntity;
        return legalEntity;
    }
    
    public static blng__RevenueRecognitionRule__c setupRevRec(string legalEntityId) {
        blng__RevenueRecognitionRule__c revRecRule = new blng__RevenueRecognitionRule__c (blng__Active__c=true,blng__CreateRevenueSchedule__c='Yes',Name='Monthly');
        insert revRecRule;
        
        blng__FinanceBook__c revFinanceBook = new blng__FinanceBook__c(blng__Active__c = true, Name = 'Rev Finance Book', blng__PeriodType__c = 'Revenue');
        insert revFinanceBook;
        
        blng__RevenueDistributionMethod__c revDist = new blng__RevenueDistributionMethod__c( blng__Active__c = true, Name = 'Monthly Invoice', blng__Type__c = 'Invoice', blng__RevenueTransactionCreationProcess__c = 'Automatic', blng__RevenueScheduleTermStartDate__c = 'Invoice Line Start Date', blng__RevenueScheduleTermEndDate__c = 'Invoice Line End Date', blng__MonthlyRecognitionProration__c = 'Number of Days', blng__DistributionMethod__c = 'Monthly');
        insert revDist;
        
        blng__GLRule__c glRule = new blng__GLRule__c(blng__Active__c = true, Name = 'GL Rule');
        insert glRule;
        
        
        blng__RevenueRecognitionTreatment__c revRecTreatment = new blng__RevenueRecognitionTreatment__c( blng__Active__c = true, blng__RevenueLegalEntity__c = legalEntityId, blng__RevenueRecognitionRule__c = revRecRule.Id, blng__ProcessingOrder__c = 10, blng__Percentage__c = 100, blng__Type__c = 'Percentage', blng__RevenueScheduleCreationAction__c = 'Invoice Posting', blng__RevenueScheduleAmount__c = 'Transaction Amount', blng__RevenueFinanceBook__c = revFinanceBook.Id, blng__RevenueDistributionMethod__c = revDist.id, blng__RevenueGLRule__c = glRule.Id);
        insert revRecTreatment;
        return revRecRule;
    }
    
    public static blng__BillingRule__c setupBillingRule(string legalEntityId) {            
        blng__BillingRule__c billingRule = new blng__BillingRule__c(blng__InitialBillingTrigger__c = 'Order Product Activation Date', 
                                                                    Name = 'TEST',blng__Active__c = true, blng__GenerateInvoices__c='Yes');
        insert billingRule;
        
        blng__FinanceBook__c accoutingFinanceBook = new blng__FinanceBook__c(blng__Active__c = true,
                                                                             Name = 'Accounting Finance Book', blng__PeriodType__c = 'Accounting');
        insert accoutingFinanceBook;
        
        blng__BillingTreatment__c billingTreatment = new blng__BillingTreatment__c( blng__BillingFinanceBook__c = accoutingFinanceBook.Id,
                                                                                   blng__Active__c = true, blng__BillingLegalEntity__c = legalEntityId, 
                                                                                   blng__BillingRule__c = billingRule.Id /*,blng__CancellationRule__c = 'LIFO based on Termination Date'*/);
        insert billingTreatment;
        
        return billingRule;
    }
    
    public static blng__TaxRule__c setupTaxRule(string legalEntityId) {            
        blng__TaxRule__c taxRule = new blng__TaxRule__c(blng__Active__c = true, blng__TaxableYesNo__c = 'Yes', Name = 'Tax Rule');
        insert taxRule;
        
        blng__TaxIntegration__c stdTaxInt = new blng__TaxIntegration__c(blng__Active__c = true, blng__Default__c = true, blng__TaxEngine__c = 'Standard');
        insert stdTaxInt;
        
        blng__TaxTreatment__c taxTreatment = new blng__TaxTreatment__c( blng__Active__c = true, blng__TaxLegalEntity__c = legalEntityId, blng__TaxRule__c = taxRule.Id, blng__TaxIntegration__c = stdTaxInt.Id);
        insert taxTreatment;
        
        return taxRule;
    }
    
    public static blng__TaxRule__c setupTaxRuleasNO(string legalEntityId) {            
        blng__TaxRule__c taxRule = new blng__TaxRule__c(blng__Active__c = true, blng__TaxableYesNo__c = 'No', Name = 'Tax Rule NO');
        insert taxRule;
        
        return taxRule;
    }

    public static SBQQ__Quote__c createQuote(String city ,String opportunityId, String accountId, String priceBookId, String type) 
    {
        SBQQ__Quote__c cpqQuote = new SBQQ__Quote__c();
        cpqQuote.SBQQ__Primary__c = false;
        cpqQuote.SBQQ__StartDate__c = System.Today();
        cpqQuote.SBQQ__Opportunity2__c = opportunityId;
        cpqQuote.SBQQ__SubscriptionTerm__c = 12;
        cpqQuote.SBQQ__BillingFrequency__c = 'Invoice Plan';
        cpqQuote.SBQQ__Account__c = accountId;
        cpqQuote.SBQQ__Type__c = type;
        cpqQuote.SBQQ__PriceBook__c = priceBookId;
        cpqQuote.SBQQ__PricebookId__c = priceBookId;
        cpqQuote.SBQQ__QuoteLanguage__c = 'English';
        cpqQuote.SBQQ__BillingCity__c = city;
        return cpqQuote;
    }

        public static SBQQ__Quote__c createQuote(Id priceBookId, String type)
    {
        SBQQ__Quote__c cpqQuote = new SBQQ__Quote__c();
        cpqQuote.SBQQ__Primary__c = false;
        cpqQuote.SBQQ__StartDate__c = System.Today();
        cpqQuote.SBQQ__SubscriptionTerm__c = 12;
        cpqQuote.SBQQ__BillingFrequency__c = 'Invoice Plan';
        cpqQuote.SBQQ__Type__c = type;
        cpqQuote.SBQQ__PriceBook__c = priceBookId;
        cpqQuote.SBQQ__PricebookId__c = priceBookId;
        cpqQuote.SBQQ__QuoteLanguage__c = 'English';
        return cpqQuote;
    }
    public static SBQQ__QuoteLine__c createQuoteLine(String productId, String quoteId, String pricebookEntryId, Decimal price,Integer qte) 
    {
        SBQQ__QuoteLine__c quoteLineInstance = new SBQQ__QuoteLine__c();
        quoteLineInstance.SBQQ__StartDate__c = System.Today();
        quoteLineInstance.SBQQ__Product__c = productId;
        quoteLineInstance.SBQQ__Quantity__c = qte;
        //quoteLineInstance.SBQQ__DefaultSubscriptionTerm__c = null;
        quoteLineInstance.SBQQ__ListPrice__c = price;
        quoteLineInstance.SBQQ__CustomerPrice__c = price;
        quoteLineInstance.SBQQ__NetPrice__c = price;
        quoteLineInstance.SBQQ__SpecialPrice__c = price;
        quoteLineInstance.SBQQ__Quote__c = quoteId;
        quoteLineInstance.SBQQ__PricebookEntryId__c = pricebookEntryId;
        quoteLineInstance.SBQQ__PricingMethod__c = 'List';
        //quoteLineInstance.SBQQ__SubscriptionPricing__c = null;
        quoteLineInstance.SBQQ__ChargeType__c ='Recurring';
        quoteLineInstance.SBQQ__BillingType__c = 'Advance';
        quoteLineInstance.SBQQ__BillingFrequency__c ='Invoice Plan';
        return quoteLineInstance;
    }
    
    
    public static List< LPCR_BaremeCAF__c > createBaremeCAF(Integer nbr, List<Date> listStartDates,List<Decimal> listTauxEffortParEnfant){
        List<LPCR_BaremeCAF__c> listBaremeCAF = new List<LPCR_BaremeCAF__c>();
        for(Date eachDate : listStartDates){
            for(Integer i = 0; i <nbr ;i++){
                listBaremeCAF.add(new LPCR_BaremeCAF__c(LPCR_DateDebut__c = eachDate,
                                                        LPCR_DateFin__c =Date.newInstance(eachDate.Year(), 12, 31),
                                                        LPCR_NombresEnfants__c =i+1,
                                                        LPCR_TauxEffortParEnfant__c =listTauxEffortParEnfant.get(i)));
            }  
        }
        
        return listBaremeCAF;
    }
    //--- End Ayoub's Part
    
    //This part of code is added by hanae on the 09/03/2020
    public static List<LPCR_Preinscription__c> createPreinscription(Integer numPrei, String nomEnfant, String prenomEnfant,String statut,Id compteFamilleId,Id contactId){	
        List<LPCR_Preinscription__c> preinscriptions = new List<LPCR_Preinscription__c>();
        for(Integer i=0;i<numPrei;i++){
            LPCR_Preinscription__c  pre = new LPCR_Preinscription__c (LPCR_CompteFamille__c=compteFamilleId,	
                                                                      LPCR_PrenomEnfant__c=prenomEnfant,	
                                                                      NomEnfant__c=nomEnfant,	
                                                                      LPCR_Statut__c = statut,
                                                                      LPCR_ContactEnfant__c=contactId);	
            preinscriptions.add(pre);
        }
        
        return preinscriptions;	
    }
    
    //--- End of Hanae's part
    
    
    public static List<LPCR_Preinscription__c> createPreinscriptions(Integer numPrei, String nomEnfant, String prenomEnfant,String statut,Id compteFamilleId,Id contactId){	
        List<LPCR_Preinscription__c> preinscriptions = new List<LPCR_Preinscription__c>();
        for(Integer i=0;i<numPrei;i++){
            preinscriptions.add(new LPCR_Preinscription__c(      
                                                            LPCR_CompteFamille__c=compteFamilleId,	
                                                            LPCR_PrenomEnfant__c=prenomEnfant,	
                                                            NomEnfant__c=nomEnfant,	
                                                            LPCR_Statut__c = statut,
                                                            LPCR_ContactEnfant__c=contactId));
        }
        
        return preinscriptions;	
    }
    public static List<Contact> createContacts(Integer numRecords, Id recType, String lastname, String address){	
        List<Contact> contacts = new List<Contact>();
        for(Integer i = 0; i < numRecords; i++){
            contacts.add(new Contact(   Lastname = lastname,
                                        RecordTypeId = recType,
                                        MailingCountry = address
                                        ));	
        }
        
        return contacts;	
    }
     public static List<Account> createAccounts(Integer numRecords, Id recType, String name){	
        List<Account> accounts = new List<Account>();
        for(Integer i = 0; i < numRecords; i++){
            accounts.add(new Account(   
                                        Name = name,
                                        RecordTypeId = recType));	
        }
        
        return accounts;	
    }
    public static List<LPCR_Preinscription__c> createPreinscriptions( List<Account> famillesAccountList, List<Contact> enfantsContactsList, List<Contact> parentContactsList,String statut, String preinsType){	
        List<LPCR_Preinscription__c> preinscriptions = new List<LPCR_Preinscription__c>();
        for(Integer i = 0; i < famillesAccountList.size(); i++){
            LPCR_Preinscription__c  pre = new LPCR_Preinscription__c(   LPCR_Statut__c = statut,
                                                                        LPCR_TypePreinscription__c = preinsType,
                                                                        LPCR_CompteFamille__c = famillesAccountList.get(i).Id,
                                                                        LPCR_ContactEnfant__c = enfantsContactsList.get(i).Id,
                                                                        LPCR_ContactParent__c = parentContactsList.get(i).Id
                                                                        );	
            preinscriptions.add(pre);
        }
        
        return preinscriptions;	
    }
    public static List<LPCR_Preinscription__c> createPreinscForEntreprise(Integer numPrei, String nomEnfant, String prenomEnfant,String statut,Id entrepriseAccountId,Id contactId){	
        List<LPCR_Preinscription__c> preinscriptions = new List<LPCR_Preinscription__c>();
        for(Integer i=0;i<numPrei;i++){
            LPCR_Preinscription__c  pre = new LPCR_Preinscription__c(      LPCR_CompteEntreprise__c= entrepriseAccountId,	
                                                                     LPCR_PrenomEnfant__c= prenomEnfant,	
                                                                     NomEnfant__c= nomEnfant,	
                                                                     LPCR_Statut__c = statut,
                                                                     LPCR_ContactEnfant__c=contactId);	
            preinscriptions.add(pre);
        }
        
        return preinscriptions;	
    }

    public static EmailTemplate createEmailTemplate(String name, String developerName, String templateType){
        return new EmailTemplate(Name = name,
                                 DeveloperName = developerName,
                                 TemplateType =templateType,
                                 FolderId = UserInfo.getUserId());
    }
    //This part of code is added by hanae on the 28/02/2020 to create Attachments and LPCR_Log__c records
    public static List<Attachment> createAttachements(Integer numAtts, String name,String body,String parentId){
        List<Attachment> atts = new List<Attachment>();
        for(Integer i=0;i<numAtts;i++){
            Attachment a = new Attachment();
            a.Name = name;
            Blob bodyBlob = Blob.valueOf(body);
            a.body = bodyBlob;
            a.ParentId = parentId;
            a.Description = 'Facture';
            atts.add(a);
        }
        return atts;
    }
    
    public static Attachment createAttachement(String name,String body,String parentId, String Description){
        Attachment atts = new Attachment();
        atts.Name = name;
        Blob bodyBlob = Blob.valueOf(body);
        atts.body = bodyBlob;
        atts.ParentId = parentId;
        atts.Description = Description;
        return atts;
    }
    
    public static List<LPCR_Log__c> createLogsFromAttachments( String name,String result, String typ,List<Attachment> attsList){
        List<LPCR_Log__c> logsList = new List<LPCR_Log__c>();
        LPCR_Log__c tempLog;
        for(Attachment eachAtt : attsList){
            tempLog = new LPCR_Log__c();
            tempLog.Name = name;
            tempLog.LPCR_TargetObject__c = '' + eachAtt.Id;
            tempLog.LPCR_Result__c = result;
            tempLog.LPCR_Type__c = typ;
            logsList.add(tempLog);
        }
        return logsList;
    }
    
    
    
    
    
    //End of the part on the same day
    
    // This part is added by hanae on the 12/03/2020
    
    
    public static LPCR_Preinscription__c createPreinscription(String nomEnfant, String prenomEnfant, String typePreinscription,Id compteFamilleId,Id contactId){	
        LPCR_Preinscription__c  preinsciption = new LPCR_Preinscription__c (LPCR_CompteFamille__c=compteFamilleId,	
                                                                            LPCR_PrenomEnfant__c=prenomEnfant,
                                                                            LPCR_TypePreinscription__c=typePreinscription,	
                                                                            NomEnfant__c=nomEnfant,	
                                                                            LPCR_ContactEnfant__c=contactId);	
        return preinsciption;	
    }
    
    //End of the part on the same day
    
        //This part is added by hanae on the 19/03/2020
    public static List<LPCR_PlanningPrevisionnel__c> createPlannings(Integer numPlann, Id idQuote, Time debutLundi, Time finLundi, Time DebutMardi, Time finMardi, Time DebutMercredi, Time finMercredi, Time DebutJeudi, Time finJeudi, Time DebutVendredi, Time finVendredi){ 
        
        LPCR_Planning__c tmpPlanning = new LPCR_Planning__c();
        tmpPlanning.LPCR_TypePlanning__c = 'Planning Classique';
        insert tmpPlanning;


        List<LPCR_PlanningPrevisionnel__c>  plannings = new List<LPCR_PlanningPrevisionnel__c>();

        for(Integer i=0;i<numPlann;i++){
            LPCR_PlanningPrevisionnel__c pl = new LPCR_PlanningPrevisionnel__c(
                                                                                LPCR_Contrat__c = idQuote,
                                                                               LPCR_Planning__c = tmpPlanning.Id,
                                                                               LPCR_HeureDebutLundi__c = debutLundi,
                                                                               LPCR_HeureFinLundi__c   = finLundi,
                                                                               LPCR_HeureDebutMardi__c = DebutMardi,
                                                                               LPCR_HeureFinMardi__c  = finMardi,
                                                                               LPCR_HeureDebutMercredi__c = DebutMercredi,
                                                                               LPCR_HeureFinMercredi__c = finMercredi, 
                                                                               LPCR_HeureDebutJeudi__c = DebutJeudi,
                                                                               LPCR_HeureFinJeudi__c = finJeudi,
                                                                               LPCR_HeureDebutVendredi__c = DebutVendredi,
                                                                               LPCR_HeureFinVendredi__c = finVendredi);
            plannings.add(pl);
        }
        return plannings;   
    }
    
    public static List<LPCR_PlanningPrevisionnel__c> createPlanningsWithoutTime(Integer numPlann,  Id idQuote){
    
        LPCR_Planning__c tmpPlanning = new LPCR_Planning__c();
        tmpPlanning.LPCR_TypePlanning__c = 'Planning Classique';
        insert tmpPlanning;

    
        List<LPCR_PlanningPrevisionnel__c>  plannings = new List<LPCR_PlanningPrevisionnel__c>();
        for(Integer i=0;i<numPlann;i++){
            LPCR_PlanningPrevisionnel__c pl = new LPCR_PlanningPrevisionnel__c(LPCR_Planning__c = tmpPlanning.id, LPCR_Contrat__c = idQuote);
            plannings.add(pl);
        }
        return plannings;   
    }
    
    
    //This part is added by Hanae on the 19/05/2020
    public static List<LPCR_ModificationEntrante__c> createModificationsEntrantes(Integer numRecs, List<SBQQ__Quote__c> quotes, String event){
        List<LPCR_ModificationEntrante__c> ModifEntrantes = new List<LPCR_ModificationEntrante__c>();
        LPCR_ModificationEntrante__c tempModif;
        for(Integer i = 0; i<numRecs; i++){
            tempModif = new LPCR_ModificationEntrante__c(
                LPCR_Devis__c  = quotes.get(i).Id,
                LPCR_Evenement__c  = event
            );
            ModifEntrantes.add(tempModif);
        }
        return ModifEntrantes;
    }
    
    public static LPCR_ModificationEntrante__c createModificationsEntrante(String event,Id accountId, Id contactId, Id contractId,Decimal revenusFamille){
        LPCR_ModificationEntrante__c modifEntrante = new LPCR_ModificationEntrante__c(LPCR_Evenement__c = event,
                                                                                     LPCR_Compte__c = accountId,LPCR_Statut__c = 'Validée',
                                                                                     LPCR_Quantite__c = 1, LPCR_Contract__c = contractId,
                                                                                     LPCR_Contact__c = contactId, LPCR_EtatTraitement__c = false,
                                                                                     LPCR_RessourceFamille__c = revenusFamille);       
        return modifEntrante;
    }
    
    //added by saurabh
    public static LPCR_ModificationEntrante__c createModificationsEntrante(String event,Id accountId, Id contactId, Id contractId,Date dateEffet,Decimal revenusFamille){
        LPCR_ModificationEntrante__c modifEntrante = new LPCR_ModificationEntrante__c(LPCR_Evenement__c = event,LPCR_Statut__c = 'Validée',
                                                                                     LPCR_DateEffet__c = dateEffet, LPCR_Compte__c = accountId,
                                                                                     LPCR_Quantite__c = 1, LPCR_Contract__c = contractId,
                                                                                     LPCR_Contact__c = contactId, LPCR_EtatTraitement__c = false,
                                                                                     LPCR_RessourceFamille__c = revenusFamille);       
        return modifEntrante;
    }

    public static List<Account> createAccountswithtype(Integer numAccs, String name, String typeCreche, String rTDevName){
        List<Account> accounts = new List<Account>();
       	Id recTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, rTDevName);
        Account tempAcc;
        for(Integer i = 0; i<numAccs; i++){
            tempAcc = new Account(Name = name, LPCR_TypeCreche__c  = typeCreche, RecordTypeId = recTypeId);
            accounts.add(tempAcc);
        }
        return accounts;
    }
    public static List<SBQQ__Quote__c> createQuoteswithStatus(Integer numRecs, List<Account> accs, List<Opportunity> opps, String status){
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c tempQuote;
        for(Integer i = 0; i<numRecs; i++){
            tempQuote = new SBQQ__Quote__c(
                SBQQ__Opportunity2__c = opps.get(i).Id,
                LPCR_Creche__c = accs.get(i).Id,
                SBQQ__Status__c = status,
                SBQQ__StartDate__c = date.today(),
                SBQQ__EndDate__c = date.newInstance(System.Today().year(), 12, 31)
            );
            quotes.add(tempQuote);
        }
        return quotes;
    }
    
    ///////////////***********///////////    
    public static List<Account> createAccountWithRecType(Integer numAccs, String name, Id recTypeId, String type){
        List<Account> accounts = new List<Account>();
        Account tempAcc;
        for(Integer i = 0; i<numAccs; i++){
            tempAcc = new Account(Name = name, RecordTypeId  = recTypeId, LPCR_TypeCreche__c = type);
            accounts.add(tempAcc);
        }
        return accounts;
    }
    public static List<Contract> createContracts(Integer numConts, Id accountID, String name, Date dateDebut, Date dateFin, Integer chiffreAffaire, String methodeRen, String renouvellementConvenu, Integer renewalUplift, String typeCreche){    
        List<Contract>  contracts = new List<Contract>();
        Contract tempCont;
        for(Integer i = 0; i<numConts; i++){
            tempCont = new Contract(AccountID = accountID, Name = name, LPCR_DateDebut__c = dateDebut, LPCR_DateFin__c = dateFin, LPCR_ChiffreAffaire__c = chiffreAffaire, LPCR_MethodeRenouvellement__c = methodeRen, SBQQ__RenewalUpliftRate__c  = renewalUplift, LPCR_TypeCreche__c = typeCreche);
            contracts.add(tempCont);
        }
        return contracts;   
    }
    public static List<Opportunity> createOpportunities(Integer numOpps, String name, String stageName, String indexation, String typeFacturation, String billingFrequency, Id renewalId, Id amendedID){
        List<Opportunity> opps = new List<Opportunity>();
        Opportunity tempOpp;
        for(Integer i = 0; i<numOpps; i++){
            tempOpp = new Opportunity(Name = name, StageName = stageName, CloseDate = Date.today(), LPCR_IndexationConvenue__c = indexation, LPCR_TypeFacturation__c = typeFacturation, LPCR_BillingFrequency__c = billingFrequency, SBQQ__RenewedContract__c= renewalId, SBQQ__AmendedContract__c = amendedID );
            opps.add(tempOpp);
        }
        return opps;
    }
    public static List<SBQQ__Quote__c> createQuotes(Integer numRecs, List<Account> accs, List<Opportunity> opps, String type, Id recTypeId, Id crecheId){
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c tempQuote;
        for(Integer i = 0; i<numRecs; i++){
            tempQuote = new SBQQ__Quote__c(
                SBQQ__Opportunity2__c = opps.get(i).Id,
                SBQQ__Account__c = accs.get(i).Id,
                SBQQ__Type__c = type,
                RecordTypeId = recTypeId,
                LPCR_Creche__c = crecheId,
                SBQQ__StartDate__c = date.today(),
                SBQQ__EndDate__c = date.newInstance(System.Today().year(), 12, 31)
            );
            quotes.add(tempQuote);
        }
        return quotes;
    }
    
    
    public static List<blng__InvoiceRun__c> createInvoiceRuns(Integer numRecs, String name, date targetDate){
        List<blng__InvoiceRun__c> invoiceRuns = new List<blng__InvoiceRun__c>();
        blng__InvoiceRun__c tempInvoiceRun;
        for(Integer i = 0; i<numRecs; i++){
            tempInvoiceRun = new blng__InvoiceRun__c(
                Name = name,
            	blng__TargetDate__c = targetDate
            );
            invoiceRuns.add(tempInvoiceRun);
        }
        return invoiceRuns;
            
        }
    
    
    
    public static List<blng__Invoice__c> createInvoices(Integer numRecs, Id accId, Id execFacId, String statut, String statutFacture){
        List<blng__Invoice__c> invoices = new List<blng__Invoice__c>();
        blng__Invoice__c tempInvoice;
        for(Integer i = 0; i<numRecs; i++){
            tempInvoice = new blng__Invoice__c(
                blng__Account__c  = accId,
            	blng__InvoiceRunCreatedBy__c  = execFacId,
                blng__InvoiceStatus__c = statut,
                LPCR_StatutFacture__c = statutFacture
            );
            invoices.add(tempInvoice);
        }
        return invoices;
            
        }
    
    
    public static Contact createContact(String name, ID rectypeId){
        Contact con = new Contact(LastName = name , RecordTypeId = rectypeId);
        return con;
    }
   
    public static List<Contract> createContracts(Integer numRecs,List<Account> accounts, List<SBQQ__Quote__c> quotes){	
        List<Contract>  contracts = new List<Contract>();
        Contract temcontract;
        for(Integer i = 0; i<numRecs; i++){
            temcontract = new Contract(
              AccountId  =  accounts.get(i).id,
              SBQQ__Quote__c = quotes.get(i).id
            );
            contracts.add(temcontract);
        }
        return contracts;	
    }


    public static List<LPCR_ModificationEntrante__c> createModificationsEntrantes(Integer numRecs, List<SBQQ__Quote__c> quotes,List<Contract> contracts ,String event){
        List<LPCR_ModificationEntrante__c> ModifEntrantes = new List<LPCR_ModificationEntrante__c>();
        LPCR_ModificationEntrante__c tempModif;
        for(Integer i = 0; i<numRecs; i++){
            tempModif = new LPCR_ModificationEntrante__c(
                LPCR_Devis__c  = quotes.get(i).Id,
                LPCR_Contract__c = contracts.get(i).Id,
                LPCR_Evenement__c  = event
            );
            ModifEntrantes.add(tempModif);
        }
        return ModifEntrantes;
    }

    
    /*
public class AccountContactRelationTdf {

public AccountContactRelation create(Id accountId, Id contactId) {
AccountContactRelation acr = new AccountContactRelation();
acr.ContactId = contactId;
acr.AccountId = accountId;

return acr;
}

public AccountContactRelation create(Id accountId, Id contactId, List<String> roles) {
AccountContactRelation acr = new AccountContactRelation();
acr.ContactId = contactId;
acr.AccountId = accountId;
acr.Roles = String.join(roles, ';');

return acr;
}

public AccountContactRelation create(Id accountId, Id contactId, List<String> roles, String fonction) {
AccountContactRelation acr = new AccountContactRelation();
acr.ContactId = contactId;
acr.AccountId = accountId;
acr.Roles = String.join(roles, ';');
acr.Function__c = fonction;

return acr;
}
}
*/
    
}