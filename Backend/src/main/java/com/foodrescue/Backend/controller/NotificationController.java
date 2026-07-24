package com.foodrescue.Backend.controller;

import com.foodrescue.Backend.dto.NotificationResponseDto;
import com.foodrescue.Backend.service.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

/**
 * REST endpoints for in-app notifications.
 *
 * Push notifications are handled asynchronously via RabbitMQ.
 * This controller only serves the in-app notification center.
 */
@RestController
@RequestMapping("/api/v1/notifications")
@RequiredArgsConstructor
@Slf4j
public class NotificationController {

    private final NotificationService notificationService;

    /**
     * Get paginated notification history.
     * Default: 20 items, newest first.
     */
    @GetMapping
    public ResponseEntity<Page<NotificationResponseDto>> getNotifications(
            @PageableDefault(size = 20, sort = "createdAt", direction = Sort.Direction.DESC)
            Pageable pageable) {

        log.info("Fetching notifications for current user");
        return ResponseEntity.ok(notificationService.getMyNotifications(pageable));
    }

    // Get unread count for app badge.
    @GetMapping("/unread-count")
    public ResponseEntity<Map<String, Long>> getUnreadCount() {
        long count = notificationService.getUnreadCount();
        return ResponseEntity.ok(Map.of("count", count));
    }

    // Mark single notification as read.
    @PutMapping("/{id}/read")
    public ResponseEntity<NotificationResponseDto> markAsRead(@PathVariable UUID id) {
        log.info("Marking notification as read: {}", id);
        return ResponseEntity.ok(notificationService.markAsRead(id));
    }

    // Mark all notifications as read.
    @PutMapping("/read-all")
    public ResponseEntity<Void> markAllAsRead() {
        log.info("Marking all notifications as read");
        notificationService.markAllAsRead();
        return ResponseEntity.noContent().build();
    }
}