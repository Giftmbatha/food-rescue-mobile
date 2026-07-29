package com.foodrescue.Backend.dto;

import com.foodrescue.Backend.entity.NotificationType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationResponseDto {
    private UUID id;
    private NotificationType type;
    private String title;
    private String body;
    private Boolean isRead;
    private Boolean pushDelivered;
    private String dataPayload;
    private LocalDateTime createdAt;
    private LocalDateTime readAt;
}