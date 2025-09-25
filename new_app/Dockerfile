# --- 1. Aşama: Build Aşaması ---
# Resmi Ubuntu 22.04 imajını kullanıyoruz. Bu en güvenilir temeldir.
FROM ubuntu:22.04 AS builder

# apt'nin interaktif soru sormasını engelle
ENV DEBIAN_FRONTEND=noninteractive

# Gerekli araçları (git, curl, unzip vb.) kuruyoruz
RUN apt-get update && apt-get install -y git curl unzip xz-utils libgtk-3-0 libgl1-mesa-glx

# Flutter'ın en son stabil versiyonunu resmi kaynağından indirip kuruyoruz
WORKDIR /opt
RUN git clone https://github.com/flutter/flutter.git --depth 1 --branch stable
ENV PATH="$PATH:/opt/flutter/bin"

# Flutter'ı ön-derleme yaparak hızlandırıyoruz ve kurulumu doğruluyoruz
RUN flutter precache
RUN flutter doctor

# Proje dosyalarını kopyalıyoruz
WORKDIR /app
COPY . .

# Flutter bağımlılıklarını kuruyoruz
RUN flutter pub get

# Flutter web build'ini oluşturuyoruz
RUN flutter build web

# --- 2. Aşama: Çalıştırma Aşaması (Bu kısım aynı kalıyor) ---
FROM nginx:alpine
COPY --from=builder /app/build/web /usr/share/nginx/html
EXPOSE 80