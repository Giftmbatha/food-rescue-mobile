package com.foodrescue.Backend.dto;

import com.foodrescue.Backend.entity.ClaimStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ClaimResponseDto {

    private UUID id;
    private UUID listingId;
    private String listingTitle;
    private UUID ngoId;
    private String ngoOrgName;
    private ClaimStatus status;
    private LocalDateTime proposedPickupTime;
    private String message;
    private String donorResponse;
    private LocalDateTime completedAt;
    private LocalDateTime createdAt;
}
