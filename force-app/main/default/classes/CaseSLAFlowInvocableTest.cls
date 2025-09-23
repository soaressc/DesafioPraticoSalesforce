@isTest
private class CaseSLAFlowInvocableTest {
    @isTest
    static void testFlowInvocable() {
        List<Case> cases = new List<Case>{
            new Case(Urgencia__c = 'Alta', MotivoDoCaso__c = 'Falha Crítica'),
            new Case(Urgencia__c = 'Baixa', MotivoDoCaso__c = 'Solicitação de Acesso')
        };
        insert cases;
        List<CaseSLAFlowInvocable.Request> reqs = new List<CaseSLAFlowInvocable.Request>();
        for (Case c : cases) {
            CaseSLAFlowInvocable.Request r = new CaseSLAFlowInvocable.Request();
            r.caseId = c.Id;
            reqs.add(r);
        }
        List<SLAFlowResult> results = CaseSLAFlowInvocable.getCaseSLA(reqs);
        System.assertEquals(2, results.size(), 'Deve retornar resultado para cada caso');
    }

    @isTest
    static void testNullRequest() {
    List<CaseSLAFlowInvocable.Request> reqs = new List<CaseSLAFlowInvocable.Request>{null};
        List<SLAFlowResult> results = CaseSLAFlowInvocable.getCaseSLA(reqs);
        System.assertEquals(1, results.size(), 'Deve retornar resultado mesmo para request nulo');
    }

    @isTest
    static void testNullCaseId() {
        CaseSLAFlowInvocable.Request r = new CaseSLAFlowInvocable.Request();
        r.caseId = null;
        List<SLAFlowResult> results = CaseSLAFlowInvocable.getCaseSLA(new List<CaseSLAFlowInvocable.Request>{r});
        System.assertEquals(1, results.size(), 'Deve retornar resultado para caseId nulo');
    }

    @isTest
    static void testNoDueDate() {
    Case c = new Case(Urgencia__c = 'Alta', MotivoDoCaso__c = 'Falha Crítica');
    insert c;
    CaseSLAFlowInvocable.Request r = new CaseSLAFlowInvocable.Request();
    r.caseId = c.Id;
    List<SLAFlowResult> results = CaseSLAFlowInvocable.getCaseSLA(new List<CaseSLAFlowInvocable.Request>{r});
    System.assertEquals(1, results.size(), 'Deve retornar resultado para caso sem DataLimiteResolucao__c');
    System.assert(results[0].minutesRemaining == null || results[0].minutesRemaining == 0, 'minutesRemaining deve ser nulo ou zero');
    }
}
