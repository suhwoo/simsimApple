package simsimSa.apple.dto;

public class GoogleLoginRequest {
    private String googleId;
    private String email;
    private String name;
    private String accessToken;

    public GoogleLoginRequest() {}

    public GoogleLoginRequest(String googleId, String email, String name, String accessToken) {
        this.googleId = googleId;
        this.email = email;
        this.name = name;
        this.accessToken = accessToken;
    }

    public String getGoogleId() {
        return googleId;
    }

    public void setGoogleId(String googleId) {
        this.googleId = googleId;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getAccessToken() {
        return accessToken;
    }

    public void setAccessToken(String accessToken) {
        this.accessToken = accessToken;
    }
} 