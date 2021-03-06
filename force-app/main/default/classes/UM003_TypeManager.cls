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
    * @Author Erwan Yhuellou
    * @Created 22/02/2021
    * @Description methode getIdsOfListObjects to get Set of fieldAPI from a List<SObject> 
    * @Inputs Set<Id> getIdsOfListObjects(List<SObject> listSObject,String fieldAPI)
    */
    public static Set<Id> getIdsOfListObjects(List<SObject> listSObject,String fieldAPI){
        Set<Id> fields = new Set<Id>();
        if(UM003_TypeManager.isNotNullAndNotEmpty(listSObject))
            for(SObject eachObj: listSObject){
                    fields.add((String)eachObj.get(fieldAPI));                
            }
        return fields;
    }

    /**
    * @Author Erwan Yhuellou
    * @Created 22/02/2021
    * @Description methode getFieldsOfListObjects to get Set of fieldAPI from a List<SObject> 
    * @Inputs Set<Date> getDatesOfListObjects(List<SObject> listSObject,String fieldAPI)
    */
    public static Set<Date> getDatesOfListObjects(List<SObject> listSObject,String fieldAPI){
        Set<Date> fields = new Set<Date>();
        if(UM003_TypeManager.isNotNullAndNotEmpty(listSObject))
            for(SObject eachObj: listSObject){
                    fields.add((Date)eachObj.get(fieldAPI));                
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
                minDate = (minDate == null || minDate > (Date)eachObj.get(fieldAPI)) ? minDate = (Date)eachObj.get(fieldAPI) : minDate;
                maxDate = (maxDate == null || maxDate < (Date)eachObj.get(fieldAPI)) ? maxDate = (Date)eachObj.get(fieldAPI) : maxDate;
            }

        return new Date[]{minDate,maxDate};
    }

    /*
    * 	@Author : Ayoub Ouarti
    * 	@Created 26/06/2020
    *	@Description : this method generate a Map By a choosen field KeyField
    * 	@Inputs	Map<String,SObject> generateMapOfObjectsByKeyField(List<SObject> listSObject,String keyField)
    */
     public static Map<String,SObject> generateMapOfObjectsByKeyField(List<SObject> listSObject,String keyField){
     Map<String,SObject> mapSObject = new Map<String,SObject>();
         if(UM003_TypeManager.isNotNullAndNotEmpty(listSObject)){
             for(SObject eachObj: listSObject){
                 if(!mapSObject.containsKey((String)eachObj.get(keyField))){
                    mapSObject.put((String)eachObj.get(keyField),eachObj);
                 }
             }
         }
        return mapSObject;
    }
    
     /*
    * 	@Author : Erwan Yhuellou
    * 	@Created 08/03/2021
    *	@Description : this method extract scale correctly without rounding
    * 	@Inputs	Decimal value
    */
    public static Decimal getDecimalValueWithScale(Decimal tmpDec, Integer tmpScale) {

        String myNumber = String.valueOf(tmpDec);
        String myTruncatedNumber = myNumber.subString(0,myNumber.indexOf('.') + tmpScale + 1);
        return Decimal.valueOf(myTruncatedNumber);
    }
}