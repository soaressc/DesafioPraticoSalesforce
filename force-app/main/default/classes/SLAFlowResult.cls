public with sharing class SLAFlowResult {
    // Campos expostos ao Flow via @InvocableVariable
    @InvocableVariable public Long minutesRemaining;
    @InvocableVariable public Boolean isLate;
    @InvocableVariable public String alertMessage;
    @InvocableVariable public String caseNumber;
    @InvocableVariable public Datetime dueAt;
}