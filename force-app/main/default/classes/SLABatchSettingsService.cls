public with sharing class SLABatchSettingsService {
    public static final Integer DEFAULT_BATCH_SIZE = 25;

    public static SLABatchSettings__mdt get() {
        return SLABatchSettings__mdt.getInstance('Default');
    }
    public static Boolean enabled() {
        SLABatchSettings__mdt s = get(); return s != null && s.Enabled__c;
    }
    public static Boolean sendEmails() {
        SLABatchSettings__mdt s = get(); return s != null && s.SendEmails__c;
    }
    public static String managerEmail() {
        SLABatchSettings__mdt s = get(); return (s != null) ? s.ManagerEmail__c : null;
    }
    public static Integer batchSize() {
        SLABatchSettings__mdt s = get();
        Integer n = (s != null && s.BatchSize__c != null) ? (Integer)s.BatchSize__c : DEFAULT_BATCH_SIZE;
        return Math.max(1, Math.min(200, n)); // scope do batch: 1..200
    }
}