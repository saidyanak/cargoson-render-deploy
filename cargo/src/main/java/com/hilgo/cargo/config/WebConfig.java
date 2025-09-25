package com.hilgo.cargo.config;

//import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

//@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOrigins(
                    "http://localhost:3000",               // React geliştirici sunucusu
                    "http://localhost",                 // local prod gibi test
                    "http://rotax-new.ddns.net",           // HTTP
                    "https://rotax-new.ddns.net"           // HTTPS
                )
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH")
                .allowedHeaders("*")
                .allowCredentials(true)
                .maxAge(3600); // Preflight istekleri cache süresi (opsiyonel)
    }
}