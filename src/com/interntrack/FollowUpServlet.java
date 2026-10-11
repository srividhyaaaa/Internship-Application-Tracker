package com.interntrack;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/followups")
public class FollowUpServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        int userId = ((Number) session.getAttribute("userId")).intValue();

        try (Connection con = DBConnection.getConnection()) {
            String editId = trim(request.getParameter("edit"));
            if (!editId.isEmpty()) {
                int id;
                try {
                    id = parseId(editId);
                } catch (NumberFormatException e) {
                    response.sendRedirect(request.getContextPath() + "/followups?error=invalid");
                    return;
                }
                String sql = "SELECT follow_up_id, description, due_date, notes, completed " +
                        "FROM follow_ups WHERE follow_up_id = ? AND user_id = ?";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, id);
                    ps.setInt(2, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            response.sendRedirect(request.getContextPath() + "/followups?error=notfound");
                            return;
                        }
                        Map<String, String> followUp = new HashMap<>();
                        followUp.put("id", String.valueOf(rs.getInt("follow_up_id")));
                        followUp.put("description", rs.getString("description"));
                        followUp.put("dueDate", rs.getDate("due_date").toLocalDate().toString());
                        followUp.put("notes", nullToEmpty(rs.getString("notes")));
                        followUp.put("completed", String.valueOf(rs.getBoolean("completed")));
                        request.setAttribute("editingFollowUp", followUp);
                    }
                }
            }

            List<Map<String, String>> followUps = new ArrayList<>();
            LocalDate today = LocalDate.now();
            String listSql = "SELECT follow_up_id, description, due_date, notes, completed " +
                    "FROM follow_ups WHERE user_id = ? " +
                    "ORDER BY completed ASC, due_date ASC, follow_up_id DESC";
            try (PreparedStatement ps = con.prepareStatement(listSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, String> followUp = new HashMap<>();
                        followUp.put("id", String.valueOf(rs.getInt("follow_up_id")));
                        followUp.put("description", rs.getString("description"));
                        followUp.put("dueDate", rs.getDate("due_date").toLocalDate().toString());
                        followUp.put("notes", nullToEmpty(rs.getString("notes")));
                        followUp.put("completed", String.valueOf(rs.getBoolean("completed")));
                        addDeadlineStatus(followUp, today);
                        followUps.add(followUp);
                    }
                }
            }
            request.setAttribute("followUps", followUps);
            request.getRequestDispatcher("/followups.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Unable to load follow-ups.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        int userId = ((Number) session.getAttribute("userId")).intValue();
        String action = trim(request.getParameter("action"));
        String redirect = request.getContextPath() + "/followups";

        try (Connection con = DBConnection.getConnection()) {
            if ("delete".equals(action)) {
                int id = parseId(request.getParameter("id"));
                try (PreparedStatement ps = con.prepareStatement(
                        "DELETE FROM follow_ups WHERE follow_up_id = ? AND user_id = ?")) {
                    ps.setInt(1, id);
                    ps.setInt(2, userId);
                    if (ps.executeUpdate() == 0) {
                        response.sendRedirect(redirect + "?error=notfound");
                        return;
                    }
                }
                response.sendRedirect(redirect + "?deleted=1");
                return;
            }
            if ("toggle".equals(action)) {
                int id = parseId(request.getParameter("id"));
                String completedValue = trim(request.getParameter("completed"));
                if (!"true".equals(completedValue) && !"false".equals(completedValue)) {
                    response.sendRedirect(redirect + "?error=invalid");
                    return;
                }
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE follow_ups SET completed = ? WHERE follow_up_id = ? AND user_id = ?")) {
                    ps.setBoolean(1, Boolean.parseBoolean(completedValue));
                    ps.setInt(2, id);
                    ps.setInt(3, userId);
                    if (ps.executeUpdate() == 0) {
                        response.sendRedirect(redirect + "?error=notfound");
                        return;
                    }
                }
                response.sendRedirect(redirect + "?updated=1");
                return;
            }
            if (!"save".equals(action)) {
                response.sendRedirect(redirect + "?error=invalid");
                return;
            }

            String description = trim(request.getParameter("description"));
            String dueDateValue = trim(request.getParameter("dueDate"));
            String notes = trim(request.getParameter("notes"));
            if (description.isEmpty() || description.length() > 255 || notes.length() > 5000) {
                response.sendRedirect(redirect + "?error=invalid");
                return;
            }
            LocalDate dueDate;
            try {
                dueDate = LocalDate.parse(dueDateValue);
            } catch (DateTimeParseException e) {
                response.sendRedirect(redirect + "?error=invalid");
                return;
            }

            String idText = trim(request.getParameter("id"));
            if (idText.isEmpty()) {
                String sql = "INSERT INTO follow_ups (user_id, description, due_date, notes) " +
                        "VALUES (?, ?, ?, ?)";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, userId);
                    ps.setString(2, description);
                    ps.setDate(3, Date.valueOf(dueDate));
                    setOptionalText(ps, 4, notes);
                    ps.executeUpdate();
                }
                response.sendRedirect(redirect + "?added=1");
                return;
            }

            int id = parseId(idText);
            String sql = "UPDATE follow_ups SET description = ?, due_date = ?, notes = ? " +
                    "WHERE follow_up_id = ? AND user_id = ?";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, description);
                ps.setDate(2, Date.valueOf(dueDate));
                setOptionalText(ps, 3, notes);
                ps.setInt(4, id);
                ps.setInt(5, userId);
                if (ps.executeUpdate() == 0) {
                    response.sendRedirect(redirect + "?error=notfound");
                    return;
                }
            }
            response.sendRedirect(redirect + "?updated=1");
        } catch (IllegalArgumentException e) {
            response.sendRedirect(redirect + "?error=invalid");
        } catch (SQLException e) {
            throw new ServletException("Unable to save follow-up.", e);
        }
    }

    private int parseId(String value) {
        int id = Integer.parseInt(value);
        if (id < 1) {
            throw new NumberFormatException("ID must be positive.");
        }
        return id;
    }

    private void setOptionalText(PreparedStatement ps, int index, String value) throws SQLException {
        if (value.isEmpty()) {
            ps.setNull(index, Types.VARCHAR);
        } else {
            ps.setString(index, value);
        }
    }

    private void addDeadlineStatus(Map<String, String> followUp, LocalDate today) {
        if ("true".equals(followUp.get("completed"))) {
            followUp.put("deadlineLabel", "Completed");
            followUp.put("deadlineClass", "deadline-completed");
            return;
        }
        long daysRemaining = ChronoUnit.DAYS.between(today, LocalDate.parse(followUp.get("dueDate")));
        if (daysRemaining < 0) {
            followUp.put("deadlineLabel", "Overdue");
            followUp.put("deadlineClass", "deadline-overdue");
        } else if (daysRemaining <= 3) {
            followUp.put("deadlineLabel", daysRemaining == 0 ? "Due today" : "Due soon");
            followUp.put("deadlineClass", "deadline-soon");
        } else {
            followUp.put("deadlineLabel", "In " + daysRemaining + " days");
            followUp.put("deadlineClass", "deadline-normal");
        }
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private String nullToEmpty(String value) {
        return value == null ? "" : value;
    }
}
