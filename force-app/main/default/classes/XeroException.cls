public class XeroException extends Exception{
    public String status;
    public String recordId;

    public XeroException(String recordId, String message) {
        this(message);
        this.recordId = recordId;
    }
}