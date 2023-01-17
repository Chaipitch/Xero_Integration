public class XeroInvoiceQueuable Implements Queueable, Database.AllowsCallouts{
    public List<Xero_Contact__c> contacts;
    public List<Xero_Invoice__c> invoiceToCreateContactList;
    public static final Skie_Xero_Variables__c SKIE_XERO_SETTING = Skie_Xero_Variables__c.getOrgDefaults();
    public static final Map<String, String> headerMap = new Map<String, String> {
        XeroCalloutUtils.HTTP_HEADER_CONTENT_TYPE => XeroCalloutUtils.HTTP_CONTENT_TYPE_JSON,
        XeroCalloutUtils.HTTP_HEADER_TENANTID => SKIE_XERO_SETTING.Xero_Tenant_Id__c
    };

    public XeroInvoiceQueuable(List<Xero_Invoice__c> invoiceToCreateContactList, List<Xero_Contact__c> contacts) {
        this.contacts = contacts;
        this.invoiceToCreateContactList = invoiceToCreateContactList;
    }

    public void execute(System.QueueableContext context) {
        // List<XeroData.InvoiceRequest> requests = new List<XeroData.InvoiceRequest>();
        // List<Xero_Log__c> xeroLogList = new List<Xero_Log__c>();

        // List<Xero_Invoice__c> xeroInvoices = [SELECT Id, Xero_Invoice_Id__c, Xero_Contact__r.Xero_Contact_Id__c, Xero_Contact__r.Name, Invoice_Type__c, (select Id, Quantity__c, UnitAmount__c, Description__c, DiscountRate__c from Xero_Invoice_Line__r) FROM Xero_Invoice__c WHERE Id IN :invoiceToCreateContactList];
        // for(Xero_Invoice__c invoice : xeroInvoices) {
        //     XeroData.InvoiceRequest request = XeroAssembler.buildRequestData(invoice.Invoice_Type__c, invoice.Xero_Contact__r, invoice.Xero_Invoice_Line__r);
        //     requests.add(request);
        // }

        // XeroData.InvoiceRequests req = new XeroData.InvoiceRequests();
        // req.Invoices = requests;

        // String requestPayload = JSON.serialize(req, true);
        // System.debug('REQ PAYLOAD::: ' + requestPayload);

        // String endpoint = 'Callout:Xero' + '/api.xro/2.0/Invoices';
        // HttpResponse response =  XeroCalloutUtils.callout(endpoint, 'POST', headerMap, requestPayload);
            
        // XeroData.InvoiceResponse resPayload = (XeroData.InvoiceResponse)JSON.deserialize(response.getBody(), XeroData.InvoiceResponse.class);
        // String resPayloadStr = JSON.serializePretty(resPayload, false);

        // if(resPayload.Status == 'OK') {
        //     List<Xerodata.Invoice> invoiceResList = resPayload.invoices;
    
        //     for(Xerodata.Invoice invoiceData : invoiceResList) {
        //         for(Xero_Invoice__c invoice : invoiceToCreateContactList) {
        //             invoice.Xero_Invoice_Id__c = invoiceData.invoiceID;
        //         }
        //     }

        //     for(Xero_Invoice__c invoice : invoiceToCreateContactList) {
        //         xerologlist.add(XeroAssembler.buildXeroLog(invoice, requestPayload, resPayloadStr, System.now(), resPayload.Message));
        //     }

        // } else {
        //     List<XeroData.Elements> elements = resPayload.Elements;

        //     for(Xerodata.Elements el : elements) {
        //         for(Xero_Invoice__c invoice : invoiceToCreateContactList) {
        //             xerologlist.add(XeroAssembler.buildXeroLog(invoice, requestPayload, resPayloadStr, System.now(), String.valueOf(el.ValidationErrors)));
        //         }
        //     }
        // }

        // insert xeroLogList;
        // update invoiceToCreateContactList;
    }
}