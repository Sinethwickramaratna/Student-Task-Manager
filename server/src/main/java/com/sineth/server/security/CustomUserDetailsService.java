/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.springframework.security.core.userdetails.UserDetails
 *  org.springframework.security.core.userdetails.UserDetailsService
 *  org.springframework.security.core.userdetails.UsernameNotFoundException
 *  org.springframework.stereotype.Service
 */
package com.sineth.server.security;

import com.sineth.server.dao.UserDao;
import com.sineth.server.model.User;
import com.sineth.server.security.UserPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
public class CustomUserDetailsService
implements UserDetailsService {
    private final UserDao userDao;

    public CustomUserDetailsService(UserDao userDao) {
        this.userDao = userDao;
    }

    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        System.out.println("[CustomUserDetailsService] Loading user: " + username);
        User user = this.userDao.findByUsername(username).orElseThrow(() -> {
            System.err.println("[CustomUserDetailsService] User not found: " + username);
            return new UsernameNotFoundException("User not found: " + username);
        });
        String roleName = user.getRole() != null ? user.getRole().getRoleName() : "NO_ROLE";
        System.out.println("[CustomUserDetailsService] User " + username + " has role: " + roleName);
        UserPrincipal principal = new UserPrincipal(user.getUsername(), user.getPassword(), roleName);
        System.out.println("[CustomUserDetailsService] Created UserPrincipal with authorities: " + principal.getAuthorities());
        return principal;
    }
}
