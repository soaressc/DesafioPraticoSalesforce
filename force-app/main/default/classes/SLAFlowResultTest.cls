@isTest
private class SLAFlowResultTest {

    @isTest
    static void testSLAFlowResultFields() {
        SLAFlowResult res = new SLAFlowResult();
        res.caseId = '001xx000003DGSWAA4';
        res.minutesRemaining = 10;
        res.isLate = false;
        res.alertMessage = 'Dentro do prazo.';
        System.assertEquals('001xx000003DGSWAA4', res.caseId);
        System.assertEquals(10, res.minutesRemaining);
        System.assertEquals(false, res.isLate);
        System.assertEquals('Dentro do prazo.', res.alertMessage);
    }
}
