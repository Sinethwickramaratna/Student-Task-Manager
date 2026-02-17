/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.springframework.jdbc.core.JdbcTemplate
 *  org.springframework.stereotype.Repository
 */
package com.sineth.server.dao;

import com.sineth.server.dao.RoleDao;
import com.sineth.server.model.Role;
import com.sineth.server.model.User;
import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class UserDao {
    private final JdbcTemplate jdbcTemplate;
    private final RoleDao roleDao;

    public UserDao(JdbcTemplate jdbcTemplate, RoleDao roleDao) {
        this.jdbcTemplate = jdbcTemplate;
        this.roleDao = roleDao;
    }

    public Optional<User> findByUsername(String user_name) {
        String sql = "SELECT * FROM users WHERE user_name = ?";
        try {
            User user = (User)this.jdbcTemplate.queryForObject(sql, (rs, rowNum) -> {
                User u = new User();
                u.setId(rs.getObject("id", UUID.class));
                u.setUsername(rs.getString("user_name"));
                u.setEmail(rs.getString("email"));
                u.setPassword(rs.getString("password"));
                u.setCreated_at(rs.getObject("created_at", LocalDate.class));
                u.setLast_login(rs.getObject("last_login", LocalDate.class));
                UUID roleId = rs.getObject("role_id", UUID.class);
                if (roleId != null) {
                    Optional<Role> role = this.roleDao.getRole(roleId);
                    role.ifPresent(u::setRole);
                }
                return u;
            }, new Object[]{user_name});
            return Optional.of(user);
        }
        catch (Exception e) {
            return Optional.empty();
        }
    }

    public Optional<User> findByEmail(String email) {
        String sql = "SELECT * FROM users WHERE email = ?";
        try {
            User user = (User)this.jdbcTemplate.queryForObject(sql, (rs, rowNum) -> {
                User u = new User();
                u.setId(rs.getObject("id", UUID.class));
                u.setUsername(rs.getString("user_name"));
                u.setEmail(rs.getString("email"));
                u.setPassword(rs.getString("password"));
                u.setCreated_at(rs.getObject("created_at", LocalDate.class));
                u.setLast_login(rs.getObject("last_login", LocalDate.class));
                UUID roleId = rs.getObject("role_id", UUID.class);
                if (roleId != null) {
                    Optional<Role> role = this.roleDao.getRole(roleId);
                    role.ifPresent(u::setRole);
                }
                return u;
            }, new Object[]{email});
            return Optional.of(user);
        }
        catch (Exception e) {
            return Optional.empty();
        }
    }

    public void updateLastLogin(UUID id) {
        String sql = "UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE id = ?";
        this.jdbcTemplate.update(sql, new Object[]{id});
    }

    public void save(User user) {
        String sql = "UPDATE users SET last_login = ? WHERE id = ?";
        this.jdbcTemplate.update(sql, new Object[]{user.getLast_login(), user.getId()});
    }

    public void updatePassword(UUID id, String hashedPassword) {
        String sql = "UPDATE users SET password = ? WHERE id = ?";
        this.jdbcTemplate.update(sql, new Object[]{hashedPassword, id});
    }
}
