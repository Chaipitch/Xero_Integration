public class XeroSyncXeroInvoicetoSFQueueable Implements Queueable, Database.AllowsCallouts{
    public static final Skie_Xero_Variables__c SKIE_XERO_SETTING = Skie_Xero_Variables__c.getOrgDefaults();
    public Integer page {get;set;}
    public String lastSync {get;set;}

    public XeroSyncXeroInvoicetoSFQueueable(Integer page, String lastSync) {
        this.page = page;
        this.lastSync = lastSync;
    }

    public void execute(System.QueueableContext context) {
        List<XeroData.Invoice> xeroInvoices = SkieXeroApiService.getInvoices(String.valueOf(page), String.valueOf(lastSync));
            
        if(xeroInvoices.size() == 100) {
            System.enqueueJob(new XeroSyncXeroInvoicetoSFQueueable(page++, lastSync));
        }

        SkieSyncXeroToSFService.syncInvoiceToSF(xeroInvoices);
    }
}