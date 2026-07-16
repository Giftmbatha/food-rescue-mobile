package com.foodrescue.Backend.entity;

/**
 * Lifecycle states for a food listing.
 *
 * State transitions:
 * AVAILABLE → CLAIMED (NGO claims)
 * AVAILABLE → EXPIRED (time passes, no claim)
 * CLAIMED → COMPLETED (donor confirms pickup)
 * CLAIMED → AVAILABLE (donor rejects claim, rare)
 *
 * EXPIRED and COMPLETED are terminal states.
 */

public enum ListingStatus {
    AVAILABLE, // Active
    CLAIMED, // NGO has claimed, awaiting pickup
    EXPIRED, // Past expiry date, no longer edible
    COMPLETED // Food successfully collected

}
