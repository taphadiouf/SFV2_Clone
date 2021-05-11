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