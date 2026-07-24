package com.foodrescue.Backend.listener;

import com.foodrescue.Backend.config.RabbitConfig;
import com.foodrescue.Backend.entity.Notification;
import com.foodrescue.Backend.event.NotificationEvent;
import com.foodrescue.Backend.repository.NotificationRepository;
import com.foodrescue.Backend.service.PushNotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

/**
 * RabbitMQ consumer for notification events.
 *
 * Runs asynchronously from the main API thread.
 * Handles: push notification delivery, updating delivery status.
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class NotificationListener {

    private final PushNotificationService pushNotificationService;
    private final NotificationRepository notificationRepository;

    @RabbitListener(queues = RabbitConfig.NOTIFICATION_QUEUE)
    public void handleNotificationEvent(NotificationEvent event) {
        log.info("Received notification event: {} for user {}",
                event.getEventType(), event.getRecipientUserId());

        try {
            // Attempt push delivery
            boolean delivered = pushNotificationService.sendPushNotification(event);

            // Update notification record with delivery status
            // We need to find the notification by related entity + user
            // For now, we track delivery separately or update the latest
            log.info("Push notification delivery result: {}", delivered);

        } catch (Exception e) {
            log.error("Failed to process notification event: {}", event.getEventType(), e);
            // Message will be retried or moved to DLQ based on RabbitMQ config
            throw e; // Re-throw to trigger retry/DLQ
        }
    }
}