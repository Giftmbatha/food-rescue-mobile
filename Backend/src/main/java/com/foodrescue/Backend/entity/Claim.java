package com.foodrescue.Backend.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "claims")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@EqualsAndHashCode(of = "id")
@ToString(exclude = {"listing", "ngo"})
public class Claim {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID id;

    // The listing being claimed
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "listing_id", nullable = false)
    private Listing listing;

    // The NGO making the claim.
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ngo_id", nullable = false)
    private Ngo ngo;

    // Current state in the claim cycle
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    private ClaimStatus status = ClaimStatus.PENDING;

    // When The NGO plans to collect the food
    @Column(nullable = false)
    private LocalDateTime proposedPickupTime;

    // Message from NGO to donor
    @Column(length = 300)
    private String message;

    // Donor's response message
    @Column(length = 300)
    private String donorResponse;

    // Actual time of pickup completion
    @Column
    private LocalDateTime completedAt;

    // Whether the donor was notified of this claim
    @Column(nullable = false)
    @Builder.Default
    private Boolean donorNotified = false;

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(nullable = false)
    private LocalDateTime updatedAt;

    /**
     * Business method: Approve this claim.
     *
     * Validates state transition before changing.
     *
     * @param donorResponse optional message from donor
     * @throws IllegalStateException if claim is not in PENDING state
     */
    public void approve(String donorResponse) {
        if (this.status != ClaimStatus.PENDING) {
            throw new IllegalStateException("Cannot approve claim state: " + this.status);
        }
        this.status = ClaimStatus.APPROVED;
        this.donorResponse = donorResponse;
    }

    // Business method: mark as reject.
    public void reject() {
        if (this.status != ClaimStatus.PENDING) {
            throw new IllegalStateException("cannot reject claim in state: " + this.status);
        }
        this.status = ClaimStatus.REJECTED;
        this.donorResponse = donorResponse;
    }

    // Business method: Mark as completed.
    public void complete() {
        if (this.status != ClaimStatus.APPROVED) {
            throw new IllegalStateException("Cannot complete claim in state: " + this.status);
        }
        this.status = ClaimStatus.COMPLETED;
        this.completedAt = LocalDateTime.now();
    }

    //Business method: Cancel by NGO.
    public void cancel() {
        if (this.status != ClaimStatus.PENDING) {
            throw new IllegalStateException("Cannot cancel claim in state: " + this.status);
        }
        this.status = ClaimStatus.CANCELLED;
    }
}