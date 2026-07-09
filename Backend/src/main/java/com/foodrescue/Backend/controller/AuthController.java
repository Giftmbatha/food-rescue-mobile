package com.foodrescue.Backend.controller;

import com.foodrescue.Backend.dto.ApiResponse;
import com.foodrescue.Backend.dto.UserRegistrationDto;
import com.foodrescue.Backend.dto.UserResponseDto;
import com.foodrescue.Backend.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Authentication controller handling registration and login.
 *
 * @RestController: Combines @Controller and @ResponseBody.
 *   - @Controller: Marks class as Spring MVC controller
 *   - @ResponseBody: Return values are serialized directly to HTTP response body
 *
 * @RequestMapping("/api/v1/auth"): Base path for all endpoints in this class.
 *   Versioning (v1) allows future API evolution without breaking clients.
 *
 * @RequiredArgsConstructor: Constructor injection of final dependencies.
 *
 * @Slf4j: Structured logging for request tracking and debugging.
 */
@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Slf4j
public class AuthController {

    private final UserService userService;

    /**
     * Register a new user account.
     *
     * @PostMapping: Handles HTTP POST requests to /api/v1/auth/register
     * @RequestBody: Deserializes JSON request body into UserRegistrationDto
     * @Valid: Triggers Bean Validation on the DTO before method execution
     *   - If validation fails, MethodArgumentNotValidException is thrown
     *   - Our @ControllerAdvice catches this and returns 400 Bad Request
     *
     * ResponseEntity: Full control over HTTP status, headers, and body.
     *   - 201 Created: Standard for successful resource creation
     *   - Location header: Could include URL of newly created resource
     */
    @PostMapping("/register")
    public ResponseEntity<ApiResponse<UserResponseDto>> register(
            @Valid @RequestBody UserRegistrationDto registrationDto) {

        log.info("Registration request received for email: {}", registrationDto.getEmail());

        UserResponseDto createdUser = userService.register(registrationDto);

        log.info("Registration successful for user: {}", createdUser.getId());

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.created(createdUser));
    }

    /**
     * Health check endpoint for monitoring.
     *
     * @GetMapping: Handles HTTP GET requests
     * No authentication required — used by load balancers and Docker health checks
     */
    @GetMapping("/health")
    public ResponseEntity<ApiResponse<String>> health() {
        return ResponseEntity.ok(ApiResponse.success("Auth service is healthy"));
    }
}