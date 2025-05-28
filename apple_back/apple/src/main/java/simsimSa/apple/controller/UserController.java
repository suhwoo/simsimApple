package simsimSa.apple.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import simsimSa.apple.service.UserService;
import simsimSa.apple.dto.LoginRequest;
import simsimSa.apple.dto.RegisterRequest;
import simsimSa.apple.dto.ApiResponse;
import simsimSa.apple.dto.UserResponse;

@RestController
@RequestMapping("/api/users")
public class UserController {
    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<Void>> registerUser(@RequestBody RegisterRequest request) {
        if (request.getId() == null || request.getId().trim().isEmpty()) {
            return ResponseEntity
                .badRequest()
                .body(ApiResponse.error("아이디를 입력해주세요.", "INVALID_INPUT"));
        }
        if (request.getPassword() == null || request.getPassword().trim().isEmpty()) {
            return ResponseEntity
                .badRequest()
                .body(ApiResponse.error("비밀번호를 입력해주세요.", "INVALID_INPUT"));
        }

        ApiResponse<Void> response = userService.registerUser(request.getId(), request.getPassword());
        return ResponseEntity
            .status(response.isSuccess() ? 200 : 400)
            .body(response);
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<UserResponse>> login(@RequestBody LoginRequest request) {
        if (request.getId() == null || request.getId().trim().isEmpty()) {
            return ResponseEntity
                .badRequest()
                .body(ApiResponse.error("아이디를 입력해주세요.", "INVALID_INPUT"));
        }
        if (request.getPassword() == null || request.getPassword().trim().isEmpty()) {
            return ResponseEntity
                .badRequest()
                .body(ApiResponse.error("비밀번호를 입력해주세요.", "INVALID_INPUT"));
        }

        ApiResponse<UserResponse> response = userService.checkUser(request.getId(), request.getPassword());
        return ResponseEntity
            .status(response.isSuccess() ? 200 : 401)
            .body(response);
    }
} 