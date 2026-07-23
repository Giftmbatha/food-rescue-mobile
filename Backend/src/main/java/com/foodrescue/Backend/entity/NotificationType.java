package com.foodrescue.Backend.entity;


/**
 * Categories of notifications for filtering and routing.
 *
 * Determines push notification icon, sound, and priority.
 */
public enum NotificationType {
    NEW_LISTING,        // Donor posted food nearby
    CLAIM_RECEIVED,     // NGO claimed your listing
    CLAIM_APPROVED,     // Donor approved your claim
    CLAIM_REJECTED,     // Donor declined your claim
    PICKUP_REMINDER,    // Claimed food, pickup window approaching
    LISTING_EXPIRED,    // Your listing passed expiry date
    SYSTEM_MESSAGE      // Admin announcements, policy updates
}
