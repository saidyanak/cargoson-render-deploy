# --- 1. Aşama: Build Aşaması ---
# Resmi Ubuntu 22.04 imajını kullanıyoruz. Bu en güvenilir temeldir.
FROM ubuntu:22.04 AS builder

# apt'nin interaktif soru sormasını engelle
ENV DEBIAN_FRONTEND=noninteractive

# Gerekli araçları kuruyoruz ve cache temizliyoruz
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    xz-utils \
    libgtk-3-0 \
    libgl1-mesa-glx \
    ca-certificates \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Flutter'ın en son stabil versiyonunu resmi kaynağından indirip kuruyoruz
WORKDIR /opt
RUN git clone https://github.com/flutter/flutter.git --depth 1 --branch stable
ENV PATH="$PATH:/opt/flutter/bin"

# Flutter web'i enable ediyoruz
RUN flutter config --enable-web

# Flutter'ı ön-derleme yaparak hızlandırıyoruz ve kurulumu doğruluyoruz
RUN flutter precache
RUN flutter doctor

# Proje dosyalarını kopyalıyoruz
WORKDIR /app

# Önce pubspec dosyalarını kopyala (Docker cache optimizasyonu için)
COPY pubspec.yaml pubspec.lock* ./

# Flutter bağımlılıklarını kuruyoruz
RUN flutter pub get

# Şimdi tüm proje dosyalarını kopyala
COPY . .

# Flutter web build'ini release modda oluşturuyoruz
RUN flutter build web --release

# --- 2. Aşama: Çalıştırma Aşaması ---
FROM nginx:alpine

# Build edilmiş dosyaları kopyala
COPY --from=builder /app/build/web /usr/share/nginx/html

# Nginx konfigürasyonunu kopyala
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Port 80'i aç
EXPOSE 80

# Nginx'i başlat
CMD ["nginx", "-g", "daemon off;"]