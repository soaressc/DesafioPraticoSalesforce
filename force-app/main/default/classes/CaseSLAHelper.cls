public with sharing class CaseSLAHelper {

    // classe DTO que concentra o resultado do cálculo de SLA
    public class Calc {
        public Long minutesRemaining;
        public Boolean isLate;
        public String alertMessage;
        public String caseNumber;
        public Datetime dueAt;
    }

    // executa a regra de negócio do SLA para um registro de caso e devolve um Calc preenchido
    public static Calc compute(Id caseId) {
        Calc res = new Calc();
        if (caseId == null) return res;

        List<Case> cs = [
            SELECT CaseNumber, DataLimiteResolucao__c
            FROM Case
            WHERE Id = :caseId
            LIMIT 1
        ];

        if (!cs.isEmpty()) {
            Case c = cs[0];
            if (c.DataLimiteResolucao__c != null) {
                Datetime nowDT = System.now();
                Long diffMin = (c.DataLimiteResolucao__c.getTime() - nowDT.getTime()) / 60000L;

                res.minutesRemaining = diffMin;
                res.isLate = diffMin < 0;
                res.alertMessage = res.isLate ? 'SLA ESTOURADO!' : 'Dentro do prazo.';
                res.caseNumber = c.CaseNumber;
                res.dueAt = c.DataLimiteResolucao__c;
            }
        }
        return res;
    }
    
    // aplica valores no campo de data limite
    public static void applyDefaultDueDates(List<Case> records, Map<Id, Case> oldMap, Datetime nowDT) {
        if (records == null || records.isEmpty()) return;

        Map<String, Integer> minsByKey = SLASettings.minutesByKey();

        for (Case c : records) {
            // dispara na criação OU quando a urgência mudou
            Boolean mustSet = (oldMap == null);
            if (!mustSet) {
                Case oldC = oldMap.get(c.Id);
                mustSet = (oldC == null) || (c.Urgencia__c != oldC.Urgencia__c);
            }
            if (!mustSet) continue;

            if (c.Urgencia__c == null) { c.DataLimiteResolucao__c = null; continue; }

            String key = c.Urgencia__c.toLowerCase();
            Integer mins = minsByKey.get(key);
            if (mins == null) mins = minsByKey.get(SLASettings.normalize(key));

            if (mins == null) {
                if ('média'.equalsIgnoreCase(c.Urgencia__c)) mins = minsByKey.get('media');
                else if ('alta'.equalsIgnoreCase(c.Urgencia__c)) mins = minsByKey.get('alta');
                else if ('baixa'.equalsIgnoreCase(c.Urgencia__c)) mins = minsByKey.get('baixa');
            }
                if (mins == null) {
                    // Validação: não encontrou configuração de minutos para urgência
                    c.addError('Não foi possível definir o prazo de resolução: configuração de SLA não encontrada para urgência "' + c.Urgencia__c + '".');
                    c.DataLimiteResolucao__c = null;
                    continue;
                }

            c.DataLimiteResolucao__c = (mins != null) ? nowDT.addMinutes(mins) : null;
        }
    }
}