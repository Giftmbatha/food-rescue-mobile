package com.foodrescue.Backend.service;

import com.foodrescue.Backend.dto.UserRegistrationDto;
import com.foodrescue.Backend.dto.UserResponseDto;
import com.foodrescue.Backend.entity.User;
import com.foodrescue.Backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

/**
 * Service for user management operations.
 *
 * @Service: Marks this as a Spring-managed bean, eligible for dependency injection.
 * @RequiredArgsConstructor: Lombok generates a constructor with all final fields.
 *   Spring injects dependencies through this constructor (recommended over @Autowired).
 * @Slf4j: Provides a logger instance named "log" for structured logging.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class UserService {

    /**
     * Dependencies injected via constructor by Spring.
     *
     * final: Ensures immutability — reference cannot change after construction.
     * This guarantees the service always has its dependencies.
     */
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    /**
     * Register a new user.
     *
     * @Transactional: Ensures atomicity. If any step fails, the entire transaction rolls back.
     *   - User creation and any related profile creation succeed or fail together
     *   - Prevents partial data (user exists but profile doesn't)
     *
     * readOnly = false (default): This method writes to the database.
     */
    @Transactional
    public UserResponseDto register(UserRegistrationDto dto) {
        log.info("Registering new user with email: {}", dto.getEmail());

        // Defensive validation: Check for existing email before any database write
        if (userRepository.existsByEmail(dto.getEmail())) {
            log.warn("Registration failed: Email already exists: {}", dto.getEmail());
            throw new IllegalArgumentException("Email already registered");
        }

        // Validate role: Only DONOR and NGO can self-register
        // ADMIN is reserved for system administrators
        if (dto.getRole() == User.Role.ADMIN) {
            log.warn("Registration failed: Attempted self-registration as ADMIN");
            throw new IllegalArgumentException("Invalid role for self-registration");
        }

        // Build entity from DTO
        // Builder pattern: Clean, readable, immutable until assignment
        User user = User.builder()
                .email(dto.getEmail().toLowerCase().trim()) // Normalize: case-insensitive emails
                .password(passwordEncoder.encode(dto.getPassword())) // BCrypt hash
                .role(dto.getRole())
                .fullName(dto.getFullName().trim())
                .phone(dto.getPhone() != null ? dto.getPhone().trim() : null)
                .isActive(true)
                .build();

        // Persist to database
        // save() returns the managed entity with generated ID and timestamps
        User savedUser = userRepository.save(user);

        log.info("User registered successfully: id={}, email={}", savedUser.getId(), savedUser.getEmail());

        // Map entity to response DTO
        // Never return the entity directly — controlled exposure
        return mapToResponseDto(savedUser);
    }

    /**
     * Find user by email.
     *
     * @Transactional(readOnly = true): Optimizes performance.
     *   - No dirty checking (Hibernate doesn't track changes)
     *   - No flush at transaction end
     *   - Database may use read optimization
     */
    @Transactional(readOnly = true)
    public Optional<UserResponseDto> findByEmail(String email) {
        return userRepository.findByEmail(email.toLowerCase().trim())
                .map(this::mapToResponseDto);
    }

    /**
     * Private helper method to map User entity to UserResponseDto.
     *
     * Single Responsibility: Centralizes mapping logic.
     * If the DTO structure changes, only this method updates.
     */
    private UserResponseDto mapToResponseDto(User user) {
        return UserResponseDto.builder()
                .id(user.getId())
                .email(user.getEmail())
                .role(user.getRole())
                .fullName(user.getFullName())
                .phone(user.getPhone())
                .isActive(user.getIsActive())
                .createdAt(user.getCreatedAt())
                .build();
    }
}