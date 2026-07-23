package com.foodrescue.Backend.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
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
public class ClaimRequestDto {

    @NotNull(message = "Listing ID is required")
    private UUID listingId;

    @NotNull(message = "Proposed pickup time is required")
    private LocalDateTime proposedPickupTime;

    @Size(max = 300, message = "Message must not exceed 300 characters")
    private String message;
}
