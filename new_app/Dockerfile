# --- AŞAMA 1: Flutter Web Uygulamasını Build Etme ---
# Flutter SDK'sının zaten kurulu olduğu, build için optimize edilmiş resmi bir imaj kullanıyoruz.
# Bu, Ubuntu üzerine manuel kurulumdan çok daha hızlı ve güvenilirdir.
FROM cirrusci/flutter:stable AS builder

# Çalışma dizinini ayarlıyoruz.
WORKDIR /app

# Proje dosyalarını kopyalıyoruz.
COPY . .

# Flutter bağımlılıklarını yüklüyoruz.
RUN flutter pub get

# Flutter web uygulamasını production için build ediyoruz.
# Bu komut, /app/build/web dizinini oluşturacak.
RUN flutter build web

# --- AŞAMA 2: Nginx ile Sunma ---
# Hafif bir Nginx imajı kullanıyoruz.
FROM nginx:alpine

# Build aşamasında oluşturulan statik dosyaları
# Nginx'in varsayılan sunum dizinine kopyalıyoruz.
COPY --from=builder /app/build/web /usr/share/nginx/html

# Canvas'ta bulunan ve SPA'lar (Flutter Web gibi) için doğru çalışmayı sağlayacak olan
# özel konfigürasyon dosyamızı kopyalıyoruz.
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Nginx'in çalışacağı 80 portunu dışarıya açıyoruz.
EXPOSE 80

# Container başladığında Nginx'i ön planda çalıştırıyoruz. Bu komut önemlidir.
CMD ["nginx", "-g", "daemon off;"]

