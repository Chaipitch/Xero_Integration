public class SkieSyncXeroToSFService {
    public static final List<Xero_Log__c> XERO_LOG_LIST = new List<Xero_Log__c>();
    public static final Skie_Xero_Variables__c SKIE_XERO_SETTING = Skie_Xero_Variables__c.getOrgDefaults();

    public static void syncInvoiceToSF(HttpResponse response, List<XeroData.Invoice> xeroInvoices) {
        String invoiceLogMessage = '';
        String contactLogMessage = '';
        String invoiceLineLogMessage = '';
        Set<String> xeroContactIDSet = new Set<String>();
        Set<String> xeroInvoiceIDSet = new Set<String>();
        Set<String> XeroInvoiceLineIDSet = new Set<String>();
        Map<string, Xero_Contact__c> contactMap = new Map<String,Xero_Contact__c>();
        Map<String, Xero_Contact__c> ctToUpsertMap = new Map<String, Xero_Contact__c >();

        List<Xero_Log__c> logForUpdate = new List<Xero_Log__c>();
        List<Xero_Log__c> logForCreate = new List<Xero_Log__c>();
        
        for(XeroData.Invoice xeroInvoice : xeroInvoices) {
            xeroInvoiceIDSet.add(xeroInvoice.invoiceID);
            xeroContactIDSet.add(xeroInvoice.contact.ContactID);

            //Store XeroLineItemID in a set for query 
            for(XeroData.LineItem xeroLineItem : xeroInvoice.lineItems) {
                XeroInvoiceLineIDSet.add(xeroLineItem.LineItemId);
            }
        }

        //Query Invoice Lines from set and do mapping for update/insert
        List<Xero_Invoice_Line__c> existingInvoiceLines = [SELECT Id, Xero_Invoice_Line_ID__c, Description__c, DiscountRate__c 
                                                           FROM Xero_Invoice_Line__c 
                                                           WHERE Xero_Invoice_Line_ID__c 
                                                           IN :XeroInvoiceLineIDSet];

        Map<String, Xero_Invoice_Line__c> invLineToUpsertMap = new Map<String, Xero_Invoice_Line__c>();
        Map<String, Xero_Invoice_Line__c> invLineMap = new Map<String, Xero_Invoice_Line__c>();

        //Query Contacts from set and do mapping for update/insert
        List<Xero_Contact__c> existingContactList = [SELECT Id, Xero_Contact_Id__c, Name 
                                                     FROM Xero_Contact__c 
                                                     WHERE Xero_Contact_Id__c 
                                                     IN :xeroContactIDSet];
                                                     
        Set<String> ctExtIdSet = new Set<String>();
    
        for(Xero_Contact__c ct : existingContactList) {
            contactMap.put(ct.Xero_Contact_Id__c, ct);
        }

        for(XeroData.Invoice inv : xeroInvoices) {
            if(contactMap.get(inv.contact.ContactID) != null) {
                ctToUpsertMap.put(inv.invoiceID, XeroAssembler.buildContactData(contactMap.get(inv.contact.ContactID), inv));
                contactLogMessage = '\nGET: Update Contact with Xero Contact ID: ' + inv.contact.ContactID + ' Successfully';

                if(!SKIE_XERO_SETTING.Keep_Error_Logs_Only__c) {
                    logForUpdate.add(XeroAssembler.buildXeroContactLog(contactMap.get(inv.contact.ContactID).Id, response.getBody(), null, String.valueOf(System.now()), null, false, contactLogMessage));
                }

            } else {
                ctToUpsertMap.put(inv.invoiceID, XeroAssembler.buildContactData(null, inv));
                contactLogMessage = '\nGET: Create Contact with Xero Contact ID: ' + inv.contact.ContactID + ' Successfully';
                ctExtIdSet.add(inv.contact.ContactID);
            }
        }

        
        List<Database.UpsertResult> saveCt = Database.upsert(ctToUpsertMap.values(), false);
        String saveContactLog = '';
        saveContactLog += contactLogMessage;
        
        for(Integer i = 0; i < ctToUpsertMap.values().size(); i++) {
            if(!saveCt.get(i).isSuccess()) {
                saveContactLog += '\nUpsert Contact Failed, Contact Id: ' + ctToUpsertMap.values().get(i).Xero_Contact_Id__c;
                
                Database.Error error = saveCt.get(i).getErrors().get(0);
                String errStr = error.getStatusCode() + error.getMessage() + error.getFields();

                saveContactLog += errStr;
                // XERO_LOG_LIST.add(XeroAssembler.buildLog(System.now(), saveContactLog, true, null));
            }
        }

        List<Xero_Contact__c> newlyCreatedContacts = [SELECT Id, Xero_Contact_Id__c FROM Xero_Contact__c WHERE Xero_Contact_Id__c IN :ctExtIdSet];
        Map<String, Xero_Contact__c> newCtMap = new Map<String, Xero_Contact__c>();
        for(Xero_Contact__c ct : newlyCreatedContacts) {
            System.debug(ct.Id);
            newCtMap.put(ct.Xero_Contact_Id__c, ct);
            String description = 'GET: Create Contact with Xero Contact ID: ' + ct.Id + ' Successfully';

            if(!SKIE_XERO_SETTING.Keep_Error_Logs_Only__c) {
                logForCreate.add(XeroAssembler.buildXeroContactLog(ct.Id, null, response.getBody(), String.valueOf(System.now()), null, false, description));
            }
        } 
        //END CONTACT--------

        //START INVOICE
        Map<String, Xero_Invoice__c> invoiceToUpsertMap = new Map<String, Xero_Invoice__c>();
        //Query Invoices from set and do mapping for update/insert
        List<Xero_Invoice__c> existingInvoiceList = [SELECT Id, Xero_Invoice_Id__c 
                                                        FROM Xero_Invoice__c 
                                                        WHERE Xero_Invoice_Id__c 
                                                        IN :xeroInvoiceIDSet];

        Map<String, Xero_Invoice__c> invoiceMap = new Map<String, Xero_Invoice__c>();

        for(Xero_Invoice__c invoice : existingInvoiceList) {
            invoiceMap.put(invoice.Xero_Invoice_Id__c, invoice);
        }

        List<Xero_Invoice__c> invoiceToCreateList = new List<Xero_Invoice__c>();
        List<Xero_Invoice__c> invoiceToUpdateList = new List<Xero_Invoice__c>();
        Set<String> invoiceExtIdSet = new Set<String>();

        for(XeroData.Invoice inv : xeroInvoices) {
            if(invoiceMap.get(inv.invoiceID) != null) {
                invoiceToUpsertMap.put(inv.invoiceID, XeroAssembler.buildInvoiceData(inv, invoiceMap.get(inv.invoiceID), ctToUpsertMap.get(inv.invoiceID)));
                invoiceLogMessage = '\nGET: Update Invoice with Xero Invoice ID: ' + inv.invoiceID + ' successfully';

                if(!SKIE_XERO_SETTING.Keep_Error_Logs_Only__c) {
                    logForUpdate.add(XeroAssembler.buildXeroLog(invoiceMap.get(inv.invoiceID), null, null, String.valueOf(System.now()), null, false, invoiceLogMessage));
                }

            } else {
                invoiceToUpsertMap.put(inv.invoiceID, XeroAssembler.buildInvoiceData(inv, null, ctToUpsertMap.get(inv.invoiceID)));
                invoiceLogMessage = '\nGET: Create Invoice with Xero Invoice ID: ' + inv.invoiceID + ' successfully';
                invoiceExtIdSet.add(inv.invoiceID);
            }
        }

        //Query Invoices from set and do mapping for update/insert
        for(Xero_Invoice_Line__c invLine : existingInvoiceLines){
            invLineMap.put(invLine.Xero_Invoice_Line_ID__c, invLine);
        }

        for(XeroData.Invoice inv : xeroInvoices) {
            for(XeroData.LineItem xeroLineItem : inv.lineItems) {
                if(invLineMap.get(xeroLineItem.LineItemId) != null) {
                    invLineToUpsertMap.put(inv.invoiceID, XeroAssembler.buildInvoiceLineData(invLineMap.get(xeroLineItem.LineItemId), xeroLineItem, invoiceToUpsertMap.get(inv.invoiceID)));
                    invoiceLineLogMessage = '\nGET: Update Invoice Line with Xero Invoice ID: ' + xeroLineItem.LineItemId + ' successfully';
                    // logForUpdate.add(XeroAssembler.buildLog(System.now(), null, false,invoiceLineLogMessage));

                } else {
                    invLineToUpsertMap.put(inv.invoiceID, XeroAssembler.buildInvoiceLineData(null, xeroLineItem, invoiceToUpsertMap.get(inv.invoiceID)));
                    invoiceLineLogMessage = '\nGET: Create Invoice Line with Xero Invoice ID: ' + xeroLineItem.LineItemId + ' successfully';

                }
            }
        }

        //Upsert Invoice
        List<Database.UpsertResult> saveInvoice = Database.upsert(invoiceToUpsertMap.values(), false);
        String saveInvoiceLog = '';
        saveInvoiceLog += invoiceLogMessage;
    
        for(Integer i = 0; i < invoiceToUpsertMap.values().size(); i++) {
            if(!saveInvoice.get(i).isSuccess()) {
                saveInvoiceLog += '\nUpsert Invoice Failed, Contact Id: ' + invoiceToUpsertMap.values().get(i).Xero_Invoice_Id__c;

                Database.Error error = saveInvoice.get(i).getErrors().get(0);
                String errStr = error.getStatusCode() + error.getMessage() + error.getFields();

                saveInvoiceLog += errStr;
                // XERO_LOG_LIST.add(XeroAssembler.buildLog(System.now(), saveInvoiceLog, true, null));
            }
        }

        List<Xero_Invoice__c> newlyCreatedInvoices = [SELECT Id, Xero_Invoice_Id__c FROM Xero_Invoice__c WHERE Xero_Invoice_Id__c IN :invoiceExtIdSet];
        Map<String, Xero_Invoice__c> newinvoiceMap = new Map<String, Xero_Invoice__c>();
        for(Xero_Invoice__c inv : newlyCreatedInvoices) {
            System.debug(inv.Id);
            newinvoiceMap.put(inv.Xero_Invoice_Id__c, inv);
            String description = 'GET: Create Invoice with Xero Invoice ID: ' + inv.Id + ' Successfully';
            if(!SKIE_XERO_SETTING.Keep_Error_Logs_Only__c) {
                logForCreate.add(XeroAssembler.buildXeroLog(inv, null, response.getBody(), String.valueOf(System.now()), null, false, description));
            }
        } 

        //Upsert Invoice lines
        List<Database.UpsertResult> saveInvoiceLine = Database.upsert(invLineToUpsertMap.values(), false);
        String saveInvoiceLineLog = '';
        saveInvoiceLineLog += invoiceLineLogMessage;
    
        for(Integer i = 0; i < invLineToUpsertMap.values().size(); i++) {
            if(!saveInvoiceLine.get(i).isSuccess()) {
                saveInvoiceLineLog += '\nUpsert Invoice Line Failed, Contact Id: ' + invLineToUpsertMap.values().get(i).Xero_Invoice_Line_ID__c;

                Database.Error error = saveInvoiceLine.get(i).getErrors().get(0);
                String errStr = error.getStatusCode() + error.getMessage() + error.getFields();

                saveInvoiceLineLog += errStr;
                // XERO_LOG_LIST.add(XeroAssembler.buildLog(System.now(), saveInvoiceLineLog, true, null));
            }
        }
        if(!SKIE_XERO_SETTING.Keep_Error_Logs_Only__c) {
            // XERO_LOG_LIST.add(XeroAssembler.buildLog(System.now(), null, false, saveInvoiceLineLog));
        }
        // insert XERO_LOG_LIST;
        insert logForUpdate;
        insert logForCreate;
        // System.enqueueJob(new SkieCreateLogQueueable(ctExtIdSet, xeroInvoices));
    }
}