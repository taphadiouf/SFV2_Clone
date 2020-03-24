/**
* @author Achraf ABOUL
* @date 24/03/2020
* @SOQL Abstract class for all  Entity  classes
*/
public abstract class EM001_AbstractObjectEntity{
    String sObjectAPIName;
    public EM001_AbstractObjectEntity(String sObjectAPIName) {
        this.sObjectAPIName = sObjectAPIName;
    }
    public void doInsert(List<SObject> l){
        insert l;
    }
    public List<SObject> getByIds(Set<Id> idsSet, Set<String> fields){
        String queryString = 'SELECT Id';
        for(String eachField : fields){
            queryString += (',' + eachField);
        }
        queryString += (' FROM ' + this.sObjectAPIName + ' WHERE Id IN :idsSet');
        return Database.query(queryString);
    }
}
