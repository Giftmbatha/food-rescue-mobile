package com.foodrescue.Backend.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "listings")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@EqualsAndHashCode(of = "id")
@ToString(exclude = {"donor", "imageUrls"})
public class Listing {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "donor_id", nullable = false)
    private Donor donor;

    // Short searchable title.
    @Column(nullable = false, length = 100)
    private String title;

    @Column(length = 500)
    private String description;

    // Food category for filtering and discovery.
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private FoodCategory category;

    // Estimated weight in kilograms.
    @Column(nullable = false)
    private Double quantityKg;

    // Last date the food is safe to consume.
    @Column(nullable = false)
    private LocalDateTime expiryDate;

    @Column(nullable = false, length = 255)
    private String pickupAddress;

    // Geocoded location for map display and radius search.
    @Column
    private Double pickupLatitude;

    @Column
    private Double pickupLongitude;

    // When the donor is available for pickup.
    @Column(nullable = false, length = 100)
    private String pickupWindow;

    // Current state
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    private ListingStatus status = ListingStatus.AVAILABLE;

    // URLs to uploaded food photos. Max 5 images, each 100 characters = 500 chars + commas
    @Column(length = 1000)
    private String imageUrls;

    // Special instructions for pickup
    @Column(length = 300)
    private String pickupNotes;

    /**
     * Whether the donor allows partial claims.
     *
     * true: Multiple NGOs can claim portions
     * false: All-or-nothing (first claim wins)
     */
    @Column(nullable = false)
    @Builder.Default
    private Boolean allowPartialClaims = false;

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(nullable = false)
    private LocalDateTime updatedAt;

    // Method to add an image URL
    public void addImageUrl(String url) {
        if (this.imageUrls == null || this.imageUrls.isEmpty()) {
            this.imageUrls = url;
        } else {
            this.imageUrls = this.imageUrls + "," + url;
        }
    }

    // Method to get image URL as list
    public java.util.List<String> getImageUrlList() {
        if (this.imageUrls == null || this.imageUrls.isEmpty()) {
            return java.util.List.of();
        }
        return java.util.List.of(this.imageUrls.split(","));
    }
}
