package com.foodrescue.Backend.service;

import com.foodrescue.Backend.dto.NgoProfileDto;
import com.foodrescue.Backend.dto.NgoStatsDto;
import com.foodrescue.Backend.entity.ClaimStatus;
import com.foodrescue.Backend.entity.Ngo;
import com.foodrescue.Backend.entity.User;
import com.foodrescue.Backend.repository.ClaimRepository;
import com.foodrescue.Backend.repository.NgoRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class NgoService {

    private final NgoRepository ngoRepository;
    private final ClaimRepository claimRepository;
    private final CurrentUserService currentUserService;

    @Transactional(readOnly = true)
    public NgoProfileDto getProfile(UUID ngoId) {
        Ngo ngo = ngoRepository.findById(ngoId)
                .orElseThrow(() -> new IllegalArgumentException("NGO not found: " + ngoId));
        return mapToProfileDto(ngo);
    }

    @Transactional(readOnly = true)
    public NgoProfileDto getMyProfile() {
        User currentUser = currentUserService.getCurrentUser();
        if (currentUser.getRole() != User.Role.NGO) {
            throw new IllegalStateException("Only NGOs have NGO profiles");
        }
        Ngo ngo = ngoRepository.findById(currentUser.getId())
                .orElseThrow(() -> new IllegalArgumentException("NGO profile not found"));
        return mapToProfileDto(ngo);
    }

    @Transactional
    public NgoProfileDto updateProfile(UUID ngoId, NgoProfileDto dto) {
        User currentUser = currentUserService.getCurrentUser();

        if (currentUser.getRole() != User.Role.NGO || !currentUser.getId().equals(ngoId)) {
            throw new IllegalStateException("You can only update your own profile");
        }

        Ngo ngo = ngoRepository.findById(ngoId)
                .orElseThrow(() -> new IllegalArgumentException("NGO not found: " + ngoId));

        ngo.setOrgName(dto.getOrgName());
        ngo.setRegNumber(dto.getRegNumber());
        ngo.setAddress(dto.getAddress());
        ngo.setLatitude(dto.getLatitude());
        ngo.setLongitude(dto.getLongitude());
        ngo.setContactPerson(dto.getContactPerson());
        ngo.setServiceArea(dto.getServiceArea());
        ngo.setPhone(dto.getPhone());

        Ngo saved = ngoRepository.save(ngo);
        log.info("NGO profile updated: {}", ngoId);

        return mapToProfileDto(saved);
    }

    @Transactional(readOnly = true)
    public NgoStatsDto getStats(UUID ngoId) {
        Ngo ngo = ngoRepository.findById(ngoId)
                .orElseThrow(() -> new IllegalArgumentException("NGO not found: " + ngoId));

        long totalClaims = claimRepository.countByNgoId(ngoId);
        long pendingClaims = claimRepository.countByNgoIdAndStatus(ngoId, ClaimStatus.PENDING);
        long approvedClaims = claimRepository.countByNgoIdAndStatus(ngoId, ClaimStatus.APPROVED);
        long completedPickups = claimRepository.countByNgoIdAndStatus(ngoId, ClaimStatus.COMPLETED);

        // Sum quantity from completed claims
        Double totalKg = claimRepository.sumQuantityKgByNgoIdAndStatus(ngoId, ClaimStatus.COMPLETED);

        return NgoStatsDto.builder()
                .ngoId(ngoId)
                .orgName(ngo.getOrgName())
                .totalClaims((int) totalClaims)
                .pendingClaims((int) pendingClaims)
                .approvedClaims((int) approvedClaims)
                .completedPickups((int) completedPickups)
                .totalKgReceived(totalKg != null ? totalKg : 0.0)
                .averageRating(ngo.getRatingAvg())
                .ratingCount(0) // TODO: Implement rating system
                .build();
    }

    private NgoProfileDto mapToProfileDto(Ngo ngo) {
        return NgoProfileDto.builder()
                .id(ngo.getId())
                .userId(ngo.getUser().getId())
                .orgName(ngo.getOrgName())
                .regNumber(ngo.getRegNumber())
                .address(ngo.getAddress())
                .latitude(ngo.getLatitude())
                .longitude(ngo.getLongitude())
                .contactPerson(ngo.getContactPerson())
                .serviceArea(ngo.getServiceArea())
                .phone(ngo.getPhone())
                .ratingAvg(ngo.getRatingAvg())
                .build();
    }
}