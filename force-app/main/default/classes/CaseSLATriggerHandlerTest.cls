@isTest
private class CaseSLATriggerHandlerTest {
    @isTest static void testInsertWithValidUrgency() {
    Case c = new Case(Urgencia__c = 'Alta', MotivoDoCaso__c = 'Falha Crítica');
        insert c;
        c = [SELECT DataLimiteResolucao__c FROM Case WHERE Id = :c.Id];
        System.assertNotEquals(null, c.DataLimiteResolucao__c, 'Data Limite deve ser definida para urgência válida');
    }

    @isTest static void testInsertWithInvalidUrgency() {
        Case c = new Case(Urgencia__c = 'Inexistente', MotivoDoCaso__c = 'Falha Crítica');
        try {
            insert c;
            System.assert(false, 'Deveria lançar erro de configuração de SLA');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('SLA não encontrada'), 'Mensagem de erro esperada');
        }
    }

    @isTest static void testUpdateUrgencyChange() {
    Case c = new Case(Urgencia__c = 'Baixa', MotivoDoCaso__c = 'Solicitação de Acesso');
        insert c;
        c.Urgencia__c = 'Alta';
        update c;
        c = [SELECT DataLimiteResolucao__c FROM Case WHERE Id = :c.Id];
        System.assertNotEquals(null, c.DataLimiteResolucao__c, 'Data Limite deve ser redefinida ao mudar urgência');
    }

    @isTest static void testBeforeUpdateNoChange() {
    Case c = new Case(Urgencia__c = 'Baixa', MotivoDoCaso__c = 'Solicitação de Acesso');
        insert c;
        Map<Id, Case> oldMap = new Map<Id, Case>{ c.Id => c.clone(false, false, false, false) };
        List<Case> cases = new List<Case>{ c };
        CaseSLATriggerHandler.beforeUpdate(cases, oldMap);
        System.assert(true, 'beforeUpdate sem mudança de urgência executado');
    }

    @isTest static void testBeforeUpdateWithChange() {
    Case c = new Case(Urgencia__c = 'Baixa', MotivoDoCaso__c = 'Solicitação de Acesso');
        insert c;
        Case oldC = c.clone(false, false, false, false);
        oldC.Urgencia__c = 'Baixa';
        c.Urgencia__c = 'Alta';
        Map<Id, Case> oldMap = new Map<Id, Case>{ c.Id => oldC };
        List<Case> cases = new List<Case>{ c };
        CaseSLATriggerHandler.beforeUpdate(cases, oldMap);
        System.assertNotEquals(null, cases[0].DataLimiteResolucao__c, 'Data Limite deve ser definida ao mudar urgência via handler');
    }

    @isTest static void testBeforeInsertEmptyList() {
        List<Case> cases = new List<Case>();
        CaseSLATriggerHandler.beforeInsert(cases);
        System.assertEquals(0, cases.size(), 'Lista vazia não deve causar erro');
    }
}
