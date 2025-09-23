public with sharing class SLABatchSettingsService {
    public static final Integer DEFAULT_BATCH_SIZE = 25;
    public static final Boolean DEFAULT_ENABLED     = true;
    public static final Boolean DEFAULT_SEND_EMAILS = true;
    public static final String  DEFAULT_MANAGER     = null;

    public static SLABatchSettings__mdt get() {
        SLABatchSettings__mdt s = SLABatchSettings__mdt.getInstance('Default');
        if (s == null) {
            // Fallback: tenta pegar QUALQUER registro (útil em orgs onde o dev name não é “Default”)
            List<SLABatchSettings__mdt> cmdt = [
                SELECT Enabled__c, SendEmails__c, ManagerEmail__c, BatchSize__c
                FROM SLABatchSettings__mdt LIMIT 1
            ];
            s = cmdt.isEmpty() ? null : cmdt[0];
        }
        return s;
    }

    public static Boolean enabled() {
        SLABatchSettings__mdt s = get();
        return (s != null) ? s.Enabled__c : DEFAULT_ENABLED;
    }

    public static Boolean sendEmails() {
        SLABatchSettings__mdt s = get();
        return (s != null) ? s.SendEmails__c : DEFAULT_SEND_EMAILS;
    }

    public static String managerEmail() {
        SLABatchSettings__mdt s = get();
        return (s != null && String.isNotBlank(s.ManagerEmail__c)) ? s.ManagerEmail__c : DEFAULT_MANAGER;
    }

    public static Integer batchSize() {
        SLABatchSettings__mdt s = get();
        Integer n = (s != null && s.BatchSize__c != null) ? (Integer)s.BatchSize__c : DEFAULT_BATCH_SIZE;
        return Math.max(1, Math.min(200, n));
    }
}
