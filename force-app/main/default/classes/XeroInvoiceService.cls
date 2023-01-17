public class XeroInvoiceService {
    public static final Skie_Xero_Variables__c SKIE_XERO_SETTING = Skie_Xero_Variables__c.getOrgDefaults();

    public static void validateOperationInvocable(String invoiceId) {
        /* Create set to store id to query for Invoice that match the id in the set */
        set<Id> invoiceIdSet = new Set<Id>();

        if(invoiceId != null) {
            System.debug('has data');
            invoiceIdSet.add(invoiceId);

            if(!invoiceIdSet.isEmpty()) {
                syncDataFuture(invoiceIdSet);
                System.debug(invoiceIdSet);
            }
        }
    } 

    public static void validateOperation(List<Xero_Invoice__c> newInvoices, Map<Id, Xero_Invoice__c> oldInvoiceMap) {
        /* Create set to store id to query for Invoice that match the id in the set */
        set<Id> invoiceIdSet = new Set<Id>();

        if(!newInvoices.isEmpty()) {
            System.debug('has data');
            for(Xero_Invoice__c xeroInvoice : newInvoices) {
                if(xeroInvoice.Xero_Invoice_Id__c == null && (xeroInvoice.Invoice_Status_Codes__c != oldInvoiceMap.get(xeroInvoice.Id).Invoice_Status_Codes__c) && (xeroInvoice.Invoice_Status_Codes__c == 'AUTHORISED')) {
                    /*Check if Xero_Contact_Id__c[External Id] is null or not? 
                    if not then add invoice to the list for creation*/
                    if(xeroInvoice.Xero_Contact__c != null) {
                        System.debug(xeroInvoice.Id);
                        invoiceIdSet.add(xeroInvoice.Id);
                    }
                }
            }
            if(!invoiceIdSet.isEmpty()) {
                syncDataFuture(invoiceIdSet);
            }
        }
    } 

    @future(callout=true)
    public static void syncDataFuture(Set<id> invoiceIdSet) {
        Set<Id> contactIdSet = new Set<Id>();
        List<Xero_Invoice__c> invoiceToCreateList = new List<Xero_Invoice__c>();
        List<Xero_Invoice__c> invoiceToCreateContactList = new List<Xero_Invoice__c>();

        for(Id invoiceId : invoiceIdSet) {
            Xero_Invoice__c invoice = [SELECT Id, Xero_Invoice_Id__c, Xero_Contact__r.Xero_Contact_Id__c,            
                                       Xero_Contact__r.Name, Invoice_Type__c,
                                      (select Id, Quantity__c, UnitAmount__c, Description__c, DiscountRate__c from Xero_Invoice_Line__r) 
                                       FROM Xero_Invoice__c 
                                       WHERE Id = :invoiceId];
            System.debug('XERO CONTACT ID:::' + invoice.Xero_Contact__r.Xero_Contact_Id__c);
            //Check for Xero_Contact_Id__c if it is null or not?
            //CHECK IF XERO HAS THIS CONTACT ALREADY OR NOT? by CHECKING FOR XERO_CONTACT_ID(EXT ID)
            //IF CONTACT EXISTS THEN PROCEED TO CREATE CONTACT ON XERO
            if(invoice.Xero_Contact__r.Xero_Contact_Id__c != null) {
                invoiceToCreateList.add(invoice);
            } else {
                //add contact id into set
                invoiceToCreateContactList.add(invoice);
                System.debug('invoiceToCreateContactList SIZE:::: ' + invoiceToCreateContactList);
                System.debug('invoiceToCreateContactList :::: ' + invoiceToCreateContactList[0]);
                contactIdSet.add(invoice.Xero_Contact__c);
            }
            System.debug('invoice:: ' + invoice);
        }

        if(!invoiceToCreateList.isEmpty()) {
            try {
                SkieXeroApiService.postInvoice(invoiceToCreateList);
                System.debug('invoiceToCreateList SIZE ' + invoiceToCreateList.size());

            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        }

        if(!contactIdSet.isEmpty()) {
            try {
                SyncContactAndInvoice(contactIdSet, invoiceToCreateContactList);

            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        }
    }
    
    public static void SyncContactAndInvoice(Set<id> contactIdSet, List<Xero_Invoice__c> invoiceToCreateContactList) {
        List<Xero_Contact__c> contacts = [SELECT Id, Name, FirstName__c, LastName__c, Xero_Contact_Id__c, emailAddress__c FROM Xero_Contact__c WHERE Id IN :contactIdSet];
        System.debug('CONTACT TO CRATE:::: ' + contacts[0]);
        System.enqueueJob(new XeroContactInvoiceQueueable(invoiceToCreateContactList, contacts));
    }
}