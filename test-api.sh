#!/bin/bash

# Apple 프로젝트 API 테스트 스크립트
# 백엔드 API가 올바르게 작동하는지 확인합니다.

echo "🧪 Apple 프로젝트 API 테스트를 시작합니다..."
echo ""

# 서버 상태 확인
echo "1️⃣ 서버 상태 확인 중..."

# Spring Boot 서버 확인
echo "   Spring Boot 서버 확인 중..."
if curl -s http://localhost:8080 > /dev/null 2>&1; then
    echo "✅ Spring Boot 서버 정상 (포트 8080)"
else
    echo "❌ Spring Boot 서버 연결 실패"
    echo "   확인사항: ./start-all.sh 로 서버를 먼저 시작했는지 확인"
    exit 1
fi

# Flutter 웹 서버 확인  
echo "   Flutter 웹 서버 확인 중..."
if curl -s http://localhost:3000 > /dev/null 2>&1; then
    echo "✅ Flutter 웹 서버 정상 (포트 3000)"
else
    echo "❌ Flutter 웹 서버 연결 실패"
    echo "   확인사항: ./start-all.sh 로 서버를 먼저 시작했는지 확인"
    exit 1
fi

# MySQL 서버 확인
echo "   MySQL 서버 확인 중..."
if docker exec mysql-apple mysqladmin ping -h"127.0.0.1" --silent > /dev/null 2>&1; then
    echo "✅ MySQL 서버 정상 (포트 3306)"
else
    echo "❌ MySQL 서버 연결 실패"
    echo "   확인사항: Docker 컨테이너가 실행 중인지 확인"
    exit 1
fi
echo ""

# API 테스트
echo "2️⃣ API 기능 테스트 중..."

# 랜덤 테스트 계정 생성
TEST_ID="testuser_$(date +%s)"
TEST_PASSWORD="testpass123"

echo "   테스트 계정: $TEST_ID"
echo ""

# 회원가입 API 테스트
echo "📝 회원가입 API 테스트..."
REGISTER_RESPONSE=$(curl -s -X POST http://localhost:8080/api/users/register \
  -H "Content-Type: application/json" \
  -d "{\"id\":\"$TEST_ID\",\"password\":\"$TEST_PASSWORD\"}")

echo "   요청: POST /api/users/register"
echo "   응답: $REGISTER_RESPONSE"

# 회원가입 성공 여부 확인
if echo "$REGISTER_RESPONSE" | grep -q '"success":true'; then
    echo "✅ 회원가입 API 테스트 성공"
else
    echo "❌ 회원가입 API 테스트 실패"
    echo "   응답 내용을 확인하세요."
fi
echo ""

# 로그인 API 테스트
echo "🔐 로그인 API 테스트..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8080/api/users/login \
  -H "Content-Type: application/json" \
  -d "{\"id\":\"$TEST_ID\",\"password\":\"$TEST_PASSWORD\"}")

echo "   요청: POST /api/users/login"
echo "   응답: $LOGIN_RESPONSE"

# 로그인 성공 여부 확인
if echo "$LOGIN_RESPONSE" | grep -q '"success":true'; then
    echo "✅ 로그인 API 테스트 성공"
    
    # 응답에서 사용자 ID 추출
    USER_ID=$(echo "$LOGIN_RESPONSE" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
    if [ "$USER_ID" = "$TEST_ID" ]; then
        echo "✅ 사용자 정보 반환 정상 (ID: $USER_ID)"
    else
        echo "⚠️  사용자 정보 불일치 (예상: $TEST_ID, 실제: $USER_ID)"
    fi
else
    echo "❌ 로그인 API 테스트 실패"
    echo "   응답 내용을 확인하세요."
fi
echo ""

# 잘못된 로그인 테스트
echo "🚫 잘못된 로그인 테스트..."
WRONG_LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8080/api/users/login \
  -H "Content-Type: application/json" \
  -d "{\"id\":\"$TEST_ID\",\"password\":\"wrongpassword\"}")

echo "   요청: POST /api/users/login (잘못된 비밀번호)"
echo "   응답: $WRONG_LOGIN_RESPONSE"

# 로그인 실패 여부 확인
if echo "$WRONG_LOGIN_RESPONSE" | grep -q '"success":false'; then
    echo "✅ 잘못된 로그인 차단 정상"
else
    echo "❌ 잘못된 로그인 차단 실패 - 보안 문제!"
fi
echo ""

# 중복 가입 테스트
echo "🔄 중복 가입 테스트..."
DUPLICATE_REGISTER_RESPONSE=$(curl -s -X POST http://localhost:8080/api/users/register \
  -H "Content-Type: application/json" \
  -d "{\"id\":\"$TEST_ID\",\"password\":\"$TEST_PASSWORD\"}")

echo "   요청: POST /api/users/register (중복 ID)"
echo "   응답: $DUPLICATE_REGISTER_RESPONSE"

# 중복 가입 차단 여부 확인
if echo "$DUPLICATE_REGISTER_RESPONSE" | grep -q '"success":false'; then
    echo "✅ 중복 가입 차단 정상"
else
    echo "❌ 중복 가입 차단 실패 - 데이터 무결성 문제!"
fi
echo ""

# 데이터베이스 확인
echo "3️⃣ 데이터베이스 확인 중..."
echo "   생성된 사용자 계정 확인..."
USER_COUNT=$(docker exec mysql-apple mysql -u root -proot -D apple -e "SELECT COUNT(*) FROM user WHERE id='$TEST_ID';" 2>/dev/null | tail -1)

if [ "$USER_COUNT" = "1" ]; then
    echo "✅ 데이터베이스에 사용자 정보 저장 정상"
else
    echo "⚠️  데이터베이스 확인 실패 또는 사용자 정보 불일치"
    echo "   수동 확인: docker exec -it mysql-apple mysql -u root -proot -D apple"
fi
echo ""

# 종합 결과
echo "🎉 API 테스트 완료!"
echo ""
echo "📋 테스트 결과 요약:"
echo "   ✅ 서버 연결: Spring Boot + Flutter + MySQL"
echo "   📝 회원가입: 새 계정 생성 기능"
echo "   🔐 로그인: 인증 및 사용자 정보 반환"
echo "   🚫 보안: 잘못된 로그인 차단"
echo "   🔄 무결성: 중복 가입 방지"
echo "   🗄️  데이터베이스: 사용자 정보 저장"
echo ""
echo "🌐 웹 테스트:"
echo "   브라우저에서 http://localhost:3000 접속"
echo "   테스트 계정으로 로그인: $TEST_ID / $TEST_PASSWORD"
echo ""
echo "📊 추가 확인:"
echo "   Spring Boot 로그: tail -f logs/spring-boot.log"
echo "   Flutter 로그: tail -f logs/flutter.log"
echo "   MySQL 로그: docker logs mysql-apple"
echo "" 