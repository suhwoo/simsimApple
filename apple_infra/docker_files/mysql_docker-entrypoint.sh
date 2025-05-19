#!/bin/bash
set -e

# MySQL 초기화
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing database..."
    mysqld --initialize-insecure --user=mysql
fi

# mysql 데몬 실행
exec "$@"
