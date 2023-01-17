public class SkieXeroInvoiceScheduler implements Schedulable{
    public void execute(SchedulableContext ctx) {
        Skie_Xero_Variables__c xeroVar = Skie_Xero_Variables__c.getOrgDefaults();
        Datetime lastSync = xeroVar.lastSyncDate__c;

        String currentDateTimeUTC = lastSync.format('yyyy-MM-dd\'T\'HH:mm:ss');

        System.enqueueJob(new XeroSyncXeroInvoicetoSFQueueable(1, currentDateTimeUTC));

        xeroVar.lastSyncDate__c = System.now();
        update xeroVar;
    }

}