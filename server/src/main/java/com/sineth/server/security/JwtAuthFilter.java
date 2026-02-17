/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  jakarta.servlet.FilterChain
 *  jakarta.servlet.ServletException
 *  jakarta.servlet.ServletRequest
 *  jakarta.servlet.ServletResponse
 *  jakarta.servlet.http.HttpServletRequest
 *  jakarta.servlet.http.HttpServletResponse
 *  org.springframework.security.authentication.UsernamePasswordAuthenticationToken
 *  org.springframework.security.core.Authentication
 *  org.springframework.security.core.context.SecurityContextHolder
 *  org.springframework.security.core.userdetails.UserDetails
 *  org.springframework.security.web.authentication.WebAuthenticationDetailsSource
 *  org.springframework.stereotype.Component
 *  org.springframework.web.filter.OncePerRequestFilter
 */
package com.sineth.server.security;

import com.sineth.server.security.CustomUserDetailsService;
import com.sineth.server.security.JwtUtil;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

@Component
public class JwtAuthFilter
extends OncePerRequestFilter {
    private final JwtUtil jwtUtil;
    private final CustomUserDetailsService userDetailsService;

    public JwtAuthFilter(JwtUtil jwtUtil, CustomUserDetailsService userDetailsService) {
        this.jwtUtil = jwtUtil;
        this.userDetailsService = userDetailsService;
    }

    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        block7: {
            String header = request.getHeader("Authorization");
            this.logger.debug((Object)("Auth Header: " + header));
            if (header != null && header.startsWith("Bearer ")) {
                String token = header.substring(7);
                String username = this.jwtUtil.extractUsername(token);
                this.logger.debug((Object)("Extracted username from JWT: " + username));
                if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                    try {
                        UserDetails userDetails = this.userDetailsService.loadUserByUsername(username);
                        this.logger.debug((Object)("Loaded user: " + userDetails.getUsername() + ", Authorities: " + userDetails.getAuthorities()));
                        if (this.jwtUtil.validateToken(token, userDetails)) {
                            UsernamePasswordAuthenticationToken auth = new UsernamePasswordAuthenticationToken((Object)userDetails, null, userDetails.getAuthorities());
                            auth.setDetails((Object)new WebAuthenticationDetailsSource().buildDetails(request));
                            SecurityContextHolder.getContext().setAuthentication((Authentication)auth);
                            this.logger.debug((Object)("Authentication set for user: " + username));
                            break block7;
                        }
                        this.logger.debug((Object)("Token validation failed for user: " + username));
                    }
                    catch (Exception e) {
                        this.logger.debug((Object)("Could not set user authentication in security context: " + e.getMessage()));
                    }
                } else {
                    this.logger.debug((Object)"Username is null or authentication is already set");
                }
            } else {
                this.logger.debug((Object)"No Authorization header with Bearer token found");
            }
        }
        filterChain.doFilter((ServletRequest)request, (ServletResponse)response);
    }
}
