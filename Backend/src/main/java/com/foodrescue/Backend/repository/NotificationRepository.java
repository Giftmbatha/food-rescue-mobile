package com.foodrescue.Backend.repository;

import com.foodrescue.Backend.entity.Notification;
import com.foodrescue.Backend.entity.NotificationType;
import com.foodrescue.Backend.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, UUID> {

    /**
     * Ge paginated notification history for user.
     * Sorted by createdAt DESC (newest first)
     */
    Page<Notification> findByUserOrderByCreatedAtDesc(User user, Pageable pageable);

    // Get only unread notifications (for badge count, urgent alerts);
    List<Notification> findByUserAndIsReadFalseOrderByCreatedAtDesc(User user);

    // Count unread notifications
    long countByUserAndIsReadFalse(User user);

    // Filter by notification type (e.g., show only CLAIM_APPROVED).
    Page<Notification> findByUserAndTypeOrderByCreatedAtDesc(
            User user, NotificationType type, Pageable pageable);

    // Mark all notifications as read for a user.
    @Modifying
    @Query("UPDATE Notification n SET n.isRead = true, n.readAt = :now " +
            "WHERE n.user = :user AND n.isRead = false")
    void markAllAsRead(@Param("user") User user, @Param("now") LocalDateTime now);

    // Delete old read notifications (cleanup job, optional).
    @Modifying
    @Query("DELETE FROM Notification n WHERE n.isRead = true AND n.readAt < :cutoff")
    void deleteReadOlderThan(@Param("cutoff") LocalDateTime cutoff);

}
