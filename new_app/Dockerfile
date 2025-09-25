# --- AŞAMA 1: Flutter Web Uygulamasını Build Etme ---
# Her zaman en güncel stabil Flutter versiyonunu temsil eden "stable" etiketini kullanıyoruz.
# Bu, "image not found" hatasını çözer.
FROM cirrusci/flutter:stable AS builder

# Çalışma dizinini ayarlıyoruz.
WORKDIR /app

# Proje dosyalarını kopyalıyoruz.
# pubspec.lock dosyası da kopyalanacağı için, Render tam olarak
# senin bilgisayarında çalışan paket sürümlerini kullanacak.
COPY . .

# Bu komut artık pubspec.lock sayesinde hatasız çalışacak.
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

