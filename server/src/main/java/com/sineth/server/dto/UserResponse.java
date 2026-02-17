/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  com.fasterxml.jackson.annotation.JsonFormat
 *  com.fasterxml.jackson.annotation.JsonFormat$Shape
 */
package com.sineth.server.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import java.time.LocalDateTime;
import java.util.UUID;

public class UserResponse {
    private UUID id;
    private String username;
    private String email;
    @JsonFormat(shape=JsonFormat.Shape.STRING, pattern="yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime lastLogin;
    @JsonFormat(shape=JsonFormat.Shape.STRING, pattern="yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime createdAt;

    public UserResponse(UUID id, String username, String email, LocalDateTime lastLogin, LocalDateTime createdAt) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.lastLogin = lastLogin;
        this.createdAt = createdAt;
    }

    public UUID getId() {
        return this.id;
    }

    public String getUsername() {
        return this.username;
    }

    public String getEmail() {
        return this.email;
    }

    public LocalDateTime getLastLogin() {
        return this.lastLogin;
    }

    public LocalDateTime getCreatedAt() {
        return this.createdAt;
    }
}
