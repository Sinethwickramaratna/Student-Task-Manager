/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.springframework.http.HttpStatus
 *  org.springframework.http.HttpStatusCode
 *  org.springframework.http.ResponseCookie
 *  org.springframework.http.ResponseEntity
 *  org.springframework.http.ResponseEntity$BodyBuilder
 *  org.springframework.security.crypto.password.PasswordEncoder
 *  org.springframework.web.bind.annotation.PostMapping
 *  org.springframework.web.bind.annotation.RequestBody
 *  org.springframework.web.bind.annotation.RequestMapping
 *  org.springframework.web.bind.annotation.RestController
 */
package com.sineth.server.controller;

import com.sineth.server.dao.UserDao;
import com.sineth.server.dto.LoginRequest;
import com.sineth.server.model.User;
import com.sineth.server.security.JwtUtil;
import java.time.LocalDate;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseCookie;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(value={"/api/auth"})
public class AuthController {
    private final UserDao userDao;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    public AuthController(UserDao userDao, PasswordEncoder passwordEncoder, JwtUtil jwtUtil) {
        this.userDao = userDao;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
    }

    @PostMapping(value={"/login"})
    public ResponseEntity<?> login(@RequestBody LoginRequest loginRequest) {
        boolean passwordValid;
        User user = this.userDao.findByUsername(loginRequest.getUsername_email()).orElseGet(() -> this.userDao.findByEmail(loginRequest.getUsername_email()).orElse(null));
        if (user == null) {
            return ResponseEntity.status((HttpStatusCode)HttpStatus.UNAUTHORIZED).body(Map.of("error", "Invalid username or email"));
        }
        String storedPassword = user.getPassword();
        if (this.isBcryptHash(storedPassword)) {
            passwordValid = this.passwordEncoder.matches((CharSequence)loginRequest.getPassword(), storedPassword);
        } else {
            passwordValid = loginRequest.getPassword().equals(storedPassword);
            if (passwordValid) {
                String newHash = this.passwordEncoder.encode((CharSequence)loginRequest.getPassword());
                this.userDao.updatePassword(user.getId(), newHash);
                user.setPassword(newHash);
            }
        }
        if (!passwordValid) {
            return ResponseEntity.status((HttpStatusCode)HttpStatus.UNAUTHORIZED).body(Map.of("error", "Invalid password"));
        }
        if (user.getRole() == null) {
            return ResponseEntity.status((HttpStatusCode)HttpStatus.UNAUTHORIZED).body(Map.of("error", "User has no assigned role"));
        }
        user.setLast_login(LocalDate.now());
        this.userDao.save(user);
        String token = this.jwtUtil.generateToken(user.getId(), user.getUsername(), user.getEmail(), user.getRole().getRoleName());
        ResponseCookie cookie = ResponseCookie.from((String)"jwt", (String)token).httpOnly(true).path("/").maxAge(86400L).build();
        return ((ResponseEntity.BodyBuilder)ResponseEntity.ok().header("Set-Cookie", new String[]{cookie.toString()})).body(Map.of("message", "Successfully logged in", "token", token, "role", user.getRole().getRoleName()));
    }

    @PostMapping(value={"/logout"})
    public ResponseEntity<?> logout() {
        ResponseCookie cookie = ResponseCookie.from((String)"jwt", (String)"").httpOnly(true).path("/").maxAge(0L).build();
        return ((ResponseEntity.BodyBuilder)ResponseEntity.ok().header("Set-Cookie", new String[]{cookie.toString()})).body(Map.of("message", "Successfully logged out"));
    }

    private boolean isBcryptHash(String value) {
        return value != null && (value.startsWith("$2a$") || value.startsWith("$2b$") || value.startsWith("$2y$"));
    }
}
