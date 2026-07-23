package com.foodrescue.Backend.controller;

import com.foodrescue.Backend.dto.*;
import com.foodrescue.Backend.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

// Authentication controller handling registration, login, and token refresh.
@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Slf4j
public class AuthController {

    private final AuthService authService;

    // Register a new user account.
    @PostMapping("/register")
    public ResponseEntity<ApiResponse<UserResponseDto>> register(
            @Valid @RequestBody UserRegistrationDto registrationDto) {

        log.info("Registration request for email: {}", registrationDto.getEmail());

        UserResponseDto createdUser = authService.register(registrationDto);

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.created(createdUser));
    }

    // Authenticate user and issue JWT tokens.
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponseDto>> login(
            @Valid @RequestBody LoginRequestDto loginDto) {

        log.info("Login attempt for email: {}", loginDto.getEmail());

        AuthResponseDto authResponse = authService.login(loginDto);

        return ResponseEntity.ok(ApiResponse.success(authResponse));
    }

    /**
     * Refresh access token using refresh token.
     *
     * POST /api/v1/auth/refresh
     *
     * Body: { "refreshToken": "..." }
     */
    @PostMapping("/refresh")
    public ResponseEntity<ApiResponse<AuthResponseDto>> refresh(
            @RequestBody RefreshTokenRequestDto requestDto) {

        log.info("Token refresh request");

        AuthResponseDto authResponse = authService.refresh(requestDto.getRefreshToken());

        return ResponseEntity.ok(ApiResponse.success(authResponse));
    }

    // Health check endpoint.
    @GetMapping("/health")
    public ResponseEntity<ApiResponse<String>> health() {
        return ResponseEntity.ok(ApiResponse.success("Auth service is healthy"));
    }
}