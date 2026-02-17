/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.springframework.jdbc.core.JdbcTemplate
 *  org.springframework.stereotype.Repository
 */
package com.sineth.server.dao;

import com.sineth.server.model.Role;
import java.util.Optional;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class RoleDao {
    private final JdbcTemplate jdbcTemplate;

    public RoleDao(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public Optional<Role> getRole(UUID id) {
        String sql = "select * from roles where id = ?";
        try {
            Role role = (Role)this.jdbcTemplate.queryForObject(sql, (rs, rowNum) -> {
                Role r = new Role();
                r.setId(rs.getObject("id", UUID.class));
                r.setRoleName(rs.getString("role_name"));
                return r;
            }, new Object[]{id});
            return Optional.of(role);
        }
        catch (Exception e) {
            return Optional.empty();
        }
    }
}
