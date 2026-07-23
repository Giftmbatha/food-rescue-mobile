package com.foodrescue.Backend.dto;

import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO for claim status updates with optional donor response message.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ClaimStatusUpdateDto {

    @Size(max = 500, message = "Response message must not exceed 500 characters")
    private String donorResponse;
}