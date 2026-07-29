package com.foodrescue.Backend.service.storage;

import com.foodrescue.Backend.config.ImageConfig;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

/**
 * AWS S3 implementation for production.
 *
 * Uses AWS SDK v2. Activated via Spring profile 'prod'.
 *
 * TODO: Add AWS SDK dependency and implement when moving to production.
 */
@Service
@RequiredArgsConstructor
@Slf4j
@Profile("prod")
public class S3ImageStorageService implements ImageStorageService {

    private final ImageConfig imageConfig;

    @Override
    public String uploadImage(MultipartFile file, String folder) {
        // TODO: Implement with AWS SDK S3Client.putObject()
        throw new UnsupportedOperationException("S3 implementation pending");
    }

    @Override
    public void deleteImage(String objectKey) {
        // TODO: Implement with AWS SDK S3Client.deleteObject()
        throw new UnsupportedOperationException("S3 implementation pending");
    }

    @Override
    public String generatePresignedUrl(String objectKey, int expiryMinutes) {
        // TODO: Implement with AWS SDK S3Presigner
        throw new UnsupportedOperationException("S3 implementation pending");
    }
}