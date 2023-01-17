trigger XeroInvoiceTrigger on Xero_Invoice__c (after insert, after update) {
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            // XeroInvoiceService.validateOperation(trigger.new, trigger.oldMap);
        }

        if(Trigger.isUpdate) {
            XeroInvoiceService.validateOperation(trigger.new, trigger.oldMap);
        }
    }
}