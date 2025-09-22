@isTest
private class CaseSLAFlowInvocableTest {
    @isTest
    static void testFlowInvocable() {
        List<Case> cases = new List<Case>{
            new Case(Urgencia__c = 'Alta'),
            new Case(Urgencia__c = 'Baixa')
        };
        insert cases;
        List<Id> ids = new List<Id>();
        for (Case c : cases) ids.add(c.Id);
        List<SLAFlowResult> results = CaseSLAFlowInvocable.getSLAResults(ids);
        System.assertEquals(2, results.size(), 'Deve retornar resultado para cada caso');
    }
}
