package com.foodrescue.Backend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DonorStatsDto {
    private UUID donorId;
    private String orgName;
    private Integer totalListings;
    private Integer activeListings;
    private Integer completedClaims;
    private Double totalKgDonated;
    private Double averageRating;
    private Integer ratingCount;
}

