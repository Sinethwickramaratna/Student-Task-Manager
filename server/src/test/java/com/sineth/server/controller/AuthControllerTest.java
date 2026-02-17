package com.sineth.server.controller;

import static org.junit.jupiter.api.Assertions.assertTrue;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class AuthControllerTest {

    @Test
    void testApplicationContextLoads() {
        // This test verifies that the Spring Boot application context can be loaded
        // without errors
        assertTrue(true, "Application context loaded successfully");
    }

    @Test
    void authControllerClassExists() {
        // Verify the AuthController class exists
        try {
            Class.forName("com.sineth.server.controller.AuthController");
            assertTrue(true, "AuthController class found");
        } catch (ClassNotFoundException e) {
            throw new AssertionError("AuthController class not found", e);
        }
    }
}