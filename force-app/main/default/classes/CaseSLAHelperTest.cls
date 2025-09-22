@isTest
private class CaseSLAHelperTest {
    @isTest static void testComputeLateCase() {
        Case c = new Case(Urgencia__c = 'Alta', DataLimiteResolucao__c = System.now().addMinutes(-10));
        insert c;
        CaseSLAHelper.Calc calc = CaseSLAHelper.compute(c.Id);
        System.assertEquals(true, calc.isLate, 'Caso deve estar atrasado');
    }

    @isTest static void testComputeOnTimeCase() {
        Case c = new Case(Urgencia__c = 'Alta', DataLimiteResolucao__c = System.now().addMinutes(10));
        insert c;
        CaseSLAHelper.Calc calc = CaseSLAHelper.compute(c.Id);
        System.assertEquals(false, calc.isLate, 'Caso deve estar dentro do prazo');
    }
}
