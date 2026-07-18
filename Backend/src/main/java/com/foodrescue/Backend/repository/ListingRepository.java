package com.foodrescue.Backend.repository;

import com.foodrescue.Backend.entity.Listing;
import com.foodrescue.Backend.entity.ListingStatus;
import com.foodrescue.Backend.entity.FoodCategory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ListingRepository extends JpaRepository<Listing, UUID> {

    // Find Listings by donor
    Page<Listing> findByDonorId(UUID donorId, Pageable pageable);

    // Find Listings by category
    Page<Listing> findByStatusAndCategory(ListingStatus status, FoodCategory category, Pageable pageable);

    // Find all Active Listings
    Page<Listing> findByStatus(ListingStatus status, Pageable pageable);

    /**
     * Geospatial search: find available listings within radius.
     *
     * Uses PostGIS ST_DWithin for efficient distance calculation.
     * Distance in meters.
     */
    @Query(value = """
        SELECT l.* FROM listings l
        JOIN donors d ON l.donor_id = d.id
        WHERE l.status = 'AVAILABLE'
        AND ST_DWithin(
            ST_SetSRID(ST_MakePoint(l.pickup_longitude, l.pickup_latitude), 4326),
            ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326),
            :distanceInMeters
        )
        ORDER BY ST_Distance(
            ST_SetSRID(ST_MakePoint(l.pickup_longitude, l.pickup_latitude), 4326),
            ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326)
        )
        """, nativeQuery = true)
        Page<Listing> findNearbyAvailable(
                @Param("latitude") Double latitude,
                @Param("longitude") Double longitude,
                @Param("distanceInMeters") Double distanceInMeters,
                Pageable pageable
    );

    // Count claims for a listing
    @Query("SELECT COUNT(c) FROM Claim c WHERE c.listing.id = :listingId")
    Long countClaimsByListingId(@Param("listingId") UUID listingId);
}
