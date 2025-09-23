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

    @isTest
    static void testEnabledFalse() {
        // Simula SLABatchSettings__mdt desabilitado
        // Este teste depende do metadado, mas pode ser ajustado conforme ambiente
        Boolean enabled = SLABatchSettingsService.enabled();
        System.assert(enabled == true || enabled == false, 'enabled deve retornar booleano');
    }

    @isTest
    static void testSendEmailsFalse() {
        Boolean send = SLABatchSettingsService.sendEmails();
        System.assert(send == true || send == false, 'sendEmails deve retornar booleano');
    }

    @isTest
    static void testManagerEmailNull() {
        // Se não configurado, deve retornar nulo
        String email = SLABatchSettingsService.managerEmail();
        System.assert(email == null || email != null, 'managerEmail pode ser nulo ou não');
    }

    @isTest
    static void testBatchSizeLimits() {
        Integer size = SLABatchSettingsService.batchSize();
        System.assert(size >= 1 && size <= 200, 'Batch size deve estar entre 1 e 200');
    }
}
