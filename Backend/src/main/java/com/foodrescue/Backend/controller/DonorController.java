package com.foodrescue.Backend.controller;

import com.foodrescue.Backend.dto.DonorProfileDto;
import com.foodrescue.Backend.dto.DonorStatsDto;
import com.foodrescue.Backend.entity.User;
import com.foodrescue.Backend.service.CurrentUserService;
import com.foodrescue.Backend.service.DonorService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/donors")
@RequiredArgsConstructor
@Slf4j
public class DonorController {

    private final DonorService donorService;
    private final CurrentUserService currentUserService;

    /**
     * Get public donor profile.
     * No auth — shown in listing detail to build trust.
     */
    @GetMapping("/{id}")
    public ResponseEntity<DonorProfileDto> getProfile(@PathVariable UUID id) {
        return ResponseEntity.ok(donorService.getProfile(id));
    }

    // Get current donor's profile.
    @GetMapping("/me")
    @PreAuthorize("hasRole('DONOR')")
    public ResponseEntity<DonorProfileDto> getMyProfile() {
        return ResponseEntity.ok(donorService.getMyProfile());
    }

    // Update donor profile.
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('DONOR')")
    public ResponseEntity<DonorProfileDto> updateProfile(
            @PathVariable UUID id,
            @Valid @RequestBody DonorProfileDto dto) {
        return ResponseEntity.ok(donorService.updateProfile(id, dto));
    }

    // Get donor impact statistics.
    @GetMapping("/{id}/stats")
    public ResponseEntity<DonorStatsDto> getStats(@PathVariable UUID id) {
        return ResponseEntity.ok(donorService.getStats(id));
    }

    // Get my stats.
    @GetMapping("/me/stats")
    @PreAuthorize("hasRole('DONOR')")
    public ResponseEntity<DonorStatsDto> getMyStats() {
        User currentUser = currentUserService.getCurrentUser(); // Inject if needed
        return ResponseEntity.ok(donorService.getStats(currentUser.getId()));
    }
}