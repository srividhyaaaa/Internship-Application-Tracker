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
import java.sql.Time;
import java.sql.Types;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.time.format.ResolverStyle;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/interviews")
public class InterviewServlet extends HttpServlet {
    private static final DateTimeFormatter FORM_DATE_TIME =
            DateTimeFormatter.ofPattern("uuuu-MM-dd'T'HH:mm").withResolverStyle(ResolverStyle.STRICT);

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int userId = ((Number) session.getAttribute("userId")).intValue();
        String editId = trim(request.getParameter("edit"));
        try (Connection con = DBConnection.getConnection()) {
            if (!editId.isEmpty()) {
                int id;
                try {
                    id = Integer.parseInt(editId);
                } catch (NumberFormatException e) {
                    response.sendRedirect(request.getContextPath() + "/interviews?error=invalid");
                    return;
                }
                String editSql = "SELECT interview_id, round_name, interview_date, interview_time, " +
                        "interview_mode, preparation_notes FROM interviews " +
                        "WHERE interview_id = ? AND user_id = ?";
                try (PreparedStatement ps = con.prepareStatement(editSql)) {
                    ps.setInt(1, id);
                    ps.setInt(2, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            response.sendRedirect(request.getContextPath() + "/interviews?error=notfound");
                            return;
                        }
                        Map<String, String> interview = new HashMap<>();
                        interview.put("id", String.valueOf(rs.getInt("interview_id")));
                        interview.put("roundName", rs.getString("round_name"));
                        interview.put("dateTime", rs.getDate("interview_date").toLocalDate()
                                .atTime(rs.getTime("interview_time").toLocalTime())
                                .format(FORM_DATE_TIME));
                        interview.put("mode", rs.getString("interview_mode"));
                        interview.put("notes", nullToEmpty(rs.getString("preparation_notes")));
                        request.setAttribute("editingInterview", interview);
                    }
                }
            }

            List<Map<String, String>> interviews = new ArrayList<>();
            String listSql = "SELECT interview_id, round_name, interview_date, interview_time, " +
                    "interview_mode, preparation_notes FROM interviews WHERE user_id = ? " +
                    "ORDER BY interview_date ASC, interview_time ASC";
            try (PreparedStatement ps = con.prepareStatement(listSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    LocalDateTime now = LocalDateTime.now();
                    while (rs.next()) {
                        LocalDateTime scheduled = rs.getDate("interview_date").toLocalDate()
                                .atTime(rs.getTime("interview_time").toLocalTime());
                        Map<String, String> interview = new HashMap<>();
                        interview.put("id", String.valueOf(rs.getInt("interview_id")));
                        interview.put("roundName", rs.getString("round_name"));
                        interview.put("dateTime", scheduled.format(FORM_DATE_TIME));
                        interview.put("mode", rs.getString("interview_mode"));
                        interview.put("notes", nullToEmpty(rs.getString("preparation_notes")));
                        boolean past = scheduled.isBefore(now);
                        boolean soon = !past && Duration.between(now, scheduled)
                                .compareTo(Duration.ofHours(48)) <= 0;
                        interview.put("past", String.valueOf(past));
                        interview.put("timelineClass", past ? "timeline-past"
                                : (soon ? "timeline-soon" : "timeline-upcoming"));
                        interview.put("timelineLabel", past ? "Past" : (soon ? "Soon" : "Upcoming"));
                        interviews.add(interview);
                    }
                }
            }
            interviews.sort(Comparator
                    .comparing((Map<String, String> interview) -> Boolean.parseBoolean(interview.get("past")))
                    .thenComparing(interview -> interview.get("dateTime")));
            request.setAttribute("interviews", interviews);
            request.setAttribute("now", LocalDateTime.now().format(FORM_DATE_TIME));
            request.getRequestDispatcher("/interviews.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Unable to load interviews.", e);
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
        String redirect = request.getContextPath() + "/interviews";

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

            String roundName = trim(request.getParameter("roundName"));
            String dateTimeValue = trim(request.getParameter("dateTime"));
            String mode = trim(request.getParameter("mode"));
            String notes = trim(request.getParameter("notes"));
            if (roundName.isEmpty() || roundName.length() > 100
                    || notes.length() > 5000 || !validMode(mode)) {
                response.sendRedirect(redirect + "?error=invalid");
                return;
            }

            LocalDateTime scheduled;
            try {
                scheduled = LocalDateTime.parse(dateTimeValue, FORM_DATE_TIME);
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
                String sql = "INSERT INTO interviews (user_id, round_name, interview_date, " +
                        "interview_time, interview_mode, preparation_notes) VALUES (?, ?, ?, ?, ?, ?)";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, userId);
                    ps.setString(2, roundName);
                    ps.setDate(3, Date.valueOf(scheduled.toLocalDate()));
                    ps.setTime(4, Time.valueOf(scheduled.toLocalTime()));
                    ps.setString(5, mode);
                    setOptionalText(ps, 6, notes);
                    ps.executeUpdate();
                }
                response.sendRedirect(redirect + "?added=1");
                return;
            }

            int id = parseId(idText);
            LocalDateTime existing;
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT interview_date, interview_time FROM interviews " +
                            "WHERE interview_id = ? AND user_id = ?")) {
                ps.setInt(1, id);
                ps.setInt(2, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        response.sendRedirect(redirect + "?error=notfound");
                        return;
                    }
                    existing = rs.getDate("interview_date").toLocalDate()
                            .atTime(rs.getTime("interview_time").toLocalTime());
                }
            }
            if (!scheduled.isAfter(LocalDateTime.now())
                    && !scheduled.truncatedTo(ChronoUnit.MINUTES)
                            .equals(existing.truncatedTo(ChronoUnit.MINUTES))) {
                response.sendRedirect(redirect + "?error=past");
                return;
            }
            String sql = "UPDATE interviews SET round_name = ?, interview_date = ?, interview_time = ?, " +
                    "interview_mode = ?, preparation_notes = ? WHERE interview_id = ? AND user_id = ?";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, roundName);
                ps.setDate(2, Date.valueOf(scheduled.toLocalDate()));
                ps.setTime(3, Time.valueOf(scheduled.toLocalTime()));
                ps.setString(4, mode);
                setOptionalText(ps, 5, notes);
                ps.setInt(6, id);
                ps.setInt(7, userId);
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
        return "Online".equals(mode) || "Phone".equals(mode) || "In-person".equals(mode);
    }

    private void setOptionalText(PreparedStatement ps, int index, String value) throws SQLException {
        if (value.isEmpty()) {
            ps.setNull(index, Types.VARCHAR);
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
