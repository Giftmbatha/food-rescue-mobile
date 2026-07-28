package com.foodrescue.Backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NgoProfileDto {

    private UUID id;
    private UUID userId;

    @NotBlank(message = "Organization name is required")
    @Size(max = 100, message = "Name must not exceed 100 characters")
    private String orgName;

    @NotBlank(message = "Registration number is required")
    @Size(max = 50, message = "Registration number must not exceed 50 characters")
    private String regNumber;

    @NotBlank(message = "Address is required")
    @Size(max = 200, message = "Address must not exceed 200 characters")
    private String address;

    private Double latitude;
    private Double longitude;

    @Size(max = 100, message = "Contact person must not exceed 100 characters")
    private String contactPerson;

    @Size(max = 500, message = "Service area must not exceed 500 characters")
    private String serviceArea;

    @Size(max = 20, message = "Phone must not exceed 20 characters")
    private String phone;

    private Double ratingAvg;
    private Integer totalClaims;
    private Integer totalPickupsCompleted;
    private Double totalKgReceived;
}