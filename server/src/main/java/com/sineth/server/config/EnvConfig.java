/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  io.github.cdimascio.dotenv.Dotenv
 */
package com.sineth.server.config;

import io.github.cdimascio.dotenv.Dotenv;

public class EnvConfig {
    public static void loadEnv() {
        Dotenv dotenv = Dotenv.configure().ignoreIfMissing().load();
        dotenv.entries().forEach(e -> System.setProperty(e.getKey(), e.getValue()));
    }
}
