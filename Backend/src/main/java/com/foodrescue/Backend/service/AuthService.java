package com.foodrescue.Backend.service;

import com.foodrescue.Backend.dto.*;
import com.foodrescue.Backend.entity.User;
import com.foodrescue.Backend.repository.UserRepository;
import com.foodrescue.Backend.security.JwtService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;

    // Register a new user.
    @Transactional
    public UserResponseDto register(UserRegistrationDto dto) {
        if (userRepository.existsByEmail(dto.getEmail())) {
            throw new IllegalArgumentException("Email already registered: " + dto.getEmail());
        }

        if (dto.getRole() == User.Role.ADMIN) {
            throw new IllegalArgumentException("Invalid role for self-registration");
        }

        User user = User.builder()
                .email(dto.getEmail().toLowerCase().trim())
                .password(passwordEncoder.encode(dto.getPassword()))
                .role(dto.getRole())
                .fullName(dto.getFullName().trim())
                .phone(dto.getPhone() != null ? dto.getPhone().trim() : null)
                .isActive(true)
                .build();

        User saved = userRepository.save(user);
        log.info("User registered: {}", saved.getId());

        return mapToUserResponse(saved);
    }

    // Authenticate and issue tokens.
    public AuthResponseDto login(LoginRequestDto dto) {
        // Spring Security validates credentials
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        dto.getEmail().toLowerCase().trim(),
                        dto.getPassword()
                )
        );

        if (!authentication.isAuthenticated()) {
            throw new BadCredentialsException("Invalid credentials");
        }

        User user = userRepository.findByEmail(dto.getEmail().toLowerCase().trim())
                .orElseThrow(() -> new BadCredentialsException("User not found"));

        String accessToken = jwtService.generateAccessToken(user.getEmail(), user.getRole().name());
        String refreshToken = jwtService.generateRefreshToken(user.getEmail());

        log.info("User logged in: {}", user.getEmail());

        return AuthResponseDto.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .expiresIn(900L) // 15 minutes in seconds
                .user(mapToUserResponse(user))
                .build();
    }

    // Refresh access token using valid refresh token.
    public AuthResponseDto refresh(String refreshToken) {
        // Validate refresh token
        if (!jwtService.isTokenValid(refreshToken)) {
            throw new IllegalArgumentException("Invalid or expired refresh token");
        }

        String email = jwtService.extractEmail(refreshToken);

        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        // Issue new access token (refresh token remains valid until its own expiry)
        String newAccessToken = jwtService.generateAccessToken(user.getEmail(), user.getRole().name());

        log.info("Token refreshed for: {}", email);

        return AuthResponseDto.builder()
                .accessToken(newAccessToken)
                .refreshToken(refreshToken) // Return same refresh token
                .tokenType("Bearer")
                .expiresIn(900L)
                .user(mapToUserResponse(user))
                .build();
    }

    private UserResponseDto mapToUserResponse(User user) {
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