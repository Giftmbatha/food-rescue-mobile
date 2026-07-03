package com.foodrescue.backend.repository;

import com.foodrescue.backend.entity.Ngo;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface NgoRepository extends JpaRepository<Ngo, UUID> {

    Optional<Ngo> findByUserId(UUID userId);

    Optional<Ngo> findByOrgNameIgnoreCase(String orgName);

    boolean existsByOrgNameIgnoreCase(String orgName);

    Page<Ngo> findByOrgnameConatainingIgnoreCase(String keyword, Pageable pageable);

    Page<Ngo> findByServiceAreaIgnoreCase(String serviceArea, Pageable pageable);
}