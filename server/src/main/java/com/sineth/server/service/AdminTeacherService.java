package com.sineth.server.service;

import java.util.List;
import java.util.UUID;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import com.sineth.server.dto.TeacherResponse;

@Service
public class AdminTeacherService {
  private final JdbcTemplate jdbcTemplate;

  public AdminTeacherService(JdbcTemplate jdbcTemplate) {
    this.jdbcTemplate = jdbcTemplate;
  }

  public List<TeacherResponse> getTeachers(int page, int size, String sortBy, String direction, String search) {
    int offset = page * size;
    if (!direction.equalsIgnoreCase("asc") && !direction.equalsIgnoreCase("desc")) {
      direction = "asc";
    }
    String sortColumn = switch (sortBy.toLowerCase()) {
      case "first_name" -> "f_name";
      case "last_name" -> "l_name";
      case "gender" -> "gender";
      case "birth_date" -> "birthdate";
      case "user_id" -> "user_id";
      default -> "id";
    };
    
    StringBuilder sql = new StringBuilder("SELECT id, f_name, l_name, gender, birthdate, user_id, profile_picture FROM teachers");
    if (search != null && !search.isEmpty()) {
      sql.append(" WHERE f_name ILIKE ? OR l_name ILIKE ? OR user_id ILIKE ?");
    }
    sql.append(" ORDER BY ").append(sortColumn).append(" ").append(direction).append(" LIMIT ? OFFSET ?");
    
    System.out.println("[AdminTeacherService] Executing query: " + sql.toString());
    try {
      List<TeacherResponse> teachers;
      if (search != null && !search.isEmpty()) {
        String searchPattern = "%" + search + "%";
        teachers = this.jdbcTemplate.query(
            sql.toString(),
            (rs, rowNum) -> new TeacherResponse(
                rs.getObject("id", UUID.class),
                rs.getString("f_name"),
                rs.getString("l_name"),
                rs.getString("gender"),
                rs.getTimestamp("birthdate").toLocalDateTime(),
                rs.getString("user_id"),
                rs.getString("profile_picture")
            ),
            searchPattern,
            searchPattern,
            searchPattern,
            size,
            offset
        );
      } else {
        teachers = this.jdbcTemplate.query(
            sql.toString(),
            (rs, rowNum) -> new TeacherResponse(
                rs.getObject("id", UUID.class),
                rs.getString("f_name"),
                rs.getString("l_name"),
                rs.getString("gender"),
                rs.getTimestamp("birthdate").toLocalDateTime(),
                rs.getString("user_id"),
                rs.getString("profile_picture")
            ),
            size,
            offset
        );
      }
      System.out.println("[AdminTeacherService] Retrieved " + teachers.size() + " teachers");
      return teachers;
    }
    catch (Exception e) {
      System.err.println("[AdminTeacherService] Error executing query: " + e.getMessage());
      e.printStackTrace();
      throw e; 
    }
  }

  public int getTotalTeacherCount(String search) {
    try {
        String sql = "SELECT COUNT(*) FROM teachers";
        Integer count;
        if (search != null && !search.isEmpty()) {
          sql += " WHERE f_name ILIKE ? OR l_name ILIKE ?";
          String searchPattern = "%" + search + "%";
          count = this.jdbcTemplate.queryForObject(sql, Integer.class, searchPattern, searchPattern);
        } else {
          count = this.jdbcTemplate.queryForObject(sql, Integer.class);
        }
        System.out.println("[AdminTeacherService] Total teacher count: " + count);
        return count != null ? count : 0;
    }
    catch (Exception e) {
        System.err.println("[AdminTeacherService] Error getting teacher count: " + e.getMessage());
        e.printStackTrace();
        return 0;
    }
  }
  
}
