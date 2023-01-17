public class XeroContactQueueable Implements Queueable, Database.AllowsCallouts{
    public static final Skie_Xero_Variables__c SKIE_XERO_SETTING = Skie_Xero_Variables__c.getOrgDefaults();
    
    public List<Xero_Contact__c> contacts;
    public List<Xero_Invoice__c> invoiceToCreateContactList;
    public static final Map<String, String> headerMap = new Map<String, String> {
        XeroCalloutUtils.HTTP_HEADER_CONTENT_TYPE => XeroCalloutUtils.HTTP_CONTENT_TYPE_JSON,
        XeroCalloutUtils.HTTP_HEADER_TENANTID => SKIE_XERO_SETTING.Xero_Tenant_Id__c
    };

    public XeroContactQueueable(List<Xero_Invoice__c> invoiceToCreateContactList, List<Xero_Contact__c> contacts) {
        this.contacts = contacts;
        this.invoiceToCreateContactList = invoiceToCreateContactList;
    }

    public void execute(System.QueueableContext context) {
        SkieXeroApiService.postContacts(contacts);

        Set<Id> invoiceIdSet = new Set<Id>();
        for(Xero_Invoice__c invoice : invoiceToCreateContactList) {
            invoiceIdSet.add(invoice.Id);
        }
        SkieXeroApiService.postInvoicesFuture(invoiceIdSet);
    }
}