package com.foodrescue.Backend.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * Standardized API response wrapper.
 *
 * Every endpoint returns this structure, ensuring frontend
 * can handle responses predictably.
 *
 * @JsonInclude(JsonInclude.Include.NON_NULL): Omits null fields
 * from JSON output — cleaner responses, smaller payloads.
 */
@Data
@Builder
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ApiResponse<T> {

    /**
     * HTTP status code duplicated for convenience.
     * Frontend can check this without parsing headers.
     */
    private int status;

    //Human-readable status: "success", "error", "created"
    private String statusText;

    //Brief message describing the result.
    private String message;

    /**
     * Timestamp of response generation.
     * Useful for debugging and client-side caching.
     */
    @Builder.Default
    private LocalDateTime timestamp = LocalDateTime.now();

    /**
     * Payload data — generic type allows reuse across endpoints.
     * Null for operations that return no data (e.g., DELETE).
     */
    private T data;

    //Error details — populated only when status indicates error.
    private ErrorDetails error;

    /**
     * Factory methods for common response patterns.
     * Reduces boilerplate in controllers.
     */
    public static <T> ApiResponse<T> success(T data) {
        return ApiResponse.<T>builder()
                .status(200)
                .statusText("success")
                .message("Request completed successfully")
                .data(data)
                .build();
    }

    public static <T> ApiResponse<T> created(T data) {
        return ApiResponse.<T>builder()
                .status(201)
                .statusText("created")
                .message("Resource created successfully")
                .data(data)
                .build();
    }

    public static <T> ApiResponse<T> error(int status, String message, ErrorDetails error) {
        return ApiResponse.<T>builder()
                .status(status)
                .statusText("error")
                .message(message)
                .error(error)
                .build();
    }


    @Data
    @Builder
    @JsonInclude(JsonInclude.Include.NON_NULL)
    public static class ErrorDetails {

        /**
         * Machine-readable error code for frontend.
         * Example: "EMAIL_EXISTS", "INVALID_CREDENTIALS"
         */
        private String code;

        //Human-readable description.
        private String description;

        //Key: field name, Value: error message
        private java.util.Map<String, String> fieldErrors;
    }
}