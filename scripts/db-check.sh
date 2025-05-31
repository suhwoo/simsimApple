#!/bin/bash

# ========================================
# 🗄️ Apple 프로젝트 데이터베이스 확인 스크립트
# ========================================
# 
# 🚀 사용법:
#   ./scripts/db-check.sh           - 대화형 메뉴
#   ./scripts/db-check.sh users     - 사용자 목록만 조회
#   ./scripts/db-check.sh tables    - 테이블 목록 조회
#   ./scripts/db-check.sh schema    - 테이블 구조 조회
#   ./scripts/db-check.sh stats     - 데이터베이스 통계

# ========================================
# 🎨 기본 설정
# ========================================

# 색상 테마
RED='\033[0;31m'      # 오류
GREEN='\033[0;32m'    # 성공
YELLOW='\033[1;33m'   # 경고
BLUE='\033[0;34m'     # 정보
PURPLE='\033[0;35m'   # 제목
CYAN='\033[0;36m'     # 섹션 헤더
NC='\033[0m'          # 색상 초기화

# MySQL 연결 정보
MYSQL_CONTAINER="mysql-apple"
MYSQL_USER="root"
MYSQL_PASSWORD="root"
MYSQL_DATABASE="apple"

# ========================================
# 🔍 데이터베이스 연결 확인 함수
# ========================================

check_mysql_connection() {
    if ! docker ps | grep -q $MYSQL_CONTAINER; then
        echo -e "${RED}❌ MySQL 컨테이너가 실행되지 않았습니다.${NC}"
        echo "   시작하려면: ./status.sh start all"
        return 1
    fi
    
    if ! docker exec $MYSQL_CONTAINER mysqladmin ping -h"127.0.0.1" --silent > /dev/null 2>&1; then
        echo -e "${RED}❌ MySQL 서버에 연결할 수 없습니다.${NC}"
        return 1
    fi
    
    return 0
}

# ========================================
# 📊 데이터베이스 조회 함수들
# ========================================

# 사용자 목록 조회
show_users() {
    echo -e "${CYAN}👥 사용자 목록${NC}"
    echo "=========================================="
    
    local query="SELECT id, created_at, CONCAT('***', RIGHT(password, 3)) as masked_password FROM users ORDER BY created_at DESC;"
    local result=$(docker exec -i $MYSQL_CONTAINER mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -D $MYSQL_DATABASE -e "$query" 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        if echo "$result" | grep -q "id"; then
            echo "$result" | column -t
            echo ""
            local count=$(docker exec -i $MYSQL_CONTAINER mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -D $MYSQL_DATABASE -e "SELECT COUNT(*) as count FROM users;" 2>/dev/null | tail -1)
            echo -e "${GREEN}📊 총 사용자 수: $count명${NC}"
        else
            echo -e "${YELLOW}📝 등록된 사용자가 없습니다.${NC}"
        fi
    else
        echo -e "${RED}❌ 사용자 정보 조회 실패${NC}"
    fi
    echo ""
}

# 테이블 목록 조회
show_tables() {
    echo -e "${CYAN}📋 테이블 목록${NC}"
    echo "=========================================="
    
    local result=$(docker exec -i $MYSQL_CONTAINER mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -D $MYSQL_DATABASE -e "SHOW TABLES;" 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        echo "$result"
        echo ""
        local count=$(echo "$result" | tail -n +2 | wc -l | xargs)
        echo -e "${GREEN}📊 총 테이블 수: $count개${NC}"
    else
        echo -e "${RED}❌ 테이블 목록 조회 실패${NC}"
    fi
    echo ""
}

# 테이블 구조 조회
show_schema() {
    echo -e "${CYAN}🏗️ users 테이블 구조${NC}"
    echo "=========================================="
    
    local result=$(docker exec -i $MYSQL_CONTAINER mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -D $MYSQL_DATABASE -e "DESCRIBE users;" 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        echo "$result" | column -t
    else
        echo -e "${RED}❌ 테이블 구조 조회 실패${NC}"
    fi
    echo ""
}

# 데이터베이스 통계 조회
show_stats() {
    echo -e "${CYAN}📊 데이터베이스 통계${NC}"
    echo "=========================================="
    
    # 기본 정보
    echo -e "${BLUE}🗄️ 데이터베이스 정보:${NC}"
    local db_info=$(docker exec -i $MYSQL_CONTAINER mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -D $MYSQL_DATABASE -e "SELECT VERSION() as mysql_version, DATABASE() as current_db, NOW() as current_time;" 2>/dev/null)
    echo "$db_info" | column -t
    echo ""
    
    # 사용자 통계
    echo -e "${BLUE}👥 사용자 통계:${NC}"
    local user_stats=$(docker exec -i $MYSQL_CONTAINER mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -D $MYSQL_DATABASE -e "
        SELECT 
            COUNT(*) as total_users,
            COUNT(CASE WHEN created_at >= DATE_SUB(NOW(), INTERVAL 1 DAY) THEN 1 END) as today_signups,
            COUNT(CASE WHEN created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY) THEN 1 END) as week_signups,
            MIN(created_at) as first_signup,
            MAX(created_at) as latest_signup
        FROM users;" 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        echo "$user_stats" | column -t
    else
        echo "사용자 통계를 가져올 수 없습니다."
    fi
    echo ""
    
    # 테이블 크기 정보
    echo -e "${BLUE}💾 테이블 크기 정보:${NC}"
    local table_size=$(docker exec -i $MYSQL_CONTAINER mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -D $MYSQL_DATABASE -e "
        SELECT 
            table_name as 'Table',
            table_rows as 'Rows',
            ROUND(((data_length + index_length) / 1024 / 1024), 2) as 'Size (MB)'
        FROM information_schema.tables 
        WHERE table_schema = '$MYSQL_DATABASE';" 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        echo "$table_size" | column -t
    else
        echo "테이블 크기 정보를 가져올 수 없습니다."
    fi
    echo ""
}

# 실시간 모니터링
show_realtime() {
    echo -e "${CYAN}📡 실시간 데이터베이스 모니터링${NC}"
    echo "=========================================="
    echo -e "${YELLOW}⏱️ 실시간 사용자 등록 모니터링 중... (Ctrl+C로 종료)${NC}"
    echo ""
    
    local last_count=0
    while true; do
        local current_count=$(docker exec -i $MYSQL_CONTAINER mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -D $MYSQL_DATABASE -e "SELECT COUNT(*) FROM users;" 2>/dev/null | tail -1)
        local current_time=$(date "+%H:%M:%S")
        
        if [ "$current_count" != "$last_count" ]; then
            echo -e "${GREEN}[$current_time] 🎉 새 사용자 등록! 총 사용자: $current_count명${NC}"
            # 최신 사용자 정보 표시
            local latest_user=$(docker exec -i $MYSQL_CONTAINER mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -D $MYSQL_DATABASE -e "SELECT id, created_at FROM users ORDER BY created_at DESC LIMIT 1;" 2>/dev/null | tail -1)
            echo "   👤 $latest_user"
            last_count=$current_count
        else
            echo -e "${BLUE}[$current_time] 👥 현재 사용자: $current_count명${NC}"
        fi
        
        sleep 3
    done
}

# SQL 쿼리 실행
execute_query() {
    echo -e "${CYAN}⚡ SQL 쿼리 실행${NC}"
    echo "=========================================="
    echo -e "${YELLOW}주의: 데이터 변경 쿼리는 신중히 사용하세요!${NC}"
    echo ""
    echo "예시 쿼리:"
    echo "  SELECT * FROM users WHERE id LIKE '%test%';"
    echo "  SELECT COUNT(*) FROM users;"
    echo "  SELECT * FROM users ORDER BY created_at DESC LIMIT 5;"
    echo ""
    echo -n "SQL 쿼리를 입력하세요: "
    read -r query
    
    if [ -n "$query" ]; then
        echo ""
        echo -e "${BLUE}🔍 실행 중: $query${NC}"
        echo "----------------------------------------"
        local result=$(docker exec -i $MYSQL_CONTAINER mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -D $MYSQL_DATABASE -e "$query" 2>/dev/null)
        
        if [ $? -eq 0 ]; then
            if [ -n "$result" ]; then
                echo "$result" | column -t
            else
                echo -e "${GREEN}✅ 쿼리가 성공적으로 실행되었습니다.${NC}"
            fi
        else
            echo -e "${RED}❌ 쿼리 실행 실패${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️ 쿼리가 입력되지 않았습니다.${NC}"
    fi
    echo ""
}

# ========================================
# 🎯 메뉴 및 실행 로직
# ========================================

# 대화형 메뉴 표시
show_interactive_menu() {
    echo -e "${PURPLE}🗄️ 데이터베이스 관리 메뉴${NC}"
    echo "=========================================="
    echo "1) 👥 사용자 목록 조회"
    echo "2) 📋 테이블 목록 조회"  
    echo "3) 🏗️ 테이블 구조 조회"
    echo "4) 📊 데이터베이스 통계"
    echo "5) 📡 실시간 모니터링"
    echo "6) ⚡ SQL 쿼리 실행"
    echo "7) 🔄 전체 정보 조회"
    echo "0) 👋 종료"
    echo ""
    echo -n "선택하세요 (0-7): "
}

# 메뉴 선택 실행
execute_menu_choice() {
    local choice=$1
    echo ""
    
    case $choice in
        1)
            show_users
            ;;
        2)
            show_tables
            ;;
        3)
            show_schema
            ;;
        4)
            show_stats
            ;;
        5)
            show_realtime
            ;;
        6)
            execute_query
            ;;
        7)
            echo -e "${PURPLE}🔄 전체 데이터베이스 정보 조회${NC}"
            echo "=============================================="
            echo ""
            show_tables
            show_schema
            show_users
            show_stats
            ;;
        0)
            echo -e "${GREEN}👋 데이터베이스 관리자를 종료합니다.${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ 잘못된 선택입니다. 0-7 사이의 숫자를 입력해주세요.${NC}"
            ;;
    esac
}

# ========================================
# 🎬 메인 실행 로직
# ========================================

main() {
    # MySQL 연결 확인
    if ! check_mysql_connection; then
        exit 1
    fi
    
    echo -e "${GREEN}✅ MySQL 연결 성공${NC}"
    echo ""
    
    # 인자가 있으면 직접 실행 모드
    if [ $# -gt 0 ]; then
        case "$1" in
            "users")
                show_users
                ;;
            "tables")
                show_tables
                ;;
            "schema")
                show_schema
                ;;
            "stats")
                show_stats
                ;;
            "realtime")
                show_realtime
                ;;
            "query")
                execute_query
                ;;
            "all")
                show_tables
                show_schema
                show_users
                show_stats
                ;;
            *)
                echo -e "${RED}❌ 사용법: $0 [users|tables|schema|stats|realtime|query|all]${NC}"
                echo ""
                echo "📖 사용 가능한 명령어:"
                echo "   $0              - 대화형 메뉴"
                echo "   $0 users        - 사용자 목록"
                echo "   $0 tables       - 테이블 목록"
                echo "   $0 schema       - 테이블 구조"
                echo "   $0 stats        - 데이터베이스 통계"
                echo "   $0 realtime     - 실시간 모니터링"
                echo "   $0 query        - SQL 쿼리 실행"
                echo "   $0 all          - 전체 정보"
                exit 1
                ;;
        esac
    else
        # 인자가 없으면 대화형 모드
        while true; do
            show_interactive_menu
            read choice
            execute_menu_choice $choice
            echo ""
            echo -n "계속하려면 Enter를 누르세요..."
            read
            clear
        done
    fi
}

# ========================================
# 🎬 스크립트 시작점
# ========================================

main "$@" 