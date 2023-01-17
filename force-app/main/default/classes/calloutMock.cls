public class calloutMock implements HttpCalloutMock{
    public static HttpResponse respond(HttpRequest request){
        HttpResponse response = new HttpResponse();

        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"Id":"bf0fb416-05b7-4b70-834e-bd32536dbe01","Status":"OK","ProviderName":"Salesforce Auth App","DateTimeUTC":"/Date(1672389194052)/","Contacts":[{"ContactID":"bf0fb416-05b7-4b70-834e-bd32536dbe01","ContactStatus":"ACTIVE","Name":"testct23","FirstName":"testct23","LastName":"testc23","EmailAddress":"","BankAccountDetails":"","Addresses":[{"AddressType":"STREET","City":"","Region":"","PostalCode":"","Country":""},{"AddressType":"POBOX","City":"","Region":"","PostalCode":"","Country":""}],"Phones":[{"PhoneType":"DEFAULT","PhoneNumber":"","PhoneAreaCode":"","PhoneCountryCode":""},{"PhoneType":"DDI","PhoneNumber":"","PhoneAreaCode":"","PhoneCountryCode":""},{"PhoneType":"FAX","PhoneNumber":"","PhoneAreaCode":"","PhoneCountryCode":""},{"PhoneType":"MOBILE","PhoneNumber":"","PhoneAreaCode":"","PhoneCountryCode":""}],"UpdatedDateUTC":"/Date(1672388392097+0000)/","ContactGroups":[],"IsSupplier":false,"IsCustomer":true,"SalesTrackingCategories":[],"PurchasesTrackingCategories":[],"ContactPersons":[],"HasValidationErrors":false}]}');
        response.setStatusCode(200);

        return response;
    }
}