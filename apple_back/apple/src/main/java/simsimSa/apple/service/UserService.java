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