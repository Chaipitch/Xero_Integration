trigger XeroContactTrigger on Xero_Contact__c (after insert) {
    switch on Trigger.operationType {
        when AFTER_INSERT {
            // XeroContactService.validateContactXeroId(Trigger.new);
        }
    }
}