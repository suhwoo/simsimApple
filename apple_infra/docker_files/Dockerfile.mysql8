# Ubuntu 22.04 이미지를 베이스로 사용
FROM ubuntu:22.04

# 환경변수 설정 (비밀번호 없이 실행 안 되게 기본 설정)
ENV DEBIAN_FRONTEND=noninteractive \
    MYSQL_ROOT_PASSWORD=rootpassword \
    MYSQL_DATABASE=testdb \
    MYSQL_USER=testuser \
    MYSQL_PASSWORD=testpass

# 필수 패키지 설치 및 MySQL APT repo 등록
RUN apt-get update && \
    apt-get install -y wget lsb-release gnupg curl && \
    wget https://dev.mysql.com/get/mysql-apt-config_0.8.29-1_all.deb && \
    dpkg -i mysql-apt-config_0.8.29-1_all.deb && \
    apt-get update && \
    apt-get install -y mysql-server=8.0.42-1ubuntu22.04 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# MySQL 포트 개방
EXPOSE 3306

# 초기화 스크립트 (필요 시 사용자 생성, DB 생성 등 자동화 가능)
COPY mysql_docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/mysql_docker-entrypoint.sh

# MySQL 데이터 디렉토리
VOLUME /var/lib/mysql

# 컨테이너 시작 시 MySQL 실행
ENTRYPOINT ["mysql_docker-entrypoint.sh"]
CMD ["mysqld"]
