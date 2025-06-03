package simsimSa.apple.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "users")
public class User {
    @Id
    private String id;
    
    @Column(nullable = true) // Google 로그인 시에는 비밀번호가 없을 수 있음
    private String password;
    
    @Column(name = "email")
    private String email;
    
    @Column(name = "name")
    private String name;
    
    @Column(name = "google_id")
    private String googleId;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "auth_provider", nullable = false)
    private AuthProvider authProvider = AuthProvider.LOCAL;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    // AuthProvider enum 정의
    public enum AuthProvider {
        LOCAL, GOOGLE
    }
    
    // 기본 생성자 (JPA 필수)
    public User() {
        this.createdAt = LocalDateTime.now();
    }

    // 전통적인 로그인용 생성자
    public User(String id, String password) {
        this.id = id;
        this.password = password;
        this.authProvider = AuthProvider.LOCAL;
        this.createdAt = LocalDateTime.now();
    }
    
    // Google 로그인용 생성자
    public User(String id, String email, String name, String googleId) {
        this.id = id;
        this.email = email;
        this.name = name;
        this.googleId = googleId;
        this.authProvider = AuthProvider.GOOGLE;
        this.createdAt = LocalDateTime.now();
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
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
    
    public String getGoogleId() {
        return googleId;
    }
    
    public void setGoogleId(String googleId) {
        this.googleId = googleId;
    }
    
    public AuthProvider getAuthProvider() {
        return authProvider;
    }
    
    public void setAuthProvider(AuthProvider authProvider) {
        this.authProvider = authProvider;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
} 