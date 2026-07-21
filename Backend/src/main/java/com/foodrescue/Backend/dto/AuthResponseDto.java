package com.foodrescue.Backend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

// DTO for authentication responses containing JWT tokens.
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponseDto {

    private String accessToken;
    private String refreshToken;
    private String tokenType;   // "Bearer"
    private Long expiresIn; // Access token expiration in seconds
    private UserResponseDto user; // User details for immediate UI use
}
