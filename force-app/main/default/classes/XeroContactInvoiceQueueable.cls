public class XeroContactInvoiceQueueable Implements Queueable, Database.AllowsCallouts{
    public static final Skie_Xero_Variables__c SKIE_XERO_SETTING = Skie_Xero_Variables__c.getOrgDefaults();
    public List<Xero_Contact__c> contacts;
    public List<Xero_Invoice__c> invoiceToCreateContactList;
    public static final Map<String, String> headerMap = new Map<String, String> {
        XeroCalloutUtils.HTTP_HEADER_CONTENT_TYPE => XeroCalloutUtils.HTTP_CONTENT_TYPE_JSON,
        XeroCalloutUtils.HTTP_HEADER_TENANTID => SKIE_XERO_SETTING.Xero_Tenant_Id__c
    };

    public XeroContactInvoiceQueueable(List<Xero_Invoice__c> invoiceToCreateContactList, List<Xero_Contact__c> contacts) {
        this.contacts = contacts;
        this.invoiceToCreateContactList = invoiceToCreateContactList;
    }

    public void execute(System.QueueableContext context) {
        try {
            Map<Id, Xero_Contact__c> contactMap = new Map<Id, Xero_Contact__c>(contacts);
            System.debug('CONTACT MAP:::' + contactMap.values());
            SkieXeroApiService.postContacts(contactMap.values());
            
        }
        catch (Exception ex) {
            
        }
        
        try {
            Map<Id, Xero_Invoice__c> invoiceIdMap = new Map<Id, Xero_Invoice__c>(invoiceToCreateContactList);
            SkieXeroApiService.postInvoicesFuture(invoiceIdMap.keySet());
            
        }
        catch (Exception ex) {
            
        }
    }
}