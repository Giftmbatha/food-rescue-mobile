package com.foodrescue.Backend.controller;

import com.foodrescue.Backend.dto.NgoProfileDto;
import com.foodrescue.Backend.dto.NgoStatsDto;
import com.foodrescue.Backend.entity.User;
import com.foodrescue.Backend.service.CurrentUserService;
import com.foodrescue.Backend.service.NgoService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/ngos")
@RequiredArgsConstructor
@Slf4j
public class NgoController {

    private final NgoService ngoService;
    private final CurrentUserService currentUserService;

    @GetMapping("/{id}")
    public ResponseEntity<NgoProfileDto> getProfile(@PathVariable UUID id) {
        return ResponseEntity.ok(ngoService.getProfile(id));
    }

    @GetMapping("/me")
    @PreAuthorize("hasRole('NGO')")
    public ResponseEntity<NgoProfileDto> getMyProfile() {
        return ResponseEntity.ok(ngoService.getMyProfile());
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('NGO')")
    public ResponseEntity<NgoProfileDto> updateProfile(
            @PathVariable UUID id,
            @Valid @RequestBody NgoProfileDto dto) {
        return ResponseEntity.ok(ngoService.updateProfile(id, dto));
    }

    @GetMapping("/{id}/stats")
    public ResponseEntity<NgoStatsDto> getStats(@PathVariable UUID id) {
        return ResponseEntity.ok(ngoService.getStats(id));
    }

    @GetMapping("/me/stats")
    @PreAuthorize("hasRole('NGO')")
    public ResponseEntity<NgoStatsDto> getMyStats() {
        User currentUser = currentUserService.getCurrentUser();
        return ResponseEntity.ok(ngoService.getStats(currentUser.getId()));
    }
}