package simsimSa.apple.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import simsimSa.apple.dto.ApiResponse;
import simsimSa.apple.dto.LoginRequest;
import simsimSa.apple.service.UserService;

import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(UserController.class)
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private UserService userService;

    @Test
    void register_WhenValidInput_ShouldReturn200() throws Exception {
        mockMvc.perform(post("/api/users/register")
                .param("id", "testUser")
                .param("password", "testPass"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("회원가입이 완료되었습니다."));
    }

    @Test
    void register_WhenUserExists_ShouldReturn400() throws Exception {
        doThrow(new IllegalStateException("이미 존재하는 아이디입니다."))
                .when(userService).registerUser(anyString(), anyString());

        mockMvc.perform(post("/api/users/register")
                .param("id", "existingUser")
                .param("password", "testPass"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.message").value("회원가입 처리 중 오류가 발생했습니다."))
                .andExpect(jsonPath("$.code").value("REGISTRATION_FAILED"));
    }

    @Test
    void login_WhenUserExists_ShouldReturn200AndSuccessResponse() throws Exception {
        // given
        LoginRequest loginRequest = new LoginRequest();
        loginRequest.setId("testUser");

        when(userService.checkUser(anyString()))
                .thenReturn(ApiResponse.success("로그인에 성공하였습니다.", null));

        // when & then
        mockMvc.perform(post("/api/users/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("로그인에 성공하였습니다."))
                .andExpect(jsonPath("$.code").value("SUCCESS"));
    }

    @Test
    void login_WhenUserNotExists_ShouldReturn401AndErrorResponse() throws Exception {
        // given
        LoginRequest loginRequest = new LoginRequest();
        loginRequest.setId("nonExistingUser");

        when(userService.checkUser(anyString()))
                .thenReturn(ApiResponse.error("존재하지 않는 사용자입니다.", "USER_NOT_FOUND"));

        // when & then
        mockMvc.perform(post("/api/users/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.message").value("존재하지 않는 사용자입니다."))
                .andExpect(jsonPath("$.code").value("USER_NOT_FOUND"));
    }

    @Test
    void login_WhenEmptyId_ShouldReturn400AndErrorResponse() throws Exception {
        // given
        LoginRequest loginRequest = new LoginRequest();
        loginRequest.setId("");

        // when & then
        mockMvc.perform(post("/api/users/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.message").value("아이디를 입력해주세요."))
                .andExpect(jsonPath("$.code").value("INVALID_INPUT"));
    }
} 