package com.foodrescue.Backend.service;

import com.foodrescue.Backend.dto.ListingRequestDto;
import com.foodrescue.Backend.dto.ListingResponseDto;
import com.foodrescue.Backend.entity.Donor;
import com.foodrescue.Backend.entity.Listing;
import com.foodrescue.Backend.entity.ListingStatus;
import com.foodrescue.Backend.entity.User;
import com.foodrescue.Backend.repository.DonorRepository;
import com.foodrescue.Backend.repository.ListingRepository;
import com.foodrescue.Backend.entity.FoodCategory;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

// Service for food listing operations.
@Service
@RequiredArgsConstructor
@Slf4j
public class ListingService {

    private final ListingRepository listingRepository;
    private final DonorRepository donorRepository;
    private final CurrentUserService currentUserService;
    private final ListingImageService listingImageService;
    private final NotificationService notificationService;

    /**
     * Create a new food listing.
     *
     * Validates donor exists, maps DTO to entity, persists.
     *
     * param donorId the authenticated donor creating the listing
     * param dto listing data from client
     * return created listing as response DTO
     */
    @Transactional
    public ListingResponseDto createListing(ListingRequestDto dto) {
        User currentUser = currentUserService.getCurrentUser();

        if (currentUser.getRole() != User.Role.DONOR) {
            throw new IllegalStateException("Only donors can create listings");
        }

        Donor donor = donorRepository.findById(currentUser.getId())
                .orElseThrow(() -> new IllegalArgumentException("Donor profile not found: "));

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

        // Attach images if provided
        listingImageService.attachImages(saved, dto.getImageObjectKeys(), dto.getImageCaptions());

        // Notify nearby NGOs
        //notificationService.notifyNearbyNgos(saved);
        log.info("Listing created: {}, by donor {}", saved.getId(), saved.getTitle());

        return mapToResponseDto(saved, 15); // 15 min URL expiry
    }

    // Get single listing by ID.
    @Transactional(readOnly = true)
    public ListingResponseDto getListingById(UUID id) {
        Listing listing = listingRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Listing not found: " + id));
        return mapToResponseDto(listing, 15);
    }

    // Get all available listings
    @Transactional(readOnly = true)
    public Page<ListingResponseDto> getActiveListings(Pageable pageable) {
        return listingRepository.findByStatus(ListingStatus.AVAILABLE, pageable)
                .map(l -> mapToResponseDto(l, 15));
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

        return listings.map(l -> mapToResponseDto(l, 15));
    }

    // Find available listings near a location.
    @Transactional(readOnly = true)
    public Page<ListingResponseDto> findNearby(Double latitude, Double longitude, Double distanceInMeters,
                                               Pageable pageable, int urlExpiryMinutes) {
        Page<Listing> listings = listingRepository.findNearbyAvailable(
                latitude, longitude, distanceInMeters, pageable);
        return listings.map(l -> mapToResponseDto(l, 15));
    }

    // Update listing
    @Transactional
    public ListingResponseDto updateListing(UUID listingId, ListingRequestDto dto) {
        User currentUser = currentUserService.getCurrentUser();

        Listing listing = listingRepository.findById(listingId)
                .orElseThrow(() -> new IllegalArgumentException("Listing not found: " + listingId));

        if (currentUser.getRole() != User.Role.DONOR ||
                !listing.getDonor().getId().equals(currentUser.getId())) {
            throw new IllegalStateException("You can only update your own listings");
        }

        // Update fields
        listing.setTitle(dto.getTitle());
        listing.setDescription(dto.getDescription());
        listing.setCategory(dto.getCategory());
        listing.setQuantityKg(dto.getQuantityKg());
        listing.setExpiryDate(dto.getExpiryDate());
        listing.setPickupAddress(dto.getPickupAddress());
        listing.setPickupLongitude(dto.getPickupLongitude());
        listing.setPickupLatitude(dto.getPickupLatitude());
        listing.setPickupWindow(dto.getPickupWindow());
        listing.setPickupNotes(dto.getPickupNotes());

        Listing saved = listingRepository.save(listing);

        // Replace images if new ones provided
        if (dto.getImageObjectKeys() != null && !dto.getImageObjectKeys().isEmpty()) {
            listingImageService.replaceImages(saved, dto.getImageObjectKeys(), dto.getImageCaptions());
        }

        return mapToResponseDto(saved, 15);
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
        return mapToResponseDto(updated, 15);
    }

    // Delete Listing
    @Transactional
    public void deleteListing(UUID listingId) {
        User currentUser = currentUserService.getCurrentUser();

        Listing listing = listingRepository.findById(listingId)
                .orElseThrow(() -> new IllegalArgumentException("Listing not found: " + listingId));

        if (currentUser.getRole() != User.Role.DONOR ||
                !listing.getDonor().getId().equals(currentUser.getId())) {
            throw new IllegalStateException("You can only delete your own listings");
        }

        // Soft delete — set status instead of removing
        listing.setStatus(ListingStatus.EXPIRED);
        listingRepository.save(listing);

        log.info("Listing soft-deleted: {}", listingId);
    }

    // Map entity to response DTO.
    private ListingResponseDto mapToResponseDto(Listing listing, int urlExpiryMinutes) {
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
                .imageUrls(listingImageService.getImagesWithUrls(listing,urlExpiryMinutes))
                .pickupNotes(listing.getPickupNotes())
                .allowPartialClaims(listing.getAllowPartialClaims())
                .createdAt(listing.getCreatedAt())
                .claimCount(listingRepository.countClaimsByListingId(listing.getId()))
                .build();
    }
}
