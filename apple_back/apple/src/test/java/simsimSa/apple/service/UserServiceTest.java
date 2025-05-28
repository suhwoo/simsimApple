package simsimSa.apple.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import simsimSa.apple.model.User;
import simsimSa.apple.repository.UserRepository;
import simsimSa.apple.dto.ApiResponse;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    private UserService userService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        userService = new UserService(userRepository);
    }

    @Test
    void registerUser_WhenValidInput_ShouldSaveUser() {
        // given
        String testId = "testUser";
        String testPassword = "testPass";
        when(userRepository.findById(anyString())).thenReturn(Optional.empty());

        // when
        userService.registerUser(testId, testPassword);

        // then
        verify(userRepository).save(any(User.class));
    }

    @Test
    void registerUser_WhenUserExists_ShouldThrowException() {
        // given
        String testId = "existingUser";
        String testPassword = "testPass";
        when(userRepository.findById(testId)).thenReturn(Optional.of(new User(testId, "password")));

        // when & then
        assertThrows(IllegalStateException.class, () -> {
            userService.registerUser(testId, testPassword);
        });
    }

    @Test
    void registerUser_WhenEmptyId_ShouldThrowException() {
        // given
        String testId = "";
        String testPassword = "testPass";

        // when & then
        assertThrows(IllegalArgumentException.class, () -> {
            userService.registerUser(testId, testPassword);
        });
    }

    @Test
    void registerUser_WhenEmptyPassword_ShouldThrowException() {
        // given
        String testId = "testUser";
        String testPassword = "";

        // when & then
        assertThrows(IllegalArgumentException.class, () -> {
            userService.registerUser(testId, testPassword);
        });
    }

    @Test
    void checkUser_WhenUserExists_ShouldReturnSuccessResponse() {
        // given
        String testId = "existingUser";
        when(userRepository.findById(testId)).thenReturn(Optional.of(new User(testId, "password")));

        // when
        ApiResponse<Void> response = userService.checkUser(testId);

        // then
        assertTrue(response.isSuccess());
        assertEquals("SUCCESS", response.getCode());
        assertEquals("로그인에 성공하였습니다.", response.getMessage());
    }

    @Test
    void checkUser_WhenUserNotExists_ShouldReturnErrorResponse() {
        // given
        String testId = "nonExistingUser";
        when(userRepository.findById(testId)).thenReturn(Optional.empty());

        // when
        ApiResponse<Void> response = userService.checkUser(testId);

        // then
        assertFalse(response.isSuccess());
        assertEquals("USER_NOT_FOUND", response.getCode());
        assertEquals("존재하지 않는 사용자입니다.", response.getMessage());
    }

    @Test
    void checkUser_WhenEmptyId_ShouldReturnErrorResponse() {
        // given
        String testId = "";

        // when
        ApiResponse<Void> response = userService.checkUser(testId);

        // then
        assertFalse(response.isSuccess());
        assertEquals("INVALID_INPUT", response.getCode());
        assertEquals("아이디는 필수 입력값입니다.", response.getMessage());
    }
} 