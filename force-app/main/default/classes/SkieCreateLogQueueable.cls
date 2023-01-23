public class SkieCreateLogQueueable Implements Queueable, Database.AllowsCallouts{
    public static final List<Xero_Log__c> XERO_LOG_LIST = new List<Xero_Log__c>();
    public Set<String> ctExtIdSet;
    public List<XeroData.Invoice> xeroInvoices;

    public SkieCreateLogQueueable(Set<String> ctExtIdSet, List<XeroData.Invoice> xeroInvoices) {
        this.ctExtIdSet = ctExtIdSet;
        this.xeroInvoices = xeroInvoices;
    }

    public void execute(System.QueueableContext context) {
        List<Xero_Contact__c> newlyCreatedContacts = [SELECT Id, Xero_Contact_Id__c FROM Xero_Contact__c WHERE Xero_Contact_Id__c IN :ctExtIdSet];
        Map<String, Xero_Contact__c> newCtMap = new Map<String, Xero_Contact__c>();
        for(Xero_Contact__c ct : newlyCreatedContacts) {
            System.debug(ct.Id);
            newCtMap.put(ct.Xero_Contact_Id__c, ct);
            XERO_LOG_LIST.add(XeroAssembler.buildXeroContactLog(ct.Id, null, null, System.now(), null, false, null));
        }  
        
        insert XERO_LOG_LIST;
    }

}