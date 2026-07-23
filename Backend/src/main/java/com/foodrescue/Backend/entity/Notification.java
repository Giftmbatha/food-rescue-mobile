package com.foodrescue.Backend.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "notifications")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@EqualsAndHashCode(of = "id")
@ToString(exclude = "user")
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID id;

    // Recipient of the notification
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    // Category determines the icon, sound, and routing
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private NotificationType type;

    // Short title for push notification header
    @Column(nullable = false, length = 100)
    private String title;

    /**
     * Body text for push and in-app display.
     *
     * Max 200 characters for push compatibility (iOS limit).
     */
    @Column(nullable = false, length = 200)
    private String body;

    @Column(nullable = false)
    @Builder.Default
    private Boolean isRead = false;

    // Whether push notification was delivered successfully
    @Column(nullable = false)
    @Builder.Default
    private Boolean pushDelivered = false;

    // JSON payload for deep linking and action routing
    @Column(length = 500)
    private String dataPayload;

    // When the notification was created. Also serve as "sent at" timestamp
    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    // When the user marked it as read. Null until isRed become true
    @Column
    private LocalDateTime readAt;

    // Mark this notification as read
    public void markAsRead() {
        if (!this.isRead) {
            this.isRead = true;
            this.readAt = LocalDateTime.now();
        }
    }
}
