
package com.interntrack;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/interviews")
public class InterviewServlet extends HttpServlet {

    private static final DateTimeFormatter FORMATTER =
            DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
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
                    id = Integer.parseInt(editId);
                } catch (NumberFormatException e) {
                    response.sendRedirect(
                            request.getContextPath() + "/interviews?error=invalid");
                    return;
                }

                String editSql =
                        "SELECT interview_id, company, position, interview_date, " +
                        "interview_type, location, notes, status " +
                        "FROM interviews WHERE interview_id = ? AND user_id = ?";

                try (PreparedStatement ps = con.prepareStatement(editSql)) {
                    ps.setInt(1, id);
                    ps.setInt(2, userId);

                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            response.sendRedirect(
                                    request.getContextPath() + "/interviews?error=notfound");
                            return;
                        }

                        Map<String, String> interview = new HashMap<>();

                        interview.put("id",
                                String.valueOf(rs.getInt("interview_id")));
                        interview.put("company", nullToEmpty(rs.getString("company")));
                        interview.put("position", nullToEmpty(rs.getString("position")));

                        Timestamp timestamp = rs.getTimestamp("interview_date");
                        interview.put("dateTime",
                                timestamp == null ? "" :
                                        timestamp.toLocalDateTime().format(FORMATTER));

                        interview.put("mode",
                                nullToEmpty(rs.getString("interview_type")));
                        interview.put("location",
                                nullToEmpty(rs.getString("location")));
                        interview.put("notes", nullToEmpty(rs.getString("notes")));
                        interview.put("status", nullToEmpty(rs.getString("status")));

                        request.setAttribute("editingInterview", interview);
                    }
                }
            }

            List<Map<String, String>> interviews = new ArrayList<>();

            String listSql =
                    "SELECT interview_id, company, position, interview_date, " +
                    "interview_type, location, notes, status " +
                    "FROM interviews WHERE user_id = ? " +
                    "ORDER BY interview_date ASC, interview_id DESC";

            try (PreparedStatement ps = con.prepareStatement(listSql)) {
                ps.setInt(1, userId);

                try (ResultSet rs = ps.executeQuery()) {
                    LocalDateTime now = LocalDateTime.now();

                    while (rs.next()) {
                        Timestamp timestamp = rs.getTimestamp("interview_date");

                        if (timestamp == null) {
                            continue;
                        }

                        LocalDateTime scheduled = timestamp.toLocalDateTime();

                        Map<String, String> interview = new HashMap<>();

                        interview.put("id",
                                String.valueOf(rs.getInt("interview_id")));
                        interview.put("company", nullToEmpty(rs.getString("company")));
                        interview.put("position", nullToEmpty(rs.getString("position")));
                        interview.put("dateTime", scheduled.format(FORMATTER));
                        interview.put("mode",
                                nullToEmpty(rs.getString("interview_type")));
                        interview.put("location",
                                nullToEmpty(rs.getString("location")));
                        interview.put("notes", nullToEmpty(rs.getString("notes")));
                        interview.put("status", nullToEmpty(rs.getString("status")));

                        boolean past = scheduled.isBefore(now);
                        boolean soon = !past &&
                                !scheduled.isAfter(now.plusHours(48));

                        interview.put("past", String.valueOf(past));
                        interview.put("timelineClass",
                                past ? "timeline-past" :
                                (soon ? "timeline-soon" : "timeline-upcoming"));
                        interview.put("timelineLabel",
                                past ? "Past" : (soon ? "Soon" : "Upcoming"));

                        interviews.add(interview);
                    }
                }
            }

            request.setAttribute("interviews", interviews);
            request.setAttribute("now", LocalDateTime.now().format(FORMATTER));

            request.getRequestDispatcher("/interviews.jsp")
                    .forward(request, response);

        } catch (SQLException e) {
            throw new ServletException("Unable to load interviews.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int userId = ((Number) session.getAttribute("userId")).intValue();
        String context = request.getContextPath();
        String redirect = context + "/interviews";
        String action = trim(request.getParameter("action"));

        try (Connection con = DBConnection.getConnection()) {

            if ("delete".equals(action)) {
                int id = parseId(request.getParameter("id"));

                try (PreparedStatement ps = con.prepareStatement(
                        "DELETE FROM interviews WHERE interview_id = ? AND user_id = ?")) {

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

            if (!"save".equals(action)) {
                response.sendRedirect(redirect + "?error=invalid");
                return;
            }

            String company = trim(request.getParameter("company"));
            String position = trim(request.getParameter("position"));
            String dateTimeValue = trim(request.getParameter("dateTime"));
            String mode = trim(request.getParameter("mode"));
            String location = trim(request.getParameter("location"));
            String notes = trim(request.getParameter("notes"));

            if (company.isEmpty() || company.length() > 255 ||
                    position.isEmpty() || position.length() > 255 ||
                    location.length() > 255 || notes.length() > 65535 ||
                    !validMode(mode)) {
                response.sendRedirect(redirect + "?error=invalid");
                return;
            }

            LocalDateTime scheduled;

            try {
                scheduled = LocalDateTime.parse(dateTimeValue, FORMATTER);
            } catch (DateTimeParseException e) {
                response.sendRedirect(redirect + "?error=invalid");
                return;
            }

            String idText = trim(request.getParameter("id"));

            if (idText.isEmpty()) {
                if (!scheduled.isAfter(LocalDateTime.now())) {
                    response.sendRedirect(redirect + "?error=past");
                    return;
                }

                String sql =
                        "INSERT INTO interviews " +
                        "(user_id, company, position, interview_date, " +
                        "interview_type, location, notes, status) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, 'Scheduled')";

                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, userId);
                    ps.setString(2, company);
                    ps.setString(3, position);
                    ps.setTimestamp(4, Timestamp.valueOf(scheduled));
                    ps.setString(5, mode);
                    setOptionalText(ps, 6, location);
                    setOptionalText(ps, 7, notes);
                    ps.executeUpdate();
                }

                response.sendRedirect(redirect + "?added=1");
                return;
            }

            int id = parseId(idText);
            LocalDateTime existing;

            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT interview_date FROM interviews " +
                    "WHERE interview_id = ? AND user_id = ?")) {

                ps.setInt(1, id);
                ps.setInt(2, userId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        response.sendRedirect(redirect + "?error=notfound");
                        return;
                    }

                    Timestamp timestamp = rs.getTimestamp("interview_date");

                    if (timestamp == null) {
                        response.sendRedirect(redirect + "?error=invalid");
                        return;
                    }

                    existing = timestamp.toLocalDateTime();
                }
            }

            if (!scheduled.isAfter(LocalDateTime.now()) &&
                    !scheduled.equals(existing)) {
                response.sendRedirect(redirect + "?error=past");
                return;
            }

            String sql =
                    "UPDATE interviews SET company = ?, position = ?, " +
                    "interview_date = ?, interview_type = ?, location = ?, notes = ? " +
                    "WHERE interview_id = ? AND user_id = ?";

            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, company);
                ps.setString(2, position);
                ps.setTimestamp(3, Timestamp.valueOf(scheduled));
                ps.setString(4, mode);
                setOptionalText(ps, 5, location);
                setOptionalText(ps, 6, notes);
                ps.setInt(7, id);
                ps.setInt(8, userId);

                if (ps.executeUpdate() == 0) {
                    response.sendRedirect(redirect + "?error=notfound");
                    return;
                }
            }

            response.sendRedirect(redirect + "?updated=1");

        } catch (IllegalArgumentException e) {
            response.sendRedirect(redirect + "?error=invalid");
        } catch (SQLException e) {
            throw new ServletException("Unable to save interview.", e);
        }
    }

    private int parseId(String value) {
        int id = Integer.parseInt(value);

        if (id < 1) {
            throw new NumberFormatException("ID must be positive.");
        }

        return id;
    }

    private boolean validMode(String mode) {
        return "Online".equals(mode) ||
               "Phone".equals(mode) ||
               "In-person".equals(mode);
    }

    private void setOptionalText(
            PreparedStatement ps, int index, String value)
            throws SQLException {

        if (value.isEmpty()) {
            ps.setNull(index, java.sql.Types.VARCHAR);
        } else {
            ps.setString(index, value);
        }
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private String nullToEmpty(String value) {
        return value == null ? "" : value;
    }
}