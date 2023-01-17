public class SkieSyncXeroToSFService {
    public static final List<Xero_Log__c> XERO_LOG_LIST = new List<Xero_Log__c>();

    public static void syncInvoiceToSF(List<XeroData.Invoice> xeroInvoices) {
        Set<String> xeroContactIDSet = new Set<String>();
        Set<String> xeroInvoiceIDSet = new Set<String>();
        Set<String> XeroInvoiceLineIDSet = new Set<String>();
        Map<string, Xero_Contact__c> contactMap = new Map<String,Xero_Contact__c>();
        Map<String, Xero_Contact__c> ctToUpsertMap = new Map<String, Xero_Contact__c >();
        
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
    
        for(Xero_Contact__c ct : existingContactList) {
            contactMap.put(ct.Xero_Contact_Id__c, ct);
        }

        for(XeroData.Invoice inv : xeroInvoices) {
            if(contactMap.get(inv.contact.ContactID) != null) {
                ctToUpsertMap.put(inv.invoiceID, XeroAssembler.buildContactData(contactMap.get(inv.contact.ContactID), inv));
                System.debug('CONTACT EXIST ====' + ctToUpsertMap.values());
            } else {
                ctToUpsertMap.put(inv.invoiceID, XeroAssembler.buildContactData(null, inv));
                System.debug('CONTACT NOT EXIST ------ ' + ctToUpsertMap.values());
            }
        }

        System.debug('UPSERT MAP ' + ctToUpsertMap.values());
        upsert ctToUpsertMap.values();

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

        for(XeroData.Invoice inv : xeroInvoices) {
            if(invoiceMap.get(inv.invoiceID) != null) {
                invoiceToUpsertMap.put(inv.invoiceID, XeroAssembler.buildInvoiceData(inv, invoiceMap.get(inv.invoiceID), ctToUpsertMap.get(inv.invoiceID)));
                System.debug('Invoice Exist ----' + inv.invoiceID);
            } else {
                invoiceToUpsertMap.put(inv.invoiceID, XeroAssembler.buildInvoiceData(inv, null, ctToUpsertMap.get(inv.invoiceID)));

                System.debug('Invoice Not Exist------' + inv.invoiceID);

            }
        }

        System.debug(invoiceToCreateList);
        upsert invoiceToUpsertMap.values();

        //Query Invoices from set and do mapping for update/insert
        for(Xero_Invoice_Line__c invLine : existingInvoiceLines){
            invLineMap.put(invLine.Xero_Invoice_Line_ID__c, invLine);
        }

        for(XeroData.Invoice inv : xeroInvoices) {
            for(XeroData.LineItem xeroLineItem : inv.lineItems) {
                if(invLineMap.get(xeroLineItem.LineItemId) != null) {
                    invLineToUpsertMap.put(inv.invoiceID, XeroAssembler.buildInvoiceLineData(invLineMap.get(xeroLineItem.LineItemId), xeroLineItem, invoiceToUpsertMap.get(inv.invoiceID)));
                    
                } else {
                    invLineToUpsertMap.put(inv.invoiceID, XeroAssembler.buildInvoiceLineData(null, xeroLineItem, invoiceToUpsertMap.get(inv.invoiceID)));
                }
            }
        }

        upsert invLineToUpsertMap.values();

        System.debug('invLineToUpsertMap:::: ' + invLineToUpsertMap.values());
        System.debug('invLineMap:::: ' + invLineMap);
        System.debug('XeroInvoiceLineIDSet:::: ' + XeroInvoiceLineIDSet);
        System.debug('contactMap--------' + contactMap);
        System.debug('ctToUpsertMap--------' + ctToUpsertMap.values());

    }
}