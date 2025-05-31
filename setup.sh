#!/bin/bash

# Apple 프로젝트 로컬 개발 환경 초기 설정 스크립트
# 이 스크립트는 처음 한 번만 실행하면 됩니다.

echo "🍎 Apple 프로젝트 초기 설정을 시작합니다..."
echo ""

# 1. Docker가 실행되어 있는지 확인
echo "1️⃣ Docker 상태 확인 중..."
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker가 실행되지 않았습니다. Docker Desktop을 먼저 실행해주세요."
    echo "   -> Applications > Docker을 실행하거나 'open -a Docker' 명령어를 사용하세요."
    exit 1
fi
echo "✅ Docker가 실행 중입니다."
echo ""

# 2. MySQL Docker 이미지 준비
echo "2️⃣ MySQL Docker 이미지 준비 중..."
if docker images mysql:8.0.26 | grep -q mysql; then
    echo "✅ MySQL 8.0.26 이미지가 이미 존재합니다."
else
    echo "📥 MySQL 8.0.26 이미지를 다운로드 중... (ARM64 플랫폼)"
    # M4 Mac (ARM64)을 위한 플랫폼 지정
    docker pull --platform linux/amd64 mysql:8.0.26
    echo "✅ MySQL 이미지 다운로드 완료"
fi
echo ""

# 3. Flutter 의존성 설치
echo "3️⃣ Flutter 프론트엔드 의존성 설치 중..."
cd apple_flutter
if flutter pub get; then
    echo "✅ Flutter 의존성 설치 완료"
else
    echo "❌ Flutter 의존성 설치 실패. Flutter SDK가 올바르게 설치되어 있는지 확인해주세요."
    exit 1
fi
cd ..
echo ""

# 4. Spring Boot 의존성 확인
echo "4️⃣ Spring Boot 백엔드 의존성 확인 중..."
cd apple_back/apple
if ./gradlew build -x test; then
    echo "✅ Spring Boot 빌드 완료"
else
    echo "❌ Spring Boot 빌드 실패. JDK 17이 설치되어 있는지 확인해주세요."
    exit 1
fi
cd ../..
echo ""

# 5. 포트 사용 상태 확인
echo "5️⃣ 포트 사용 상태 확인 중..."
check_port() {
    if lsof -i :$1 > /dev/null 2>&1; then
        echo "⚠️  포트 $1이 이미 사용 중입니다."
        echo "   사용 중인 프로세스를 종료하려면: lsof -ti:$1 | xargs kill -9"
        return 1
    else
        echo "✅ 포트 $1 사용 가능"
        return 0
    fi
}

check_port 3306  # MySQL
check_port 8080  # Spring Boot
check_port 3000  # Flutter
echo ""

echo "🎉 초기 설정이 완료되었습니다!"
echo ""
echo "다음 단계:"
echo "1. ./start-all.sh 를 실행하여 전체 서비스를 시작하세요"
echo "2. 브라우저에서 http://localhost:3000 으로 접속하세요"
echo "3. 테스트가 끝나면 ./stop-all.sh 로 모든 서비스를 중지하세요"
echo "" 