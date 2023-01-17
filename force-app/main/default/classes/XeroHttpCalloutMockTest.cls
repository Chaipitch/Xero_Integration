@isTest
public class XeroHttpCalloutMockTest implements HttpCalloutMock{
    HttpResponse res;

    Map<String, HttpResponse> responseByEndpointOrContent;

    public XeroHttpCalloutMockTest(HttpResponse res, Map<String, HttpResponse> responseByEndpointOrContent) {
        this.res = res;
        this.responseByEndpointOrContent = responseByEndpointOrContent;
    }

    public HttpResponse respond(HttpRequest req) {
        String endpoint = req.getEndpoint().substringBefore('?');
        String Key = req.getMethod() + '_' + endpoint;

        if(responseByEndpointOrContent == null) {
            return res;

        } else {
            if(responseByEndpointOrContent.containsKey(key)) {
                return responseByEndpointOrContent.get(key);
            }
        }

        return res;
    }

    public static void setTestMockResponse(Integer statusCode, String status, String body, Map<String, HttpResponse> responseByEndpointOrContent) {
        HttpResponse mockResponse = new HttpResponse();

        if(statusCode != null) {
            mockResponse.setStatusCode(statusCode);
        }

        if(status != null) {
            mockResponse.setStatus(status);
        }

        if(body != null) {
            mockResponse.setBody(body);
        }

        Test.setMock(HttpCalloutMock.class, new XeroHttpCalloutMockTest(mockResponse, responseByEndpointOrContent));
    }

    public static String postInvoiceToXeroSuccessResponse() {
        return '{"Id":"05c38e77-01fd-467b-b73e-191f03832ac8","Status":"OK","ProviderName":"Salesforce Auth App","DateTimeUTC":"/Date(1672111566477)/","Invoices":[{"Type":"ACCREC","InvoiceID":"bc1160b2-0d76-433b-bd1f-7550a11023aa","InvoiceNumber":"INV-0079","Reference":"","Prepayments":[],"Overpayments":[],"AmountDue":6074.99,"AmountPaid":0,"SentToContact":false,"CurrencyRate":1,"IsDiscounted":false,"HasErrors":false,"InvoicePaymentServices":[],"Contact":{"ContactID":"eec1f8d9-b695-4def-b8fa-09d221a7d6d6","ContactStatus":"ACTIVE","Name":"testCt5","FirstName":"testCt5","LastName":"testCt5","HasValidationErrors":false},"BrandingThemeID":"d613f7f9-8fcb-477f-97f0-31eb85b7e5cf","Status":"DRAFT","LineAmountTypes":"Exclusive","LineItems":[{"Description":"Lamp","UnitAmount":23,"TaxType":"OUTPUT","TaxAmount":462.99,"LineAmount":5612,"AccountCode":"200","Tracking":[],"Quantity":244,"LineItemID":"a2bbf76f-a608-4d5c-8cc0-6ba1a88c3e3c","ValidationErrors":[]}],"SubTotal":5612,"TotalTax":462.99,"Total":6074.99,"UpdatedDateUTC":"/Date(1672111566430+0000)/","CurrencyCode":"USD"}]}';
    }

    public static String postContactToXeroSuccessResponse() {
        return '{"Id":"bf0fb416-05b7-4b70-834e-bd32536dbe01","Status":"OK","ProviderName":"Salesforce Auth App","DateTimeUTC":"/Date(1672389194052)/","Contacts":[{"ContactID":"df897507-bfff-4e28-afe9-05c304cdc5b5","ContactStatus":"ACTIVE","Name":"testct23","FirstName":"testct23","LastName":"testc23","EmailAddress":"","BankAccountDetails":"","Addresses":[{"AddressType":"STREET","City":"","Region":"","PostalCode":"","Country":""},{"AddressType":"POBOX","City":"","Region":"","PostalCode":"","Country":""}],"Phones":[{"PhoneType":"DEFAULT","PhoneNumber":"","PhoneAreaCode":"","PhoneCountryCode":""},{"PhoneType":"DDI","PhoneNumber":"","PhoneAreaCode":"","PhoneCountryCode":""},{"PhoneType":"FAX","PhoneNumber":"","PhoneAreaCode":"","PhoneCountryCode":""},{"PhoneType":"MOBILE","PhoneNumber":"","PhoneAreaCode":"","PhoneCountryCode":""}],"UpdatedDateUTC":"/Date(1672388392097+0000)/","ContactGroups":[],"IsSupplier":false,"IsCustomer":true,"SalesTrackingCategories":[],"PurchasesTrackingCategories":[],"ContactPersons":[],"HasValidationErrors":false}]}';
    }

    public static String postInvoiceToXeroErrorResponse() {
        return '{"ErrorNumber":10,"Type":"ValidationException","Message":"A validation exception occurred","Elements":[{"Type":"ACCREC","InvoiceID":"00000000-0000-0000-0000-000000000000","Payments":[],"CreditNotes":[],"Prepayments":[],"Overpayments":[],"IsDiscounted":false,"InvoiceAddresses":[],"HasErrors":true,"InvoicePaymentServices":[],"Contact":{"ContactID":"a55bdefb-85e7-4e0e-a15e-1474f65029e0","Addresses":[],"Phones":[],"ContactGroups":[],"ContactPersons":[],"HasValidationErrors":false,"ValidationErrors":[]},"DateString":"2022-12-26T00:00:00","Date":"/Date(1672012800000+0000)/","Status":"DRAFT","LineAmountTypes":"Exclusive","LineItems":[],"SubTotal":0,"TotalTax":0,"Total":0,"CurrencyCode":"USD","ValidationErrors":[{"Message":"One or more line items must be specified"}]}]}';
    }

    public static String postContactToXeroErrorResponse() {
        return '';
    }

    public static String getInvoiceFromXeroSuccessResponse() {
        return '{"Id":"255794ca-4205-43fc-b696-bb5631ad01b9","Status":"OK","ProviderName":"Salesforce Auth App","DateTimeUTC":"/Date(1673595369668)/","Invoices":[{"Type":"ACCREC","InvoiceID":"a078d378-ee75-4c8c-b450-527fa6099f50","InvoiceNumber":"INV-0110","Reference":"","Payments":[],"CreditNotes":[],"Prepayments":[],"Overpayments":[],"AmountDue":21.7,"AmountPaid":0,"AmountCredited":0,"CurrencyRate":1,"IsDiscounted":false,"HasAttachments":false,"InvoiceAddresses":[],"HasErrors":false,"InvoicePaymentServices":[],"Contact":{"ContactID":"3f58af86-b4d9-4ac9-950c-2e4cdd94d5be","Name":"SMART Agency","Addresses":[],"Phones":[],"ContactGroups":[],"ContactPersons":[],"HasValidationErrors":false},"DateString":"2023-01-13T00:00:00","Date":"/Date(1673568000000+0000)/","DueDateString":"2023-01-19T00:00:00","DueDate":"/Date(1674086400000+0000)/","BrandingThemeID":"d613f7f9-8fcb-477f-97f0-31eb85b7e5cf","Status":"AUTHORISED","LineAmountTypes":"Exclusive","LineItems":[],"SubTotal":19.95,"TotalTax":1.75,"Total":21.7,"UpdatedDateUTC":"/Date(1673576897217+0000)/","CurrencyCode":"USD"}]}';
    }
}