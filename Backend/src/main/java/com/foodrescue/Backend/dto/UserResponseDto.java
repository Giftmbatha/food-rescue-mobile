package com.foodrescue.Backend.dto;

import com.foodrescue.Backend.entity.User;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
public class UserResponseDto {

    private UUID id;
    private String email;
    private User.Role role;
    private String fullName;
    private String phone;
    private Boolean isActive;
    private LocalDateTime createdAt;
}