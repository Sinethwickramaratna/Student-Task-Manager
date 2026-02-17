/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.springframework.security.core.GrantedAuthority
 *  org.springframework.security.core.authority.SimpleGrantedAuthority
 *  org.springframework.security.core.userdetails.UserDetails
 */
package com.sineth.server.security;

import java.util.Collection;
import java.util.List;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

public class UserPrincipal
implements UserDetails {
    private final String username;
    private final String password;
    private final String role;

    public UserPrincipal(String username, String password, String role) {
        this.username = username;
        this.password = password;
        this.role = role;
        System.out.println("UserPrincipal created for " + username + " with role: " + role);
    }

    public Collection<? extends GrantedAuthority> getAuthorities() {
        Object roleWithPrefix = this.role.startsWith("ROLE_") ? this.role : "ROLE_" + this.role;
        System.out.println("Getting authorities for " + this.username + ": " + (String)roleWithPrefix);
        return List.of(new SimpleGrantedAuthority((String)roleWithPrefix));
    }

    public String getPassword() {
        return this.password;
    }

    public String getUsername() {
        return this.username;
    }

    public boolean isAccountNonExpired() {
        return true;
    }

    public boolean isAccountNonLocked() {
        return true;
    }

    public boolean isCredentialsNonExpired() {
        return true;
    }

    public boolean isEnabled() {
        return true;
    }
}
