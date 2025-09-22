global with sharing class BatchOverdueCases
implements Database.Batchable<SObject>, Schedulable {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Integer cap = SLABatchSettingsService.batchSize();
        return Database.getQueryLocator([
            SELECT Id, CaseNumber, Urgencia__c, DataLimiteResolucao__c
            FROM Case
            WHERE IsClosed = false
              AND DataLimiteResolucao__c != null
              AND DataLimiteResolucao__c < :System.now()
              AND (Urgencia__c = null OR Urgencia__c != 'Alta')   // evita updates desnecessários
            ORDER BY DataLimiteResolucao__c ASC
            LIMIT :cap
        ]);
    }

    global void execute(Database.BatchableContext bc, List<Case> scope) {
        if (scope.isEmpty()) return;

        List<Case> ups = new List<Case>();
        List<String> nums = new List<String>();
        for (Case c : scope) {
            if (c.Urgencia__c != 'Alta') {
                c.Urgencia__c = 'Alta';
                ups.add(c);
            }
            nums.add(c.CaseNumber);
        }
        if (!ups.isEmpty()) update ups;

        if (SLABatchSettingsService.sendEmails()) {
            String toAddr = SLABatchSettingsService.managerEmail();
            if (String.isNotBlank(toAddr)) {
                Messaging.SingleEmailMessage m = new Messaging.SingleEmailMessage();
                m.setToAddresses(new String[] { toAddr });
                m.setSubject('Alerta: Casos com SLA estourado (' + scope.size() + ')');
                m.setPlainTextBody(
                    'Urgência elevada para ALTA em ' + ups.size() + ' caso(s): ' + String.join(nums, ', ')
                );
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { m });
            }
        }
    }

    global void finish(Database.BatchableContext bc) {}

    global void execute(SchedulableContext sc) {
        if (SLABatchSettingsService.enabled()) {
            Integer scopeSize = SLABatchSettingsService.batchSize();
            Database.executeBatch(new BatchOverdueCases(), scopeSize);
        }
    }

    // agenda com CRON expression para cada 5 minutos
    public static void scheduleEveryFive() {
        System.schedule('BatchOverdueCases_Every5', '0 0/5 * * * ?', new BatchOverdueCases());
    }
}