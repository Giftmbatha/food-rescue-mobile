package com.foodrescue.backend.repository;

import com.foodrescue.backend.entity.Donor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface DonorRepository extends JpaRepository<Donor, UUID>{

    Optional<Donor> findByUserId(UUID userId);

    Optional<Donor> findByOrgNameIgnoreCase(String orgName);

    boolean existsByOrgnameIgnoreCase(String orgName);

    Page<Donor> findByOrgNameContainingIgnoreCase(String keyword, Pageable pageable);

    /**
     * Find donors within geographic radius.
     *
     * Uses PostGIS ST_DWithin for efficient geospatial search.
     * Native query required because JPQL doesn't support PostGIS functions.
     *
     * @Param binds method parameters to query placeholders.
     * 6371000 converts distance to meters (Earth's radius in meters).
     */
    @Query(value = """
            SELECT d.* FROM donors d
            WHERE ST_DWithin(
                ST_SetSRID(ST_MakePoint(d.longitude, d.latitude), 4326),
                ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326),
                :distanceInMeters
            )
             ORDER BY ST_Distance(
                ST_SetSRID(ST_MakePoint(d.longitude, d.latitude), 4326),
                ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326)
            )
            """, nativeQuery = true)
    Page<Donor> findByNearby(
            @Param("latitude") Double latitude,
            @Param("longitude") Double longitude,
            @Param("distanceInMeters") Double distanceInMeters,
            Pageable pageable);
}