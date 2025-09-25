# Projeyi derlemek için Maven ve Java'nın tam sürümünü kullan
FROM maven:3.8.5-openjdk-17 AS builder

# Proje dosyalarını container içine kopyala
WORKDIR /app
COPY . .

# Maven ile projeyi build et (TESTLERİ ATLAYARAK)
# Bu komut, /app/target/içinde tek bir JAR dosyası oluşturacak
RUN mvn clean package -DskipTests

# --- Çalıştırma Aşaması ---
# Sadece Java'nın çalışma ortamını içeren küçük bir imaj kullan
FROM eclipse-temurin:17-jre

WORKDIR /app

# Builder aşamasında oluşturulan tek JAR dosyasını kopyala
COPY --from=builder /app/target/cargo-0.0.1-SNAPSHOT.jar ./app.jar

# Uygulamanın çalışacağı portu belirt
EXPOSE 8080

# Container başladığında uygulamayı çalıştır
ENTRYPOINT ["java", "-jar", "app.jar"]