/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.springframework.jdbc.core.JdbcTemplate
 *  org.springframework.stereotype.Repository
 */
package com.sineth.server.dao;

import java.util.List;
import java.util.Map;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class AdminDashboardDao {
    private final JdbcTemplate jdbcTemplate;

    public AdminDashboardDao(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public Map<String, Object> getStats() {
        return this.jdbcTemplate.queryForMap("SELECT * FROM admin_dashboard_stats");
    }

    public List<Map<String, Object>> usersByRole() {
        return this.jdbcTemplate.queryForList("SELECT * FROM admin_users_by_role");
    }

    public List<Map<String, Object>> studentsByGrade() {
        return this.jdbcTemplate.queryForList("SELECT * FROM admin_students_by_grade");
    }

    public Map<String, Object> taskCompletion() {
        return this.jdbcTemplate.queryForMap("SELECT * FROM admin_task_completion");
    }

    public List<Map<String, Object>> auditLogs() {
        return this.jdbcTemplate.queryForList("SELECT a.*,u.user_name\nFROM audit_logs a\nLEFT JOIN users u ON a.user_id = u.id\nORDER BY created_at DESC\nLIMIT 50\n");
    }
}
