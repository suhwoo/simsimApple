#!/bin/bash

# ========================================
# 🍎 Apple 프로젝트 통합 서비스 관리자
# ========================================
# 
# 🚀 사용법:
#   ./status.sh                     - 상태 확인 + 대화형 메뉴
#   ./status.sh start all           - 전체 서비스 시작
#   ./status.sh stop all            - 전체 서비스 중지
#   ./status.sh restart all         - 전체 서비스 재시작
#   ./status.sh restart flutter     - Flutter만 재시작 (clean 포함)
#   ./status.sh restart spring      - Spring Boot만 재시작
#   ./status.sh restart mysql       - MySQL만 재시작
#
# 📦 관리하는 서비스:
#   - MySQL 8.0.26 (포트 3306)
#   - Spring Boot (포트 8080) 
#   - Flutter Web (포트 3000)

# ========================================
# 🎨 기본 설정
# ========================================

# 작업 디렉토리 설정
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 색상 테마
RED='\033[0;31m'      # 오류, 중지
GREEN='\033[0;32m'    # 성공, 실행 중
YELLOW='\033[1;33m'   # 경고, 진행 중
BLUE='\033[0;34m'     # 정보, 링크
PURPLE='\033[0;35m'   # 제목
CYAN='\033[0;36m'     # 섹션 헤더
NC='\033[0m'          # 색상 초기화

# 로그 디렉토리 생성
mkdir -p logs

# ========================================
# 🔍 서비스 상태 확인 함수들
# ========================================

# MySQL 상태 확인
check_mysql_status() {
    if docker ps | grep -q mysql-apple; then
        MYSQL_CONTAINER_ID=$(docker ps --filter "name=mysql-apple" --format "{{.ID}}")
        MYSQL_UPTIME=$(docker ps --filter "name=mysql-apple" --format "{{.Status}}")
        echo -e "${GREEN}✅ 실행 중${NC} (ID: $MYSQL_CONTAINER_ID)"
        echo "   상태: $MYSQL_UPTIME"
        return 0
    else
        echo -e "${RED}❌ 중지됨${NC}"
        return 1
    fi
}

# Spring Boot 상태 확인
check_spring_status() {
    if [ -f "logs/spring-boot.pid" ]; then
        SPRING_PID=$(cat logs/spring-boot.pid)
        if ps -p $SPRING_PID > /dev/null 2>&1; then
            SPRING_CPU=$(ps -p $SPRING_PID -o %cpu | tail -1 | xargs)
            SPRING_MEM=$(ps -p $SPRING_PID -o %mem | tail -1 | xargs)
            echo -e "${GREEN}✅ 실행 중${NC} (PID: $SPRING_PID)"
            echo "   리소스: CPU ${SPRING_CPU}%, MEM ${SPRING_MEM}%"
            return 0
        else
            echo -e "${RED}❌ 중지됨${NC} (좀비 PID 파일 정리 중...)"
            rm -f logs/spring-boot.pid
            return 1
        fi
    else
        echo -e "${RED}❌ 중지됨${NC}"
        return 1
    fi
}

# Flutter 상태 확인
check_flutter_status() {
    if [ -f "logs/flutter.pid" ]; then
        FLUTTER_PID=$(cat logs/flutter.pid)
        if ps -p $FLUTTER_PID > /dev/null 2>&1; then
            FLUTTER_CPU=$(ps -p $FLUTTER_PID -o %cpu | tail -1 | xargs)
            FLUTTER_MEM=$(ps -p $FLUTTER_PID -o %mem | tail -1 | xargs)
            echo -e "${GREEN}✅ 실행 중${NC} (PID: $FLUTTER_PID)"
            echo "   리소스: CPU ${FLUTTER_CPU}%, MEM ${FLUTTER_MEM}%"
            return 0
        else
            echo -e "${RED}❌ 중지됨${NC} (좀비 PID 파일 정리 중...)"
            rm -f logs/flutter.pid
            return 1
        fi
    else
        echo -e "${RED}❌ 중지됨${NC}"
        return 1
    fi
}

# ========================================
# 🚀 서비스 시작 함수들
# ========================================

# MySQL 시작
start_mysql() {
    echo -e "${YELLOW}🔄 MySQL 시작 중...${NC}"
    
    # 기존 컨테이너 정리
    if docker ps -a | grep -q mysql-apple; then
        echo "   기존 MySQL 컨테이너 정리 중..."
        docker stop mysql-apple > /dev/null 2>&1
        docker rm mysql-apple > /dev/null 2>&1
    fi
    
    # 새 컨테이너 시작
    echo "   MySQL 8.0.26 컨테이너 시작 중..."
    docker run -d --name mysql-apple \
        --platform linux/amd64 \
        -e MYSQL_ROOT_PASSWORD=root \
        -e MYSQL_DATABASE=apple \
        -p 3306:3306 \
        mysql:8.0.26 \
        --bind-address=0.0.0.0 > /dev/null 2>&1
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ MySQL 컨테이너 시작 실패${NC}"
        return 1
    fi
    
    # 초기화 대기
    echo "   MySQL 서버 초기화 대기 중..."
    for i in {1..30}; do
        if docker exec mysql-apple mysqladmin ping -h"127.0.0.1" --silent > /dev/null 2>&1; then
            echo -e "${GREEN}✅ MySQL 시작 완료${NC} (포트 3306, DB: apple)"
            return 0
        fi
        sleep 1
    done
    
    echo -e "${RED}❌ MySQL 초기화 시간 초과${NC}"
    return 1
}

# Spring Boot 시작
start_spring() {
    echo -e "${YELLOW}🔄 Spring Boot 시작 중...${NC}"
    
    # application.properties 파일 확인/생성
    PROPERTIES_FILE="apple_back/apple/src/main/resources/application.properties"
    if [ ! -f "$PROPERTIES_FILE" ]; then
        echo "   application.properties 파일 생성 중..."
        mkdir -p "apple_back/apple/src/main/resources"
        cat > "$PROPERTIES_FILE" << 'EOF'
# MySQL 데이터베이스 설정
spring.datasource.url=jdbc:mysql://localhost:3306/apple?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
spring.datasource.username=root
spring.datasource.password=root
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

# JPA/Hibernate 설정
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQLDialect

# 서버 포트 설정
server.port=8080

# CORS 설정 (Flutter 개발용)
spring.web.cors.allowed-origins=http://localhost:3000
spring.web.cors.allowed-methods=GET,POST,PUT,DELETE,OPTIONS
spring.web.cors.allowed-headers=*
spring.web.cors.allow-credentials=true
EOF
    fi
    
    # Spring Boot 서버 실행
    echo "   Spring Boot 서버 실행 중..."
    cd apple_back/apple
    nohup ./gradlew bootRun > ../../logs/spring-boot.log 2>&1 &
    SPRING_PID=$!
    echo $SPRING_PID > ../../logs/spring-boot.pid
    cd ../..
    
    # 시작 대기
    echo "   Spring Boot 시작 확인 중..."
    for i in {1..60}; do
        if curl -s http://localhost:8080 > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Spring Boot 시작 완료${NC} (포트 8080)"
            return 0
        fi
        sleep 1
    done
    
    echo -e "${RED}❌ Spring Boot 시작 시간 초과${NC}"
    echo "   로그 확인: tail -f logs/spring-boot.log"
    return 1
}

# Flutter 시작  
start_flutter() {
    echo -e "${YELLOW}🔄 Flutter 시작 중...${NC}"
    
    # Flutter 캐시 정리 및 의존성 설치
    echo "   Flutter 캐시 정리 중..."
    cd apple_flutter
    flutter clean > /dev/null 2>&1
    echo "   Flutter 의존성 설치 중..."
    flutter pub get > /dev/null 2>&1
    
    # Flutter 웹 서버 실행
    echo "   Flutter 웹 서버 실행 중..."
    nohup flutter run -d web-server --web-port=3000 > ../logs/flutter.log 2>&1 &
    FLUTTER_PID=$!
    echo $FLUTTER_PID > ../logs/flutter.pid
    cd ..
    
    # 시작 대기
    echo "   Flutter 시작 확인 중..."
    for i in {1..30}; do
        if curl -s http://localhost:3000 > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Flutter 시작 완료${NC} (포트 3000)"
            return 0
        fi
        sleep 1
    done
    
    echo -e "${RED}❌ Flutter 시작 시간 초과${NC}"
    echo "   로그 확인: tail -f logs/flutter.log"
    return 1
}

# 전체 스택 시작
start_all_services() {
    echo -e "${PURPLE}🚀 Apple 프로젝트 전체 스택 시작${NC}"
    echo "=============================================="
    echo ""
    
    # 1단계: MySQL 시작
    start_mysql
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ MySQL 시작 실패로 중단합니다.${NC}"
        return 1
    fi
    echo ""
    
    # 2단계: Spring Boot 시작  
    start_spring
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Spring Boot 시작 실패로 중단합니다.${NC}"
        return 1
    fi
    echo ""
    
    # 3단계: Flutter 시작
    start_flutter
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Flutter 시작 실패로 중단합니다.${NC}"
        return 1
    fi
    echo ""
    
    # 성공 메시지
    echo -e "${GREEN}🎉 전체 스택 시작 완료!${NC}"
    echo ""
    echo "📋 서비스 접속 정보:"
    echo "   🗄️  MySQL Database: localhost:3306 (DB: apple)"
    echo "   ⚙️  Spring Boot API: http://localhost:8080"
    echo -e "   🌐 Flutter Web App: ${BLUE}http://localhost:3000${NC}"
    echo ""
    echo "🧪 테스트 방법:"
    echo "   1. 브라우저에서 http://localhost:3000 접속"
    echo "   2. 회원가입으로 새 계정 생성"
    echo "   3. 로그인으로 계정 확인"
    echo "   4. API 테스트: ./status.sh 메뉴에서 '7) API 테스트 실행'"
    
    return 0
}

# ========================================
# 🛑 서비스 중지 함수들  
# ========================================

# Flutter 중지
stop_flutter() {
    echo -e "${YELLOW}🔄 Flutter 중지 중...${NC}"
    
    if [ -f "logs/flutter.pid" ]; then
        FLUTTER_PID=$(cat logs/flutter.pid)
        if ps -p $FLUTTER_PID > /dev/null 2>&1; then
            echo "   Flutter 프로세스 종료 중... (PID: $FLUTTER_PID)"
            kill $FLUTTER_PID
            sleep 2
            if ps -p $FLUTTER_PID > /dev/null 2>&1; then
                echo "   Flutter 강제 종료 중..."
                kill -9 $FLUTTER_PID
            fi
        fi
        rm -f logs/flutter.pid
    fi
    
    # 포트 3000 정리
    if lsof -ti:3000 > /dev/null 2>&1; then
        echo "   포트 3000 정리 중..."
        lsof -ti:3000 | xargs kill -9 > /dev/null 2>&1
    fi
    
    echo -e "${GREEN}✅ Flutter 중지 완료${NC}"
}

# Spring Boot 중지
stop_spring() {
    echo -e "${YELLOW}🔄 Spring Boot 중지 중...${NC}"
    
    if [ -f "logs/spring-boot.pid" ]; then
        SPRING_PID=$(cat logs/spring-boot.pid)
        if ps -p $SPRING_PID > /dev/null 2>&1; then
            echo "   Spring Boot 프로세스 종료 중... (PID: $SPRING_PID)"
            kill $SPRING_PID
            sleep 3
            if ps -p $SPRING_PID > /dev/null 2>&1; then
                echo "   Spring Boot 강제 종료 중..."
                kill -9 $SPRING_PID
            fi
        fi
        rm -f logs/spring-boot.pid
    fi
    
    # 포트 8080 정리
    if lsof -ti:8080 > /dev/null 2>&1; then
        echo "   포트 8080 정리 중..."
        lsof -ti:8080 | xargs kill -9 > /dev/null 2>&1
    fi
    
    # Gradle daemon 중지
    echo "   Gradle daemon 중지 중..."
    cd apple_back/apple
    ./gradlew --stop > /dev/null 2>&1
    cd ../..
    
    echo -e "${GREEN}✅ Spring Boot 중지 완료${NC}"
}

# MySQL 중지
stop_mysql() {
    echo -e "${YELLOW}🔄 MySQL 중지 중...${NC}"
    
    if docker ps | grep -q mysql-apple; then
        echo "   MySQL 컨테이너 중지 중..."
        docker stop mysql-apple > /dev/null 2>&1
        echo "   MySQL 컨테이너 제거 중..."
        docker rm mysql-apple > /dev/null 2>&1
    fi
    
    echo -e "${GREEN}✅ MySQL 중지 완료${NC}"
}

# 전체 스택 중지
stop_all_services() {
    echo -e "${PURPLE}🛑 Apple 프로젝트 전체 스택 중지${NC}"
    echo "=============================================="
    echo ""
    
    # 1단계: Flutter 중지
    stop_flutter
    echo ""
    
    # 2단계: Spring Boot 중지
    stop_spring
    echo ""
    
    # 3단계: MySQL 중지
    stop_mysql
    echo ""
    
    # 로그 아카이브
    echo -e "${YELLOW}🗂️  로그 파일 아카이브 중...${NC}"
    if [ -d "logs" ] && [ "$(ls -A logs)" ]; then
        TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
        mkdir -p archived_logs
        mv logs "archived_logs/logs_$TIMESTAMP"
        echo -e "${GREEN}✅ 로그가 archived_logs/logs_$TIMESTAMP 로 이동되었습니다.${NC}"
        mkdir -p logs  # 새 로그 디렉토리 생성
    else
        echo "   정리할 로그 파일이 없습니다."
    fi
    echo ""
    
    # 완료 메시지
    echo -e "${GREEN}🎉 전체 스택 중지 완료!${NC}"
    echo ""
    echo "📊 정리된 서비스:"
    echo "   🗄️  MySQL Database (포트 3306)"
    echo "   ⚙️  Spring Boot API (포트 8080)"
    echo "   🌐 Flutter Web App (포트 3000)"
    echo ""
    echo "🔄 다시 시작하려면: ./status.sh start all"
}

# ========================================
# 🔄 개별 서비스 재시작 함수들
# ========================================

restart_mysql() {
    echo -e "${YELLOW}🔄 MySQL 재시작 중...${NC}"
    stop_mysql
    sleep 2
    start_mysql
}

restart_spring() {
    echo -e "${YELLOW}🔄 Spring Boot 재시작 중...${NC}"
    stop_spring
    sleep 2
    start_spring
}

restart_flutter() {
    echo -e "${YELLOW}🔄 Flutter 재시작 중 (clean 포함)...${NC}"
    stop_flutter
    sleep 2
    start_flutter
}

# ========================================
# 📊 상태 표시 함수들
# ========================================

# 전체 상태 확인 및 표시
show_current_status() {
    echo -e "${PURPLE}📊 Apple 프로젝트 서비스 상태 확인${NC}"
    echo "=============================================="
    echo ""

    # MySQL 상태
    echo -e "${CYAN}1️⃣ MySQL 데이터베이스${NC}"
    echo "----------------------------------------"
    check_mysql_status
    mysql_running=$?
    echo ""

    # Spring Boot 상태
    echo -e "${CYAN}2️⃣ Spring Boot 백엔드${NC}"
    echo "----------------------------------------"
    check_spring_status
    spring_running=$?
    echo ""

    # Flutter 상태
    echo -e "${CYAN}3️⃣ Flutter 웹 프론트엔드${NC}"
    echo "----------------------------------------"
    check_flutter_status
    flutter_running=$?
    if [ $flutter_running -eq 0 ]; then
        echo -e "🌐 접속 URL: ${BLUE}http://localhost:3000${NC}"
    fi
    echo ""

    # 전체 상태 요약
    running_count=$((($mysql_running == 0) + ($spring_running == 0) + ($flutter_running == 0)))
    echo -e "${CYAN}4️⃣ 전체 상태 요약${NC}"
    echo "----------------------------------------"
    
    if [ $running_count -eq 3 ]; then
        echo -e "상태: ${GREEN}🎉 전체 스택 정상 실행 중${NC} ($running_count/3)"
        echo "🧪 테스트: 브라우저에서 http://localhost:3000 접속"
    elif [ $running_count -eq 0 ]; then
        echo -e "상태: ${RED}❌ 전체 스택 중지됨${NC} ($running_count/3)"
        echo "🚀 시작: ./status.sh start all"
    else
        echo -e "상태: ${YELLOW}⚠️  부분 실행 중${NC} ($running_count/3)"
        echo "🔧 수정: 개별 서비스 재시작 권장"
    fi
    echo ""
}

# 대화형 메뉴 표시
show_interactive_menu() {
    echo -e "${PURPLE}🛠️  서비스 관리 메뉴${NC}"
    echo "=============================================="
    echo "1) 🚀 전체 스택 시작"
    echo "2) 🛑 전체 스택 중지"
    echo "3) 🔄 전체 스택 재시작"
    echo "4) 🎯 Flutter만 재시작 (clean 포함)"
    echo "5) ⚙️  Spring Boot만 재시작"
    echo "6) 🗄️  MySQL만 재시작"
    echo "7) 🧪 API 테스트 실행"
    echo "8) 📊 실시간 로그 확인"
    echo "0) 👋 종료"
    echo ""
    echo -n "선택하세요 (0-8): "
}

# 메뉴 선택 실행
execute_menu_choice() {
    local choice=$1
    echo ""
    
    case $choice in
        1)
            start_all_services
            ;;
        2)
            stop_all_services
            ;;
        3)
            echo -e "${YELLOW}🔄 전체 스택 재시작 중...${NC}"
            stop_all_services
            echo ""
            echo -e "${YELLOW}⏳ 시스템 안정화 대기 중... (3초)${NC}"
            sleep 3
            echo ""
            start_all_services
            ;;
        4)
            restart_flutter
            ;;
        5)
            restart_spring
            ;;
        6)
            restart_mysql
            ;;
        7)
            echo -e "${YELLOW}🧪 API 테스트 실행 중...${NC}"
            if [ -f "test-api.sh" ]; then
                ./test-api.sh
            else
                echo -e "${RED}❌ test-api.sh 파일을 찾을 수 없습니다.${NC}"
            fi
            ;;
        8)
            echo -e "${YELLOW}📊 실시간 로그 확인 중... (Ctrl+C로 종료)${NC}"
            echo ""
            echo "📋 로그 파일 위치:"
            echo "   Spring Boot: logs/spring-boot.log"
            echo "   Flutter: logs/flutter.log"
            echo "   MySQL: docker logs mysql-apple"
            echo ""
            echo "🔍 로그 모니터링 시작..."
            tail -f logs/*.log 2>/dev/null || echo "로그 파일이 없습니다."
            ;;
        0)
            echo -e "${GREEN}👋 Apple 프로젝트 관리자를 종료합니다.${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ 잘못된 선택입니다. 0-8 사이의 숫자를 입력해주세요.${NC}"
            ;;
    esac
}

# ========================================
# 🎯 메인 실행 로직
# ========================================

main() {
    # 인자가 있으면 직접 실행 모드
    if [ $# -gt 0 ]; then
        case "$1" in
            "start")
                if [ "$2" = "all" ]; then
                    start_all_services
                else
                    echo -e "${RED}❌ 사용법: $0 start all${NC}"
                    exit 1
                fi
                ;;
            "stop")
                if [ "$2" = "all" ]; then
                    stop_all_services
                else
                    echo -e "${RED}❌ 사용법: $0 stop all${NC}"
                    exit 1
                fi
                ;;
            "restart")
                case "$2" in
                    "all")
                        stop_all_services
                        sleep 3
                        start_all_services
                        ;;
                    "flutter")
                        restart_flutter
                        ;;
                    "spring")
                        restart_spring
                        ;;
                    "mysql")
                        restart_mysql
                        ;;
                    *)
                        echo -e "${RED}❌ 사용법: $0 restart [all|flutter|spring|mysql]${NC}"
                        exit 1
                        ;;
                esac
                ;;
            *)
                echo -e "${RED}❌ 사용법: $0 [start|stop|restart] [옵션]${NC}"
                echo ""
                echo "📖 사용 가능한 명령어:"
                echo "   $0                  - 대화형 메뉴"
                echo "   $0 start all        - 전체 시작"
                echo "   $0 stop all         - 전체 중지"
                echo "   $0 restart all      - 전체 재시작"
                echo "   $0 restart flutter  - Flutter만 재시작"
                echo "   $0 restart spring   - Spring Boot만 재시작"
                echo "   $0 restart mysql    - MySQL만 재시작"
                exit 1
                ;;
        esac
    else
        # 인자가 없으면 대화형 모드
        while true; do
            clear
            show_current_status
            show_interactive_menu
            read choice
            execute_menu_choice $choice
            echo ""
            echo -n "계속하려면 Enter를 누르세요..."
            read
        done
    fi
}

# ========================================
# 🎬 스크립트 시작점
# ========================================

main "$@" 