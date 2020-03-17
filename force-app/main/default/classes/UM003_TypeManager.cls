/**
   * @author Ayoub Ouarti
   * @date 20/02/2020
   * @Type Manager class
*/

public with sharing class UM003_TypeManager{

    public static Boolean isNullOrEmpty(List<SObject> listSObject){
        return (listSObject==null || listSObject.size()==0) ?true:false;
    }

    public static Boolean isNotNullAndNotEmpty(List<SObject> listSObject){
        return (listSObject!=null && listSObject.size()>0) ?true:false;
    }


    public static Boolean isNotNull(SObject obj){
        return obj!=null ?true:false;
    }
    public static Boolean isNull(SObject obj){
        return obj==null ?true:false;
    }

    public static Boolean idNotNull(Id id){
        return id!=null ?true:false;
    }

 public static Set<Id> getIdsOfListObjects(List<SObject> listSObject){
     Set<Id> ids = new Set<Id> ();
     if(UM003_TypeManager.isNotNullAndNotEmpty(listSObject))
            for(SObject eachObj: listSObject){
                ids.add(eachObj.Id);
            }
        return ids;
    }

}