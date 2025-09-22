public with sharing class CaseSLATriggerHandler {
    public static void beforeInsert(List<Case> newList) {
        CaseSLAHelper.applyDefaultDueDates(newList, null, System.now());
    }
    public static void beforeUpdate(List<Case> newList, Map<Id, Case> oldMap) {
        CaseSLAHelper.applyDefaultDueDates(newList, oldMap, System.now());
    }
}