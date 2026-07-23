package com.foodrescue.Backend.repository;

import com.foodrescue.Backend.entity.Claim;
import com.foodrescue.Backend.entity.ClaimStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ClaimRepository extends JpaRepository<Claim, UUID> {

    // Find claim by NGO
    Page<Claim> findByNgoId(UUID ngoId, Pageable pageable);

    // Find claims for listings created by a donor
    @Query("SELECT c FROM Claim c JOIN c.listing l WHERE l.donor.id = :donorId")
    Page<Claim> findByListingDonorId(@Param("donorId") UUID donorId, Pageable pageable);

    // Find claims for specific listing
    List<Claim> findByListingId(UUID listingId);

    // Count pending claims for a listing
    Long countByListingIdAndStatus(UUID listingId, ClaimStatus status);
}
