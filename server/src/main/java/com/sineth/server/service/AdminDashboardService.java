/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.springframework.stereotype.Service
 */
package com.sineth.server.service;

import com.sineth.server.dao.AdminDashboardDao;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Service;

@Service
public class AdminDashboardService {
    private final AdminDashboardDao adminDashboardDao;

    public AdminDashboardService(AdminDashboardDao adminDashboardDao) {
        this.adminDashboardDao = adminDashboardDao;
    }

    public Map<String, Object> dashboard() {
        HashMap<String, Object> response = new HashMap<String, Object>();
        try {
            response.put("stats", this.adminDashboardDao.getStats());
        }
        catch (Exception e) {
            response.put("stats", Map.of("error", "Stats view not found"));
        }
        try {
            response.put("usersByRole", this.adminDashboardDao.usersByRole());
        }
        catch (Exception e) {
            response.put("usersByRole", List.of());
        }
        try {
            response.put("studentsByGrade", this.adminDashboardDao.studentsByGrade());
        }
        catch (Exception e) {
            response.put("studentsByGrade", List.of());
        }
        try {
            response.put("taskCompletion", this.adminDashboardDao.taskCompletion());
        }
        catch (Exception e) {
            response.put("taskCompletion", Map.of("error", "Task completion view not found"));
        }
        try {
            response.put("auditLogs", this.adminDashboardDao.auditLogs());
        }
        catch (Exception e) {
            response.put("auditLogs", List.of());
        }
        return response;
    }
}
