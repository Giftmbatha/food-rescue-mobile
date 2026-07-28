package com.foodrescue.Backend.service;

import com.foodrescue.Backend.dto.DonorProfileDto;
import com.foodrescue.Backend.dto.DonorStatsDto;
import com.foodrescue.Backend.entity.ClaimStatus;
import com.foodrescue.Backend.entity.Donor;
import com.foodrescue.Backend.entity.ListingStatus;
import com.foodrescue.Backend.entity.User;
import com.foodrescue.Backend.repository.ClaimRepository;
import com.foodrescue.Backend.repository.DonorRepository;
import com.foodrescue.Backend.repository.ListingRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class DonorService {

    private final DonorRepository donorRepository;
    private final ListingRepository listingRepository;
    private final ClaimRepository claimRepository;
    private final CurrentUserService currentUserService;

    /**
     * Get donor profile by ID.
     * Public profile — no auth required (used in listing detail).
     */
    @Transactional(readOnly = true)
    public DonorProfileDto getProfile(UUID donorId) {
        Donor donor = donorRepository.findById(donorId)
                .orElseThrow(() -> new IllegalArgumentException("Donor not found: " + donorId));
        return mapToProfileDto(donor);
    }

    /**
     * Get current donor's own profile.
     */
    @Transactional(readOnly = true)
    public DonorProfileDto getMyProfile() {
        User currentUser = currentUserService.getCurrentUser();
        if (currentUser.getRole() != User.Role.DONOR) {
            throw new IllegalStateException("Only donors have donor profiles");
        }
        Donor donor = donorRepository.findById(currentUser.getId())
                .orElseThrow(() -> new IllegalArgumentException("Donor profile not found"));
        return mapToProfileDto(donor);
    }

    /**
     * Update donor profile.
     * Only the donor themselves can update.
     */
    @Transactional
    public DonorProfileDto updateProfile(UUID donorId, DonorProfileDto dto) {
        User currentUser = currentUserService.getCurrentUser();

        if (currentUser.getRole() != User.Role.DONOR || !currentUser.getId().equals(donorId)) {
            throw new IllegalStateException("You can only update your own profile");
        }

        Donor donor = donorRepository.findById(donorId)
                .orElseThrow(() -> new IllegalArgumentException("Donor not found: " + donorId));

        // Update fields
        donor.setOrgName(dto.getOrgName());
        donor.setOrgType(dto.getOrgType());
        donor.setAddress(dto.getAddress());
        donor.setLatitude(dto.getLatitude());
        donor.setLongitude(dto.getLongitude());
        donor.setContactPerson(dto.getContactPerson());
        donor.setPhone(dto.getPhone());

        Donor saved = donorRepository.save(donor);
        log.info("Donor profile updated: {}", donorId);

        return mapToProfileDto(saved);
    }

    /**
     * Get donor impact statistics.
     * Aggregates across listings and claims.
     */
    @Transactional(readOnly = true)
    public DonorStatsDto getStats(UUID donorId) {
        Donor donor = donorRepository.findById(donorId)
                .orElseThrow(() -> new IllegalArgumentException("Donor not found: " + donorId));

        long totalListings = listingRepository.countByDonorId(donorId);
        long activeListings = listingRepository.countByDonorIdAndStatus(donorId, ListingStatus.AVAILABLE);
        long completedClaims = claimRepository.countByListingDonorIdAndStatus(donorId, ClaimStatus.COMPLETED);

        // Sum of quantity_kg from completed claims
        Double totalKg = listingRepository.sumQuantityKgByDonorIdAndCompletedClaims(donorId);

        return DonorStatsDto.builder()
                .donorId(donorId)
                .orgName(donor.getOrgName())
                .totalListings((int) totalListings)
                .activeListings((int) activeListings)
                .completedClaims((int) completedClaims)
                .totalKgDonated(totalKg != null ? totalKg : 0.0)
                .averageRating(donor.getRatingAvg())
                .ratingCount(0) // TODO: Implement rating system
                .build();
    }

    private DonorProfileDto mapToProfileDto(Donor donor) {
        return DonorProfileDto.builder()
                .id(donor.getId())
                .userId(donor.getUser().getId())
                .orgName(donor.getOrgName())
                .orgType(donor.getOrgType())
                .address(donor.getAddress())
                .latitude(donor.getLatitude())
                .longitude(donor.getLongitude())
                .contactPerson(donor.getContactPerson())
                .phone(donor.getPhone())
                .ratingAvg(donor.getRatingAvg())
                .build();
    }
}