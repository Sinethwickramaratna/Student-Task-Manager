/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  io.jsonwebtoken.Claims
 *  io.jsonwebtoken.JwtException
 *  io.jsonwebtoken.Jwts
 *  io.jsonwebtoken.SignatureAlgorithm
 *  io.jsonwebtoken.security.Keys
 *  org.springframework.beans.factory.annotation.Value
 *  org.springframework.security.core.userdetails.UserDetails
 *  org.springframework.stereotype.Component
 */
package com.sineth.server.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import java.security.Key;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

@Component
public class JwtUtil {
    @Value(value="${app.secret-key:your-secret-key-here}")
    private String SECRET_KEY;
    private static final long EXPIRATION_TIME = 86400000L;

    public String generateToken(UUID user_id, String user_name, String email, String role_name) {
        HashMap<String, Object> claims = new HashMap<String, Object>();
        claims.put("user_id", user_id);
        claims.put("user_name", user_name);
        claims.put("email", email);
        claims.put("role_name", role_name);
        return this.createToken(claims, user_name);
    }

    private String createToken(Map<String, Object> claims, String subject) {
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + 86400000L);
        return Jwts.builder().setClaims(claims).setSubject(subject).setIssuedAt(now).setExpiration(expiryDate).signWith((Key)Keys.hmacShaKeyFor((byte[])this.SECRET_KEY.getBytes()), SignatureAlgorithm.HS256).compact();
    }

    public String extractUsername(String token) {
        try {
            String username = ((Claims)Jwts.parserBuilder().setSigningKey((Key)Keys.hmacShaKeyFor((byte[])this.SECRET_KEY.getBytes())).build().parseClaimsJws(token).getBody()).getSubject();
            System.out.println("[JwtUtil] Successfully extracted username: " + username);
            return username;
        }
        catch (JwtException | IllegalArgumentException e) {
            System.err.println("[JwtUtil] Error extracting username: " + e.getMessage());
            return null;
        }
    }

    public boolean validateToken(String token, UserDetails userDetails) {
        try {
            String username = this.extractUsername(token);
            boolean isValid = username != null && username.equals(userDetails.getUsername()) && !this.isTokenExpired(token);
            System.out.println("[JwtUtil] Token validation for " + userDetails.getUsername() + ": " + isValid);
            return isValid;
        }
        catch (JwtException | IllegalArgumentException e) {
            System.err.println("[JwtUtil] Token validation error: " + e.getMessage());
            return false;
        }
    }

    private boolean isTokenExpired(String token) {
        try {
            Date expiration = ((Claims)Jwts.parserBuilder().setSigningKey((Key)Keys.hmacShaKeyFor((byte[])this.SECRET_KEY.getBytes())).build().parseClaimsJws(token).getBody()).getExpiration();
            return expiration.before(new Date());
        }
        catch (JwtException | IllegalArgumentException e) {
            return true;
        }
    }

    public Claims getAllClaims(String token) {
        try {
            return (Claims)Jwts.parserBuilder().setSigningKey((Key)Keys.hmacShaKeyFor((byte[])this.SECRET_KEY.getBytes())).build().parseClaimsJws(token).getBody();
        }
        catch (JwtException | IllegalArgumentException e) {
            return null;
        }
    }
}
