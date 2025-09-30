global with sharing class BatchOverdueCases
implements Database.Batchable<SObject>, Schedulable {

    // ---- Test hooks (@TestVisible) ----
    @TestVisible static Boolean tvEnabled;
    @TestVisible static Boolean tvSendEmails;
    @TestVisible static Integer tvBatchSize;
    @TestVisible static String  tvManagerEmail;

    // ---- Accessors (overrides em teste; serviço em produção) ----
    private static Boolean getEnabled()     { return (tvEnabled != null)    ? tvEnabled    : SLABatchSettingsService.enabled(); }
    private static Boolean getSendEmails()  { return (tvSendEmails != null) ? tvSendEmails : SLABatchSettingsService.sendEmails(); }
    private static Integer getBatchSize()   {
        Integer v = (tvBatchSize != null) ? tvBatchSize : SLABatchSettingsService.batchSize();
        return (v != null && v > 0) ? v : 200;
    }
    private static String getManagerEmail() { return (tvManagerEmail != null)? tvManagerEmail: SLABatchSettingsService.managerEmail(); }

    // ---- Batchable ----
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Integer cap = getBatchSize();
        return Database.getQueryLocator([
            SELECT Id, CaseNumber, Urgencia__c, DataLimiteResolucao__c
            FROM Case
            WHERE IsClosed = false
              AND DataLimiteResolucao__c != null
              AND DataLimiteResolucao__c < :System.now()
              AND (Urgencia__c = null OR Urgencia__c != 'Alta')
            ORDER BY DataLimiteResolucao__c ASC
            LIMIT :cap
        ]);
    }

    global void execute(Database.BatchableContext bc, List<Case> scope) {
        if (scope.isEmpty()) return;

        List<Case> ups = new List<Case>();
        List<String> nums = new List<String>();

        for (Case c : scope) {
            if (c.Urgencia__c == null || c.Urgencia__c != 'Alta') {
                c.Urgencia__c = 'Alta';
                ups.add(c);
            }
            nums.add(c.CaseNumber);
        }

        if (!ups.isEmpty()) {
            // allOrNone=false para não derrubar o lote inteiro caso alguma RV bloqueie
            Database.update(ups, /*allOrNone*/ false);
        }

        if (getSendEmails() && !nums.isEmpty()) {
            String toAddr = getManagerEmail();
            if (String.isNotBlank(toAddr)) {
                Messaging.SingleEmailMessage m = new Messaging.SingleEmailMessage();
                m.setToAddresses(new String[] { toAddr });
                m.setSubject('Alerta: Casos com SLA estourado (' + nums.size() + ')');
                m.setPlainTextBody('Urgência elevada para ALTA nos casos: ' + String.join(nums, ', '));
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { m });
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
        if (!getEnabled()) return;
    
        String ts = Datetime.now().format('yyyyMMdd_HHmmss');
        String jobName = 'BatchOverdueCases_' + ts;

        Integer minutes = 5;
        if (Test.isRunningTest()) {
            // Em testes, mantenha pequeno para rodar dentro do start/stop
            minutes = 1;
        }
    
        Integer scope = getBatchSize();
    
        try {
            System.scheduleBatch(new BatchOverdueCases(), jobName, minutes, scope);
        } catch (Exception ex) {
            String fallbackName = 'BatchOverdueCases_' + String.valueOf(Crypto.getRandomInteger());
            try {
                System.scheduleBatch(new BatchOverdueCases(), fallbackName, Math.max(1, minutes), scope);
            } catch (Exception ex2) {
                System.debug(LoggingLevel.ERROR,
                    'Falha ao reagendar BatchOverdueCases: ' + ex.getMessage() + ' | Fallback: ' + ex2.getMessage());
            }
        }
    }

    // ---- Schedulable ----
    global void execute(SchedulableContext sc) {
        if (getEnabled()) {
            Database.executeBatch(new BatchOverdueCases(), getBatchSize());
        }
    }

}