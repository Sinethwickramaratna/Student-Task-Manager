/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  jakarta.persistence.Column
 *  jakarta.persistence.Entity
 *  jakarta.persistence.FetchType
 *  jakarta.persistence.GeneratedValue
 *  jakarta.persistence.Id
 *  jakarta.persistence.JoinColumn
 *  jakarta.persistence.ManyToOne
 *  jakarta.persistence.Table
 */
package com.sineth.server.model;

import com.sineth.server.model.Role;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name="users")
public class User {
    @Id
    @GeneratedValue
    @Column(name="id", updatable=false, nullable=false)
    private UUID id;
    @Column(name="user_name", unique=true, nullable=false)
    private String username;
    @Column(name="email", unique=true, nullable=false)
    private String email;
    @Column(nullable=false)
    private String password;
    @Column(name="created_at")
    private LocalDate created_at;
    @Column(name="last_login")
    private LocalDate last_login;
    @ManyToOne(fetch=FetchType.EAGER)
    @JoinColumn(name="role_id", nullable=false)
    private Role role;

    public User() {
    }

    public User(String username, String email) {
        this.username = username;
        this.email = email;
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

    public String getPassword() {
        return this.password;
    }

    public LocalDate getCreated_at() {
        return this.created_at;
    }

    public LocalDate getLast_login() {
        return this.last_login;
    }

    public Role getRole() {
        return this.role;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public void setCreated_at(LocalDate created_at) {
        this.created_at = created_at;
    }

    public void setLast_login(LocalDate last_login) {
        this.last_login = last_login;
    }

    public void setRole(Role role) {
        this.role = role;
    }

    public UUID getID() {
        return this.id;
    }

    @Deprecated
    public String getUser_name() {
        return this.username;
    }

    @Deprecated
    public UUID getRoleID() {
        return this.role != null ? this.role.getId() : null;
    }

    @Deprecated
    public void setID(UUID id) {
        this.id = id;
    }

    @Deprecated
    public void setUser_name(String user_name) {
        this.username = user_name;
    }

    @Deprecated
    public void setRoleID(UUID role_id) {
    }
}
