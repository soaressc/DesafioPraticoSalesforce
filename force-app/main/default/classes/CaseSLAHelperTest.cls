@isTest
private class CaseSLAHelperTest {
    @isTest static void testComputeLateCase() {
    Case c = new Case(Urgencia__c = 'Alta', DataLimiteResolucao__c = System.now().addMinutes(-10), MotivoDoCaso__c = 'Falha Crítica');
        insert c;
        CaseSLAHelper.Calc calc = CaseSLAHelper.compute(c.Id);
        System.assertEquals(true, calc.isLate, 'Caso deve estar atrasado');
    }

    @isTest static void testComputeOnTimeCase() {
    Case c = new Case(Urgencia__c = 'Alta', DataLimiteResolucao__c = System.now().addMinutes(10), MotivoDoCaso__c = 'Falha Crítica');
        insert c;
        CaseSLAHelper.Calc calc = CaseSLAHelper.compute(c.Id);
        System.assertEquals(false, calc.isLate, 'Caso deve estar dentro do prazo');
    }

    @isTest static void testApplyDefaultDueDatesUrgenciaNula() {
    List<Case> cases = new List<Case>{ new Case(Urgencia__c = null, MotivoDoCaso__c = 'Falha Crítica') };
        CaseSLAHelper.applyDefaultDueDates(cases, null, System.now());
        System.assertEquals(null, cases[0].DataLimiteResolucao__c, 'Data Limite deve ser nula para urgência nula');
    }

    @isTest static void testApplyDefaultDueDatesUrgenciaInvalida() {
    List<Case> cases = new List<Case>{ new Case(Urgencia__c = 'Inexistente', MotivoDoCaso__c = 'Falha Crítica') };
        CaseSLAHelper.applyDefaultDueDates(cases, null, System.now());
        System.assert(cases[0].DataLimiteResolucao__c == null, 'Data Limite deve ser nula para urgência inválida');
    }

    @isTest static void testApplyDefaultDueDatesListaVazia() {
        List<Case> cases = new List<Case>();
        CaseSLAHelper.applyDefaultDueDates(cases, null, System.now());
        System.assertEquals(0, cases.size(), 'Lista vazia não deve causar erro');
    }

    @isTest static void testApplyDefaultDueDatesListaNula() {
        CaseSLAHelper.applyDefaultDueDates(null, null, System.now());
        System.assert(true, 'Lista nula não deve causar erro');
    }

    @isTest static void testApplyDefaultDueDatesUpdateUrgencia() {
    Case c = new Case(Urgencia__c = 'Baixa', MotivoDoCaso__c = 'Solicitação de Acesso');
        insert c;
        Case oldC = c.clone(false, false, false, false);
        oldC.Urgencia__c = 'Baixa';
        c.Urgencia__c = 'Alta';
        c.MotivoDoCaso__c = 'Falha Crítica';
        List<Case> cases = new List<Case>{ c };
        Map<Id, Case> oldMap = new Map<Id, Case>{ c.Id => oldC };
        CaseSLAHelper.applyDefaultDueDates(cases, oldMap, System.now());
        System.assertNotEquals(null, cases[0].DataLimiteResolucao__c, 'Data Limite deve ser definida ao mudar urgência');
    }
}
