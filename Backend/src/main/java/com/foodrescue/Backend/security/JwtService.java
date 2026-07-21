package com.foodrescue.Backend.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.util.Date;
import java.util.UUID;

/**
 * Service for JWT token operations.
 *
 * Handles generation, validation, and parsing of access and refresh tokens.
 *
 * Token structure:
 * - Header: algorithm (HS256) and type (JWT)
 * - Payload: subject (userId), role, issuedAt, expiration
 * - Signature: HMAC-SHA256 of header + payload
 */
@Service
@Slf4j
public class JwtService {

    private final SecretKey secretKey;
    private final long accessTokenExpiration;
    private final long refreshTokenExpiration;

    /**
     * Constructor with configuration injection.
     *
     * @Value reads from application.yml or environment variables.
     */
    public JwtService(
            @Value("${app.jwt.secret}") String secret,
            @Value("${app.jwt.access-token-expiration-ms}") long accessTokenExpiration,
            @Value("${app.jwt.refresh-token-expiration-ms}") long refreshTokenExpiration) {

        // Decode Base64 secret or use raw bytes if not Base64
        byte[] keyBytes = Decoders.BASE64.decode(secret);
        this.secretKey = Keys.hmacShaKeyFor(keyBytes);
        this.accessTokenExpiration = accessTokenExpiration;
        this.refreshTokenExpiration = refreshTokenExpiration;
    }

    /**
     * Generate access token for authenticated user.
     *
     * Short-lived (15 min) — used for API requests.
     */
    public String generateAccessToken(String email, String role) {
        return buildToken(email, role, accessTokenExpiration);
    }

    /**
     * Generate refresh token for session renewal.
     *
     * Long-lived (7 days) — used to get new access tokens.
     * Stored securely on mobile device.
     */
    public String generateRefreshToken(String email) {
        return buildToken(email, null, refreshTokenExpiration);
    }

    /**
     * Core token builder.
     */
    private String buildToken(String email, String role, long expirationMs) {
        Date now = new Date();
        Date expiry = new Date(now.getTime() + expirationMs);

        JwtBuilder builder = Jwts.builder()
                .subject(email)
                .issuedAt(now)
                .expiration(expiry)
                .signWith(secretKey, Jwts.SIG.HS256);

        if (role != null) {
            builder.claim("role", role);
        }

        return builder.compact();
    }

    /**
     * Extract user email from token.
     *
     * @throws JwtException if token is invalid or expired
     */
    public String extractEmail(String token) {
        return parseClaims(token).getSubject();
    }

    /**
     * Extract role from token.
     */
    public String extractRole(String token) {
        return parseClaims(token).get("role", String.class);
    }

    /**
     * Validate token: signature correct and not expired.
     */
    public boolean isTokenValid(String token) {
        try {
            parseClaims(token);
            return true;
        } catch (ExpiredJwtException e) {
            log.warn("Token expired: {}", e.getMessage());
            return false;
        } catch (JwtException e) {
            log.warn("Invalid token: {}", e.getMessage());
            return false;
        }
    }

    /**
     * Check if token is expired.
     */
    public boolean isTokenExpired(String token) {
        try {
            parseClaims(token);
            return false;
        } catch (ExpiredJwtException e) {
            return true;
        }
    }

    /**
     * Parse and validate token claims.
     */
    private Claims parseClaims(String token) {
        return Jwts.parser()
                .verifyWith(secretKey)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }
}
