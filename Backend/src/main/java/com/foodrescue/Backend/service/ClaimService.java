package com.foodrescue.Backend.service;


import com.foodrescue.Backend.dto.ClaimRequestDto;
import com.foodrescue.Backend.dto.ClaimResponseDto;
import com.foodrescue.Backend.repository.ClaimRepository;
import com.foodrescue.Backend.repository.ListingRepository;
import com.foodrescue.Backend.repository.NgoRepository;
import com.foodrescue.Backend.service.CurrentUserService;
import com.foodrescue.Backend.entity.*;
import org.springframework.transaction.annotation.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class ClaimService {

    private final ClaimRepository claimRepository;
    private final ListingRepository listingRepository;
    private final NgoRepository ngoRepository;
    private final CurrentUserService currentUserService;

    // NGO creates a claim on available listing
    @Transactional
    public ClaimResponseDto createClaim(ClaimRequestDto dto) {
        User currentUser = currentUserService.getCurrentUser();

        // validate if user is an NGO
        if (currentUser.getRole() != User.Role.NGO) {
            throw new IllegalStateException("Only NGOs can create claims");
        }

        Ngo ngo = ngoRepository.findById(currentUser.getId()).orElseThrow(() -> new IllegalArgumentException("NGO profile not found"));

        // Validate if listing exists and is AVAILABLE
        Listing listing = listingRepository.findById(dto.getListingId())
                .orElseThrow(() -> new IllegalArgumentException("Listing not found:" + dto.getListingId()));

        if (listing.getStatus() != ListingStatus.AVAILABLE) {
            throw new IllegalStateException("Listing is not available for claiming");
        }

        // Validate if NGO already has pending claim on this listing
        Long existingClaims = claimRepository.countByListingIdAndStatus(
                listing.getId(), ClaimStatus.PENDING);
        if (existingClaims > 0 && !listing.getAllowPartialClaims()) {
            throw new IllegalStateException("This listing already has a pending claim");
        }

        Claim claim = Claim.builder()
                .listing(listing)
                .ngo(ngo)
                .status(ClaimStatus.PENDING)
                .proposedPickupTime(dto.getProposedPickupTime())
                .message(dto.getMessage())
                .donorNotified(false)
                .build();
        Claim saved = claimRepository.save(claim);

        // Update listing status if not allowing partial claims
        if (listing.getAllowPartialClaims()) {
            listing.setStatus(ListingStatus.CLAIMED);
            listingRepository.save(listing);
        }

        log.info("Claim created: {} on listing {}", saved.getId(), listing.getId());
        return mapToResponseDto(saved);
    }

    // NGO approves a pending claim
    @Transactional
    public ClaimResponseDto approveClaim(UUID claimId, String donorResponse) {
        User currentUser = currentUserService.getCurrentUser();

        if (currentUser.getRole() != User.Role.DONOR) {
            throw new IllegalStateException("Only donors can approve claims");
        }

        Claim claim = claimRepository.findById(claimId)
                .orElseThrow(() -> new IllegalArgumentException("Claim not found: " + claimId));

        // Validate if this claim is for donor's listing
        if (!claim.getListing().getDonor().getId().equals(currentUser.getId())) {
            throw new IllegalStateException("You can only approve claims for your own listings");
        }

        claim.approve(donorResponse);
        Claim saved = claimRepository.save(claim);

        log.info("Claim approved: {}", claimId);

        return mapToResponseDto(saved);
    }

    // Donor rejects pending claim.
    @Transactional
    public ClaimResponseDto rejectClaim(UUID claimId, String donorResponse) {
        User currentUser = currentUserService.getCurrentUser();

        if (currentUser.getRole() != User.Role.DONOR) {
            throw new IllegalStateException("Only Donors can reject claims");
        }

        Claim claim = claimRepository.findById(claimId)
                .orElseThrow(() -> new IllegalArgumentException("Claim not found: " + claimId));

        if (!claim.getListing().getDonor().getId().equals(currentUser.getId())) {
            throw new IllegalStateException("You can only reject claims for your own listings");
        }

        claim.reject(donorResponse);

        // Revert listing to AVAILABLE if no other pending claims
        Listing listing = claim.getListing();
        Long pendingCount = claimRepository.countByListingIdAndStatus(listing.getId(), ClaimStatus.PENDING);
        if (pendingCount == 0) {
            listing.setStatus(ListingStatus.AVAILABLE);
            listingRepository.save(listing);
        }

        Claim saved = claimRepository.save(claim);

        log.info("Claim rejected: {}", claimId);

        return mapToResponseDto(saved);
    }

    // Mark claim as completed (pickup done)
    @Transactional
    public ClaimResponseDto completeClaim(UUID claimId) {
        User currentUser = currentUserService.getCurrentUser();

        Claim claim = claimRepository.findById(claimId)
                .orElseThrow(() -> new IllegalArgumentException("Claim not found: " + claimId));

        // Either donor or NGO can mark complete
        boolean isDonor = currentUser.getRole() == User.Role.DONOR
                && claim.getListing().getDonor().getId().equals(currentUser.getId());
        boolean isNgo = currentUser.getRole() == User.Role.NGO
                && claim.getNgo().getId().equals(currentUser.getId());

        if (!isDonor && !isNgo) {
            throw new IllegalStateException("Only involved parties can complete a claim");
        }

        claim.complete();
        Claim saved = claimRepository.save(claim);

        // Update listing status
        Listing listing = claim.getListing();
        listing.setStatus(ListingStatus.COMPLETED);
        listingRepository.save(listing);

        log.info("Claim completed: {}", claimId);

        return mapToResponseDto(saved);
    }

    // Get claims for current user (NGO sees their claims, dono sees claims on their listings
    @Transactional(readOnly = true)
    public Page<ClaimResponseDto> getMyClaims(Pageable pageable) {
        User currentUser = currentUserService.getCurrentUser();

        Page<Claim> claims;
        if (currentUser.getRole() == User.Role.NGO) {
            claims = claimRepository.findByNgoId(currentUser.getId(), pageable);
        } else {
            claims = claimRepository.findByListingDonorId(currentUser.getId(), pageable);
        }

        return claims.map((this::mapToResponseDto));
    }

        private ClaimResponseDto mapToResponseDto(Claim claim) {
        return ClaimResponseDto.builder()
                .id(claim.getId())
                .listingId(claim.getListing().getId())
                .listingTitle(claim.getListing().getTitle())
                .ngoId(claim.getNgo().getId())
                .ngoOrgName(claim.getNgo().getOrgName())
                .status(claim.getStatus())
                .proposedPickupTime(claim.getProposedPickupTime())
                .message(claim.getMessage())
                .donorResponse(claim.getDonorResponse())
                .completedAt(claim.getCompletedAt())
                .createdAt(claim.getCreatedAt())
                .build();
    }
}
