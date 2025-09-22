@isTest
private class BatchOverdueCasesTest {
    @isTest
    static void testBatchProcessLateCases() {
        // Cria caso atrasado
        Case c = new Case(Urgencia__c = 'Baixa', DataLimiteResolucao__c = System.now().addMinutes(-5));
        insert c;
        Test.startTest();
        BatchOverdueCases batch = new BatchOverdueCases();
        Database.executeBatch(batch, 1);
        Test.stopTest();
        c = [SELECT Urgencia__c FROM Case WHERE Id = :c.Id];
        System.assertEquals('Alta', c.Urgencia__c, 'Urgência deve ser elevada para Alta');
    }
}
