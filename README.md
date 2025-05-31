# 🍎 Apple 프로젝트

Full-Stack 웹 애플리케이션 (Spring Boot + Flutter + MySQL)

## 📁 프로젝트 구조

```
flutter/
├── apple_back/           # Spring Boot 백엔드 API
│   └── apple/           # Java 17 + Spring Boot 3.4.5
├── apple_flutter/       # Flutter 웹 프론트엔드
│   ├── lib/            # Dart 소스 코드
│   └── Dockerfile      # 컨테이너화 준비
├── apple_infra/        # 인프라스트럭처 설정
│   ├── k8s_yaml/       # Kubernetes 배포 설정
│   └── docker_files/   # Docker 설정
├── hello_world/        # Flutter 학습용 프로젝트
├── setup.sh           # 🔧 초기 설정 스크립트
├── start-all.sh       # 🚀 전체 스택 실행 스크립트
├── stop-all.sh        # 🛑 전체 스택 중지 스크립트
├── status.sh          # 📊 서비스 상태 확인 스크립트
└── test-api.sh        # 🧪 API 테스트 스크립트
```

## 🚀 빠른 시작 (로컬 개발)

### 1️⃣ 초기 설정 (최초 1회만)
```bash
./setup.sh
```
- Docker 상태 확인
- MySQL 이미지 준비
- Flutter 의존성 설치
- Spring Boot 빌드
- 포트 사용 상태 확인

### 2️⃣ 전체 스택 실행
```bash
./start-all.sh
```
- MySQL 데이터베이스 (포트 3306)
- Spring Boot API 서버 (포트 8080)
- Flutter 웹 앱 (포트 3000)

### 3️⃣ 웹 애플리케이션 접속
브라우저에서 **http://localhost:3000** 접속
- 회원가입으로 새 계정 생성
- 로그인으로 인증 테스트

### 4️⃣ 서비스 상태 확인 (언제든지)
```bash
./status.sh
```
- 실시간 서비스 상태 확인
- 각 서비스별 로그 표시
- CPU/메모리 사용률 확인
- 포트 사용 현황

### 5️⃣ API 테스트 (선택사항)
```bash
./test-api.sh
```
- 자동화된 API 기능 테스트
- 회원가입/로그인/보안 검증

### 6️⃣ 전체 스택 중지
```bash
./stop-all.sh
```
- 모든 서비스 안전 종료
- 포트 정리 및 로그 아카이브

## 🛠 기술 스택

### 백엔드 (apple_back)
- **Java 17** + **Spring Boot 3.4.5**
- **Spring Web** (REST API)
- **Spring Data JPA** (ORM)
- **MySQL 8.0.26** (데이터베이스)
- **Gradle** (빌드 도구)

### 프론트엔드 (apple_flutter)
- **Flutter 3.24+** (웹/모바일)
- **Dart** (프로그래밍 언어)
- **Material Design 3** (UI)
- **HTTP** (API 통신)

### 인프라 (apple_infra)
- **Docker** (컨테이너화)
- **Kubernetes** (오케스트레이션)
- **Nginx** (웹 서버)
- **MySQL** (데이터베이스)

## 🔗 API 명세

### 회원가입
```
POST /api/users/register
Content-Type: application/json

{
  "id": "사용자ID",
  "password": "비밀번호"
}
```

### 로그인
```
POST /api/users/login
Content-Type: application/json

{
  "id": "사용자ID", 
  "password": "비밀번호"
}
```

## 📊 모니터링 & 로그

### 실시간 로그 확인
```bash
# Spring Boot 로그
tail -f logs/spring-boot.log

# Flutter 로그  
tail -f logs/flutter.log

# MySQL 로그
docker logs mysql-apple

# 전체 로그 동시 확인
tail -f logs/*.log
```

### 서비스 상태 확인
```bash
# 포트 사용 상태
lsof -i :3306  # MySQL
lsof -i :8080  # Spring Boot
lsof -i :3000  # Flutter

# Docker 컨테이너 상태
docker ps | grep mysql

# 프로세스 상태
ps aux | grep java     # Spring Boot
ps aux | grep flutter  # Flutter
```

## 🐳 Docker 배포

### 개별 컨테이너 빌드
```bash
# Flutter 웹 앱
cd apple_flutter
docker build -t apple-flutter-web .

# MySQL (커스텀 이미지)
cd apple_infra/docker_files/mysql
docker build -t apple-mysql .
```

### 전체 스택 Docker Compose (예정)
```bash
docker-compose up -d
```

## ☁️ AWS 배포 계획

### 아키텍처
- **ECS Fargate**: 컨테이너 실행
- **RDS MySQL**: 관리형 데이터베이스
- **ALB**: 로드 밸런서
- **CloudFront**: CDN (선택사항)

### 예상 비용
- 개발환경: 월 $30-50
- 프로덕션: 월 $100-200

## 🤝 팀 역할

1. **백엔드 개발자**: Spring Boot API 개발
2. **프론트엔드 개발자**: Flutter UI/UX 개발  
3. **인프라 개발자**: Docker/K8s 배포 환경

## 🔧 개발 환경 요구사항

### 필수 도구
- **Docker Desktop** (컨테이너 실행)
- **Flutter SDK 3.24+** (프론트엔드)
- **JDK 17** (백엔드)
- **MySQL Client** (데이터베이스 접근)

### 권장 IDE
- **IntelliJ IDEA** (Spring Boot)
- **VS Code / Cursor** (Flutter)
- **DataGrip** (MySQL)

## 📝 개발 가이드

### 브랜치 전략
```
main        # 프로덕션 배포
develop     # 개발 통합
feature/*   # 기능 개발
hotfix/*    # 긴급 수정
```

### 커밋 메시지
```
feat: 새로운 기능 추가
fix: 버그 수정
docs: 문서 수정
style: 코드 포맷팅
refactor: 코드 리팩토링
test: 테스트 코드
chore: 빌드 업무 수정
```

## 🚨 문제 해결

### 자주 발생하는 문제

**1. 포트 충돌**
```bash
# 사용 중인 포트 확인 및 종료
lsof -ti:8080 | xargs kill -9
```

**2. Docker 연결 실패**
```bash
# Docker Desktop 재시작
open -a Docker
```

**3. Flutter 빌드 실패**
```bash
# Flutter 캐시 정리
cd apple_flutter
flutter clean
flutter pub get
```

**4. Spring Boot 시작 실패**
```bash
# Gradle 캐시 정리
cd apple_back/apple
./gradlew clean build
```

### 지원 및 문의
- 📧 팀 슬랙 채널
- 📋 GitHub Issues
- 📖 프로젝트 Wiki

---

**마지막 업데이트**: 2024년 12월
**버전**: 1.0.0
**라이선스**: Private 