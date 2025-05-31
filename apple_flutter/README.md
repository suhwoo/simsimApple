# Apple Flutter Frontend

백엔드 API와 연동하는 Flutter 웹 애플리케이션입니다.

## 🎯 기능

- ✅ 회원가입 (POST /api/users/register)
- ✅ 로그인 (POST /api/users/login)
- ✅ 반응형 웹 UI
- ✅ Docker 컨테이너화

## 🛠 기술 스택

- **Flutter** 3.24+ (웹 지원)
- **Dart** (프로그래밍 언어)
- **HTTP** (REST API 통신)
- **Docker** + **Nginx** (컨테이너화)

## 🏗 프로젝트 구조

```
lib/
├── main.dart           # 앱 진입점
├── screens/
│   └── auth_screen.dart # 로그인/회원가입 화면
└── services/
    └── auth_service.dart # API 통신 서비스
```

## 🚀 로컬 개발 실행

### 1. 의존성 설치
```bash
flutter pub get
```

### 2. 웹 서버 실행
```bash
flutter run -d web-server --web-port 3000
```

브라우저에서 `http://localhost:3000` 접속

## 🐳 Docker 실행

### 1. Docker 이미지 빌드
```bash
docker build -t apple-flutter-web .
```

### 2. 컨테이너 실행
```bash
docker run -p 8080:80 apple-flutter-web
```

브라우저에서 `http://localhost:8080` 접속

## 📡 백엔드 API 연동

### 개발 환경
- API 서버: `http://localhost:8080`
- 네트워크 오류 시 Mock 데이터로 대체

### 프로덕션 환경
`lib/services/auth_service.dart`에서 `baseUrl` 수정:
```dart
static const String baseUrl = 'https://your-api-server.com/api/users';
```

## 🔗 백엔드 API 명세

### 회원가입
```
POST /api/users/register
Content-Type: application/json

{
  "id": "string",
  "password": "string"
}

Response:
{
  "success": boolean,
  "message": "string", 
  "code": "string",
  "data": null
}
```

### 로그인
```
POST /api/users/login
Content-Type: application/json

{
  "id": "string",
  "password": "string" 
}

Response:
{
  "success": boolean,
  "message": "string",
  "code": "string", 
  "data": {
    "id": "string"
  }
}
```

## 🔧 설정

### CORS 설정
백엔드에서 Flutter 웹 도메인에 대한 CORS 허용 필요:
```java
@CrossOrigin(origins = "http://localhost:3000")
```

### 프록시 설정 (Docker)
Dockerfile의 Nginx 설정에서 `/api/` 요청을 백엔드로 프록시:
```nginx
location /api/ {
    proxy_pass http://backend:8080;
}
```

## 📱 향후 확장

- ✅ 웹 버전 (현재)
- 🔄 Android 앱 빌드
- 🔄 iOS 앱 빌드
- 🔄 추가 기능 (프로필, 설정 등)

## 🤝 팀 협업

1. **백엔드 개발자**: Spring Boot API 서버 구축
2. **인프라 개발자**: Docker/K8s 배포 환경 구성
3. **프론트엔드 개발자**: Flutter UI/UX 개발

프로젝트 통합 시 `docker-compose.yml`로 전체 스택 연결 예정
