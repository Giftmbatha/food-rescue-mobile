package com.foodrescue.Backend.service;

import com.foodrescue.Backend.config.RabbitConfig;
import com.foodrescue.Backend.dto.NotificationResponseDto;
import com.foodrescue.Backend.entity.Notification;
import com.foodrescue.Backend.entity.NotificationType;
import com.foodrescue.Backend.entity.User;
import com.foodrescue.Backend.event.NotificationEvent;
import com.foodrescue.Backend.event.NotificationEventType;
import com.foodrescue.Backend.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final CurrentUserService currentUserService;
    private final RabbitTemplate rabbitTemplate;

    /**
     * Create and persist an in-app notification.
     * Also publishes event to RabbitMQ for push delivery.
     * <p>
     * This is the main entry point — business services call this,
     * not RabbitMQ directly, to ensure in-app notification is always saved.
     */
    @Transactional
    public void createNotification(
            User recipient,
            NotificationType type,
            String title,
            String body,
            Map<String, String> dataPayload) {

        // Truncate body to 200 chars for push compatibility
        String truncatedBody = body.length() > 200 ? body.substring(0, 197) + "..." : body;

        Notification notification = Notification.builder()
                .user(recipient)
                .type(type)
                .title(title)
                .body(truncatedBody)
                .dataPayload(dataPayload != null ? toJson(dataPayload) : null)
                .build();

        Notification saved = notificationRepository.save(notification);
        log.info("In-app notification created: {} for user {}", saved.getId(), recipient.getId());

        // Publish async event for push notification
        NotificationEvent event = NotificationEvent.builder()
                .eventType(mapToEventType(type))
                .recipientUserId(recipient.getId())
                .title(title)
                .body(truncatedBody)
                .notificationType(type)
                .dataPayload(dataPayload)
                .relatedEntityId(extractEntityId(dataPayload))
                .build();

        rabbitTemplate.convertAndSend(
                RabbitConfig.NOTIFICATION_EXCHANGE,
                "notification." + type.name().toLowerCase(),
                event
        );

        log.info("Notification event published to RabbitMQ: {}", event.getEventType());

    }

    // Get paginated notification history for current user.
    @Transactional(readOnly = true)
    public Page<NotificationResponseDto> getMyNotifications(Pageable pageable) {
        User currentUser = currentUserService.getCurrentUser();
        return notificationRepository.findByUserOrderByCreatedAtDesc(currentUser, pageable)
                .map(this::mapToDto);
    }

    // Get unread notification count (for app badge).
    @Transactional(readOnly = true)
    public long getUnreadCount() {
        User currentUser = currentUserService.getCurrentUser();
        return notificationRepository.countByUserAndIsReadFalse(currentUser);
    }

    // Mark single notification as read.
    @Transactional
    public NotificationResponseDto markAsRead(UUID notificationId) {
        User currentUser = currentUserService.getCurrentUser();

        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new IllegalArgumentException("Notification not found: " + notificationId));

        if (!notification.getUser().getId().equals(currentUser.getId())) {
            throw new IllegalStateException("You can only mark your own notifications as read");
        }

        notification.markAsRead();
        return mapToDto(notificationRepository.save(notification));
    }

    // Mark all notifications as read (e.g., "Mark all read" button).
    @Transactional
    public void markAllAsRead() {
        User currentUser = currentUserService.getCurrentUser();
        notificationRepository.markAllAsRead(currentUser, LocalDateTime.now());
        log.info("All notifications marked as read for user: {}", currentUser.getId());
    }

    // --- Helper methods ---

    private NotificationResponseDto mapToDto(Notification n) {
        return NotificationResponseDto.builder()
                .id(n.getId())
                .type(n.getType())
                .title(n.getTitle())
                .body(n.getBody())
                .isRead(n.getIsRead())
                .pushDelivered(n.getPushDelivered())
                .dataPayload(n.getDataPayload())
                .createdAt(n.getCreatedAt())
                .readAt(n.getReadAt())
                .build();
    }

    private String toJson(Map<String, String> map) {
        try {
            return new tools.jackson.databind.ObjectMapper().writeValueAsString(map);
        } catch (Exception e) {
            log.warn("Failed to serialize notification payload", e);
            return null;
        }
    }

    private NotificationEventType mapToEventType(NotificationType type) {
        return switch (type) {
            case NEW_LISTING -> NotificationEventType.NEW_LISTING_CREATED;
            case CLAIM_RECEIVED -> NotificationEventType.CLAIM_SUBMITTED;
            case CLAIM_APPROVED -> NotificationEventType.CLAIM_APPROVED;
            case CLAIM_REJECTED -> NotificationEventType.CLAIM_REJECTED;
            case PICKUP_REMINDER -> NotificationEventType.PICKUP_REMINDER;
            case LISTING_EXPIRED -> NotificationEventType.LISTING_EXPIRED;
            case SYSTEM_MESSAGE -> NotificationEventType.SYSTEM_MESSAGE;
        };
    }

    private UUID extractEntityId(Map<String, String> payload) {
        if (payload == null) return null;
        String id = payload.get("claimId");
        if (id == null) id = payload.get("listingId");
        if (id == null) id = payload.get("userId");
        return id != null ? UUID.fromString(id) : null;
    }
}