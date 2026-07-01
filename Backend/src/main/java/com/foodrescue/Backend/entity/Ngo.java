package com.foodrescue.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "ngos")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@EqualsAndHashCode(of = "id")
@ToString
public class Ngo {

    @Id
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @MapsId
    @JoinColumn(name = "id")
    private User user;

    @Column(nullable = false, length = 100)
    private String orgName;

    /**
     * Official NPO registration number for verification
     */
    @Column(length = 50)
    private String regNumber;

    @Column(nullable = false, length = 255)
    private String address;

    @Column(precision = 10, scale = 8)
    private Double latitude;

    @Column(precision = 10, scale = 8)
    private Double logitude;

    @Column(length = 100)
    private String contactPerson;

    /**
     * Geographic area served (e.g., "Cape Town Metro", "Khayelitsha").
     * Used for filtering relevant listings.
     */
    @Column(length = 100)
    private String serviceArea;

    @Column(precision = 2, scale = 1)
    @Builder.Default
    private Double ratingAvg = 0.0;

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(nullable = false)
    private LocalDateTime updatedAt;
}