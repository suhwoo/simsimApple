package simsimSa.apple.dto;

public class UserResponse {
    private String id;
    private String email;
    private String name;

    // 기존 생성자 (하위 호환성)
    public UserResponse(String id) {
        this.id = id;
    }
    
    // Google 로그인용 생성자
    public UserResponse(String id, String email, String name) {
        this.id = id;
        this.email = email;
        this.name = name;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
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
} 