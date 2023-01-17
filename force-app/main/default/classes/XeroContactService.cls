public with sharing class XeroContactService {
    public static final Skie_Xero_Variables__c SKIE_XERO_SETTING = Skie_Xero_Variables__c.getOrgDefaults();

    public static void validateContactXeroId(List<Xero_Contact__c> newContacts) {
        System.debug('Call from ContactTrigger');
        Set<Id> ctToCreateSet = new Set<Id>();

        for(Xero_Contact__c contact : newContacts) {
            if(contact.Xero_Contact_Id__c == null) { 
                System.debug('Ready to make invoice callouts');
                ctToCreateSet.add(contact.Id);
            }
        }

        if(!ctToCreateSet.isEmpty()) {
            syncCtToXero(ctToCreateSet);
        }
    }

    @future(callout=true)
    public static void syncCtToXero(Set<Id> ctToCreateSet) {
        List<Xero_Contact__c> contacts = [SELECT Id, Name, FirstName__c, LastName__c, Xero_Contact_Id__c FROM Xero_Contact__c WHERE Id IN :ctToCreateSet];
        if(!contacts.isEmpty()) {
            System.debug('CT SIZE:::: ' + contacts.size());
            System.debug('CT List:::: ' + contacts);
            SkieXeroApiService.postContacts(contacts);
        }
    }
    // public static void syncInvoiceToXero(Set<Id> invoiceToCreateSet) {
    //     List<Xero_Invoice__c> invoiceList = [SELECT Id, Xero_Invoice_Id__c, Xero_Contact__r.Xero_Contact_Id__c,            
    //                                         Xero_Contact__r.Name, Invoice_Type__c,
    //                                         (select Id, Quantity__c, UnitAmount__c, Description__c, DiscountRate__c from Xero_Invoice_Line__r) 
    //                                         FROM Xero_Invoice__c 
    //                                         WHERE Id IN :invoiceToCreateSet];

    //     System.enqueueJob(new XeroInvoiceQueuable(invoiceList));
    // }
}