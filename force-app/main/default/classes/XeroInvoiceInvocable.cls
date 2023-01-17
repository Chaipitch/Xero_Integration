public class XeroInvoiceInvocable {
    @InvocableMethod(label='Sync Xero Invoices' description='Create Invoices in Xero via Salesforce')
    public static List<Response> syncSalesforceInvoicesToXero(List<Request> reqList) {
        String invoiceID = reqList[0].invoiceID;
        List<Response> responses = new List<Response>();
        Response res = new Response();
        try {
            XeroInvoiceService.validateOperationInvocable(invoiceID);
        } catch (Exception e) {
            res.errorMsg = '[Error] Uncaught Exception with message: ' + e.getMessage() + '\n' + e.getStackTraceString();
        }
        
        responses.add(res);
        return responses;
    }
    
    public class Request {
        @invocableVariable(label='InvoiceID' required=true)
        public String invoiceID;
    }

    public class Response {
        @invocableVariable(label='Import Error Message')
        public String errorMsg;
    }
}