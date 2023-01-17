trigger XeroCreditNoteTrigger on Xero_Credit_Note__c (after update) {
    switch on Trigger.operationType {
        when AFTER_UPDATE {
            //XeroCreditNoteService.validateCreditNotes(Trigger.new, Trigger.oldMap);
        }
    }
}