import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  // 백엔드 서버 URL (.env에서 로드, 기본값은 localhost)
  static String get baseUrl => '${dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api'}/users';
  
  // Google Sign-In 설정 (.env에서 클라이언트 ID 로드)
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
    clientId: dotenv.env['GOOGLE_CLIENT_ID'], // .env에서 로드
  );
  
  // 생성자에서 환경변수 확인
  AuthService() {
    final clientId = dotenv.env['GOOGLE_CLIENT_ID'];
    if (clientId == null || clientId.isEmpty || clientId == 'YOUR_GOOGLE_CLIENT_ID_HERE') {
      print('⚠️ [WARNING] GOOGLE_CLIENT_ID가 설정되지 않았습니다!');
      print('💡 [INFO] .env 파일에 GOOGLE_CLIENT_ID를 설정해주세요');
      print('📖 [INFO] 자세한 설정 방법은 GOOGLE_SETUP.md를 참고하세요');
    } else {
      print('🔧 [DEBUG] Google Client ID 로드 성공: ${clientId.substring(0, 20)}...');
    }
    print('🔧 [DEBUG] API Base URL: $baseUrl');
  }
  
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

  // Google 로그인
  Future<Map<String, dynamic>> signInWithGoogle() async {
    print('🔧 [DEBUG] Google 로그인 시작');
    
    // 클라이언트 ID 확인
    final clientId = dotenv.env['GOOGLE_CLIENT_ID'];
    if (clientId == null || clientId.isEmpty || clientId == 'YOUR_GOOGLE_CLIENT_ID_HERE') {
      return {
        'success': false,
        'message': 'Google 클라이언트 ID가 설정되지 않았습니다. .env 파일을 확인해주세요.',
        'code': 'GOOGLE_CLIENT_ID_NOT_SET',
      };
    }
    
    try {
      // Google 로그인 프로세스 시작
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // 사용자가 로그인을 취소한 경우
        return {
          'success': false,
          'message': '로그인이 취소되었습니다.',
          'code': 'LOGIN_CANCELLED',
        };
      }

      // Google 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      print('🔧 [DEBUG] Google 사용자 정보:');
      print('  - 이름: ${googleUser.displayName}');
      print('  - 이메일: ${googleUser.email}');
      print('  - Google ID: ${googleUser.id}');

      // 백엔드에 Google 로그인 정보 전송
      return await _loginWithGoogleToken(
        googleUser.id,
        googleUser.email,
        googleUser.displayName ?? '',
        googleAuth.accessToken ?? '',
      );
      
    } catch (e) {
      print('🚨 [ERROR] Google 로그인 실패: $e');
      return {
        'success': false,
        'message': 'Google 로그인 중 오류가 발생했습니다: $e',
        'code': 'GOOGLE_LOGIN_ERROR',
      };
    }
  }

  // Google 토큰으로 백엔드 로그인
  Future<Map<String, dynamic>> _loginWithGoogleToken(
    String googleId,
    String email,
    String name,
    String accessToken,
  ) async {
    print('🔧 [DEBUG] Google 토큰으로 백엔드 로그인 시작');
    print('🔧 [DEBUG] URL: $baseUrl/google-login');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/google-login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'googleId': googleId,
          'email': email,
          'name': name,
          'accessToken': accessToken,
        }),
      );

      print('🔧 [DEBUG] 응답 상태 코드: ${response.statusCode}');
      print('🔧 [DEBUG] 응답 본문: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      if (responseData['success'] == true && responseData['data'] != null) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Google 로그인 성공',
          'userId': responseData['data']['id'] ?? email,
          'userEmail': responseData['data']['email'] ?? email,
          'userName': responseData['data']['name'] ?? name,
          'authType': 'GOOGLE',
          'code': responseData['code'] ?? 'SUCCESS',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Google 로그인에 실패했습니다.',
          'code': responseData['code'] ?? 'GOOGLE_LOGIN_FAILED',
        };
      }
    } catch (e) {
      print('🚨 [ERROR] Google 백엔드 로그인 실패: $e');
      return {
        'success': false,
        'message': '네트워크 오류가 발생했습니다. 서버 연결을 확인해주세요.',
        'code': 'NETWORK_ERROR',
      };
    }
  }

  // Google 로그아웃
  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
      print('🔧 [DEBUG] Google 로그아웃 완료');
    } catch (e) {
      print('🚨 [ERROR] Google 로그아웃 실패: $e');
    }
  }
} 