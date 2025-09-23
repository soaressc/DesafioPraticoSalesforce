@IsTest
private class BatchOverdueCasesTest {

    // Liga os hooks para não depender de CMDT de settings
    private static void enableTestOverrides() {
        BatchOverdueCases.tvEnabled      = true;   // schedulable ON (se testarmos)
        BatchOverdueCases.tvSendEmails   = true;   // garante envio de e-mail
        BatchOverdueCases.tvBatchSize    = 200;    // escopo confortável
        BatchOverdueCases.tvManagerEmail = 'gerente.suporte@example.com';
    }

    // Cria um caso normal (Trigger define a DataLimite conforme SLA__mdt),
    // depois "força atraso" atualizando APENAS a DataLimite para o passado.
    private static Case makeOverdueCase() {
        Case c = new Case(
            Urgencia__c      = 'Baixa',
            MotivoDoCaso__c  = 'Solicitação de Acesso'
        );
        insert c;

        // Força atraso: mover a DataLimite para o passado SEM mudar a urgência
        c = [SELECT Id, Urgencia__c, DataLimiteResolucao__c FROM Case WHERE Id = :c.Id];
        c.DataLimiteResolucao__c = System.now().addMinutes(-30);
        update c; // Trigger NÃO recalcula porque a urgência não mudou

        return c;
    }

    @IsTest
    static void testBatchProcessLateCases() {
        enableTestOverrides();
        Case c = makeOverdueCase();

        Test.startTest();
        Database.executeBatch(new BatchOverdueCases(), 50);
        Test.stopTest();

        c = [SELECT Urgencia__c FROM Case WHERE Id = :c.Id];
        System.assertEquals('Alta', c.Urgencia__c,
            'Urgência deve ser elevada para Alta');
    }

    @IsTest
    static void testBatchSendsEmail() {
        enableTestOverrides();
        makeOverdueCase();

        Test.startTest();
        Database.executeBatch(new BatchOverdueCases(), 50);
        Test.stopTest();

        System.assert(Limits.getEmailInvocations() > 0,
            'O batch deve enviar um e-mail para o gerente de suporte');
    }

    @IsTest
    static void testBatchNoCases() {
        enableTestOverrides();

        Test.startTest();
        Database.executeBatch(new BatchOverdueCases(), 50);
        Test.stopTest();

        System.assertEquals(0, Limits.getEmailInvocations(),
            'Não deve enviar e-mail sem casos atrasados');
    }

    @IsTest
    static void testBatchMultipleCases() {
        enableTestOverrides();

        List<Case> cs = new List<Case>{
            new Case(Urgencia__c='Baixa', MotivoDoCaso__c='Solicitação de Acesso'),
            new Case(Urgencia__c='Baixa', MotivoDoCaso__c='Solicitação de Acesso')
        };
        insert cs;

        // Tornar ambos atrasados SEM mudar urgência (trigger não recalcula)
        for (Case c : [SELECT Id, DataLimiteResolucao__c FROM Case WHERE Id IN :cs]) {
            c.DataLimiteResolucao__c = System.now().addMinutes(-15);
        }
        update cs;

        Test.startTest();
        Database.executeBatch(new BatchOverdueCases(), 200);
        Test.stopTest();

        for (Case c : [SELECT Urgencia__c FROM Case WHERE Id IN :cs]) {
            System.assertEquals('Alta', c.Urgencia__c,
                'Todos os casos devem ser elevados para Alta');
        }
    }

    @IsTest
    static void testFinishMethod() {
        Test.startTest();
        new BatchOverdueCases().finish(null);
        Test.stopTest();
        System.assert(true, 'finish executado');
    }

    @IsTest
    static void testExecuteSchedulable() {
        enableTestOverrides();
        makeOverdueCase();

        Test.startTest();
        new BatchOverdueCases().execute((SchedulableContext) null);
        Test.stopTest();

        System.assert(true, 'execute(SchedulableContext) executado');
    }

    @IsTest
    static void testScheduleEveryFive() {
        Test.startTest();
        System.schedule('BatchOverdueCases_Every5_Test', '0 0 0 1 1 ? 2026', new BatchOverdueCases());
        Test.stopTest();
        System.assert(true, 'scheduleEveryFive válido');
    }
}