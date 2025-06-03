# 🔧 Google Sign-in 설정 가이드 (상세 버전)

## 🎯 목표
- 기존 아이디/패스워드 로그인과 Google 로그인을 병행 지원
- Flutter Web에서 Google OAuth 2.0 인증 구현
- Spring Boot 백엔드와 연동
- **.env 파일로 보안 관리** (팀원과 안전하게 공유 가능)

---

## 1️⃣ Google Cloud Console 설정 (필수)

### 단계 1: Google Cloud 프로젝트 생성
1. **브라우저에서 접속**: https://console.cloud.google.com/
2. **로그인**: Google 계정으로 로그인
3. **프로젝트 생성**:
   - 상단 드롭다운에서 "새 프로젝트" 클릭
   - 프로젝트 이름: `Apple-Flutter-Auth` (원하는 이름)
   - 조직: 선택 안함 (개인 프로젝트)
   - **만들기** 버튼 클릭

### 단계 2: 필수 API 활성화 ⚠️ 중요!
다음 API들을 **모두** 활성화해야 합니다:

1. **왼쪽 메뉴** → **API 및 서비스** → **라이브러리**
2. 다음 API들을 순서대로 검색하여 활성화:

```
✅ People API              ← 가장 중요! (없으면 Google 로그인 실패)
✅ Google+ API             ← 기본 프로필 정보
✅ Google Sign-In API      ← 인증 관련
✅ Identity and Access Management (IAM) API  ← 권한 관리
```

**각 API마다**: **검색** → **클릭** → **"사용" 버튼 클릭**

### 단계 3: OAuth 동의 화면 설정
1. **왼쪽 메뉴** → **API 및 서비스** → **OAuth 동의 화면**
2. **사용자 유형**: **외부** 선택 → **만들기**
3. **앱 정보** 입력:
   ```
   앱 이름: Apple Flutter App
   사용자 지원 이메일: [본인 이메일]
   개발자 연락처 정보: [본인 이메일]
   ```
4. **저장 후 계속** 클릭
5. **범위** 페이지: **저장 후 계속** (기본값 사용)
6. **테스트 사용자** 페이지: **저장 후 계속**

### 단계 4: OAuth 클라이언트 ID 생성
1. **왼쪽 메뉴** → **API 및 서비스** → **사용자 인증 정보**
2. **+ 사용자 인증 정보 만들기** → **OAuth 클라이언트 ID**
3. **애플리케이션 유형**: **웹 애플리케이션** 선택
4. **세부 정보 입력**:

**개발 환경용 설정**:
```
이름: Apple Flutter Web Client (Dev)

승인된 자바스크립트 원본:
- http://localhost:3000
- http://127.0.0.1:3000

승인된 리디렉션 URI:
- http://localhost:3000
- http://localhost:3000/
- http://127.0.0.1:3000
- http://127.0.0.1:3000/
```

5. **만들기** 버튼 클릭

### 단계 5: 클라이언트 ID 복사
```
📋 생성된 클라이언트 ID 예시:
123456789012-abcdefghijklmnopqrstuvwxyz123456.apps.googleusercontent.com

⚠️ 이 값을 안전한 곳에 복사해두세요!
```

---

## 2️⃣ Flutter 앱 설정 (.env 방식) 🆕

### 단계 1: .env 파일 생성 (매우 간단!)

**터미널에서 실행**:
```bash
# apple_flutter 디렉토리로 이동
cd apple_flutter

# .env_example을 .env로 복사
cp .env_example .env
```

### 단계 2: .env 파일 편집

**파일**: `apple_flutter/.env`를 열어서 수정:

```bash
# 🔧 Google OAuth 설정
# Google Cloud Console에서 생성한 OAuth 클라이언트 ID를 입력하세요
GOOGLE_CLIENT_ID=123456789012-abcdefghijklmnopqrstuvwxyz123456.apps.googleusercontent.com

# 🌐 백엔드 API 설정
API_BASE_URL=http://localhost:8080/api
```

**⚠️ 중요**: `123456789012-abcdefghijklmnopqrstuvwxyz123456.apps.googleusercontent.com` 부분을 **Google Cloud Console에서 복사한 실제 클라이언트 ID**로 교체하세요!

### 단계 3: 설정 완료 확인

**이제 코드 수정이 전혀 필요하지 않습니다!** ✨
- AuthService가 자동으로 `.env`에서 클라이언트 ID를 읽어옵니다
- API URL도 `.env`에서 설정 가능합니다

---

## 3️⃣ 🔒 보안 및 팀 공유

### ✅ **장점**
- **`.env` 파일은 git에 업로드되지 않음** (보안)
- **`.env_example` 파일로 팀원에게 공유** (안전)
- **코드에 민감한 정보가 포함되지 않음**

### 🔄 **팀원과 공유하는 방법**
1. **`.env_example` 파일은 git에 커밋** (문제없음)
2. **팀원이 받은 후**:
   ```bash
   cp .env_example .env
   # 그 후 .env에서 실제 클라이언트 ID만 입력
   ```

### ❓ **클라이언트 시크릿은 필요없나요?**
**답: Flutter Web에서는 필요하지 않습니다!**
- ✅ **클라이언트 ID**: 공개되어도 괜찮은 값, Flutter Web에서 사용
- ❌ **클라이언트 시크릿**: 서버 사이드에서만 사용, Flutter Web에서는 불필요

---

## 4️⃣ 전체 시스템 테스트

### 단계 1: 서비스 시작
```bash
# 터미널에서 프로젝트 루트 디렉토리로 이동
cd /Users/kimjihoon/Desktop/flutter

# 전체 스택 시작
./status.sh start all
```

**예상 출력**:
```
🚀 Apple 프로젝트 전체 스택 시작
==============================================

🔄 MySQL 시작 중...
✅ MySQL 시작 완료 (포트 3306, DB: apple)

🔄 Spring Boot 시작 중...
✅ Spring Boot 시작 완료 (포트 8080)

🔄 Flutter 시작 중...
🔧 [DEBUG] .env 파일 로드 성공
🔧 [DEBUG] Google Client ID 로드 성공: 123456789012-abcdef...
🔧 [DEBUG] API Base URL: http://localhost:8080/api/users
✅ Flutter 시작 완료 (포트 3000)

🎉 전체 스택 시작 완료!
```

### 단계 2: 브라우저에서 접속
1. **브라우저 열기**: Chrome, Safari, Firefox 등
2. **주소 입력**: `http://localhost:3000`
3. **화면 확인**: 로그인 화면이 표시되어야 함

### 단계 3: UI 확인
**정상적으로 설정되었다면 다음과 같은 화면이 보입니다**:

```
🍎 [Apple 아이콘]
     로그인

[Google로 로그인] 버튼 (흰색, Google 로고)
        
      ─── 또는 ───

[아이디 입력 필드]
[비밀번호 입력 필드]
    [로그인] 버튼

계정이 없으신가요? 회원가입
```

### 단계 4: Google 로그인 테스트
1. **"Google로 로그인"** 버튼 클릭
2. **Google 로그인 팝업** 창이 열림
3. **Google 계정 선택** 또는 **로그인**
4. **권한 허용** (이메일, 프로필 정보 접근)
5. **Welcome 화면** 표시:
   ```
   🔴 [계정 아이콘]
   Google 로그인 성공!
   안녕하세요, [Google 이름]님!
   ```

---

## 5️⃣ 백엔드 데이터베이스 확인

### MySQL 데이터베이스 접속
```bash
# MySQL 컨테이너 접속
docker exec -it mysql-apple mysql -u root -p

# 비밀번호 입력: root
```

### 사용자 데이터 확인
```sql
-- 데이터베이스 선택
USE apple;

-- 테이블 구조 확인
DESCRIBE users;

-- Google 로그인 사용자 확인
SELECT id, email, name, google_id, auth_provider, created_at 
FROM users 
WHERE auth_provider = 'GOOGLE';

-- 모든 사용자 확인
SELECT * FROM users ORDER BY created_at DESC;
```

**예상 결과**:
```
+----------+------------------+-------------+---------------------+---------------+---------------------+
| id       | email            | name        | google_id           | auth_provider | created_at          |
+----------+------------------+-------------+---------------------+---------------+---------------------+
| john123  | john@gmail.com   | John Doe    | 1234567890123456789 | GOOGLE        | 2024-01-15 10:30:45 |
| testuser | NULL             | NULL        | NULL                | LOCAL         | 2024-01-15 09:15:30 |
+----------+------------------+-------------+---------------------+---------------+---------------------+
```

---

## 6️⃣ 실시간 로그 모니터링

### Spring Boot 로그 확인
```bash
# 새 터미널 창에서
tail -f logs/spring-boot.log
```

**Google 로그인 시 예상 로그**:
```
INFO  - Google 로그인 요청 받음: googleId=1234567890123456789, email=john@gmail.com
INFO  - 새 Google 사용자 생성: john123
INFO  - Google 로그인 성공: john123
```

### Flutter 로그 확인
```bash
# 다른 터미널에서
tail -f logs/flutter.log
```

---

## 🚨 문제 해결 (Troubleshooting) - 실제 경험한 오류들

### ❌ 문제 1: ".env 파일 로드 실패" 로그
**원인**: .env 파일이 없거나 잘못된 위치  
**해결**:
```bash
cd apple_flutter
cp .env_example .env
# 그 후 .env 파일에서 GOOGLE_CLIENT_ID 설정
```

### ❌ 문제 2: "GOOGLE_CLIENT_ID가 설정되지 않았습니다"
**원인**: .env 파일에서 클라이언트 ID 미설정  
**해결**:
```bash
# .env 파일 편집
nano .env  # 또는 VS Code로 열기

# 다음 형태로 수정:
GOOGLE_CLIENT_ID=실제클라이언트ID.apps.googleusercontent.com
```

### ❌ 문제 3: "Error 400: redirect_uri_mismatch" 🔥 자주 발생!
**원인**: Google Cloud Console의 리디렉션 URI 설정 오류  
**해결**:
1. Google Cloud Console → **사용자 인증 정보** → **OAuth 클라이언트 ID 편집**
2. **승인된 자바스크립트 원본**에 정확히 입력:
   ```
   http://localhost:3000
   http://127.0.0.1:3000
   ```
3. **승인된 리디렉션 URI**에 정확히 입력:
   ```
   http://localhost:3000
   http://localhost:3000/
   http://127.0.0.1:3000
   http://127.0.0.1:3000/
   ```
4. **저장 후 5-10분 대기**

### ❌ 문제 4: "People API has not been used" 🔥 가장 흔한 오류!
**원인**: People API가 비활성화되어 있음  
**해결**:
1. Google Cloud Console → **API 및 서비스** → **라이브러리**
2. **"People API"** 검색 → 클릭 → **"사용"** 버튼 클릭
3. 5-10분 대기 후 재시도

### ❌ 문제 5: "Google 로그인" 버튼이 안 보임
**원인**: 회원가입 모드에 있음  
**해결**: 로그인 모드로 변경
```
화면 하단의 "이미 계정이 있으신가요? 로그인" 클릭
```

### ❌ 문제 6: "클라이언트가 승인되지 않음" 오류
**원인**: Google Cloud Console 설정 문제  
**해결 순서**:
1. Google Cloud Console → OAuth 클라이언트 ID 설정 재확인
2. 승인된 자바스크립트 원본에 `http://localhost:3000` 추가
3. 설정 저장 후 5-10분 대기 (Google 서버 반영 시간)

### ❌ 문제 7: Google 팝업이 뜨지 않음
**원인**: 브라우저 팝업 차단  
**해결**:
```
Chrome: 주소창 오른쪽 팝업 차단 아이콘 클릭 → 허용
Safari: 환경설정 → 웹사이트 → 팝업 윈도우 → localhost 허용
```

### ❌ 문제 8: "네트워크 오류" 메시지
**원인**: 백엔드 서버 연결 문제  
**해결**:
```bash
# 서비스 상태 확인
./status.sh

# Spring Boot 재시작
./status.sh restart spring

# 포트 8080 확인
curl http://localhost:8080
```

---

## 🚀 배포 환경 설정 (Production Deployment)

### 1️⃣ **Google Cloud Console 배포용 설정**

**새로운 OAuth 클라이언트 ID 생성** (권장):
```
이름: Apple Flutter Web Client (Production)

승인된 자바스크립트 원본:
- https://yourdomain.com
- https://www.yourdomain.com

승인된 리디렉션 URI:
- https://yourdomain.com
- https://yourdomain.com/
- https://www.yourdomain.com
- https://www.yourdomain.com/
```

### 2️⃣ **배포용 .env 설정**

**배포 서버의 `.env` 파일**:
```bash
# 🔧 Google OAuth 설정 (배포용)
GOOGLE_CLIENT_ID=987654321098-xyzkjklmnopqrstuvwxyzabcdef987654.apps.googleusercontent.com

# 🌐 백엔드 API 설정 (배포용)
API_BASE_URL=https://api.yourdomain.com/api
```

### 3️⃣ **환경별 설정 관리**

**개발/스테이징/프로덕션 환경 분리**:
```bash
# 개발용
.env.development
GOOGLE_CLIENT_ID=dev_client_id
API_BASE_URL=http://localhost:8080/api

# 스테이징용  
.env.staging
GOOGLE_CLIENT_ID=staging_client_id
API_BASE_URL=https://staging-api.yourdomain.com/api

# 프로덕션용
.env.production
GOOGLE_CLIENT_ID=prod_client_id
API_BASE_URL=https://api.yourdomain.com/api
```

### 4️⃣ **배포 시 주의사항**

**보안 체크리스트**:
- ✅ **HTTPS 사용** (Google OAuth는 HTTPS 필수)
- ✅ **도메인 검증** (Google Cloud Console에서 실제 도메인 등록)
- ✅ **API 키 환경변수 관리** (서버 환경변수로 설정)
- ✅ **CORS 설정** (백엔드에서 프론트엔드 도메인 허용)

---

## 📊 사용자 데이터 관리 전략

### 1️⃣ **현재 구현된 시스템**

**우리 백엔드가 이미 Google 로그인을 완벽 처리하고 있습니다!** ✨

```sql
-- users 테이블 구조
CREATE TABLE users (
    id VARCHAR(255) PRIMARY KEY,           -- 고유 사용자 ID
    password VARCHAR(255),                 -- 로컬 계정용 (Google은 NULL)
    email VARCHAR(255),                    -- Google 이메일
    name VARCHAR(255),                     -- Google 이름
    google_id VARCHAR(255),                -- Google 고유 ID
    auth_provider ENUM('LOCAL', 'GOOGLE'), -- 인증 방식
    created_at TIMESTAMP                   -- 계정 생성일
);
```

### 2️⃣ **Google 로그인 시 자동 처리 로직**

**백엔드(UserService)가 자동으로 처리하는 내용**:

1. **첫 Google 로그인** → 새 계정 자동 생성
   ```
   사용자 ID: john123 (이메일 앞부분 + 중복 시 숫자)
   이메일: john@gmail.com
   이름: John Doe
   Google ID: 1234567890123456789
   인증방식: GOOGLE
   ```

2. **재 로그인** → 기존 계정 정보 업데이트
   ```
   이름이나 이메일 변경 시 자동 동기화
   ```

3. **기존 로컬 계정 연동** → Google 정보 추가
   ```
   같은 이메일의 로컬 계정이 있으면 Google 정보 연동
   ```

### 3️⃣ **사용자 데이터 보관 방법**

**✅ 권장 방식: 우리 백엔드에 보관**

**장점**:
- 🔒 **데이터 통제권**: 우리가 직접 관리
- 🚀 **빠른 접근**: DB 직접 쿼리 가능
- 🛡️ **보안**: Google 의존성 최소화
- 📊 **분석**: 사용자 행동 분석 가능

**보관할 데이터**:
```sql
-- 기본 사용자 정보 (이미 구현됨)
users 테이블: id, email, name, google_id, auth_provider, created_at

-- 추가 사용자 데이터 (필요 시 확장)
user_profiles 테이블: 
  - user_id (FK)
  - profile_image_url
  - bio
  - preferences (JSON)
  - last_login_at
  - login_count

user_activities 테이블:
  - user_id (FK) 
  - action_type
  - action_data (JSON)
  - created_at
```

### 4️⃣ **사용자 데이터 활용 예시**

**프론트엔드에서 사용자 정보 접근**:
```dart
// Google 로그인 성공 후 받는 데이터
{
  'success': true,
  'userId': 'john123',
  'userEmail': 'john@gmail.com', 
  'userName': 'John Doe',
  'authType': 'GOOGLE'
}

// 이후 API 호출로 추가 정보 가져오기
GET /api/users/john123/profile
GET /api/users/john123/activities
```

**백엔드에서 사용자별 데이터 관리**:
```java
// 사용자별 맞춤 기능
@GetMapping("/users/{userId}/dashboard")
public ResponseEntity<UserDashboard> getUserDashboard(@PathVariable String userId) {
    // Google 로그인 사용자든 로컬 사용자든 동일하게 처리
    return userService.getDashboard(userId);
}
```

### 5️⃣ **프라이버시 및 GDPR 준수**

**데이터 처리 원칙**:
- ✅ **최소 수집**: 필요한 정보만 저장
- ✅ **사용자 동의**: 명시적 동의 하에 수집
- ✅ **데이터 삭제**: 사용자 요청 시 완전 삭제
- ✅ **보안 저장**: 암호화 및 접근 제어

---

## 7️⃣ 개발 팁

### 🔄 빠른 재시작 명령어
```bash
# Flutter만 재시작 (UI 변경 후)
./status.sh restart flutter

# Spring Boot만 재시작 (백엔드 변경 후)
./status.sh restart spring

# 전체 재시작
./status.sh restart all
```

### 📊 실시간 상태 모니터링
```bash
# 대화형 메뉴로 서비스 관리
./status.sh

# 실시간 로그 모니터링 (메뉴에서 8번 선택)
```

### 🧪 API 직접 테스트
```bash
# 전통적 로그인 테스트
curl -X POST http://localhost:8080/api/users/login \
  -H "Content-Type: application/json" \
  -d '{"id":"testuser","password":"password123"}'

# Google 로그인 테스트 (실제 데이터로)
curl -X POST http://localhost:8080/api/users/google-login \
  -H "Content-Type: application/json" \
  -d '{"googleId":"123456789","email":"test@gmail.com","name":"Test User","accessToken":"dummy"}'
```

---

## 🎯 최종 체크리스트

### ✅ Google Cloud Console
- [ ] 프로젝트 생성됨
- [ ] **People API 활성화됨** ← 가장 중요!
- [ ] OAuth 동의 화면 설정됨  
- [ ] OAuth 클라이언트 ID 생성됨
- [ ] 클라이언트 ID 복사함

### ✅ Flutter 설정 (.env 방식)
- [ ] `cp .env_example .env` 실행
- [ ] `.env` 파일에 실제 `GOOGLE_CLIENT_ID` 입력
- [ ] `flutter pub get` 실행 완료

### ✅ 백엔드 설정
- [ ] `build.gradle`에 Google 의존성 추가됨
- [ ] User 모델에 Google 필드 추가됨
- [ ] `/google-login` 엔드포인트 생성됨

### ✅ 테스트
- [ ] `./status.sh start all` 성공
- [ ] http://localhost:3000 접속 가능
- [ ] Google 로그인 버튼 표시됨
- [ ] Google 로그인 프로세스 정상 작동
- [ ] 데이터베이스에 사용자 정보 저장됨

### ✅ 보안
- [ ] `.env` 파일이 `.gitignore`에 추가됨
- [ ] `.env_example` 파일로 팀 공유 가능

### ✅ 사용자 데이터 관리
- [ ] Google 로그인 시 자동 계정 생성 확인
- [ ] 데이터베이스에 사용자 정보 저장 확인
- [ ] 재로그인 시 정보 업데이트 확인

---

## 🎉 요약

**.env 방식의 장점**:
- ✅ **설정 간편함**: 코드 수정 불필요
- ✅ **보안 강화**: 민감 정보가 git에 올라가지 않음
- ✅ **팀 공유 편함**: `.env_example`로 안전하게 공유
- ✅ **환경별 관리**: 개발/운영 환경 분리 가능

**🚀 이제 단 3단계면 완료!**
1. **Google Cloud Console에서 클라이언트 ID 생성 + People API 활성화**
2. **`.env` 파일에 클라이언트 ID 입력**
3. **서비스 시작 후 테스트**

**📊 사용자 데이터는 이미 우리 백엔드가 완벽 관리 중!**
- Google 로그인 → 자동 계정 생성
- 사용자 정보 → MySQL 데이터베이스 저장
- 재로그인 → 정보 자동 업데이트
- 확장 가능 → 추가 테이블로 더 많은 데이터 관리

문제가 발생하면 위의 문제 해결 섹션을 참고하시거나, 구체적인 오류 메시지를 알려주세요! 🚀 