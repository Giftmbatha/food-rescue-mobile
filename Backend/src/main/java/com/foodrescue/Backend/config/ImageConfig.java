package com.foodrescue.Backend.config;


import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Getter
@Setter
@Configuration
@ConfigurationProperties(prefix = "image")
public class ImageConfig {

    private String storage = "minio"; // "minio" or "S3"
    private int maxSizeMb = 5;
    private List<String> allowedTypes = List.of("image/jpeg", "image/png", "image/webp");
    private String bucket = "foodrescue-images";

    @Getter
    @Setter
    public static class minioConfig {
        private String endpoint = "http://localhost:9000";
        private String accessKey = "minioadmin";
        private String secretKey = "minioadmin";
    }

    private minioConfig minio = new minioConfig();
}