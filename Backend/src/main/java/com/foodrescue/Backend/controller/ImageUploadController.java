package com.foodrescue.Backend.controller;

import com.foodrescue.Backend.config.ImageConfig;
import com.foodrescue.Backend.dto.ImageUploadResponse;
import com.foodrescue.Backend.service.storage.ImageStorageService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

/**
 * REST endpoint for image uploads.
 *
 * Returns object keys — callers (ListingController) attach these to their entities.
 *
 * Security: Only authenticated users can upload. Caller validates ownership.
 */
@RestController
@RequestMapping("/api/v1/images")
@RequiredArgsConstructor
@Slf4j
public class ImageUploadController {

    private final ImageStorageService imageStorageService;
    private final ImageConfig imageConfig;

    /**
     * Upload a single image.
     *
     * @param file the image file
     * @param folder optional folder prefix (e.g., "listings", "avatars")
     * @return object key and pre-signed URL
     */
    @PostMapping("/upload")
    public ResponseEntity<ImageUploadResponse> uploadImage(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "folder", required = false, defaultValue = "") String folder) {

        // Validation
        validateFile(file);

        // Normalize folder: ensure trailing slash if provided
        String normalizedFolder = folder.isEmpty() ? "" : folder.endsWith("/") ? folder : folder + "/";

        String objectKey = imageStorageService.uploadImage(file, normalizedFolder);

        // Generate short-lived URL for immediate use
        String presignedUrl = imageStorageService.generatePresignedUrl(objectKey, 15);

        log.info("Image uploaded: {} by user {}", objectKey, getCurrentUserId());

        return ResponseEntity.ok(ImageUploadResponse.builder()
                .objectKey(objectKey)
                .presignedUrl(presignedUrl)
                .expiresInMinutes(15)
                .build());
    }

    /**
     * Generate fresh pre-signed URL for an existing image.
     * Called when mobile app needs to refresh expired URLs.
     */
    @GetMapping("/url")
    public ResponseEntity<ImageUploadResponse> getPresignedUrl(
            @RequestParam String objectKey,
            @RequestParam(defaultValue = "15") int expiryMinutes) {

        String url = imageStorageService.generatePresignedUrl(objectKey, expiryMinutes);

        return ResponseEntity.ok(ImageUploadResponse.builder()
                .objectKey(objectKey)
                .presignedUrl(url)
                .expiresInMinutes(expiryMinutes)
                .build());
    }

    /**
     * Delete an image by object key.
     * Caller must verify ownership before calling.
     */
    @DeleteMapping("/{objectKey}")
    public ResponseEntity<Void> deleteImage(@PathVariable String objectKey) {
        // TODO: Verify user owns this image before deleting
        imageStorageService.deleteImage(objectKey);
        return ResponseEntity.noContent().build();
    }

    // --- Validation ---

    private void validateFile(MultipartFile file) {
        if (file.isEmpty()) {
            throw new IllegalArgumentException("File is empty");
        }

        // Size check
        long maxSizeBytes = (long) imageConfig.getMaxSizeMb() * 1024 * 1024;
        if (file.getSize() > maxSizeBytes) {
            throw new IllegalArgumentException(
                    "File too large. Max size: " + imageConfig.getMaxSizeMb() + "MB");
        }

        // Type check
        String contentType = file.getContentType();
        if (contentType == null || !imageConfig.getAllowedTypes().contains(contentType)) {
            throw new IllegalArgumentException(
                    "Invalid file type. Allowed: " + imageConfig.getAllowedTypes());
        }
    }

    private String getCurrentUserId() {
        // TODO: Integrate with CurrentUserService
        return "anonymous";
    }
}