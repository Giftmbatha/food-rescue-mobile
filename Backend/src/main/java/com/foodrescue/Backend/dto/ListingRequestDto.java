package com.foodrescue.Backend.dto;

import com.foodrescue.Backend.entity.FoodCategory;
import jakarta.validation.constraints.*;
import lombok.*;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ListingRequestDto {

    @NotBlank(message = "Title is Required")
    @Size(max = 100, message = "Title must not exceed 100 characters")
    private String title;

    @Size(max = 500, message = "Description must not exceed 500 characters")
    private String description;

    @NotNull(message = "Food category is required")
    private FoodCategory category;

    @NotNull(message = "Quantity is required")
    @Positive(message = "Quantity must be greater than 0")
    @DecimalMax(value = "10000.0", message = "Quantity must not exceed 10,000 kg")
    private Double quantityKg;

    @NotNull(message = "Expiry date is required")
    @Future(message = "Expiry date must be in the future")
    private LocalDateTime expiryDate;

    @NotBlank(message = "Pickup address is required")
    @Size(max = 255, message = "Address must not exceed 255 characters")
    private String pickupAddress;

    private Double pickupLatitude;

    private Double pickupLongitude;

    @NotBlank(message = "Pickup window is required")
    @Size(max = 100, message = "Pickup window must not exceed 100 characters")
    private String pickupWindow;

    @Size(max = 300, message = "Notes must not exceed 300 characters")
    private String pickupNotes;

    @Builder.Default
    private Boolean allowPartialClaims = false;
}
