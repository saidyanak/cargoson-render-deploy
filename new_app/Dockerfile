# --- 1. Aşama: Build Aşaması ---
FROM ubuntu:22.04 AS builder

# Render ortamı için gerekli ayarlar
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="$PATH:/opt/flutter/bin"

# Gerekli araçları kuruyoruz
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    xz-utils \
    ca-certificates \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Flutter kullanıcısı oluştur
RUN useradd -m -s /bin/bash flutter

# Flutter'ı flutter kullanıcısı olarak kur
USER flutter
WORKDIR /home/flutter

# Flutter'ı git ile indir
RUN git clone https://github.com/flutter/flutter.git --depth 1 --branch stable flutter

# Flutter PATH'ini ayarla
ENV PATH="$PATH:/home/flutter/flutter/bin"

# Flutter web'i enable et
RUN flutter config --enable-web

# Sadece web bileşenlerini precache et
RUN flutter precache --web

# Flutter doctor çalıştır
RUN flutter doctor

# Root'a geç ve proje dosyalarını hazırla
USER root
WORKDIR /app

# pubspec dosyalarını kopyala
COPY pubspec.yaml pubspec.lock* ./
RUN chown -R flutter:flutter /app

# Flutter kullanıcısı olarak bağımlılıkları yükle
USER flutter
RUN flutter pub get

# Tüm proje dosyalarını kopyala
USER root
COPY . .
RUN chown -R flutter:flutter /app

# Flutter kullanıcısı olarak build et
USER flutter
RUN flutter build web --release

# --- 2. Aşama: Nginx ile Servis ---
FROM nginx:alpine

# Render'ın PORT environment variable'ını kullan
ENV PORT=80

# Build edilmiş dosyaları kopyala
COPY --from=builder /app/build/web /usr/share/nginx/html

# Nginx konfigürasyonunu kopyala
COPY nginx.conf /etc/nginx/conf.d/default.conf.template

# Nginx'i PORT ile başlatacak script
RUN echo '#!/bin/sh \n\
envsubst "\$PORT" < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf \n\
nginx -g "daemon off;"' > /start.sh && \
chmod +x /start.sh

# Render'ın dinamik PORT'unu expose et
EXPOSE $PORT

# Start script'i çalıştır
CMD ["/start.sh"]