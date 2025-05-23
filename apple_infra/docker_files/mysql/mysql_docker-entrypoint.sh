#!/bin/bash
set -e

# MySQL 초기화
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing database..."
    mysqld --initialize-insecure --user=mysql

    echo "Starting MySQL temporarily..."
    mysqld --user=mysql --skip-networking &
    pid="$!"

    echo "Waiting for MySQL to start..."
    until mysqladmin ping --silent; do
        sleep 1
    done

    echo "Setting root password..."
    mysql -uroot <<-EOSQL
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        FLUSH PRIVILEGES;
EOSQL

    if [ -n "$MYSQL_DATABASE" ]; then
        echo "Creating database: $MYSQL_DATABASE"
        mysql -uroot -p${MYSQL_ROOT_PASSWORD} <<-EOSQL
            CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
EOSQL
    fi

    if [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_PASSWORD" ]; then
        echo "Creating user: $MYSQL_USER"
        mysql -uroot -p${MYSQL_ROOT_PASSWORD} <<-EOSQL
            CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
            GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
            FLUSH PRIVILEGES;
EOSQL
    fi

    echo "Shutting down temporary server..."
    mysqladmin -uroot -p${MYSQL_ROOT_PASSWORD} shutdown
    wait "$pid"
fi

# mysql 데몬 실행
exec "$@"