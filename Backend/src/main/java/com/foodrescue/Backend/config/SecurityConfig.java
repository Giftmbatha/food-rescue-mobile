package com.foodrescue.Backend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {
    /**
     * BCrypt password encoder bean.
     *
     * BCrypt automatically generates a salt and incorporates it into the hash.
     * Strength 10 (default): ~100ms to hash on modern hardware.
     * Higher strength = more secure but slower.
     *
     * @Bean exposes this as a Spring-managed singleton, injectable anywhere.
     */
    @Bean
    public PasswordEncoder passwordEncoder(){
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                //Disable CSRF for stateless API (we use JWT, not sessions)
                .csrf(AbstractHttpConfigurer::disable)
                // Permiy all requests during development
                .authorizeHttpRequests(auth -> auth.anyRequest().permitAll());
        return http.build();
    }
}