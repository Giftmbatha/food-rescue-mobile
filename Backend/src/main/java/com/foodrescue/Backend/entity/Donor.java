package com.foodrescue.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "donors")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@EqualsAndHashCode(of = "id")
@ToString
public class Donor {

    /**
     * Shared primary key with User.
     *
     * MapsId tells JPA: "use the user's ID as my ID."
     * No @GeneratedVlaue needed - the ID comes from user
     */
    @Id
    private UUID id;

   @OneToOne(fetch = FetchType.LAZY)
    @MapsId
    @JoinColumn(name = "id")
    private User user;

   @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private OrgType orgType;

   @Column(nullable = false, length = 255)
    private String address;

    /**
     * Geolocation for map displays and raduis search.
     *
     * Precision: 8 decimal places = ∼1.1mm accuracy.
     * sufficient for building-level pickup locations
     */
    @Column(precision = 10, scale = 8)
    private Double latitude;

    @Column(precision = 10, scale = 8)
    private Double longitude;

    @Column(length = 100)
    private String contactPerson;

    @Column(precision = 2, scale = 1)
    @Builder.Default
    private Double ratingAvg = 0.0;

    @CreationTimestamp
    @Column(nullable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(nullable = false)
    private LocalDateTime updatedAt;

    public enum OrgType {
        SUPERMARKET,
        RESTURANT,
        BAKERY,
        HOTEL,
        CATERING,
        FARM,
        SURPLIER,
        OTHER
    }
}