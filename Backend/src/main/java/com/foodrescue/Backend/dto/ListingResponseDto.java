package com.foodrescue.Backend.dto;

import com.foodrescue.Backend.entity.FoodCategory;
import com.foodrescue.Backend.entity.ListingStatus;
import lombok.*;

import java.time.LocalDateTime;
import java.util.UUID;
import java.util.List;

// DTO for listing data returned to client.
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ListingResponseDto {

    private UUID id;
    private String donorOrgName;
    private String donorOrgType;
    private String title;
    private String description;
    private FoodCategory category;
    private Double quantityKg;
    private LocalDateTime expiryDate;
    private String pickupAddress;
    private Double pickupLatitude;
    private Double pickupLongitude;
    private String pickupWindow;
    private ListingStatus status;
    private List<String> imageUrls;
    private String pickupNotes;
    private Boolean allowPartialClaims;
    private LocalDateTime createdAt;
    private Integer claimCount;
}
