
package com.interntrack;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL JDBC driver is missing.", e);
        }

        String username = System.getenv("INTERNTRACK_DB_USER");
        String password = System.getenv("INTERNTRACK_DB_PASSWORD");

        if (username == null || password == null) {
            throw new SQLException("Database environment variables are not configured.");
        }

        return DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/interntrack",
            username,
            password
        );
    }
}
