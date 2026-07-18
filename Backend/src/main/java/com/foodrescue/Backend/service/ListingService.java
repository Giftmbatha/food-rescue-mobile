package com.foodrescue.Backend.service;

import com.foodrescue.Backend.dto.ListingRequestDto;
import com.foodrescue.Backend.dto.ListingResponseDto;
import com.foodrescue.Backend.entity.Donor;
import com.foodrescue.Backend.entity.Listing;
import com.foodrescue.Backend.entity.ListingStatus;
import com.foodrescue.Backend.entity.FoodCategory;
import com.foodrescue.Backend.repository.DonorRepository;
import com.foodrescue.Backend.repository.ListingRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

// Service for food listing operations.
@Service
@RequiredArgsConstructor
@Slf4j
public class ListingService {

    private final ListingRepository listingRepository;
    private final DonorRepository donorRepository;

    /**
     * Create a new food listing.
     *
     * Validates donor exists, maps DTO to entity, persists.
     *
     * @param donorId the authenticated donor creating the listing
     * @param dto listing data from client
     * @return created listing as response DTO
     */
    @Transactional
    public ListingResponseDto createListing(UUID donorId, ListingRequestDto dto) {
        log.info("Creating listing for donor: {}", donorId);

        Donor donor = donorRepository.findById(donorId)
                .orElseThrow(() -> new IllegalArgumentException("Donor not found: " + donorId));

        Listing listing = Listing.builder()
                .donor(donor)
                .title(dto.getTitle().trim())
                .description(dto.getDescription() != null ? dto.getDescription().trim() : null)
                .category(dto.getCategory())
                .quantityKg(dto.getQuantityKg())
                .expiryDate(dto.getExpiryDate())
                .pickupAddress(dto.getPickupAddress().trim())
                .pickupLatitude(dto.getPickupLatitude())
                .pickupLongitude(dto.getPickupLongitude())
                .pickupWindow(dto.getPickupWindow().trim())
                .pickupNotes(dto.getPickupNotes() != null ? dto.getPickupNotes().trim() : null)
                .allowPartialClaims(dto.getAllowPartialClaims())
                .status(ListingStatus.AVAILABLE)
                .build();

        Listing saved = listingRepository.save(listing);
        log.info("Listing created: id={}, title={}", saved.getId(), saved.getTitle());

        return mapToResponseDto(saved);
    }

    // Get single listing by ID.
    @Transactional(readOnly = true)
    public ListingResponseDto getListingById(UUID id) {
        Listing listing = listingRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Listing not found: " + id));
        return mapToResponseDto(listing);
    }

    // Search available listings with optional category filter.
    @Transactional(readOnly = true)
    public Page<ListingResponseDto> searchListings(ListingStatus status, FoodCategory category, Pageable pageable) {
        Page<Listing> listings;

        if (category != null && status != null) {
            listings = listingRepository.findByStatusAndCategory(status, category, pageable);
        } else if (status != null) {
            listings = listingRepository.findByStatus(status, pageable);
        } else {
            listings = listingRepository.findAll(pageable);
        }

        return listings.map(this::mapToResponseDto);
    }

    // Find available listings near a location.
    @Transactional(readOnly = true)
    public Page<ListingResponseDto> findNearby(Double latitude, Double longitude, Double distanceInMeters, Pageable pageable) {
        Page<Listing> listings = listingRepository.findNearbyAvailable(
                latitude, longitude, distanceInMeters, pageable);
        return listings.map(this::mapToResponseDto);
    }

    // Update listing status. Validates transition is allowed.
    @Transactional
    public ListingResponseDto updateStatus(UUID listingId, ListingStatus newStatus) {
        Listing listing = listingRepository.findById(listingId)
                .orElseThrow(() -> new IllegalArgumentException("Listing not found: " + listingId));

        // Validate state transition
        if (listing.getStatus() == ListingStatus.COMPLETED || listing.getStatus() == ListingStatus.EXPIRED) {
            throw new IllegalStateException("Cannot change status of a " + listing.getStatus() + " listing");
        }

        listing.setStatus(newStatus);
        Listing updated = listingRepository.save(listing);

        log.info("Listing {} status changed to {}", listingId, newStatus);
        return mapToResponseDto(updated);
    }

    // Map entity to response DTO.
    private ListingResponseDto mapToResponseDto(Listing listing) {
        return ListingResponseDto.builder()
                .id(listing.getId())
                .donorOrgName(listing.getDonor().getOrgName())
                .donorOrgType(listing.getDonor().getOrgType().name())
                .title(listing.getTitle())
                .description(listing.getDescription())
                .category(listing.getCategory())
                .quantityKg(listing.getQuantityKg())
                .expiryDate(listing.getExpiryDate())
                .pickupAddress(listing.getPickupAddress())
                .pickupLatitude(listing.getPickupLatitude())
                .pickupLongitude(listing.getPickupLongitude())
                .pickupWindow(listing.getPickupWindow())
                .status(listing.getStatus())
                .imageUrls(listing.getImageUrlList())
                .pickupNotes(listing.getPickupNotes())
                .allowPartialClaims(listing.getAllowPartialClaims())
                .createdAt(listing.getCreatedAt())
                .claimCount(listingRepository.countClaimsByListingId(listing.getId()).intValue())
                .build();
    }
}
