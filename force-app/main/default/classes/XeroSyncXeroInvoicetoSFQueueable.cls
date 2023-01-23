public class XeroSyncXeroInvoicetoSFQueueable Implements Queueable, Database.AllowsCallouts{
    public static final Skie_Xero_Variables__c SKIE_XERO_SETTING = Skie_Xero_Variables__c.getOrgDefaults();
    public static final List<Xero_Log__c> XERO_LOG_LIST = new List<Xero_Log__c>();
    public Integer page {get;set;}
    public String lastSync {get;set;}

    public XeroSyncXeroInvoicetoSFQueueable(Integer page, String lastSync) {
        this.page = page;
        this.lastSync = lastSync;
    }

    public void execute(System.QueueableContext context) {
        try {
            HttpResponse response = SkieXeroApiService.getInvoices(String.valueOf(page), String.valueOf(lastSync));
            XeroData.InvoiceResponse invoiceResponseWrapper = (XeroData.InvoiceResponse)JSON.deserialize(response.getBody(), XeroData.InvoiceResponse.class);
            List<XeroData.Invoice> xeroInvoiceList = invoiceResponseWrapper.invoices;
            String responseStr = JSON.serializePretty(invoiceResponseWrapper, false);

            try {
                SkieSyncXeroToSFService.syncInvoiceToSF(response, xeroInvoiceList);
                if(!SKIE_XERO_SETTING.Keep_Error_Logs_Only__c) {
                    XERO_LOG_LIST.add(XeroAssembler.buildLog(null, responseStr, String.valueOf(System.now()),null , false, 'Successfully sync data from Xero'));
                }

            } catch (XeroException ex) {
                XERO_LOG_LIST.add(XeroAssembler.buildLog(ex.endpoint, ex.getMessage(), String.valueOf(System.now()), 'Error Message: '+ex.getMessage() + '\nStackTrace: ' + ex.getStackTraceString(), true, null));
            }

            if(xeroInvoiceList.size() == 100) {
                System.enqueueJob(new XeroSyncXeroInvoicetoSFQueueable(page++, lastSync));
            }
    
        }
        catch (XeroException ex) {
            XERO_LOG_LIST.add(XeroAssembler.buildLog(ex.endpoint, ex.getMessage(), String.valueOf(System.now()),null , true, null));
        }
        insert XERO_LOG_LIST;
    }
}