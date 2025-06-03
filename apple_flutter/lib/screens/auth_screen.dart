import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'welcome_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _idController.clear();
      _passwordController.clear();
    });
  }

  // Google 로그인 처리
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final result = await _authService.signInWithGoogle();
      
      if (result['success']) {
        String userId = result['userId'] ?? result['userEmail'];
        String userName = result['userName'] ?? '';
        String authType = result['authType'] ?? 'GOOGLE';
        
        print('🎉 [DEBUG] Google 로그인 성공! userId: $userId, authType: $authType');
        
        // Google 로그인 성공 시 Welcome 화면으로 이동
        if (mounted) {
          print('🔧 [DEBUG] Welcome 화면으로 이동 시작...');
          try {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => WelcomeScreen(
                  userId: userId,
                  userName: userName,
                  welcomeType: 'google_login',
                ),
              ),
            );
            print('🔧 [DEBUG] Welcome 화면에서 돌아옴');
            
            // Welcome 화면에서 돌아온 후 입력 필드 정리
            if (mounted) {
              setState(() {
                _idController.clear();
                _passwordController.clear();
              });
            }
          } catch (e) {
            print('🚨 [ERROR] Welcome 화면 이동 실패: $e');
          }
          return; // 스낵바를 표시하지 않고 바로 리턴
        }
      } else {
        // Google 로그인 실패 시 에러 메시지 표시
        if (mounted && result['code'] != 'LOGIN_CANCELLED') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google 로그인 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String id = _idController.text.trim();
      String password = _passwordController.text.trim();

      bool success;
      String message;

      if (_isLogin) {
        final result = await _authService.login(id, password);
        success = result['success'];
        message = result['message'];
        
        if (success) {
          String userId = result['userId'];
          print('🎉 [DEBUG] 로그인 성공! userId: $userId');
          
          // 로그인 성공 시 Welcome 화면으로 이동
          if (mounted) {
            print('🔧 [DEBUG] Welcome 화면으로 이동 시작...');
            try {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => WelcomeScreen(
                    userId: userId, 
                    welcomeType: 'login'
                  ),
                ),
              );
              print('🔧 [DEBUG] Welcome 화면에서 돌아옴');
              
              // Welcome 화면에서 돌아온 후 입력 필드 정리
              if (mounted) {
                setState(() {
                  _idController.clear();
                  _passwordController.clear();
                });
              }
            } catch (e) {
              print('🚨 [ERROR] Welcome 화면 이동 실패: $e');
            }
            return; // 스낵바를 표시하지 않고 바로 리턴
          }
        }
      } else {
        final result = await _authService.register(id, password);
        success = result['success'];
        message = result['message'];
        
        if (success) {
          // 회원가입 성공 시 Welcome 화면으로 이동
          if (mounted) {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => WelcomeScreen(userId: id),
              ),
            );
            
            // Welcome 화면에서 돌아온 후 로그인 모드로 전환
            if (mounted) {
              setState(() {
                _isLogin = true;
                // 아이디는 그대로 두고 비밀번호만 지워서 사용자 편의성 향상
                _passwordController.clear();
              });
            }
            return; // 스낵바를 표시하지 않고 바로 리턴
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );

        if (success && !_isLogin) {
          // 이 부분은 더 이상 필요하지 않음 (Welcome 화면에서 이미 처리)
          // setState(() {
          //   _isLogin = true;
          //   _idController.clear();
          //   _passwordController.clear();
          // });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          child: Card(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 로고 또는 제목
                    Icon(
                      Icons.apple,
                      size: 64,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isLogin ? '로그인' : '회원가입',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Google 로그인 버튼 (로그인 모드일 때만 표시)
                    if (_isLogin) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            side: BorderSide(color: Colors.grey.shade300),
                            elevation: 1,
                          ),
                          icon: _isGoogleLoading 
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade600),
                                  ),
                                )
                              : Image.network(
                                  'https://developers.google.com/identity/images/g-logo.png',
                                  width: 18,
                                  height: 18,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.account_circle, size: 18, color: Colors.grey.shade600);
                                  },
                                ),
                          label: Text(
                            _isGoogleLoading ? 'Google 로그인 중...' : 'Google로 로그인',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // 구분선
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '또는',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // 아이디 입력
                    TextFormField(
                      controller: _idController,
                      decoration: const InputDecoration(
                        labelText: '아이디',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '아이디를 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // 비밀번호 입력
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: '비밀번호',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '비밀번호를 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // 제출 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                _isLogin ? '로그인' : '회원가입',
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 모드 전환 버튼
                    TextButton(
                      onPressed: _toggleMode,
                      child: Text(
                        _isLogin 
                            ? '계정이 없으신가요? 회원가입'
                            : '이미 계정이 있으신가요? 로그인',
                        style: TextStyle(color: Colors.deepPurple),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 