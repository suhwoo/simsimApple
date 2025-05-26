docker run -d \
  --name my-mysql \
  -e MYSQL_ROOT_PASSWORD=rootpassword \
  -e MYSQL_DATABASE=testdb \
  -e MYSQL_USER=testuser \
  -e MYSQL_PASSWORD=testpass \
  -p 3306:3306 \
  -v mysql-data:/var/lib/mysql \
  apple_mysql8:latest




  docker run -d --name mysql8 -e MYSQL_ROOT_PASSWORD=rootpassword -e MYSQL_DATABASE=testdb -e MYSQL_USER=testuser -e MYSQL_PASSWORD=testpass -p 3306:3306 -v mysql-data:/var/lib/mysql mysql:8.0  --bind-address=0.0.0.0


이 명령어 실행하고, 
접속 -> docker exec -it mysql8 bash
로그인 -> mysql -u root -p
비밀번호: rootpassword
비밀번호 인증방식 변경 -> ALTER USER 'testuser'@'%' IDENTIFIED WITH mysql_native_password BY 'testpass';
FLUSH PRIVILEGES;

이래야 외부접속 가능