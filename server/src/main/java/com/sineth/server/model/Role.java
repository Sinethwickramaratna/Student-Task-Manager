/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  jakarta.persistence.Column
 *  jakarta.persistence.Entity
 *  jakarta.persistence.GeneratedValue
 *  jakarta.persistence.Id
 *  jakarta.persistence.Table
 */
package com.sineth.server.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.util.UUID;

@Entity
@Table(name="Roles")
public class Role {
    @Id
    @GeneratedValue
    @Column(name="id", updatable=false, nullable=false)
    private UUID id;
    @Column(name="role_name", unique=true, nullable=false)
    private String roleName;

    public Role() {
    }

    public Role(String roleName) {
        this.roleName = roleName;
    }

    public UUID getId() {
        return this.id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getRoleName() {
        return this.roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }

    @Deprecated
    public String getRole_name() {
        return this.roleName;
    }

    @Deprecated
    public void setRole_name(String role_name) {
        this.roleName = role_name;
    }
}
