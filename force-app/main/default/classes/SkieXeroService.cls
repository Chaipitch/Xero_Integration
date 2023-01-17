public class SkieXeroService {
    public static final Map<String, String> headerMap = new Map<String, String> {
        
    };

    public static void createNewContact(String contactId) {
        List<Contact> createContactList = [SELECT Id, Name FROM Contact WHERE Id IN :contactId];
        String contactPayload = prepareData(createContactList);
        String endpoint = 'callout:Xero' + '/';

        HttpResponse res = SkieXeroCalloutUtils.callout(endpoint, SkieXeroCalloutUtils.HTTP_REQUEST_METHOD_POST, headerMap, contactPayload);

    }

    public String prepareData(List<Contact> ctList) {
        List<SkieXeroData.ContactRequest> contactWarpperList = new List<SkieXeroData.ContactRequest>();

        for(Contact ct : contactWarpperList) {
            contactWarpperList.add(SkieXeroAssembler.buildContactData(ct));
        }

        return JSON.serializePretty(contactWarpperList, false);
    }
}
