package com.foodrescue.Backend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ListingImageDto {
    private String objectKey;
    private String presignedUrl;
    private String caption;
    private Integer displayOrder;
}
