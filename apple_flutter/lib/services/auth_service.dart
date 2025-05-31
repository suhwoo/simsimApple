import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // 백엔드 서버 URL (개발 시에는 localhost, 나중에 실제 서버 URL로 변경)
  static const String baseUrl = 'http://localhost:8080/api/users';
  
  // 회원가입 API 호출
  Future<Map<String, dynamic>> register(String id, String password) async {
    print('🔧 [DEBUG] 회원가입 API 호출 시작');
    print('🔧 [DEBUG] URL: $baseUrl/register');
    print('🔧 [DEBUG] 요청 데이터: {id: $id, password: [숨김]}');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id': id,
          'password': password,
        }),
      );

      print('🔧 [DEBUG] 응답 상태 코드: ${response.statusCode}');
      print('🔧 [DEBUG] 응답 헤더: ${response.headers}');
      print('🔧 [DEBUG] 응답 본문: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      return {
        'success': responseData['success'] ?? false,
        'message': responseData['message'] ?? '알 수 없는 오류가 발생했습니다.',
        'code': responseData['code'] ?? 'UNKNOWN_ERROR',
      };
    } catch (e) {
      print('🚨 [ERROR] 회원가입 API 호출 실패: $e');
      return {
        'success': false,
        'message': '네트워크 오류가 발생했습니다. 서버 연결을 확인해주세요.',
        'code': 'NETWORK_ERROR',
      };
    }
  }

  // 로그인 API 호출
  Future<Map<String, dynamic>> login(String id, String password) async {
    print('🔧 [DEBUG] 로그인 API 호출 시작');
    print('🔧 [DEBUG] URL: $baseUrl/login');
    print('🔧 [DEBUG] 요청 데이터: {id: $id, password: [숨김]}');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id': id,
          'password': password,
        }),
      );

      print('🔧 [DEBUG] 응답 상태 코드: ${response.statusCode}');
      print('🔧 [DEBUG] 응답 헤더: ${response.headers}');
      print('🔧 [DEBUG] 응답 본문: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      if (responseData['success'] == true && responseData['data'] != null) {
        return {
          'success': true,
          'message': responseData['message'] ?? '로그인 성공',
          'userId': responseData['data']['id'],
          'code': responseData['code'] ?? 'SUCCESS',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? '로그인에 실패했습니다.',
          'code': responseData['code'] ?? 'LOGIN_FAILED',
        };
      }
    } catch (e) {
      print('🚨 [ERROR] 로그인 API 호출 실패: $e');
      return {
        'success': false,
        'message': '네트워크 오류가 발생했습니다. 서버 연결을 확인해주세요.',
        'code': 'NETWORK_ERROR',
      };
    }
  }
} 