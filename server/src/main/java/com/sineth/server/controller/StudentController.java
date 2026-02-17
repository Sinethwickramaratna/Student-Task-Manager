/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.springframework.http.ResponseEntity
 *  org.springframework.security.access.prepost.PreAuthorize
 *  org.springframework.security.core.Authentication
 *  org.springframework.web.bind.annotation.GetMapping
 *  org.springframework.web.bind.annotation.RequestMapping
 *  org.springframework.web.bind.annotation.RestController
 */
package com.sineth.server.controller;

import java.util.Map;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(value={"/api/student"})
@PreAuthorize(value="hasRole('Student')")
public class StudentController {
    @GetMapping(value={"/dashboard"})
    public ResponseEntity<?> getStudentDashboard(Authentication authentication) {
        return ResponseEntity.ok(Map.of("message", "Welcome Student", "user", authentication.getName(), "role", authentication.getAuthorities()));
    }

    @GetMapping(value={"/tasks"})
    public ResponseEntity<?> getStudentTasks() {
        return ResponseEntity.ok(Map.of("message", "Student task list", "tasks", new Object[0]));
    }
}
