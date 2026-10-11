package com.internshiptracker.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public final class Database {
    private static final String DEFAULT_URL =
            "jdbc:mysql://localhost:3306/internship_tracker?useSSL=false&serverTimezone=UTC";

    private Database() {
    }

    public static Connection getConnection() throws SQLException {
        String url = setting("DB_URL", DEFAULT_URL);
        String username = setting("DB_USER", null);
        String password = System.getenv("DB_PASSWORD");
        if (username == null || password == null) {
            throw new SQLException("DB_USER and DB_PASSWORD must be configured.");
        }
        return DriverManager.getConnection(url, username, password);
    }

    private static String setting(String name, String defaultValue) {
        String value = System.getenv(name);
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }
        return value.trim();
    }
}
