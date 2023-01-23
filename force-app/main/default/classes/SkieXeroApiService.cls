public class SkieXeroApiService {
    public static final Skie_Xero_Variables__c SKIE_XERO_SETTING = Skie_Xero_Variables__c.getOrgDefaults();

    public static List<Xero_Invoice__c> invoiceToUpdateList = new List<Xero_Invoice__c>();
    public static List<Xero_Credit_Note__c> creditNoteToUpdateList = new List<Xero_Credit_Note__c>();

    public static final List<Xero_Log__c> XERO_LOG_LIST = new List<Xero_Log__c>();

    public static final Map<String, String> headerMap = new Map<String, String> {
        XeroCalloutUtils.HTTP_HEADER_CONTENT_TYPE => XeroCalloutUtils.HTTP_CONTENT_TYPE_JSON,
        XeroCalloutUtils.HTTP_HEADER_TENANTID => SKIE_XERO_SETTING.Xero_Tenant_Id__c
    };

    public static HttpResponse getInvoices(String pagination, String lastSync) {
        Map<String, String> getHeaderMap = new Map<String, String>{
            XeroCalloutUtils.HTTP_HEADER_CONTENT_TYPE => XeroCalloutUtils.HTTP_CONTENT_TYPE_JSON,
            XeroCalloutUtils.HTTP_HEADER_TENANTID => SKIE_XERO_SETTING.Xero_Tenant_Id__c,
            XeroCalloutUtils.HTTP_HEADER_IF_MODIFIED_SINCE => lastSync
        };

        String endpoint = 'Callout:Xero' + '/api.xro/2.0/Invoices?page=' + pagination;
        HttpResponse response = XeroCalloutUtils.callout(endpoint, XeroCalloutUtils.HTTP_REQUEST_METHOD_GET, getHeaderMap);

        if(response.getStatusCode() == 200) {
            return response;

        } else {
            throw new XeroException(response.getStatusCode(), response.getBody(), endpoint);
        }
    }
    
    public static void postInvoice(List<Xero_Invoice__c> invoices) {
        List<XeroData.InvoiceRequest> requests = new List<XeroData.InvoiceRequest>();

        for(Xero_Invoice__c xeroInvoice : invoices ) {
        XeroData.InvoiceRequest request = XeroAssembler.buildRequestData(xeroInvoice.Invoice_Type__c, xeroInvoice.Xero_Contact__r, xeroInvoice.Xero_Invoice_Line__r); 
        requests.add(request);
        }

        XeroData.InvoiceRequests req = new XeroData.InvoiceRequests();
        req.Invoices = requests;

        String requestPayload = JSON.serialize(req, true);

        String endpoint = 'Callout:Xero' + '/api.xro/2.0/Invoices';
        HttpResponse response =  XeroCalloutUtils.callout(endpoint, 'POST', headerMap, requestPayload);
        
        XeroData.InvoiceResponse resPayload = (XeroData.InvoiceResponse)JSON.deserialize(response.getBody(), XeroData.InvoiceResponse.class);

        // return resPayload;

        String resPayloadStr = JSON.serializePretty(resPayload, false);
        if(resPayload.Status == 'OK') {
            List<Xerodata.Invoice> invoiceResList = resPayload.invoices;

            Map<Integer, String> invoiceWrapper = new Map<Integer, String>();
            
            for(Integer i = 0; i < invoiceResList.size(); i++) {
                invoiceWrapper.put(i, invoiceResList[i].invoiceID);
            }

            for(Integer i = 0; i < invoiceResList.size(); i++) {
                invoices[i].Xero_Invoice_Id__c = invoiceWrapper.get(i);
                invoiceToUpdateList.add(invoices[i]);
                if(!SKIE_XERO_SETTING.Keep_Error_Logs_Only__c) {
                    String description = 'POST: Xero Invoice with ID: '+ invoice.Id +' Successfully';
                    XERO_LOG_LIST.add(XeroAssembler.buildXeroLog(invoices[i], requestPayload, resPayloadStr, String.valueOf(System.now()), resPayload.Message, false, description));
                }
            }

        } else {
            List<XeroData.Elements> elements = resPayload.Elements;
            for(Xerodata.Elements el : elements) {
               for(Xero_Invoice__c invoice : invoices) {
                String description = 'POST: Xero Invoice with ID: '+ invoice.Id +' failed';
                XERO_LOG_LIST.add(XeroAssembler.buildXeroLog(invoice, requestPayload, resPayloadStr, String.valueOf(System.now()), String.valueOf(el.ValidationErrors), true, description));
                    System.debug('ERROR LOG');
                    System.debug(XERO_LOG_LIST);
                }
                insert XERO_LOG_LIST;
                throw new XeroException(response.getStatusCode(), String.valueOf(el.ValidationErrors), endpoint);
            }
        }
        insert XERO_LOG_LIST;
        update invoices;
    }

    public static void postContacts(List<Xero_Contact__c> contacts) {
        List<XeroData.ContactRequest> ctReqList = new List<XeroData.ContactRequest>();
        List<Xero_Contact__c> contactToUpdateList = new List<Xero_Contact__c>();
        Map<Id, Xero_Contact__c> contactToUpdateMap = new Map<Id, Xero_Contact__c>();


        for(Xero_Contact__c contact : contacts) {
            XeroData.ContactRequest request = XeroAssembler.buildContactRequestData(contact);
            System.debug('CONTACTS ----->' + contact);
            ctReqList.add(request);
        } 
        System.debug('ctReqList ----->' + ctReqList);

        XeroData.ContactRequests ctRequests = new XeroData.ContactRequests();
        ctRequests.Contacts = ctReqList;

        String requestPayload = JSON.serialize(ctRequests, false);

        String endpoint = 'Callout:Xero' + '/api.xro/2.0/Contacts';

        HttpResponse response =  XeroCalloutUtils.callout(endpoint, 'POST', headerMap, requestPayload);
        XeroData.ContactResponse resPayload = (XeroData.ContactResponse)JSON.deserialize(response.getBody(), XeroData.ContactResponse.class);
        String resPayloadStr = JSON.serialize(resPayload);
        
        if(resPayload.Status == 'OK'){
            List<XeroData.Contact> contactResList = resPayload.Contacts;
            Map<Integer,String> xeroConIdMap = new Map<Integer,String>();
            for(Integer i = 0; i < contactResList.size(); i++) {
                xeroConIdMap.put(i, contactResList[i].ContactID);
            }

            for(Integer i = 0; i < contacts.size(); i++) {
                contacts[i].Xero_Contact_Id__c = xeroConIdMap.get(i);
                contactToUpdateList.add(contacts[i]);
                if(!SKIE_XERO_SETTING.Keep_Error_Logs_Only__c) {
                    String description = 'POST: Xero Contact with ID: ' + contacts[i].Id + ' successfully';
                    XERO_LOG_LIST.add(XeroAssembler.buildXeroContactLog(contacts[i], requestPayload, resPayloadStr, String.valueOf(System.now()), null, false, description));
                }
            }

        } else {
            System.debug('RES MESSAGE ' + resPayload.Message);
            
            List<XeroData.Elements> elements = resPayload.Elements;
            for(XeroData.Elements element : elements) {
                for(Xero_Contact__c ct : contacts) {
                    String description = 'POST: Xero Contact with ID: ' + ct.Id + ' failed';
                    XERO_LOG_LIST.add(XeroAssembler.buildXeroContactLog(ct, requestPayload, resPayloadStr, String.valueOf(System.now()), String.valueOf(element.ValidationErrors), true, description));

                    insert XERO_LOG_LIST;
                    throw new XeroException(response.getStatusCode(), String.valueOf(element.ValidationErrors), endpoint);
                }
            }
        }
        
        insert XERO_LOG_LIST;
        update contactToUpdateList;
    }

    @future(callout=true)
    public static void postInvoicesFuture(Set<Id> invoiceIdSet) {
        List<XeroData.InvoiceRequest> requests = new List<XeroData.InvoiceRequest>();
        List<Xero_Invoice__c> xeroInvoices = [SELECT Id, Xero_Invoice_Id__c, Xero_Contact__r.Xero_Contact_Id__c, Xero_Contact__r.Name, Invoice_Type__c, (select Id, Quantity__c, UnitAmount__c, Description__c, DiscountRate__c from Xero_Invoice_Line__r) FROM Xero_Invoice__c WHERE Id IN :invoiceIdSet];

        for(Xero_Invoice__c invoice : xeroInvoices) {
            XeroData.InvoiceRequest request = XeroAssembler.buildRequestData(invoice.Invoice_Type__c, invoice.Xero_Contact__r, invoice.Xero_Invoice_Line__r);
            requests.add(request);
        }

        XeroData.InvoiceRequests req = new XeroData.InvoiceRequests();
        req.Invoices = requests;

        String requestPayload = JSON.serialize(req, true);
        System.debug('REQ PAYLOAD::: ' + requestPayload);

        String endpoint = 'Callout:Xero' + '/api.xro/2.0/Invoices';
        HttpResponse response =  XeroCalloutUtils.callout(endpoint, 'POST', headerMap, requestPayload);
            
        XeroData.InvoiceResponse resPayload = (XeroData.InvoiceResponse)JSON.deserialize(response.getBody(), XeroData.InvoiceResponse.class);
        String resPayloadStr = JSON.serializePretty(resPayload, false);

        if(resPayload.Status == 'OK') {
            List<Xerodata.Invoice> invoiceResList = resPayload.invoices;

            Map<Integer,String> xeroInvoiceIdMap = new Map<Integer,String>();
            for(Integer i = 0; i < invoiceResList.size(); i++) {
                xeroInvoiceIdMap.put(i, invoiceResList.get(i).invoiceID);
            } 

            for(Integer i = 0; i < xeroInvoices.size(); i++) {
                xeroInvoices[i].Xero_Invoice_Id__c = xeroInvoiceIdMap.get(i);
                if(!SKIE_XERO_SETTING.Keep_Error_Logs_Only__c) {
                    String description = 'POST: Xero Invoice with ID: '+ xeroInvoices[i].Id +' Successfully';
                    XERO_LOG_LIST.add(XeroAssembler.buildXeroLog(xeroInvoices[i], requestPayload, resPayloadStr, String.valueOf(System.now()), resPayload.Message, false, description));
                }
            }

        } else {
            List<XeroData.Elements> elements = resPayload.Elements;

            for(Xerodata.Elements el : elements) {
                for(Xero_Invoice__c invoice : xeroInvoices) {
                    String description = 'POST: Xero Invoice with ID: '+ invoice.Id +' failed';
                    XERO_LOG_LIST.add(XeroAssembler.buildXeroLog(invoice, requestPayload, resPayloadStr, String.valueOf(System.now()), String.valueOf(el.ValidationErrors), true, description));
                    // insert XERO_LOG_LIST;

                    // throw new XeroException(resPayload.Status, String.valueOf(el.ValidationErrors));
                }
            }
        }

        insert XERO_LOG_LIST;
        update xeroInvoices;
    }

    public static void createLog(){
        if(!XERO_LOG_LIST.isEmpty()) {
            insert XERO_LOG_LIST;
        }
    }
}