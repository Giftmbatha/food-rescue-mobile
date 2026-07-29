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
public class NgoStatsDto {
    private UUID ngoId;
    private String orgName;
    private Integer totalClaims;
    private Integer pendingClaims;
    private Integer approvedClaims;
    private Integer completedPickups;
    private Double totalKgReceived;
    private Double averageRating;
    private Integer ratingCount;
}
