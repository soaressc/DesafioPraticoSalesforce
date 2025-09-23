@isTest
private class SLASettingsTest {
    @isTest static void testMinutesByKey() {
        Map<String, Integer> mins = SLASettings.minutesByKey();
        System.assert(mins.containsKey('alta'), 'Deve conter chave "alta"');
        System.assert(mins.get('alta') > 0, 'Minutos para "alta" deve ser positivo');
    }

    @isTest static void testNormalize() {
    String s = 'Média';
    String norm = SLASettings.normalize(s).toLowerCase();
    System.assertEquals('media', norm, 'Normalização deve remover acento');
    }
}
