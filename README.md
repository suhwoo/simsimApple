# 🍎 Apple Project

Flutter + Spring Boot + MySQL을 사용한 풀스택 웹 애플리케이션

## 🚀 빠른 시작

```bash
# 전체 스택 시작
./status.sh start all

# 또는 대화형 메뉴 사용
./status.sh
```

## 📂 프로젝트 구조

```
flutter/
├── 🍎 status.sh          ← 메인 서비스 관리 스크립트
├── ⚙️ setup.sh           ← 초기 환경 설정
├── 🧪 test-api.sh        ← API 테스트 도구
├── 📁 scripts/           ← 관리 도구 모음
│   └── 🗄️ db-check.sh    ← 데이터베이스 관리 도구
├── 📱 apple_flutter/     ← Flutter 웹 프론트엔드
├── ⚙️ apple_back/        ← Spring Boot 백엔드
├── 🐳 apple_infra/       ← Docker & Kubernetes 설정
└── 📝 README.md          ← 이 파일
```

## 🛠️ 주요 스크립트

### 🍎 status.sh - 메인 관리 도구
```bash
./status.sh                    # 대화형 메뉴
./status.sh start all           # 전체 시작
./status.sh stop all            # 전체 중지
./status.sh restart all         # 전체 재시작
./status.sh restart flutter     # Flutter만 재시작 (clean 포함)
./status.sh restart spring      # Spring Boot만 재시작
./status.sh restart mysql       # MySQL만 재시작
```

### 🗄️ scripts/db-check.sh - 데이터베이스 관리
```bash
./scripts/db-check.sh           # 대화형 데이터베이스 관리 메뉴
./scripts/db-check.sh users     # 사용자 목록 조회
./scripts/db-check.sh tables    # 테이블 목록 조회
./scripts/db-check.sh schema    # 테이블 구조 조회
./scripts/db-check.sh stats     # 데이터베이스 통계
./scripts/db-check.sh realtime  # 실시간 모니터링
./scripts/db-check.sh query     # SQL 쿼리 실행
./scripts/db-check.sh all       # 전체 정보 조회
```

**데이터베이스 관리 기능:**
- 👥 사용자 목록 조회 (비밀번호 마스킹)
- 📊 상세 통계 (일별/주별 가입자, 테이블 크기 등)
- 📡 실시간 사용자 등록 모니터링
- ⚡ 커스텀 SQL 쿼리 실행
- 🏗️ 테이블 구조 확인

### 🧪 test-api.sh - API 테스트
```bash
./test-api.sh                   # 전체 API 테스트 실행
```

## 🎯 서비스 구성

- **🌐 Flutter Web**: `http://localhost:3000`
- **⚙️ Spring Boot API**: `http://localhost:8080`
- **🗄️ MySQL Database**: `localhost:3306` (DB: apple)

## 💻 개발 환경

- **Frontend**: Flutter 3.24+ (Web)
- **Backend**: Spring Boot 3.4.5 + Java 17
- **Database**: MySQL 8.0.26 (Docker)
- **Infrastructure**: Docker + Kubernetes

## 📊 모니터링 & 디버깅

### 📋 로그 확인
```bash
# 실시간 로그 모니터링 (status.sh 메뉴에서 '8' 선택)
tail -f logs/spring-boot.log    # Spring Boot 로그
tail -f logs/flutter.log        # Flutter 로그
docker logs mysql-apple         # MySQL 로그
```

### 🗄️ 데이터베이스 직접 접근
```bash
# status.sh 메뉴에서 '9' 선택하거나
./scripts/db-check.sh

# 또는 직접 MySQL 접속
docker exec -it mysql-apple mysql -u root -proot -D apple
```

## 🎮 사용법

1. **초기 설정**: `./setup.sh`
2. **서비스 시작**: `./status.sh start all`
3. **브라우저 접속**: `http://localhost:3000`
4. **회원가입/로그인** 테스트
5. **데이터베이스 확인**: `./scripts/db-check.sh users`

## 🔧 문제 해결

### 서비스가 시작되지 않는 경우
```bash
./status.sh                     # 현재 상태 확인
./status.sh restart all         # 전체 재시작
```

### 데이터베이스 연결 문제
```bash
./scripts/db-check.sh           # DB 연결 상태 확인
./status.sh restart mysql       # MySQL만 재시작
```

### Flutter 캐시 문제
```bash
./status.sh restart flutter     # clean + 재시작
```

## 📈 프로덕션 배포

AWS ECS 배포 준비:
```bash
cd apple_infra
# Kubernetes 설정 파일들 확인
ls k8s_yaml/
```

---

## 🎉 주요 기능

✅ **완전한 인증 시스템**: 회원가입, 로그인, 보안 검증  
✅ **실시간 데이터베이스 저장**: JPA + MySQL 연동  
✅ **반응형 웹 UI**: Material Design 3  
✅ **CORS 설정**: Flutter ↔ Spring Boot 통신  
✅ **포괄적인 관리 도구**: 서비스 관리, DB 관리, API 테스트  
✅ **개발자 친화적**: 상세한 로그, 실시간 모니터링, 디버깅 도구 