# --- AŞAMA 1: Gerekli Flutter Sürümünü Kur ve Build Et ---
# Temiz bir Ubuntu 22.04 imajı ile başlıyoruz.
FROM ubuntu:22.04 AS builder

# Gerekli araçları ve SSL sertifikalarını kuruyoruz.
# 'ca-certificates' paketi, curl'ün SSL hatası vermesini engeller.
RUN apt-get update && apt-get install -y git curl unzip xz-utils ca-certificates --no-install-recommends

# Çalışma dizinini ayarlıyoruz.
WORKDIR /flutter

# Dart 3 içeren modern bir Flutter sürümünü indiriyoruz.
# Not: Bu URL, Flutter'ın resmi indirme arşividir.
RUN curl -fSL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.6-stable.tar.xz" -o flutter.tar.xz
RUN tar -xvf flutter.tar.xz
RUN rm flutter.tar.xz
ENV PATH="$PATH:/flutter/flutter/bin"

# Git'in güvenlik hatasını çözerek Flutter'ın kendi versiyonunu doğru okumasını sağlıyoruz.
# Bu komut, "dubious ownership" hatasını engeller.
RUN git config --global --add safe.directory /flutter/flutter

# Flutter kurulumunu doğruluyoruz.
RUN flutter doctor

# Proje dosyalarını kopyalamak için yeni bir çalışma dizini oluşturuyoruz.
WORKDIR /app
COPY . .

# pubspec.lock sayesinde bağımlılıkları yüklüyoruz.
# Bu adım artık doğru Dart sürümüyle çalıştığı için başarılı olacak.
RUN flutter pub get

# Flutter web uygulamasını production için build ediyoruz.
RUN flutter build web

# --- AŞAMA 2: Nginx ile Sunma ---
# Bu kısım aynı kalıyor.
FROM nginx:alpine

COPY --from=builder /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

