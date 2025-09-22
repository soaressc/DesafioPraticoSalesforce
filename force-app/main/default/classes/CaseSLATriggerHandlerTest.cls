@isTest
private class CaseSLATriggerHandlerTest {
    @isTest static void testInsertWithValidUrgency() {
        Case c = new Case(Urgencia__c = 'Alta');
        insert c;
        c = [SELECT DataLimiteResolucao__c FROM Case WHERE Id = :c.Id];
        System.assertNotEquals(null, c.DataLimiteResolucao__c, 'Data Limite deve ser definida para urgência válida');
    }

    @isTest static void testInsertWithInvalidUrgency() {
        Case c = new Case(Urgencia__c = 'Inexistente');
        try {
            insert c;
            System.assert(false, 'Deveria lançar erro de configuração de SLA');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('configuração de SLA não encontrada'), 'Mensagem de erro esperada');
        }
    }

    @isTest static void testUpdateUrgencyChange() {
        Case c = new Case(Urgencia__c = 'Baixa');
        insert c;
        c.Urgencia__c = 'Alta';
        update c;
        c = [SELECT DataLimiteResolucao__c FROM Case WHERE Id = :c.Id];
        System.assertNotEquals(null, c.DataLimiteResolucao__c, 'Data Limite deve ser redefinida ao mudar urgência');
    }
}
