package simsimSa.apple.service;

import org.springframework.stereotype.Service;
import simsimSa.apple.model.User;
import simsimSa.apple.repository.UserRepository;
import simsimSa.apple.dto.ApiResponse;
import simsimSa.apple.dto.UserResponse;

import java.util.Optional;

@Service
public class UserService {
    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public ApiResponse<Void> registerUser(String id, String password) {
        try {
            validateId(id);
            validatePassword(password);
            
            if (userRepository.findById(id.trim()).isPresent()) {
                return ApiResponse.error("이미 존재하는 아이디입니다.", "DUPLICATE_USER");
            }

            User user = new User(id.trim(), password);
            userRepository.save(user);
            return ApiResponse.success("회원가입이 완료되었습니다.", null);
        } catch (IllegalArgumentException e) {
            return ApiResponse.error(e.getMessage(), "INVALID_INPUT");
        } catch (Exception e) {
            return ApiResponse.error("회원가입 처리 중 오류가 발생했습니다.", "REGISTRATION_FAILED");
        }
    }

    public ApiResponse<UserResponse> checkUser(String id, String password) {
        try {
            validateId(id);
            validatePassword(password);
            
            return userRepository.findById(id.trim())
                .map(user -> {
                    if (!user.getPassword().equals(password)) {
                        return ApiResponse.<UserResponse>error("비밀번호가 일치하지 않습니다.", "INVALID_PASSWORD");
                    }
                    return ApiResponse.success("로그인에 성공하였습니다.", new UserResponse(user.getId()));
                })
                .orElse(ApiResponse.error("존재하지 않는 사용자입니다.", "USER_NOT_FOUND"));
        } catch (IllegalArgumentException e) {
            return ApiResponse.error(e.getMessage(), "INVALID_INPUT");
        }
    }

    // Google 로그인 처리
    public ApiResponse<UserResponse> processGoogleLogin(String googleId, String email, String name, String accessToken) {
        try {
            // 입력값 검증
            if (googleId == null || googleId.trim().isEmpty()) {
                return ApiResponse.error("Google ID가 필요합니다.", "INVALID_GOOGLE_ID");
            }
            if (email == null || email.trim().isEmpty()) {
                return ApiResponse.error("이메일이 필요합니다.", "INVALID_EMAIL");
            }

            // Google ID로 기존 사용자 찾기
            Optional<User> existingUserByGoogleId = userRepository.findByGoogleId(googleId);
            if (existingUserByGoogleId.isPresent()) {
                // 기존 Google 사용자 - 로그인 처리
                User user = existingUserByGoogleId.get();
                // 사용자 정보 업데이트 (이름이나 이메일이 변경될 수 있음)
                user.setName(name);
                user.setEmail(email);
                userRepository.save(user);
                
                return ApiResponse.success("Google 로그인에 성공하였습니다.", 
                    new UserResponse(user.getId(), user.getEmail(), user.getName()));
            }

            // 이메일로 기존 사용자 찾기 (일반 계정이 있는 경우)
            Optional<User> existingUserByEmail = userRepository.findByEmail(email);
            if (existingUserByEmail.isPresent()) {
                User user = existingUserByEmail.get();
                if (user.getAuthProvider() == User.AuthProvider.LOCAL) {
                    // 기존 로컬 계정이 있는 경우 - Google 정보 연동
                    user.setGoogleId(googleId);
                    user.setAuthProvider(User.AuthProvider.GOOGLE);
                    user.setName(name);
                    userRepository.save(user);
                    
                    return ApiResponse.success("Google 계정이 기존 계정과 연동되었습니다.", 
                        new UserResponse(user.getId(), user.getEmail(), user.getName()));
                }
            }

            // 새 Google 사용자 생성
            // 고유한 사용자 ID 생성 (이메일의 @ 앞부분 사용, 중복시 숫자 추가)
            String baseUserId = email.split("@")[0];
            String uniqueUserId = generateUniqueUserId(baseUserId);
            
            User newUser = new User(uniqueUserId, email, name, googleId);
            userRepository.save(newUser);
            
            return ApiResponse.success("Google 계정으로 회원가입이 완료되었습니다.", 
                new UserResponse(newUser.getId(), newUser.getEmail(), newUser.getName()));

        } catch (Exception e) {
            return ApiResponse.error("Google 로그인 처리 중 오류가 발생했습니다: " + e.getMessage(), "GOOGLE_LOGIN_FAILED");
        }
    }

    // 고유한 사용자 ID 생성
    private String generateUniqueUserId(String baseId) {
        String candidateId = baseId;
        int counter = 1;
        
        while (userRepository.findById(candidateId).isPresent()) {
            candidateId = baseId + counter;
            counter++;
        }
        
        return candidateId;
    }

    private void validateId(String id) {
        if (id == null || id.trim().isEmpty()) {
            throw new IllegalArgumentException("아이디는 필수 입력값입니다.");
        }
    }

    private void validatePassword(String password) {
        if (password == null || password.trim().isEmpty()) {
            throw new IllegalArgumentException("비밀번호는 필수 입력값입니다.");
        }
    }
} 