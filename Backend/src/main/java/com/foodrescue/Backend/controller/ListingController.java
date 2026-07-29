package com.foodrescue.Backend.controller;

import com.foodrescue.Backend.dto.*;
import com.foodrescue.Backend.entity.FoodCategory;
import com.foodrescue.Backend.entity.ListingStatus;
import com.foodrescue.Backend.entity.User;
import com.foodrescue.Backend.service.ClaimService;
import com.foodrescue.Backend.security.CurrentUser;
import com.foodrescue.Backend.service.CurrentUserService;
import com.foodrescue.Backend.service.ListingService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/listings")
@RequiredArgsConstructor
@Slf4j
public class ListingController {

    private final ListingService listingService;
    private final CurrentUserService currentUserService;
    private final ClaimService claimService;

    /**
     * Create a new listing — DONOR only.
     *
     * Extracts authenticated user from JWT, verifies they are a donor,
     * then creates the listing with their donor profile.
     */
    @PostMapping
    @PreAuthorize("hasRole('DONOR')")
    public ResponseEntity<ListingResponseDto> createListing(
            @Valid @RequestBody ListingRequestDto dto) {

        log.info("Creating listing: {}", dto.getTitle());
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(listingService.createListing(dto));
    }

    // Get a single listing by ID.
    @GetMapping("/{id}")
    public ResponseEntity<ListingResponseDto> getListing(@PathVariable UUID id) {
        return ResponseEntity.ok(listingService.getListingById(id));
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

    // Get all available listings
    @GetMapping
    public ResponseEntity<Page<ListingResponseDto>> getActiveListings(
            @PageableDefault(size = 20, sort = "createdAt", direction = Sort.Direction.DESC)
            Pageable pageable) {

        return ResponseEntity.ok(listingService.getActiveListings(pageable));
    }

    // Find listings near a geographic location.
    @GetMapping("/nearby")
    public ResponseEntity<ApiResponse<Page<ListingResponseDto>>> findNearby(
            @RequestParam Double lat,
            @RequestParam Double lng,
            @RequestParam(defaultValue = "5000") Double distance,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "15") int urlExpiryMinutes) {

        log.info("Nearby search: lat={}, lng={}, distance={}m", lat, lng, distance);

        Pageable pageable =PageRequest.of(page, size);

        Page<ListingResponseDto> results = listingService.findNearby(lat, lng, distance, pageable, urlExpiryMinutes);

        return ResponseEntity.ok(ApiResponse.success(results));
    }

    // Update listing status
    @PutMapping("/{id}/status")
    @PreAuthorize("hasRole('Donor'")
    public ResponseEntity<ApiResponse<ListingResponseDto>> updateStatus(@PathVariable UUID id, @RequestParam ListingStatus status) {

        log.info("Status update for listing {}: {}", id, status);

        ListingResponseDto updated = listingService.updateStatus(id, status);

        return ResponseEntity.ok(ApiResponse.success(updated));
    }

    // Update listing
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('DONOR')")
    public ResponseEntity<ListingResponseDto> updateListing(
            @PathVariable UUID id,
            @Valid @RequestBody ListingRequestDto dto) {

        log.info("Updating listing: {}", id);
        return ResponseEntity.ok(listingService.updateListing(id, dto));
    }

    // Delete listing
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('DONOR')")
    public ResponseEntity<Void> deleteListing(@PathVariable UUID id) {
        listingService.deleteListing(id);
        return ResponseEntity.noContent().build();
    }
    /**
     * Create a claim on a specific listing.
     *
     * Alternative to POST /api/v1/claims. More RESTful because the listing
     * is part of the URL path, not the request body.
     */
    @PostMapping("/{id}/claim")
    @PreAuthorize("hasRole('NGO')")
    public ResponseEntity<ClaimResponseDto> claimListing(
            @PathVariable UUID id,
            @Valid @RequestBody ClaimRequestDto dto) {

        // Override listingId in DTO with path variable for safety
        dto.setListingId(id);

        log.info("NGO claiming listing: {}", id);
        ClaimResponseDto response = claimService.createClaim(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }
}
