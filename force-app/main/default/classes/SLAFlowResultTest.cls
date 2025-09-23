@isTest
private class SLAFlowResultTest {

    @isTest
    static void testSLAFlowResultFields() {
        SLAFlowResult res = new SLAFlowResult();
        res.caseNumber = '000123';
        res.minutesRemaining = 10;
        res.isLate = false;
        res.alertMessage = 'Dentro do prazo.';
        res.dueAt = System.now().addDays(1);
        System.assertEquals('000123', res.caseNumber);
        System.assertEquals(10, res.minutesRemaining);
        System.assertEquals(false, res.isLate);
        System.assertEquals('Dentro do prazo.', res.alertMessage);
        System.assertNotEquals(null, res.dueAt);
    }
}
