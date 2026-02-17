/*
 * Decompiled with CFR 0.152.
 */
package com.sineth.server.dto;

public class LoginRequest {
    private String username_email;
    private String password;

    public String getUsername_email() {
        return this.username_email;
    }

    public void setUsername_email(String username_email) {
        this.username_email = username_email;
    }

    public String getPassword() {
        return this.password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}
