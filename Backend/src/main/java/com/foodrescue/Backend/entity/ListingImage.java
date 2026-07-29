package com.foodrescue.Backend.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "listing_images")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@EqualsAndHashCode(of = "id")
public class ListingImage {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "listing_id", nullable = false)
    private Listing listing;

    // S3/MinIO object key (e.g., "listings/2026/07/uuid.jpg")
    @Column(nullable = false, length = 500)
    private String objectKey;

    // Display order for gallery
    @Column(nullable = false)
    @Builder.Default
    private Integer displayOrder = 0;

    // Optional caption
    @Column(length = 200)
    private String caption;

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime uploadedAt;
}