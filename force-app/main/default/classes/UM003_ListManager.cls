/**
   * @author Ayoub Ouarti
   * @date 20/02/2020
   * @List Manager class
*/

public with sharing class UM003_ListManager{

    public static Boolean isNullOrEmpty(List<SObject> listSObject){
        return (listSObject==null || listSObject.size()==0) ?true:false;
    }

    public static Boolean isNotNullAndNotEmpty(List<SObject> listSObject){
        return (listSObject!=null && listSObject.size()>0) ?false:true;
    }

}