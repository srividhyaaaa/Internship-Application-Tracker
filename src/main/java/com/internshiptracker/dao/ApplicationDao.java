package com.internshiptracker.dao;

import com.internshiptracker.config.Database;
import com.internshiptracker.model.Application;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class ApplicationDao {
    private static final String SELECT_FIELDS =
            "SELECT id, company_name, role_name, deadline, priority, status, application_link "
                    + "FROM applications";

    public List<Application> findAll() throws SQLException {
        List<Application> applications = new ArrayList<Application>();
        String sql = SELECT_FIELDS + " ORDER BY deadline ASC, updated_at DESC, id DESC";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {
            while (resultSet.next()) {
                applications.add(readApplication(resultSet));
            }
        }
        return applications;
    }

    public Application findById(long id) throws SQLException {
        String sql = SELECT_FIELDS + " WHERE id = ?";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, id);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() ? readApplication(resultSet) : null;
            }
        }
    }

    public void insert(Application application) throws SQLException {
        String sql = "INSERT INTO applications "
                + "(company_name, role_name, deadline, priority, status, application_link) "
                + "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            bindApplication(statement, application);
            statement.executeUpdate();
        }
    }

    public boolean update(Application application) throws SQLException {
        String sql = "UPDATE applications SET company_name = ?, role_name = ?, deadline = ?, "
                + "priority = ?, status = ?, application_link = ? WHERE id = ?";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            bindApplication(statement, application);
            statement.setLong(7, application.getId());
            if (statement.executeUpdate() > 0) {
                return true;
            }
        }
        return exists(application.getId());
    }

    public boolean delete(long id) throws SQLException {
        String sql = "DELETE FROM applications WHERE id = ?";
        try (Connection connection = Database.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, id);
            return statement.executeUpdate() > 0;
        }
    }

    private boolean exists(long id) throws SQLException {
        try (Connection connection = Database.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement("SELECT 1 FROM applications WHERE id = ?")) {
            statement.setLong(1, id);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    private void bindApplication(PreparedStatement statement, Application application)
            throws SQLException {
        statement.setString(1, application.getCompanyName());
        statement.setString(2, application.getRole());
        statement.setDate(3, Date.valueOf(LocalDate.parse(application.getDeadline())));
        statement.setString(4, application.getPriority());
        statement.setString(5, application.getStatus());
        statement.setString(6, application.getApplicationLink());
    }

    private Application readApplication(ResultSet resultSet) throws SQLException {
        Application application = new Application();
        application.setId(resultSet.getLong("id"));
        application.setCompanyName(resultSet.getString("company_name"));
        application.setRole(resultSet.getString("role_name"));
        application.setDeadline(resultSet.getDate("deadline").toLocalDate().toString());
        application.setPriority(resultSet.getString("priority"));
        application.setStatus(resultSet.getString("status"));
        application.setApplicationLink(resultSet.getString("application_link"));
        return application;
    }
}
