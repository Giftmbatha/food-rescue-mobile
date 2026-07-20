package com.foodrescue.Backend.controller;

import com.foodrescue.Backend.entity.FoodCategory;
import com.foodrescue.Backend.entity.ListingStatus;
import com.foodrescue.Backend.service.ListingService;
import com.foodrescue.Backend.dto.ListingRequestDto;
import com.foodrescue.Backend.dto.ListingResponseDto;
import com.foodrescue.Backend.dto.ApiResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/listings")
@RequiredArgsConstructor
@Slf4j
public class ListingController {

    private final ListingService listingService;

    /**
     * Create a new food listing.
     *
     * POST /api/v1/listings
     *
     * For now, donorId is passed as query param.
     * In Week 3, we'll extract it from JWT token.
     */
    @PostMapping
    public ResponseEntity<ApiResponse<ListingResponseDto>> createListing(@RequestParam UUID donorId, @Valid @RequestBody ListingRequestDto requestDto){

        log.info("Listing creation request from donor: {}", donorId);

        ListingResponseDto created = listingService.createListing(donorId, requestDto);

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.created(created));
    }

    // Get a single listing by ID.
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<ListingResponseDto>> getListing(@PathVariable UUID id) {

        ListingResponseDto listing = listingService.getListingById(id);

        return ResponseEntity.ok(ApiResponse.success(listing));
    }

    // Search listings with filters.
    @GetMapping
    public ResponseEntity<ApiResponse<Page<ListingResponseDto>>> searchListings(
            @RequestParam(required = false) ListingStatus status,
            @RequestParam(required = false) FoodCategory category,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {

        Pageable pageable = PageRequest.of(page, size, Sort.by("CreatedAt").descending());

        // Default to AVAILABLE if no status specified
        ListingStatus effectiveStatus = status != null ? status : ListingStatus.AVAILABLE;

        Page<ListingResponseDto> results = listingService.searchListings(effectiveStatus, category, pageable);

        return ResponseEntity.ok(ApiResponse.success(results));
    }

    // Find listings near a geographic location.
    @GetMapping("/nearby")
    public ResponseEntity<ApiResponse<Page<ListingResponseDto>>> findNearby(
            @RequestParam Double lat,
            @RequestParam Double lng,
            @RequestParam(defaultValue = "5000") Double distance,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {

        log.info("Nearby search: lat={}, lng={}, distance={}m", lat, lng, distance);

        Pageable pageable =PageRequest.of(page, size);

        Page<ListingResponseDto> results = listingService.findNearby(lat, lng, distance, pageable);

        return ResponseEntity.ok(ApiResponse.success(results));
    }

    // Update listing status
    @PutMapping("/{id}/status")
    public ResponseEntity<ApiResponse<ListingResponseDto>> updateStatus(@PathVariable UUID id, @RequestParam ListingStatus status) {

        log.info("Status update for listing {}: {}", id, status);

        ListingResponseDto updated = listingService.updateStatus(id, status);

        return ResponseEntity.ok(ApiResponse.success(updated));
    }
}
