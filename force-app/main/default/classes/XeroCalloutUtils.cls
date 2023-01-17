public class XeroCalloutUtils {
    // HTTP Request methods
    public static final String HTTP_REQUEST_METHOD_GET = 'GET';
    public static final String HTTP_REQUEST_METHOD_POST = 'POST';
    public static final String HTTP_REQUEST_METHOD_PUT = 'PUT';
    public static final String HTTP_REQUEST_METHOD_PATCH = 'PATCH';
    public static final String HTTP_REQUEST_METHOD_DELETE = 'DELETE';

     // Common HTTP Request header keys
    public static final String HTTP_HEADER_CONTENT_TYPE = 'Content-Type';
    public static final String HTTP_HEADER_ACCEPT = 'Accept';
    public static final String HTTP_HEADER_AUTHORIZATION = 'Authorization';
    public static final String HTTP_HEADER_TENANTID = 'xero-tenant-id';
    public static final String HTTP_HEADER_IF_MODIFIED_SINCE = 'If-Modified-Since';

    // Common HTTP Content Types
    public static final String HTTP_CONTENT_TYPE_TEXT = 'text/plain';
    public static final String HTTP_CONTENT_TYPE_JSON = 'application/json';
    public static final String HTTP_CONTENT_TYPE_FORM_URLENCODED = 'application/x-www-form-urlencoded';

    // URL Encoding Types
    public static final String ENCODING_UTF_8 = 'UTF-8';

    // HTTP Response status codes
    public static final Integer HTTP_RESPONSE_STATUS_OK = 200;
    public static final Integer HTTP_RESPONSE_STATUS_CREATED = 201;
    public static final Integer HTTP_RESPONSE_STATUS_NO_CONTENT = 204;

    public static final Integer HTTP_RESPONSE_STATUS_BAD_REQUEST = 400;
    public static final Integer HTTP_RESPONSE_STATUS_UNAUTHORIZED = 403;
    public static final Integer HTTP_RESPONSE_STATUS_NOT_FOUND = 404;

    public static final Integer HTTP_RESPONSE_STATUS_INTERNAL_ERROR = 500;
    
    public static final Skie_Xero_Variables__c SKIE_XERO_SETTING = Skie_Xero_Variables__c.getOrgDefaults();

    public static HttpResponse callout(String endpoint, String method, Map<String, String> headerMap, String payload) {
        Http http = new Http();
        System.debug('BEGIN with SKieCalloutUtils.callout : REQ= ' + payload);

        HttpRequest request = new HttpRequest();
        request.setMethod(method);
        request.setEndpoint(endpoint);
        request.setBody(payload);

        if(headerMap != null) {
            System.debug(headerMap);
            for(String key : headerMap.keySet()) {
                String value = headerMap.get(key);
                request.setHeader(key, value);
            }
        }
        System.debug('req.method-- ' + request.getMethod());
        System.debug('req.setEndpoint-- ' + request.getEndpoint());
        System.debug('req.setBody-- ' + request.getBody());
        System.debug('req.getHeader-- ' + request.getHeader('Content-Type'));
        System.debug('req.getHeader-- ' + request.getHeader('xero-tenant-id'));

        HttpResponse response = http.send(request);
        System.debug('RESPONSE::: ' + response);
        System.debug('RESPONSEBODYYY::: ' + response.getBody());
        // if (response.getStatusCode() != 201 && response.getStatusCode() != 200) {
        //     System.debug('Failed to create invoice in Xero. Status code: ' + response.getStatusCode() + ' Error message: ' + response.getBody());
        // }

        Xerodata.InvoiceResponse responsePayload = (Xerodata.InvoiceResponse)JSON.deserialize(response.getBody(), Xerodata.InvoiceResponse.class);
        System.debug('RES PAYLOAD:: ' + responsePayload);
        return response;
    }
    public static HttpResponse callout(String endpoint, String method, Map<String, String> headerMap) {
        Http http = new Http();
        // System.debug('BEGIN with SKieCalloutUtils.callout : REQ= ' + payload);

        HttpRequest request = new HttpRequest();
        request.setMethod(method);
        request.setEndpoint(endpoint);
        // request.setBody(payload);

        if(headerMap != null) {
            for(String key : headerMap.keySet()) {
                String value = headerMap.get(key);
                request.setHeader(key, value);
            }
        }

        HttpResponse response = http.send(request);
        if (response.getStatusCode() != 201 && response.getStatusCode() != 200) {
            System.debug('Failed to create invoice in Xero. Status code: ' + response.getStatusCode() + ' Error message: ' + response.getBody());
        }
        System.debug(response.getBody());

        Xerodata.InvoiceResponse responsePayload = (Xerodata.InvoiceResponse)JSON.deserialize(response.getBody(), Xerodata.InvoiceResponse.class);
        System.debug('RES PAYLOAD:: ' + responsePayload);
        return response;
    }
}