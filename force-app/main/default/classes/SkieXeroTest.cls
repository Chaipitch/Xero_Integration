@isTest
public class SkieXeroTest {
    @TestSetup
    static void createData(){
        Skie_Xero_Variables__c customSett = new Skie_Xero_Variables__c();
        customSett.Xero_Tenant_Id__c = '3d9b3ccf-324a-4f30-815d-fea132aa140d';
        customSett.lastSyncDate__c = System.now();
        insert customSett;
    }

    @isTest
    public static void givenInvoiceAndContactWithoutExtId_whenSyncInvoicetoXero_thenProcessSuccessfully() {
        Xero_Contact__c ct1 = prepCt('testCT', 'firstName', 'lastName', 'test@mail.com', null);
        List<Xero_Contact__c> ctList = new List<Xero_Contact__c>{ct1};
        insert ctList;

        Xero_Invoice__c invoice = buildInvoiceData('ACCREC', 'DRAFT', null, ctList[0].Id);
        List<Xero_Invoice__c> invoices = new List<Xero_Invoice__c>{invoice};
        insert invoices;

        Xero_Invoice_Line__c lineitem1 = buildLineItemData('testItem 1', (Double)1, (Double)33.00, invoices[0].Id);
        insert lineitem1;

        Xero_Invoice__c updInvoice = [SELECT Id, Invoice_Status_Codes__c, Xero_Invoice_Id__c FROM Xero_Invoice__c LIMIT 1];
        updInvoice.Invoice_Status_Codes__c = 'AUTHORISED';
        
        HttpResponse syncContacts = new HttpResponse();
        syncContacts.setStatusCode(200);
        syncContacts.setBody(XeroHttpCalloutMockTest.postContactToXeroSuccessResponse());

        HttpResponse syncInvoices = new HttpResponse();
        syncInvoices.setStatusCode(200);
        syncInvoices.setBody(XeroHttpCalloutMockTest.postInvoiceToXeroSuccessResponse());


        Map<String, HttpResponse> expectedResponse = new Map<String, HttpResponse>{
            'POST_Callout:Xero/api.xro/2.0/Contacts' => syncContacts,
            'POST_Callout:Xero/api.xro/2.0/Invoices' => syncInvoices
        };

        test.startTest();
        XeroHttpCalloutMockTest.setTestMockResponse(200, 'OK', null, expectedResponse);
        update updInvoice;
        test.stopTest();
        List<Xero_Invoice__c>  xeroInvoices = [SELECT Id, Xero_Invoice_Id__c FROM Xero_Invoice__c];
        System.debug('XERO INVOICES : ' + xeroInvoices) ;
    }

    @isTest
    public static void givenInvoiceAndContactWithExtId_whenSyncInvoicetoXero_thenProcessSuccessfully() {
        Xero_Contact__c ct1 = prepCt('testCT', 'firstName', 'lastName', 'test@mail.com', 'df897507-bfff-4e28-afe9-05c304cdc5b5');
        List<Xero_Contact__c> ctList = new List<Xero_Contact__c>{ct1};
        insert ctList;

        Xero_Invoice__c invoice = buildInvoiceData('ACCREC', 'DRAFT', null, ctList[0].Id);
        List<Xero_Invoice__c> invoices = new List<Xero_Invoice__c>{invoice};
        insert invoices;

        Xero_Invoice_Line__c lineitem1 = buildLineItemData('testItem 1', (Double)1, (Double)33.00, invoices[0].Id);
        insert lineitem1;

        Xero_Invoice__c updInvoice = [SELECT Id, Invoice_Status_Codes__c FROM Xero_Invoice__c LIMIT 1];
        updInvoice.Invoice_Status_Codes__c = 'AUTHORISED';
        
        HttpResponse syncContacts = new HttpResponse();
        syncContacts.setStatusCode(200);
        syncContacts.setBody(XeroHttpCalloutMockTest.postContactToXeroSuccessResponse());

        HttpResponse syncInvoices = new HttpResponse();
        syncInvoices.setStatusCode(200);
        syncInvoices.setBody(XeroHttpCalloutMockTest.postInvoiceToXeroSuccessResponse());


        Map<String, HttpResponse> expectedResponse = new Map<String, HttpResponse>{
            'POST_Callout:Xero/api.xro/2.0/Contacts' => syncContacts,
            'POST_Callout:Xero/api.xro/2.0/Invoices' => syncInvoices
        };

        test.startTest();
        XeroHttpCalloutMockTest.setTestMockResponse(200, 'OK', null, expectedResponse);
        update updInvoice;
        test.stopTest();
        List<Xero_Invoice__c>  xeroInvoices = [SELECT Id, Xero_Invoice_Id__c FROM Xero_Invoice__c];
        System.debug('XERO INVOICES : ' + xeroInvoices) ;
    }

    @isTest
    public static void givenInvoiceAndContactWithExtId_whenSyncInvoicetoXero_thenProcessFailed() {
        Xero_Contact__c ct1 =  prepCt('testCT', 'firstName', 'lastName', 'test@mail.com', 'df897507-bfff-4e28-afe9-05c304cdc5b5');
        List<Xero_Contact__c> ctList = new List<Xero_Contact__c>{ct1};
        insert ctList;

        Xero_Invoice__c invoice = buildInvoiceData('ACCREC', 'DRAFT', null, ctList[0].Id);
        List<Xero_Invoice__c> invoices = new List<Xero_Invoice__c>{invoice};
        insert invoices;

        Xero_Invoice_Line__c lineitem1 = buildLineItemData('testItem 1', (Double)1, (Double)33.00, invoices[0].Id);
        insert lineitem1;

        Xero_Invoice__c updInvoice = [SELECT Id, Invoice_Status_Codes__c FROM Xero_Invoice__c LIMIT 1];
        updInvoice.Invoice_Status_Codes__c = 'AUTHORISED';
        
        HttpResponse syncContacts = new HttpResponse();
        syncContacts.setStatusCode(400);
        syncContacts.setBody(XeroHttpCalloutMockTest.postContactToXeroErrorResponse());

        HttpResponse syncInvoices = new HttpResponse();
        syncInvoices.setStatusCode(400);
        syncInvoices.setBody(XeroHttpCalloutMockTest.postInvoiceToXeroErrorResponse());


        Map<String, HttpResponse> expectedResponse = new Map<String, HttpResponse>{
            'POST_Callout:Xero/api.xro/2.0/Contacts' => syncContacts,
            'POST_Callout:Xero/api.xro/2.0/Invoices' => syncInvoices
        };

        test.startTest();
        XeroHttpCalloutMockTest.setTestMockResponse(400, null, null, expectedResponse);
        update updInvoice;
        test.stopTest();
        List<Xero_Invoice__c>  xeroInvoices = [SELECT Id, Xero_Invoice_Id__c FROM Xero_Invoice__c];
        System.debug('XERO INVOICES : ' + xeroInvoices) ;
    }

    @isTest
    public static void givenInvoiceAndContactWithoutExtId_whenSyncInvoicetoXeroUsingInvocable_thenProcessSuccessfully() {
        Xero_Contact__c ct1 =  prepCt('testCT', 'firstName', 'lastName', 'test@mail.com', null);
        List<Xero_Contact__c> ctList = new List<Xero_Contact__c>{ct1};
        insert ctList;

        Xero_Invoice__c invoice = buildInvoiceData('ACCREC', 'DRAFT', null, ctList[0].Id);
        List<Xero_Invoice__c> invoices = new List<Xero_Invoice__c>{invoice};
        insert invoices;

        Xero_Invoice_Line__c lineitem1 = buildLineItemData('testItem 1', (Double)1, (Double)33.00, invoices[0].Id);
        insert lineitem1;

        List<XeroInvoiceInvocable.Request> reqList = new List<XeroInvoiceInvocable.Request>();
        XeroInvoiceInvocable.Request req = new XeroInvoiceInvocable.Request();
        req.invoiceID = invoices[0].Id;
        reqList.add(req);
        
        HttpResponse syncContacts = new HttpResponse();
        syncContacts.setStatusCode(200);
        syncContacts.setBody(XeroHttpCalloutMockTest.postContactToXeroSuccessResponse());

        HttpResponse syncInvoices = new HttpResponse();
        syncInvoices.setStatusCode(200);
        syncInvoices.setBody(XeroHttpCalloutMockTest.postInvoiceToXeroSuccessResponse());

        Map<String, HttpResponse> expectedResponse = new Map<String, HttpResponse>{
            'POST_Callout:Xero/api.xro/2.0/Contacts' => syncContacts,
            'POST_Callout:Xero/api.xro/2.0/Invoices' => syncInvoices
        };

        test.startTest();
        XeroHttpCalloutMockTest.setTestMockResponse(200, 'OK', null, expectedResponse);
        XeroInvoiceInvocable.syncSalesforceInvoicesToXero(reqList);
        test.stopTest();

        List<Xero_Invoice__c>  xeroInvoices = [SELECT Id, Xero_Invoice_Id__c FROM Xero_Invoice__c];
        System.debug('XERO INVOICES : ' + xeroInvoices) ;
    }

    @isTest
    public static void givenContacts_whenInsertContact_thenTriggerCalledSuccessfully() {
        Xero_Contact__c ct1 = prepCt('testCT', 'firstName', 'lastName', 'test@mail.com', null);

        HttpResponse syncContacts = new HttpResponse();
        syncContacts.setStatusCode(200);
        syncContacts.setBody(XeroHttpCalloutMockTest.postContactToXeroSuccessResponse());
        System.debug(syncContacts.getBody());
        
        Map<String, HttpResponse> expectedResponse = new Map<String, HttpResponse>{
            'POST_Callout:Xero/api.xro/2.0/Contacts' => syncContacts
        };

        test.startTest();
        XeroHttpCalloutMockTest.setTestMockResponse(200, 'OK', null, expectedResponse);
        insert ct1;
        test.stopTest();
    }

    @isTest
    public static void givenXeroData_whenCallGetInvoice_thenCreateRecordSuccesscully() {
        HttpResponse syncInvoice = new HttpResponse();
        syncInvoice.setStatusCode(200);
        syncInvoice.setBody(XeroHttpCalloutMockTest.getInvoiceFromXeroSuccessResponse());

        Map<String, HttpResponse> expectedResponse = new Map<String, HttpResponse>{
            'GET_Callout:Xero/api.xro/2.0/Invoices' => syncInvoice
        };

        test.startTest();
        XeroHttpCalloutMockTest.setTestMockResponse(200, 'OK', null, expectedResponse);
        new SkieXeroInvoiceScheduler().execute(null);
        test.stopTest();
    }
    
    public static Xero_Contact__c prepCt(String Name, String firstName, String lastName, String email, String xeroCTId) {
        Xero_Contact__c ct = new Xero_Contact__c();
        ct.Name = Name;
        ct.FirstName__c = firstName;
        ct.LastName__c = lastName;
        ct.emailAddress__c = email;
        ct.Xero_Contact_Id__c = xeroCTId;

        return ct;
    }

    public static Xero_Invoice__c buildInvoiceData(String type, String invoiceStatusCode, String xeroId, String xeroCTId) {
        Xero_Invoice__c invoice =  new Xero_Invoice__c();
        invoice.Invoice_Type__c = type;
        invoice.Invoice_Status_Codes__c = invoiceStatusCode;
        invoice.Xero_Invoice_Id__c = xeroId;
        invoice.Xero_Contact__c = xeroCTId;

        return invoice;
    }

    public static Xero_Invoice_Line__c buildLineItemData(String description, Double quantity, Double unitAmt, String xeroInvId) {
        Xero_Invoice_Line__c lineItem = new Xero_Invoice_Line__c();
        lineItem.Description__c = description;
        lineItem.Quantity__c = quantity;
        lineItem.UnitAmount__c = unitAmt;
        lineItem.Xero_Invoice__c = xeroInvId;

        return lineItem;
    }

}


