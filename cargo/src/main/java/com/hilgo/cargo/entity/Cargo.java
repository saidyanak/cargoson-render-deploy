package com.hilgo.cargo.entity;

import java.time.LocalDateTime;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import com.hilgo.cargo.entity.enums.CargoSituation;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToOne;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Cargo {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@OneToOne(cascade= CascadeType.ALL)
	private Location selfLocation;

	@OneToOne(cascade= CascadeType.ALL)
	private Location targetLocation;

	@OneToOne(cascade= CascadeType.ALL)
	private Measure measure;

	@Enumerated(EnumType.STRING)
	private CargoSituation cargoSituation;

	@Column
	private String phoneNumber;

	@Column
	private String verificationCode;
	
	@Column
	private  LocalDateTime takingTime;


	@Column
	private  LocalDateTime deliveredTime;
	
	@Column
	private  String description;

	@ManyToOne
	@JoinColumn(name = "distributor_user_id", referencedColumnName = "user_id")
	private Distributor distributor;
	
	@ManyToOne
	@JoinColumn(name = "driver_user_id", referencedColumnName = "user_id")
	private Driver driver;

	@CreationTimestamp
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(name = "updated_at") 
    private LocalDateTime updatedAt;
	//@Lob
//    private byte[] qrCodeImage;

}
