@isTest
private class SLABatchSettingsServiceTest {
    @isTest
    static void testBatchSize() {
        Integer size = SLABatchSettingsService.batchSize();
        System.assert(size > 0, 'Batch size deve ser positivo');
    }
    @isTest
    static void testManagerEmail() {
        String email = SLABatchSettingsService.managerEmail();
        System.assertNotEquals(null, email, 'Email do gerente deve estar configurado');
    }
}
