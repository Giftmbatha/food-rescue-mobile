package com.foodrescue.Backend.service.storage;

import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;
import java.util.UUID;

/**
 * Abstraction for image storage backends.
 *
 * Implements: MinIO (dev), AWS S3 (production).
 * Both provide: upload, delete, and pre-signed URL generation.
 */
public interface ImageStorageService {

    /**
     * Upload image and return the stored object key.
     *
     * @param file the uploaded file
     * @param folder optional folder prefix (e.g., "listings/2026/07/")
     * return object key for later retrieval
     */
    String uploadImage(MultipartFile file, String folder);

    // Delete image by object key.

    void deleteImage(String objectKey);

    /**
     * Generate temporary pre-signed URL for secure image access.
     *
     * @param objectKey the stored key
     * @param expiryMinutes how long the URL is valid
     * return pre-signed HTTPS URL
     */
    String generatePresignedUrl(String objectKey, int expiryMinutes);

    // Generate a unique filename to prevent collisions and hide original names.
    default String generateUniqueFilename(String originalFilename) {
        String extension = originalFilename.substring(originalFilename.lastIndexOf('.'));
        return UUID.randomUUID() + extension;
    }
}