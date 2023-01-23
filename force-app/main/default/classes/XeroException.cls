public class XeroException extends Exception{
    public String status;
    public Integer statusCode;
    // public String recordId;
    public String endpoint;

    public XeroException(Integer statusCode, String message) {
        this(message);
        this.statusCode = statusCode;
    }

    public XeroException(Integer statusCode, String message, String endpoint) {
        this(message);
        this.statusCode = statusCode;
        this.endpoint = endpoint;
    }
}