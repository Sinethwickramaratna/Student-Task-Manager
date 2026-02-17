/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.springframework.jdbc.core.JdbcTemplate
 *  org.springframework.stereotype.Service
 */
package com.sineth.server.service;

import java.util.List;
import java.util.UUID;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import com.sineth.server.dto.UserResponse;

@Service
public class AdminUserService {
    private final JdbcTemplate jdbcTemplate;

    public AdminUserService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<UserResponse> getUsers(int page, int size, String sortBy, String direction, String search) {
        int offset = page * size;
        if (!direction.equalsIgnoreCase("asc") && !direction.equalsIgnoreCase("desc")) {
            direction = "asc";
        }
        String sortColumn = switch (sortBy.toLowerCase()) {
            case "email" -> "email";
            case "last_login" -> "last_login";
            case "created_at" -> "created_at";
            case "username" -> "user_name";
            default -> "last_login";
        };
        
        StringBuilder sql = new StringBuilder("SELECT id, user_name, email, last_login, created_at FROM users");
        if (search != null && !search.isEmpty()) {
            sql.append(" WHERE user_name ILIKE ? OR email ILIKE ?");
        }
        sql.append(" ORDER BY ").append(sortColumn).append(" ").append(direction).append(" LIMIT ? OFFSET ?");
        
        System.out.println("[AdminUserService] Executing query: " + sql.toString());
        try {
            List users;
            if (search != null && !search.isEmpty()) {
                String searchPattern = "%" + search + "%";
                users = this.jdbcTemplate.query(sql.toString(), new Object[]{searchPattern, searchPattern, size, offset}, (rs, rowNum) -> new UserResponse(rs.getObject("id", UUID.class), rs.getString("user_name"), rs.getString("email"), rs.getTimestamp("last_login") != null ? rs.getTimestamp("last_login").toLocalDateTime() : null, rs.getTimestamp("created_at").toLocalDateTime()));
            } else {
                users = this.jdbcTemplate.query(sql.toString(), new Object[]{size, offset}, (rs, rowNum) -> new UserResponse(rs.getObject("id", UUID.class), rs.getString("user_name"), rs.getString("email"), rs.getTimestamp("last_login") != null ? rs.getTimestamp("last_login").toLocalDateTime() : null, rs.getTimestamp("created_at").toLocalDateTime()));
            }
            System.out.println("[AdminUserService] Retrieved " + users.size() + " users");
            return users;
        }
        catch (Exception e) {
            System.err.println("[AdminUserService] Error executing query: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
    }

    public int getTotalUserCount(String search) {
        try {
            String sql = "SELECT COUNT(*) FROM users";
            Integer count;
            if (search != null && !search.isEmpty()) {
                sql += " WHERE user_name ILIKE ? OR email ILIKE ?";
                String searchPattern = "%" + search + "%";
                count = (Integer) this.jdbcTemplate.queryForObject(sql, new Object[]{searchPattern, searchPattern}, Integer.class);
            } else {
                count = (Integer) this.jdbcTemplate.queryForObject(sql, Integer.class);
            }
            System.out.println("[AdminUserService] Total user count: " + count);
            return count != null ? count : 0;
        }
        catch (Exception e) {
            System.err.println("[AdminUserService] Error getting user count: " + e.getMessage());
            e.printStackTrace();
            return 0;
        }
    }
}
