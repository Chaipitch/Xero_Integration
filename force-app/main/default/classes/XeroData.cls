public class XeroData {
    public class ContactRequests {
        public List<ContactRequest> Contacts {get;set;}
    }

    public class ContactRequest {
        public String Name {get;set;}
        public String FirstName {get;set;}
        public String LastName {get;set;}
        public String EmailAddress {get;set;}
        public String ContactID {get;set;}
    }

    public class ContactResponse {
        public String Id {get;set;}
        public String Status {get;set;}
        public String ProviderName {get;set;}
        public List<Contact> Contacts {get;set;}
        public String Message {get;set;}
        public List<Elements> Elements {get;set;} 
    }

    public class InvoiceRequest {
        public String Type {get;set;}
        public Contact Contact {get;set;}
        public List<LineItem> LineItems {get;set;}
    }

    public class InvoiceResponse {
        public String Id {get;set;}
        public String Status {get;set;}
        public String ProviderName {get;set;}
        public List<Invoice> invoices {get;set;}
        public String Message {get;set;}
        public List<Elements> Elements {get;set;} 
    }

    public class Elements {
		public List<ValidationErrors> ValidationErrors {get;set;} 
    }

    public class ValidationErrors {
        public String Message {get;set;}
    }

    public class Invoice {
        public String type {get;set;}
        public String invoiceID {get;set;}
        public Contact contact {get;set;}
        public String brandingThemeId {get;set;}
        public String status {get;set;}
        public List<LineItem> lineItems {get;set;}
    }

    public class Contact {
        public String ContactID {get;set;}
        public String contactStatus {get;set;}
        public String Name {get;set;}
        public String emailAddress {get;set;}
        public Boolean hasValidationErrors {get;set;}
    }

    public class LineItem {
        public String ItemCode {get;set;}
        public String Description {get;set;}
        public Double UnitAmount {get;set;}
        public String TaxType {get;set;}
        public Double TaxAmount {get;set;}
        public Double LineAmount {get;set;}
        public String AccountCode {get;set;}
        public Double Quantity {get;set;}
        public Double DiscountRate {get;set;}
        public String LineItemId {get;set;}

    }

    public class InvoiceRequests {
        public List<InvoiceRequest> Invoices {get; set;}
    }
}