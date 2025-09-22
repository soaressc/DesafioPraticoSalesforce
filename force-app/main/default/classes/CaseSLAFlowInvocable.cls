public with sharing class CaseSLAFlowInvocable {

    public class Request {
        @InvocableVariable(required=true) public Id caseId;
    }

    @InvocableMethod(label='Obter SLA de Caso')
    public static List<SLAFlowResult> getCaseSLA(List<Request> reqs) {
        List<SLAFlowResult> outs = new List<SLAFlowResult>();

        for (Request r : reqs) {
            SLAFlowResult dto = new SLAFlowResult();

            if (r != null && r.caseId != null) {
                CaseSLAHelper.Calc calc = CaseSLAHelper.compute(r.caseId);
                dto.minutesRemaining = calc.minutesRemaining;
                dto.isLate = calc.isLate;
                dto.alertMessage = calc.alertMessage;
                dto.caseNumber = calc.caseNumber;
                dto.dueAt = calc.dueAt;
            }

            outs.add(dto);
        }
        return outs;
    }
}