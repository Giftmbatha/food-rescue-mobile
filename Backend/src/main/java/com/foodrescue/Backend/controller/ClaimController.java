package com.foodrescue.Backend.controller;

import com.foodrescue.Backend.dto.ClaimRequestDto;
import com.foodrescue.Backend.dto.ClaimResponseDto;
import com.foodrescue.Backend.dto.ClaimStatusUpdateDto;
import com.foodrescue.Backend.service.ClaimService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

/**
 * REST controller for claim operations.
 *
 * Design decisions:
 * - Explicit action endpoints (/approve, /reject, /complete) over generic /status
 *   because claims are a state machine, not free-form updates.
 * - Service layer handles all authorization to keep controllers thin.
 * - Pageable defaults prevent unbounded queries.
 */
@RestController
@RequestMapping("/api/v1/claims")
@RequiredArgsConstructor
@Slf4j
public class ClaimController {

    private final ClaimService claimService;

    /**
     * NGO creates a claim on a listing.
     *
     * Returns 201 CREATED because we're creating a new resource.
     * Location header could be added for full REST compliance.
     */
    @PostMapping
    @PreAuthorize("hasRole('NGO')")
    public ResponseEntity<ClaimResponseDto> createClaim(
            @Valid @RequestBody ClaimRequestDto dto) {

        log.info("Creating claim for listing: {}", dto.getListingId());
        ClaimResponseDto response = claimService.createClaim(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    /**
     * List claims for the authenticated user.
     *
     * NGO: claims they submitted.
     * Donor: claims on their listings.
     *
     * Pagination prevents memory issues when users have hundreds of claims.
     */
    @GetMapping
    public ResponseEntity<Page<ClaimResponseDto>> getMyClaims(
            @PageableDefault(
                    size = 20,
                    sort = "createdAt",
                    direction = Sort.Direction.DESC
            ) Pageable pageable) {

        log.info("Fetching claims for current user, page: {}", pageable.getPageNumber());
        Page<ClaimResponseDto> claims = claimService.getMyClaims(pageable);
        return ResponseEntity.ok(claims);
    }

    /**
     * Get single claim detail.
     *
     * Authorization: must be the NGO who claimed or the donor who listed.
     */
    @GetMapping("/{id}")
    public ResponseEntity<ClaimResponseDto> getClaim(@PathVariable UUID id) {
        log.info("Fetching claim detail: {}", id);
        ClaimResponseDto claim = claimService.getClaimById(id);
        return ResponseEntity.ok(claim);
    }

    /**
     * Donor approves a pending claim.
     *
     * Optional donorResponse lets donor add a message (e.g., "See you at 10!").
     */
    @PutMapping("/{id}/approve")
    @PreAuthorize("hasRole('DONOR')")
    public ResponseEntity<ClaimResponseDto> approveClaim(
            @PathVariable UUID id,
            @RequestBody(required = false) ClaimStatusUpdateDto dto) {

        log.info("Approving claim: {}", id);
        String donorResponse = dto != null ? dto.getDonorResponse() : null;
        ClaimResponseDto response = claimService.approveClaim(id, donorResponse);
        return ResponseEntity.ok(response);
    }

    /**
     * Donor rejects a pending claim.
     *
     * Rejection reverts listing to AVAILABLE if no other pending claims.
     */
    @PutMapping("/{id}/reject")
    @PreAuthorize("hasRole('DONOR')")
    public ResponseEntity<ClaimResponseDto> rejectClaim(
            @PathVariable UUID id,
            @RequestBody(required = false) ClaimStatusUpdateDto dto) {

        log.info("Rejecting claim: {}", id);
        String donorResponse = dto != null ? dto.getDonorResponse() : null;
        ClaimResponseDto response = claimService.rejectClaim(id, donorResponse);
        return ResponseEntity.ok(response);
    }

    /**
     * Mark claim as completed after pickup.
     *
     * Either party can call this. No @PreAuthorize because service checks roles.
     */
    @PutMapping("/{id}/complete")
    public ResponseEntity<ClaimResponseDto> completeClaim(@PathVariable UUID id) {
        log.info("Completing claim: {}", id);
        ClaimResponseDto response = claimService.completeClaim(id);
        return ResponseEntity.ok(response);
    }

    /**
     * NGO cancels their own pending claim.
     *
     * POST (not DELETE) because we're not deleting the record — we're
     * transitioning state to CANCELLED. DELETE would imply removal from DB.
     */
    @PostMapping("/{id}/cancel")
    @PreAuthorize("hasRole('NGO')")
    public ResponseEntity<ClaimResponseDto> cancelClaim(@PathVariable UUID id) {
        log.info("Cancelling claim: {}", id);
        ClaimResponseDto response = claimService.cancelClaim(id);
        return ResponseEntity.ok(response);
    }
}