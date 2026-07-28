package com.foodrescue.Backend.dto;

import com.foodrescue.Backend.entity.Donor;
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
public class DonorProfileDto {

    private UUID id;
    private UUID userId;

    @NotBlank(message = "Organization name is required")
    @Size(max = 100, message = "Name must not exceed 100 characters")
    private String orgName;

    @Size(max = 50, message = "Type must not exceed 50 characters")
    private Donor.OrgType orgType; // "Restaurant", "Supermarket", "Bakery", etc.

    @NotBlank(message = "Address is required")
    @Size(max = 200, message = "Address must not exceed 200 characters")
    private String address;

    private Double latitude;
    private Double longitude;

    @Size(max = 100, message = "Contact person must not exceed 100 characters")
    private String contactPerson;

    @Size(max = 20, message = "Phone must not exceed 20 characters")
    private String phone;

    private Double ratingAvg;
    private Integer totalListings;
    private Integer totalClaimsReceived;
    private Double totalKgDonated;
}