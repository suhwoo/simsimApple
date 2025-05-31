# Flutter 웹 빌드를 위한 멀티스테이지 Dockerfile

# 빌드 스테이지
FROM debian:stable-slim AS build

# Flutter SDK 설치
RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    unzip \
    libgconf-2-4 \
    gdb \
    libstdc++6 \
    libglu1-mesa \
    fonts-droid-fallback \
    lib32stdc++6 \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Flutter SDK 다운로드 및 설치
ENV FLUTTER_HOME="/opt/flutter"
ENV PATH="$FLUTTER_HOME/bin:$PATH"

RUN git clone https://github.com/flutter/flutter.git $FLUTTER_HOME
RUN flutter --version

# Flutter 웹 활성화
RUN flutter config --enable-web

# 작업 디렉토리 설정
WORKDIR /app

# 의존성 파일 복사 및 설치
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# 소스 코드 복사
COPY . .

# Flutter 웹 빌드
RUN flutter build web --release

# 실행 스테이지 (Nginx)
FROM nginx:alpine AS runtime

# Flutter 웹 빌드 결과물을 Nginx에 복사
COPY --from=build /app/build/web /usr/share/nginx/html

# Nginx 설정 복사 (SPA 라우팅 지원)
RUN echo 'server { \
    listen 80; \
    server_name localhost; \
    root /usr/share/nginx/html; \
    index index.html index.htm; \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
    location /api/ { \
        proxy_pass http://backend:8080; \
        proxy_set_header Host $host; \
        proxy_set_header X-Real-IP $remote_addr; \
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; \
        proxy_set_header X-Forwarded-Proto $scheme; \
    } \
}' > /etc/nginx/conf.d/default.conf

# 포트 노출
EXPOSE 80

# Nginx 실행
CMD ["nginx", "-g", "daemon off;"] 