/**
* DM000_SObject : Abstract Class used for giving extended feature for manipulating DML operation for an object

Each EM Object Class should extend this Class and override getDataManagerClassName and getObjectName :

public with sharing class EM00X_<Object> extends DM000_SObject{

@TestVisible
protected override String getDataManagerClassName() {
return EM00X_<Object>.class.getName();
}


@TestVisible
protected override String getObjectName() {
return Schema.sObjectType.<Object>.name;
}

...
}

*/
public abstract class DM000_SObject{
    
    
    String sObjectAPIName;
    
    //Suppported Dml Operations
    public enum DmlOperationType{INSERT_OP, UPDATE_OP, UPSERT_OP, DELETE_OP, ANY_OP}
    
    // DML LAUNCHED FROM :
    // ----> TRIGGER_SRC : Apex Trigger
    // ----> VFC_SRC : Visual Force Controller
    // ----> LWCC_SRC : LWC Controller
    // ----> LCC : Lightning Component Controller
    public enum ProcessType {TRIGGER_SRC, VFC_SRC, LWCC_SRC, LCC_SRC}
    
    /* allFields for SELECT, built only when needed */
    private String allFieldsLazy;
    
    /* Each DM must implement this method by providing class Name */
    protected Abstract String getDataManagerClassName();
    
    /* Each DM must implement this method by providing the object Name to manipulate */
    protected Abstract String getObjectName();
    
    /* Description of Objects and fields */
    private static Map<String, Schema.SObjectType> schemaMap;
    private static Map<String, Map <String, Schema.SObjectField>> fieldsMaps;
    
    protected Boolean isAccessible = false;
    protected Boolean isCreateable = false;
    protected Boolean isDeletable = false;
    protected Boolean isUpdateable = false;
    protected Boolean isQueryable = false;
    
    Private String FIELDSTODELETE = '';
    
    /**
* @description Constructor to init security parameters for SObject
*/
    public DM000_SObject(){
        
        init(getObjectName());
    }
    
    /**
* @param sObjectName name of the sObject
* @description Constructor to init security parameters for SObject
*/
    public DM000_SObject(String sObjectName){
        
        init(sObjectName);
        //New  
        this.sObjectAPIName = sObjectName;
    }
    
    /**
* @param sObjectName name of the sObject
* @description method to init the instanciation of the DM00_SObject
*/
    public void init(String sObjectName){
        
        Schema.DescribeSObjectResult describeSObjectResult = schemaMap.get(sObjectName).getDescribe();
        
        isAccessible = describeSObjectResult.isAccessible();
        isCreateable = describeSObjectResult.isCreateable();
        isDeletable = describeSObjectResult.isDeletable();
        isUpdateable = describeSObjectResult.isUpdateable();
        isQueryable = describeSObjectResult.isQueryable();
    }
    
    static {
        schemaMap = Schema.getGlobalDescribe();
        fieldsMaps = new Map<String, Map <String, Schema.SObjectField>>();
    }
    
    /**
* @description Method to get a string containing all the fields of the Object
* @return String
*/
    @TestVisible
    public String getAllFields() {
        
        if (allFieldsLazy == null) {
            allFieldsLazy = constructFieldListForQueryFrom(getObjectName());
        }
        String[] fieldsToDelete = FIELDSTODELETE.split(',');
        
        for(String field : fieldsToDelete){
            allFieldsLazy = allFieldsLazy.trim().replace(field + ',','');
            allFieldsLazy = allFieldsLazy.trim().replace(field ,'');
        }
        
        
        return allFieldsLazy;
    }
    
    /**
* @description Method to get the request 'Select * from Object'    (* being the selected fields)
* @return String
*/
    @TestVisible
    protected String getRequestAllFields() {
        
        return 'SELECT ' + getAllFields() + ' FROM ' + getObjectName();
    }
    
    
    
    public String dmlExecuteRequestBack(String dmlOperation, List<SObject> objList, Boolean allOrNoneMode,  String methodName, ProcessType pt) {
        
        String errorMsg = '';
        PAD.Log(getDataManagerClassName(), methodName, 'objList :' + objList);
        
        System.Savepoint sp = Database.setSavepoint();
        try {
            
            if (isAccessible && objList != null && objList.size() > 0) {
                
                switch on dmlOperation{
                    when 'insert'{
                        if (isCreateable){ Database.insert(objList, allOrNoneMode);}
                    }
                    when 'update'{
                        if (isUpdateable){ Database.update(objList, allOrNoneMode); }
                    }
                    when 'upsert'{
                        if (isCreateable && isUpdateable){ Database.upsert(objList, allOrNoneMode); }
                    }
                    when 'delete'{
                        if (isDeletable){ Database.delete(objList,  allOrNoneMode); }
                    }
                    when else{
                        throw new DMLException(String.valueOf(dmlOperation) + ': operation not implemented');
                    }
                }
            }
            
        }
        catch(DMLException e) {            
            errorMsg = String.valueOf(e);
            Database.rollback(sp);            
        }
        finally {
            if (errorMsg != '') {
                UM001_LogManager.writeLogActivity('Apex DML Exception', dmlOperation, getDataManagerClassName() + ' - ' + methodName, null, 'methodName:' + methodName + ' DMLException:' + errorMsg, 'ERROR');  
            } 
        }
        
        PAD.Log(getDataManagerClassName(), methodName, 'finished');
        return errorMsg;
    }
    
    public String dmlExecuteRequestUI(String dmlOperation, List<SObject> objList, Boolean allOrNoneMode,  String methodName, ProcessType pt) {
        
        String errorMsg = '';        
        PAD.Log(getDataManagerClassName(), methodName, 'objList :' + objList);
        
        try {
            
            if (isAccessible && objList != null && objList.size() > 0) {
                
                switch on dmlOperation{
                    when 'insert'{
                        if (isCreateable){ Database.insert(objList, allOrNoneMode);}
                    }
                    when 'update'{
                        if (isUpdateable){ Database.update(objList, allOrNoneMode); }
                    }
                    when 'upsert'{
                        if (isCreateable && isUpdateable){ Database.upsert(objList, allOrNoneMode); }
                    }
                    when 'delete'{
                        if (isDeletable){ Database.delete(objList,  allOrNoneMode); }
                    }
                    when else{
                        throw new DMLException(String.valueOf(dmlOperation) + ': operation not implemented');
                    }
                }
            }
            
        }
        catch(DMLException e) {
            
            errorMsg = String.valueOf(e);
            throw new DMLException(errorMsg);
        }
        
        PAD.Log(getDataManagerClassName(), methodName, 'finished');
        return errorMsg;
    }
    
    /**
* @description Method to update/insert/upsert/delete a list of SObject with exception handling
* @param dmlOperation : update/insert/upsert/delete
* @param objList : list of SObject
* @param allOrNoneMode : dml operation rollback if one error appears
* @param methodName : the name of the caller public method
* @param externalIdField : External Id field used for upsert
*/
    @TestVisible
    public String dmlExecuteRequest(String dmlOperation, List<SObject> objList, Boolean allOrNoneMode,  String methodName, ProcessType pt) {
        
        String errorMsg = '';        
        
        if (pt == ProcessType.TRIGGER_SRC && !FeatureManagement.checkPermission('LPCR_ForceDefaultLogMechnism')) {
            errorMsg = dmlExecuteRequestBack( dmlOperation, objList, allOrNoneMode, methodName, pt);   
        }
        else {
            errorMsg = dmlExecuteRequestUI( dmlOperation, objList, allOrNoneMode, methodName, pt);             
        }
        
        return errorMsg;
        
        
    }
    
    /**
* @description Method to get a Map of fields for a given SObject
* @param sObjectName sObject name
* @return Map<String, Schema.SObjectField> Map of fields for a given SObject
*/
    private Map<String, Schema.SObjectField> buildFieldsMap(String sObjectName){
        
        Map <String, Schema.SObjectField> fieldsMap = fieldsMaps.get(sObjectName);
        
        if (fieldsMap == null){
            fieldsMap = schemaMap.get(sObjectName).getDescribe().fields.getMap();
            fieldsMaps.put(sObjectName, fieldsMap);
        }
        
        return fieldsMap;
    }
    
    /**
* @description Method to get a list of fields for a given SObject
* @param sObjectName  sObject name
* @return List<String> list of fields for a given SObject
*/
    private List<String> getFieldsListFor(String sObjectName) {
        
        Map <String, Schema.SObjectField> fieldsMap = buildFieldsMap(sObjectName);
        
        List<String> fieldsList = new List<String>();
        
        for (Schema.SObjectField sfield : fieldsMap.values()) {
            fieldsList.add(sfield.getDescribe().getName());
        }
        
        return fieldsList;
    }
    
    /**
* @description Method to get a list of fields for a given SObject
* @param sObjectName sObject name
* @return String list of fields for a given SObject
*/
    private String constructFieldListForQueryFrom(String sObjectName) {
        
        return constructFilteredFieldListForQueryFrom(sObjectName, '');
    }
    
    /**
* @description Returns all fields EXCEPT those ending with the specified string (example: "__pc" to exclude personAccount fields on account query)
* @param sObjectName String Nom du sObject
* @param notEndingFilter String specifies the endding name of the fields to omit
* @return String liste des champs du sObject en paramètre
*/
    private String constructFilteredFieldListForQueryFrom(String sObjectName, String notEndingFilter) {
        
        return constructFilteredPrefixedFieldListForQueryFrom(sObjectName, notEndingFilter, '');
    }
    
    /**
* @description Returns all fields EXCEPT those ending with the specified string (example: "__pc" to exclude personAccount fields on account query)
*              and adds a prefix on each field name
* @param sObjectName String Nom du sObject
* @param notEndingFilter String specifies the endding name of the fields to omit
* @return String liste des champs du sObject en paramètre
*/
    private String constructFilteredPrefixedFieldListForQueryFrom(String sObjectName, String notEndingFilter, String prefix) {
        
        List<String> fieldsList = getFieldsListFor(sObjectName);
        String fieldsQuery = '';
        
        for (String field : fieldsList) {
            if (String.isEmpty(notEndingFilter) || !field.endsWith(notEndingFilter)) {
                fieldsQuery = fieldsQuery + '' + prefix + field + ',';
            }
        }
        
        return fieldsQuery.replace(fieldsQuery, fieldsQuery.substring(0, fieldsQuery.length() - 1));
    }
    
    
    
    /**
* @description Method to return picklist values for a given field
* @param fieldName : Picklist field name
* @return List<Schema.PicklistEntry> Picklist values
*/
    public List<Schema.PicklistEntry> getPickListValues(String fieldName){
        
        Map <String, Schema.SObjectField> fieldsMap = buildFieldsMap(getObjectName());
        
        List<Schema.PicklistEntry> picklistValues = fieldsMap.get(fieldName).getDescribe().getPickListValues();
        
        return picklistValues;
    }
    
    /**
* @description Method to get field describer by type
* @param String type
* @return Map<String, Schema.SObjectField> : Fields representing the desired searched Type
*/
    public Map<String, Schema.SObjectField> getFieldDescribeByType(String searchType){
        
        Map<String, Schema.SObjectField> sobjectFieldMap = new Map<String,Schema.SObjectField>();
        Map<String, Schema.SObjectField> fieldsMap = buildFieldsMap(getObjectName());
        for(String fieldName : fieldsMap.keySet()){
            
            Schema.DescribeFieldResult sObjectFieldDescribe = fieldsMap.get(fieldName).getDescribe();
            if(String.valueOf(sObjectFieldDescribe.getType()).equals(searchType)){
                
                sobjectFieldMap.put(fieldName, fieldsMap.get(fieldName));
                
            }
        }
        return sobjectFieldMap;
        
    }
    
    
    
    //methods merged from EM001_AbstarctObjectEntity
    public List<SObject> getAllWithAllFields(){
        Set<String> fields = Schema.getGlobalDescribe().get(this.sObjectAPIName).getDescribe().fields.getMap().keySet(); 
        String queryString = 'SELECT ';
        for(String eachField : fields){
            queryString += ( eachField +',');
        }
        queryString = queryString.removeEnd(',');
        queryString += (' FROM ' + this.sObjectAPIName);
        return Database.query(queryString);
    }
    public List<SObject> getAll(Set<String> fields){
        String queryString = 'SELECT Id';
        for(String eachField : fields){
            queryString += (',' + eachField);
        }
        queryString += (' FROM ' + this.sObjectAPIName);
        return Database.query(queryString);
    }
    public List<SObject> getByIds(Set<Id> idsSet, Set<String> fields){
        String queryString = 'SELECT Id';
        if(fields != null){
            for(String eachField : fields){
                        queryString += (',' + eachField);
                    }
        }
        queryString += (' FROM ' + this.sObjectAPIName + ' WHERE Id IN :idsSet');
        return Database.query(queryString);
    }
    public SObject getById(Id recId, Set<String> fields){
        String queryString = 'SELECT Id';
        for(String eachField : fields){
            queryString += (',' + eachField);
        }
        queryString += (' FROM ' + this.sObjectAPIName + ' WHERE Id = :recId');
        return Database.query(queryString);
    }
    public List<SObject> getBy(Set<String> returnedFields, Map<String, Set<String>> filtersMap){
        String queryString = 'SELECT Id';
        if(returnedFields != null){
            for(String eachField : returnedFields){
                queryString += (',' + eachField);
            }
        }
        queryString += (' FROM ' + this.sObjectAPIName );
        if(filtersMap != null && filtersMap.size()>0){
            queryString += ' WHERE ';
            for(String eachField : filtersMap.keySet()){
                Set<String> filterValues = filtersMap.get(eachField);
                queryString += (eachField + ' IN :filterValues AND ');
            }
            queryString = queryString.trim();
            queryString = queryString.removeEnd('AND');
        }
        return Database.query(queryString);
    }
    public List<SObject> getBy(Set<String> returnedFields, Map<String, Set<Id>> filtersMap){
        String queryString = 'SELECT Id';
        if(returnedFields != null){
            for(String eachField : returnedFields){
                queryString += (',' + eachField);
            }
        }
        queryString += (' FROM ' + this.sObjectAPIName );
        if(filtersMap != null && filtersMap.size()>0){
            queryString += ' WHERE ';
            for(String eachField : filtersMap.keySet()){
                Set<Id> filterValues = filtersMap.get(eachField);
                queryString += (eachField + ' IN '+ filterValues + ' AND ');
            }
            queryString = queryString.trim();
            queryString = queryString.removeEnd('AND');
        }
        queryString = queryString.replaceAll('{', '(');
        queryString = queryString.replaceAll('}', ')');
        
        return Database.query(queryString);
    }
    public List<SObject> getBy(String filterField, Set<String> filterSet, Set<String> returnedFields){
        String queryString = 'SELECT Id';
        if(returnedFields != null){
            for(String eachField : returnedFields){
                queryString += (',' + eachField);
            }
        }
        queryString += (' FROM ' + this.sObjectAPIName + ' WHERE '+ filterField + ' IN :filterSet');
        return Database.query(queryString);
    }
    public List<SObject> getBy(String filterField, Set<Id> filterSet, Set<String> returnedFields){
        String queryString = 'SELECT Id';
        if(returnedFields != null){
            for(String eachField : returnedFields){
                queryString += (',' + eachField);
            }
        }
        queryString += (' FROM ' + this.sObjectAPIName + ' WHERE '+ filterField + ' IN :filterSet');
        return Database.query(queryString);
    }
}