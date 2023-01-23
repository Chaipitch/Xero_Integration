public class XeroAssembler {
    public static XeroData.InvoiceRequest buildRequestData(String reqType, Xero_Contact__c contact, List<Xero_Invoice_Line__c> lineItems) {
        XeroData.InvoiceRequest request = new XeroData.InvoiceRequest();
        request.type = reqType;

        XeroData.Contact ct = new XeroData.Contact();
        ct.ContactID = contact.Xero_Contact_Id__c;
        request.Contact = ct;

        List<XeroData.LineItem> lines = new List<XeroData.LineItem>();
        for(Xero_Invoice_Line__c xeroInvoice : lineItems) {
            XeroData.LineItem line = new XeroData.LineItem();
            // line.Description = xeroInvoice.Description__c;
            line.Quantity = xeroInvoice.Quantity__c;
            line.UnitAmount = xeroInvoice.UnitAmount__c;
            //line.DiscountRate = xeroInvoice.DiscountRate__c;
            line.AccountCode = '200';
            lines.add(line);
        }
        request.lineItems = lines;

        return request;
    }

    public static XeroData.ContactRequest buildContactRequestData(Xero_Contact__c contact) {
        XeroData.ContactRequest contactRequest = new XeroData.ContactRequest();
        contactRequest.Name = contact.Name;
        contactRequest.ContactID = contact.Xero_Contact_Id__c;
        contactRequest.FirstName = contact.FirstName__c;
        contactRequest.LastName = contact.LastName__c;
        contactRequest.EmailAddress = contact.emailAddress__c;

        return contactRequest;
    }

    public static Xero_Log__c buildXeroLog(Xero_Invoice__c invoice, String req, String res,String processTime, String message, boolean hasError, String description) {
        Xero_Log__c log = new Xero_Log__c();
        log.Xero_Invoice__c = invoice?.Id;
        log.Error_Message__c = message;
        log.Process_Time__c = DateTime.valueOf(processTime);
        log.Request_Payload__c = req;
        log.Response_Payload__c = res;
        log.Error__c = hasError;
        log.Description__c = description;
        
        return log;
    }

    public static Xero_Log__c buildXeroContactLog(Xero_Contact__c contact, String req, String res, String processTime, String message, Boolean hasError, String description) {
        Xero_Log__c log = new Xero_Log__c();
        log.Xero_Contact__c = contact?.Id;
        log.Error_Message__c = message;
        log.Process_Time__c = DateTime.valueOf(processTime);
        log.Request_Payload__c = req;
        log.Response_Payload__c = res;
        log.Error__c = hasError;
        log.Description__c = description;

        return log;
    }

    public static Xero_Log__c buildXeroContactLog(String contact, String req, String res, String processTime, String message, Boolean hasError, String description) {
        Xero_Log__c log = new Xero_Log__c();
        log.Xero_Contact__c = contact;
        log.Error_Message__c = message;
        log.Process_Time__c = DateTime.valueOf(processTime);
        log.Request_Payload__c = req;
        log.Response_Payload__c = res;
        log.Error__c = hasError;
        log.Description__c = description;

        return log;
    }

    public static Xero_Log__c buildLog(String req, String res, String processTime, String message, Boolean hasError, String description) {
        Xero_Log__c log = new Xero_Log__c();
        // log.Xero_Contact__c = contact?.Id;
        log.Error_Message__c = message;
        log.Process_Time__c = DateTime.valueOf(processTime);
        log.Request_Payload__c = req;
        log.Response_Payload__c = res;
        log.Error__c = hasError;
        log.Description__c = description;

        return log;
    }

    public static Xero_Invoice__c buildInvoiceData(XeroData.Invoice invoiceWrapper, Xero_Invoice__c invoice, Xero_Contact__c contact) {
        Xero_Invoice__c sfInvoice;
        if(invoice == null) {
            sfInvoice = new Xero_Invoice__c();
        } else {
            sfInvoice = invoice;
        }

        sfInvoice.Xero_Invoice_Id__c = invoiceWrapper?.invoiceID;
        sfInvoice.Xero_Contact__c = contact?.Id;
        sfInvoice.Invoice_Status_Codes__c = invoiceWrapper?.status;

        return sfInvoice;
    }

    public static Xero_Invoice_Line__c buildInvoiceLineData(Xero_Invoice_Line__c xeroInvoiceLine, XeroData.LineItem lineItem, Xero_Invoice__c inv) {
        Xero_Invoice_Line__c sfInvoiceLine;
        if(xeroInvoiceLine == null) {
            sfInvoiceLine = new Xero_Invoice_Line__c();

        } else {
            sfInvoiceLine = xeroInvoiceLine;
        }

        sfInvoiceLine.Xero_Invoice_Line_ID__c = lineItem?.LineItemId;
        sfInvoiceLine.Description__c = lineItem?.Description;
        sfInvoiceLine.DiscountRate__c = lineItem?.DiscountRate;
        sfInvoiceLine.Quantity__c = lineItem?.Quantity;
        sfInvoiceLine.Xero_Invoice__c = inv?.Id;

        return sfInvoiceLine;
    }

    public static Xero_Contact__c buildContactData(Xero_Contact__c xeroContact, XeroData.Invoice invoiceWrapper) {
        Xero_Contact__c sfContact;
        if(xeroContact == null) {
            sfContact = new Xero_Contact__c();
        } else {
            sfContact = xeroContact;
        }
        
        sfContact.Xero_Contact_Id__c = invoiceWrapper.contact?.ContactID;
        sfContact.Name = invoiceWrapper.contact?.Name;

        return sfContact;
    }
}