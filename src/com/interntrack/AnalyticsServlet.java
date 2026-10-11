package com.interntrack;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;
@WebServlet("/analytics")
public class AnalyticsServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        int userId = (Integer) session.getAttribute("userId");
        String sql = "SELECT application_id, company, role, deadline, status, application_link " +
                     "FROM applications WHERE user_id = ? ORDER BY deadline ASC";
        Map<String, Integer> counts = new HashMap<>();
        List<Map<String, String>> applications = new ArrayList<>();
        int total = 0;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String status = rs.getString("status");
                    if (status == null) status = "";
                    counts.put(status, counts.getOrDefault(status, 0) + 1);
                    total++;
                    Map<String, String> app = new HashMap<>();
                    app.put("id", String.valueOf(rs.getInt("application_id")));
                    app.put("company", rs.getString("company"));
                    app.put("role", rs.getString("role"));
                    String deadline = rs.getString("deadline");
                    app.put("deadline", deadline == null ? "Not set" : deadline);
                    app.put("status", status);
                    String link = rs.getString("application_link");
                    app.put("link", link == null ? "" : link);
                    applications.add(app);
                }
            }
            int oa = counts.getOrDefault("OA", 0);
            int interviews = counts.getOrDefault("Interview", 0)
                    + counts.getOrDefault("Technical Interview", 0)
                    + counts.getOrDefault("HR Interview", 0);
            int selected = counts.getOrDefault("Selected", 0);
            int rejected = counts.getOrDefault("Rejected", 0);
            double oaRate = total == 0 ? 0.0 : oa * 100.0 / total;
            double interviewRate = total == 0 ? 0.0 : interviews * 100.0 / total;
            double selectionRate = total == 0 ? 0.0 : selected * 100.0 / total;
            request.setAttribute("totalApplications", total);
            request.setAttribute("oaCount", oa);
            request.setAttribute("interviewCount", interviews);
            request.setAttribute("selectedCount", selected);
            request.setAttribute("rejectedCount", rejected);
            request.setAttribute("applicationList", applications);
            request.setAttribute("oaConversionRate", oaRate);
            request.setAttribute("interviewConversionRate", interviewRate);
            request.setAttribute("selectionRate", selectionRate);
            request.getRequestDispatcher("/dashboard.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Unable to load InternTrack dashboard. Check DB settings and applications table.", e);
        }
    }
}
