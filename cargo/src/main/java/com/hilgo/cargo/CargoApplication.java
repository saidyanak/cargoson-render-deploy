package com.hilgo.cargo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class CargoApplication {

	public static void main(String[] args) {
		SpringApplication.run(CargoApplication.class, args);
	}
}
//https://67n86mnm-8080.euw.devtunnels.ms/
//taskkill /PID 5900 /F
//netstat -aon | findstr :8080