package com.sineth.server.controller;

import com.sineth.server.dto.TeacherResponse;
import com.sineth.server.service.AdminTeacherService;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(value={"/api/admin/teachers"})
public class AdminTeacherController {
  private final AdminTeacherService adminTeacherService;

  public AdminTeacherController(AdminTeacherService adminTeacherService) {
    this.adminTeacherService = adminTeacherService;
  }

  @GetMapping
  @PreAuthorize("hasRole('Admin')")
  public Map<String, Object> getTeachers(
      @RequestParam(defaultValue = "0") int page,
      @RequestParam(defaultValue = "10") int size,
      @RequestParam(defaultValue = "id") String sortBy,
      @RequestParam(defaultValue = "asc") String direction,
      @RequestParam(required = false, defaultValue = "") String search) {
    List<TeacherResponse> teachers = this.adminTeacherService.getTeachers(page, size, sortBy, direction, search);
    int totalTeachers = this.adminTeacherService.getTotalTeacherCount(search);
    Map<String, Object> response = new HashMap<>();
    response.put("teachers", teachers);
    response.put("totalTeachers", totalTeachers);
    response.put("currentPage", page);
    return response;
  }
}
