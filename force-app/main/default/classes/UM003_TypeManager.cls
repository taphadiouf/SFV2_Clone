/**
   * @author Ayoub Ouarti
   * @date 20/02/2020
   * @Type Manager class
*/

public with sharing class UM003_TypeManager{


/**
* @Author Ayoub Ouarti
* @Created 20/02/2020
* @Description methode isNullOrEmpty to check if a List<SObject> is null or empty
* @Inputs Boolean isNullOrEmpty(List<SObject> listSObject)
*/
    public static Boolean isNullOrEmpty(List<SObject> listSObject){
        return (listSObject==null || listSObject.size()==0) ?true:false;
    }


/**
* @Author Ayoub Ouarti
* @Created 20/02/2020
* @Description methode isNotNullAndNotEmpty to check if a List<SObject> is not null and not empty
* @Inputs Boolean isNotNullAndNotEmpty(List<SObject> listSObject)
*/
    public static Boolean isNotNullAndNotEmpty(List<SObject> listSObject){
        return (listSObject!=null && listSObject.size()>0) ?true:false;
    }

/**
* @Author Ayoub Ouarti
* @Created 20/02/2020
* @Description methode isNotNull to check if a SObject is not null 
* @Inputs Boolean isNotNull(SObject obj)
*/
    public static Boolean isNotNull(SObject obj){
        return obj!=null ?true:false;
    }

    /**
* @Author Ayoub Ouarti
* @Created 20/02/2020
* @Description methode isNull to check if a SObject is  null 
* @Inputs Boolean isNull(SObject obj)
*/
    public static Boolean isNull(SObject obj){
        return obj==null ?true:false;
    }


    public static Boolean idNotNull(Id id){
        return id!=null ?true:false;
    }

    /**
* @Author Ayoub Ouarti
* @Created 20/02/2020
* @Description methode getIdsOfListObjects to get Set of Ids from a List<SObject> 
* @Inputs Set<Id> getIdsOfListObjects(List<SObject>)
*/
 public static Set<Id> getIdsOfListObjects(List<SObject> listSObject){
     Set<Id> ids = new Set<Id> ();
     if(UM003_TypeManager.isNotNullAndNotEmpty(listSObject))
            for(SObject eachObj: listSObject){
                ids.add(eachObj.Id);
            }
        return ids;
    }

        /**
* @Author Ayoub Ouarti
* @Created 20/02/2020
* @Description methode getFieldsOfListObjects to get Set of fieldAPI from a List<SObject> 
* @Inputs Set<Id> getFieldsOfListObjects(List<SObject> listSObject,String fieldAPI)
*/
    public static Set<String> getFieldsOfListObjects(List<SObject> listSObject,String fieldAPI){
     Set<String> fields = new Set<String>();
     if(UM003_TypeManager.isNotNullAndNotEmpty(listSObject))
            for(SObject eachObj: listSObject){
                fields.add((String)eachObj.get(fieldAPI));
            }
        return fields;
    }

        /**
* @Author Ayoub Ouarti
* @Created 22/06/2020
* @Description methode getMinMaxOfListObjectsDate to get Min & Max dates (fieldAPI) from a List<SObject> listSObject
* @Inputs Date[] getMinMaxOfListObjectsDate(List<SObject> listSObject,String fieldAPI)
*/
    public static Date[] getMinMaxOfListObjectsDate(List<SObject> listSObject,String fieldAPI){
     Date minDate = null;
     Date maxDate = null;
     if(UM003_TypeManager.isNotNullAndNotEmpty(listSObject))
            for(SObject eachObj: listSObject){
                minDate=(minDate==null || minDate> (Date)eachObj.get(fieldAPI)) ? minDate=(Date)eachObj.get(fieldAPI):minDate;
                 maxDate=(maxDate==null || maxDate< (Date)eachObj.get(fieldAPI)) ? maxDate=(Date)eachObj.get(fieldAPI):maxDate;
            }

        return new Date[]{minDate,maxDate};
    }
/*
    public static Map<String,List<SObject>> generateKeyValuesMapOfListObjects(String fieldKeyAPI,List<SObject> listSObject){
    Map<String,List<SObject>> mapOfSObject = new Map<String,List<SObject>>();
     if(UM003_TypeManager.isNotNullAndNotEmpty(listSObject))
            for(SObject eachObj: listSObject){
                if(mapOfSObject.containsKey(fieldKeyAPI)){
                    if(!listContainsValue(mapOfSObject.get(fieldKeyAPI),eachObj,'Id')){
                        mapOfSObject.get(fieldKeyAPI).add(eachObj);
                    }
                }else{

                }
                minDate=(minDate==null || minDate> (Date)eachObj.get(fieldAPI)) ? minDate=(Date)eachObj.get(fieldAPI):minDate;
                 maxDate=(maxDate==null || maxDate< (Date)eachObj.get(fieldAPI)) ? maxDate=(Date)eachObj.get(fieldAPI):maxDate;
            }

        return new Date[]{minDate,maxDate};
    }
*/
     
        /**
* @Author Ayoub Ouarti
* @Created 22/06/2020
* @Description methode listContainsValue to check if a list contains an object using a fieldIdentifierKey
* @Inputs Boolean listContainsValue(List<SObject> listSObject,SObject obj,String fieldIdentifierKey)
*/
    public static Boolean listContainsValue(List<SObject> listSObject,SObject obj,String fieldIdentifierKey){
    
     if(UM003_TypeManager.isNotNullAndNotEmpty(listSObject))
            for(SObject eachObj: listSObject){
               if(((String)obj.get(fieldIdentifierKey)).equals( ((String) eachObj.get(fieldIdentifierKey)) ) ){
                   return true;
               }
            }
        return false;
    }


    /*
    //DCO this must be delete, use EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(objName, rtName) instead
    public static Id getQuoteRecordTypeIdByDeveloperName(String recordTypeDeveloperName){
        return Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).getRecordTypeId();
    }
    */
}