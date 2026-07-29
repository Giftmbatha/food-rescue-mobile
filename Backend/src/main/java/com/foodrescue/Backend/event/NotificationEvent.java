package com.foodrescue.Backend.event;

import com.foodrescue.Backend.entity.NotificationType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;
import java.util.UUID;


/**
 * Domain event for notification system.
 *
 * Published to RabbitMQ by business services (ClaimService, ListingService).
 * Consumed by NotificationListener to send push + persist in-app.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationEvent {
    private NotificationEventType eventType;
    private UUID recipientUserId;   // Who gets notified
    private String title;   // Push notification title
    private String body;    // Push notification body
    private NotificationType notificationType;  // Category for UI routing
    private Map<String, String> dataPayload;    // Deep link data (JSON-serialized)
    private UUID relatedEntityId;   // Claim ID, Listing ID etc. for routing
}

