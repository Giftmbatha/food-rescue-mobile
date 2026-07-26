package com.foodrescue.Backend.service;

import com.foodrescue.Backend.dto.ListingImageDto;
import com.foodrescue.Backend.entity.Listing;
import com.foodrescue.Backend.entity.ListingImage;
import com.foodrescue.Backend.repository.ListingImageRepository;
import com.foodrescue.Backend.service.storage.ImageStorageService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ListingImageService {

    private final ListingImageRepository listingImageRepository;
    private final ImageStorageService imageStorageService;

    /**
     * Attach images to a listing.
     * Called after listing is created/updated.
     */
    @Transactional
    public void attachImages(Listing listing, List<String> objectKeys, List<String> captions) {
        if (objectKeys == null || objectKeys.isEmpty()) {
            return;
        }

        for (int i = 0; i < objectKeys.size(); i++) {
            String objectKey = objectKeys.get(i);
            String caption = (captions != null && i < captions.size()) ? captions.get(i) : null;

            ListingImage image = ListingImage.builder()
                    .listing(listing)
                    .objectKey(objectKey)
                    .caption(caption)
                    .displayOrder(i)
                    .build();

            listingImageRepository.save(image);
        }

        log.info("Attached {} images to listing {}", objectKeys.size(), listing.getId());
    }

    /**
     * Replace all images on a listing.
     * Deletes old images from DB (storage cleanup optional).
     */
    @Transactional
    public void replaceImages(Listing listing, List<String> objectKeys, List<String> captions) {
        // Remove existing image records
        List<ListingImage> oldImages = listingImageRepository.findByListingIdOrderByDisplayOrderAsc(listing.getId());

        // Optional: Delete from storage too
        // oldImages.forEach(img -> imageStorageService.deleteImage(img.getObjectKey()));

        listingImageRepository.deleteAll(oldImages);

        // Attach new images
        attachImages(listing, objectKeys, captions);
    }

    // Get images with pre-signed URLs for a listing.
    @Transactional(readOnly = true)
    public List<ListingImageDto> getImagesWithUrls(Listing listing, int urlExpiryMinutes) {
        List<ListingImage> images = listingImageRepository.findByListingIdOrderByDisplayOrderAsc(listing.getId());

        return images.stream().map(img -> {
            String presignedUrl = imageStorageService.generatePresignedUrl(img.getObjectKey(), urlExpiryMinutes);
            return ListingImageDto.builder()
                    .objectKey(img.getObjectKey())
                    .presignedUrl(presignedUrl)
                    .caption(img.getCaption())
                    .displayOrder(img.getDisplayOrder())
                    .build();
        }).collect(Collectors.toList());
    }
}