package com.foodrescue.Backend.repository;

import com.foodrescue.Backend.entity.ListingImage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ListingImageRepository extends JpaRepository<ListingImage, UUID> {

    List<ListingImage> findByListingIdOrderByDisplayOrderAsc(UUID listingId);

    void deleteByListingId(UUID listingId);
}