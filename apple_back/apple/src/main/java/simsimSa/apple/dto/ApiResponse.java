package simsimSa.apple.dto;

public class ApiResponse<T> {
    private boolean success;
    private String message;
    private String code;
    private T data;

    public ApiResponse(boolean success, String message, String code, T data) {
        this.success = success;
        this.message = message;
        this.code = code;
        this.data = data;
    }

    public static <T> ApiResponse<T> success(String message, T data) {
        return new ApiResponse<>(true, message, "SUCCESS", data);
    }

    public static <T> ApiResponse<T> error(String message, String code) {
        return new ApiResponse<>(false, message, code, null);
    }

    public boolean isSuccess() {
        return success;
    }

    public String getMessage() {
        return message;
    }

    public String getCode() {
        return code;
    }

    public T getData() {
        return data;
    }
} 