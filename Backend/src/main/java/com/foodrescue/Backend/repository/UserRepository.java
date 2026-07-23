package com.foodrescue.Backend.repository;

import com.foodrescue.Backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface UserRepository extends JpaRepository<User, UUID>{

    /**
     * Find user by email address.
     *
     * Spring Data JPA parses the method name and generates:
     * SELECT * FROM users WHERE email = ?
     *
     * Return type Optional<User> avoids null checks in service layer.
     * Optional forces the caller to handle "not found" explicitly.
     * */
    Optional<User> findByEmail(String email);

    /**
     * Check if email already exists.
     *
     * Generated query: SELECT COUNT(*) FROM users WHERE email = ?
     * Returns boolean — efficient, doesn't load the full entity.
     */
    boolean existsByEmail(String email);

    @Query("SELECT u FROM User u WHERE u.email = :email")
    Optional<User> findByEmailCustom(@Param("email") String email);

    Optional<User> findByEmailAndIsActiveTrue(String email);
}