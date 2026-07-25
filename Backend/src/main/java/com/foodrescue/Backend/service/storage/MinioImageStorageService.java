package com.foodrescue.Backend.service.storage;

import com.foodrescue.Backend.config.ImageConfig;
import io.minio.*;
import io.minio.http.Method;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.concurrent.TimeUnit;

/**
 * MinIO implementation for local development.
 *
 * Runs in Docker (see docker-compose.yml). API-compatible with AWS S3,
 * so switching to production S3 is a config change, not code change.
 */
@Service
@RequiredArgsConstructor
@Slf4j
@Profile({"dev", "default"})
public class MinioImageStorageService implements ImageStorageService {

    private final ImageConfig imageConfig;
    private MinioClient minioClient;

    @PostConstruct
    public void init() {
        this.minioClient = MinioClient.builder()
                .endpoint(imageConfig.getMinio().getEndpoint())
                .credentials(imageConfig.getMinio().getAccessKey(), imageConfig.getMinio().getSecretKey())
                .build();

        ensureBucketExists();
    }

    private void ensureBucketExists() {
        try {
            boolean exists = minioClient.bucketExists(
                    BucketExistsArgs.builder().bucket(imageConfig.getBucket()).build());
            if (!exists) {
                minioClient.makeBucket(
                        MakeBucketArgs.builder().bucket(imageConfig.getBucket()).build());
                log.info("Created MinIO bucket: {}", imageConfig.getBucket());
            }
        } catch (Exception e) {
            throw new RuntimeException("Failed to initialize MinIO bucket", e);
        }
    }

    @Override
    public String uploadImage(MultipartFile file, String folder) {
        String filename = generateUniqueFilename(file.getOriginalFilename());
        String objectKey = folder != null ? folder + filename : filename;

        try {
            minioClient.putObject(
                    PutObjectArgs.builder()
                            .bucket(imageConfig.getBucket())
                            .object(objectKey)
                            .stream(file.getInputStream(), file.getSize(), -1)
                            .contentType(file.getContentType())
                            .build()
            );
            log.info("Uploaded image to MinIO: {}", objectKey);
            return objectKey;
        } catch (Exception e) {
            throw new RuntimeException("Failed to upload image to MinIO", e);
        }
    }

    @Override
    public void deleteImage(String objectKey) {
        try {
            minioClient.removeObject(
                    RemoveObjectArgs.builder()
                            .bucket(imageConfig.getBucket())
                            .object(objectKey)
                            .build()
            );
            log.info("Deleted image from MinIO: {}", objectKey);
        } catch (Exception e) {
            throw new RuntimeException("Failed to delete image from MinIO", e);
        }
    }

    @Override
    public String generatePresignedUrl(String objectKey, int expiryMinutes) {
        try {
            return minioClient.getPresignedObjectUrl(
                    GetPresignedObjectUrlArgs.builder()
                            .method(Method.GET)
                            .bucket(imageConfig.getBucket())
                            .object(objectKey)
                            .expiry(expiryMinutes, TimeUnit.MINUTES)
                            .build()
            );
        } catch (Exception e) {
            throw new RuntimeException("Failed to generate pre-signed URL", e);
        }
    }
}