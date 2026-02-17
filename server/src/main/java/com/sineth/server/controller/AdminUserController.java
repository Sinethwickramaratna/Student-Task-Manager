/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.springframework.security.access.prepost.PreAuthorize
 *  org.springframework.web.bind.annotation.GetMapping
 *  org.springframework.web.bind.annotation.RequestMapping
 *  org.springframework.web.bind.annotation.RequestParam
 *  org.springframework.web.bind.annotation.RestController
 */
package com.sineth.server.controller;

import com.sineth.server.dto.UserResponse;
import com.sineth.server.service.AdminUserService;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(value={"/api/admin/users"})
public class AdminUserController {
    private final AdminUserService adminUserService;

    public AdminUserController(AdminUserService adminUserService) {
        this.adminUserService = adminUserService;
    }

    @PreAuthorize(value="hasRole('Admin')")
    @GetMapping
    public Map<String, Object> getUsers(@RequestParam(defaultValue="0") int page, @RequestParam(defaultValue="10") int size, @RequestParam(defaultValue="last_login") String sortBy, @RequestParam(defaultValue="asc") String direction, @RequestParam(required=false, defaultValue="") String search) {
        List<UserResponse> users = this.adminUserService.getUsers(page, size, sortBy, direction, search);
        int totalUsers = this.adminUserService.getTotalUserCount(search);
        HashMap<String, Object> response = new HashMap<String, Object>();
        response.put("users", users);
        response.put("totalUsers", totalUsers);
        response.put("currentPage", page);
        return response;
    }
}
