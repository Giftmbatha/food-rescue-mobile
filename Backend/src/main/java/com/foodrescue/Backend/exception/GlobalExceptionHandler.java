package com.foodrescue.Backend.exception;

import com.foodrescue.Backend.dto.ApiResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.HashMap;
import java.util.Map;

/**
 * Global exception handler for all controllers.
 *
 * @RestControllerAdvice: Combines @ControllerAdvice and @ResponseBody.
 *   - @ControllerAdvice: Applies to all @Controller classes globally
 *   - @ResponseBody: Return values are serialized to JSON
 *
 * Centralizes error handling — no try-catch blocks in controllers.
 * Consistent error format across all endpoints.
 */
@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    /**
     * Handle validation failures from @Valid annotation.
     *
     * Triggered when: @RequestBody DTO fails Bean Validation constraints
     * Example: Email blank, password too short, missing required field
     *
     * Extracts field-level errors and returns them in structured format.
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiResponse<Void>> handleValidationErrors(
            MethodArgumentNotValidException ex) {

        Map<String, String> fieldErrors = new HashMap<>();

        // Extract field errors from the exception
        ex.getBindingResult().getAllErrors().forEach(error -> {
            String fieldName = ((FieldError) error).getField();
            String errorMessage = error.getDefaultMessage();
            fieldErrors.put(fieldName, errorMessage);
        });

        log.warn("Validation failed: {}", fieldErrors);

        ApiResponse.ErrorDetails errorDetails = ApiResponse.ErrorDetails.builder()
                .code("VALIDATION_ERROR")
                .description("Request validation failed")
                .fieldErrors(fieldErrors)
                .build();

        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(400, "Invalid request data", errorDetails));
    }

    /**
     * Handle business logic violations.
     *
     * Triggered when: Service layer throws IllegalArgumentException
     * Example: Email already exists, invalid role, duplicate organization name
     */
    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ApiResponse<Void>> handleIllegalArgument(
            IllegalArgumentException ex) {

        log.warn("Business rule violation: {}", ex.getMessage());

        ApiResponse.ErrorDetails errorDetails = ApiResponse.ErrorDetails.builder()
                .code("BUSINESS_RULE_VIOLATION")
                .description(ex.getMessage())
                .build();

        return ResponseEntity
                .status(HttpStatus.CONFLICT)
                .body(ApiResponse.error(409, ex.getMessage(), errorDetails));
    }

    /**
     * Handle unexpected server errors.
     *
     * Catch-all for exceptions not handled by specific handlers.
     * Logs full stack trace for debugging; returns generic message to client.
     *
     * Security principle: Never expose internal details (stack traces, SQL) to clients.
     */
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<Void>> handleGenericException(Exception ex) {

        log.error("Unexpected error occurred", ex);

        ApiResponse.ErrorDetails errorDetails = ApiResponse.ErrorDetails.builder()
                .code("INTERNAL_ERROR")
                .description("An unexpected error occurred. Please try again later.")
                .build();

        return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error(500, "Internal server error", errorDetails));
    }
}