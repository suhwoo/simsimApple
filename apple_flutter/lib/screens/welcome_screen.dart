import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  final String userId;
  final String welcomeType; // 'login' 또는 'register'

  const WelcomeScreen({
    super.key, 
    required this.userId, 
    this.welcomeType = 'register'
  });

  @override
  Widget build(BuildContext context) {
    bool isLogin = welcomeType == 'login';
    
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      body: Center(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(32),
          child: Card(
            elevation: 12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 성공 아이콘
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: isLogin ? Colors.blue[100] : Colors.green[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isLogin ? Icons.login : Icons.check_circle,
                      size: 60,
                      color: isLogin ? Colors.blue : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 환영 메시지
                  Text(
                    isLogin ? '로그인 성공!' : '회원가입 완료!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 개인화된 인사말
                  Text(
                    '안녕하세요, $userId님!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    isLogin 
                        ? 'Apple 프로젝트에 다시 오신 것을 환영합니다!'
                        : 'Apple 프로젝트에 오신 것을 환영합니다!',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // 구분선
                  Divider(color: Colors.grey[300], thickness: 1),
                  const SizedBox(height: 24),
                  
                  // 다음 단계 안내
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isLogin ? Colors.green[50] : Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isLogin ? Colors.green[200]! : Colors.blue[200]!
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          isLogin ? Icons.verified_user : Icons.info_outline,
                          color: isLogin ? Colors.green[700] : Colors.blue[700],
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isLogin ? '로그인 완료' : '다음 단계',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isLogin ? Colors.green[800] : Colors.blue[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isLogin 
                              ? '성공적으로 로그인되었습니다!\n이제 모든 기능을 이용하실 수 있습니다.'
                              : '이제 새로 만든 계정으로 로그인하여\n서비스를 이용하실 수 있습니다!',
                          style: TextStyle(
                            color: isLogin ? Colors.green[700] : Colors.blue[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // 메인 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(isLogin ? Icons.home : Icons.login),
                      label: Text(
                        isLogin ? '메인으로 이동' : '로그인 화면으로 이동',
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // 보조 버튼 (선택사항)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      '돌아가기',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 