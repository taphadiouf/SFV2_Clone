/**
 * @author Erwan Yhuellou
 * @created 13/01/2020
 * @description PAD Framework used for byPass, log and limit monitoring
 */
public class PAD {
    
    //Used In order to know if user can by pass a class given in parameter
    public static boolean canTrigger(String ApexName) {
        
        String PAD_BypassTrigger; //List of triggers that can be bypassed
        String userRoleName; //User Role Name
        String userProfileName; //User Profile Name

        PAD.log('PAD', 'canTrigger', 'current username', UserInfo.getName());

        User user = [SELECT UserRole.Name, Profile.Name, LPCR_BypassTrigger__c FROM User WHERE Id = : UserInfo.getUserId() LIMIT 1];
        PAD_BypassTrigger = ';' + user.LPCR_BypassTrigger__c + ';';
        userRoleName = user.UserRole.Name;
        userProfileName = user.Profile.Name;

        PAD.log('PAD', 'canTrigger', 'PAD_BypassTrigger.indexOf(ApexName)', String.valueOf(PAD_BypassTrigger.indexOf(';' + ApexName + ';')));

        return (PAD_BypassTrigger.indexOf(';' + ApexName + ';') == -1);
    }

    public static void logAllList(String className, String methodName, String description, List<SObject> listObject) {
        for (SObject o : listObject) {
            System.Debug('>> ' + className + ' - ' + methodName + ' - ' + description + ' - element of list:' + String.valueOf(o));
        } 
    }

    public static void logAllSetId(String className, String methodName, String description, Set<Id> setObject) {
        for (Id o : setObject) {
            System.Debug('>> ' + className + ' - ' + methodName + ' - ' + description + ' - element of set:' + String.valueOf(o));
        } 
    }

    public static void logAllSetString(String className, String methodName, String description, Set<String> setObject) {
        for (String o : setObject) {
            System.Debug('>> ' + className + ' - ' + methodName + ' - ' + description + ' - element of set:' + String.valueOf(o));
        } 
    }

    public static void log(String className, String methodName, String description, String value) {
        System.Debug('>> ' + className + ' - ' + methodName + ' - ' + description + ':' + value);
    }

    public static void log(String className, String methodName, String description, SObject value) {
        System.Debug('>> ' + className + ' - ' + methodName + ' - ' + description + ':' + String.valueOf(value));
    }

    public static void log(String className, String methodName, String description) {
        System.Debug('>> ' + className + ' - ' + methodName + ' - ' + description);
    }

    public static void logLimit(String description) {
        System.Debug('>> logLimit - ' + description);
    }

    public static void limits() {
        logLimit('AggregateQueries - ' + Limits.getAggregateQueries() + ' / ' + Limits.getLimitAggregateQueries());
        logLimit('Callouts - ' + Limits.getCallouts() + ' / ' + Limits.getLimitCallouts());
        logLimit('DMLRows - ' + Limits.getDMLRows() + ' / ' + Limits.getLimitDMLRows());
        logLimit('DMLStatements - ' + Limits.getDMLStatements() + ' / ' + Limits.getLimitDMLStatements());
        logLimit('EmailInvocations - ' + Limits.getEmailInvocations() + ' / ' + Limits.getLimitEmailInvocations());
        logLimit('FindSimilarCalls - ' + Limits.getFindSimilarCalls() + ' / ' + Limits.getLimitFindSimilarCalls());
        logLimit('FutureCalls - ' + Limits.getFutureCalls() + ' / ' + Limits.getLimitFutureCalls());
        logLimit('HeapSize - ' + Limits.getHeapSize() + ' / ' + Limits.getLimitHeapSize());
        logLimit('Queries - ' + Limits.getQueries() + ' / ' + Limits.getLimitQueries());
        logLimit('QueryRows - ' + Limits.getQueryRows() + ' / ' + Limits.getLimitQueryRows());
        logLimit('SavepointRollbacks - ' + Limits.getSavepointRollbacks() + ' / ' + Limits.getLimitSavepointRollbacks());
        logLimit('Savepoints - ' + Limits.getSavepoints() + ' / ' + Limits.getLimitSavepoints());
        logLimit('SoslQueries - ' + Limits.getSoslQueries() + ' / ' + Limits.getLimitSoslQueries());
    }
}