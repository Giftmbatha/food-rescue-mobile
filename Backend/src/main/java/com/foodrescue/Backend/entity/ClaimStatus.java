package com.foodrescue.Backend.entity;

/**
 * Lifecycle states for a food claim.
 *
 * State transitions:
 * PENDING → APPROVED (donor accepts)
 * PENDING → REJECTED (donor declines or no response)
 * PENDING → CANCELLED (NGO withdraws)
 * APPROVED → COMPLETED (food collected)
 * APPROVED → EXPIRED (pickup window passed, no show)
 *
 * PENDING is the only state where the NGO can cancel.
 * Once APPROVED, the claim is binding (though may expire).
 */

public enum ClaimStatus {
    PENDING,
    APPROVED,
    REJECTED,
    CANCELLED,
    COMPLETED,
    EXPIRED
}
