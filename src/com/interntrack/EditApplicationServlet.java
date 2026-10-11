package com.interntrack;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
@WebServlet("/editApplication")
public class EditApplicationServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        String idText = request.getParameter("id");
        try {
            int id = Integer.parseInt(idText);
            String sql = "SELECT application_id, company, role, deadline, status, application_link " +
                         "FROM applications WHERE application_id = ? AND user_id = ?";
            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, id);
                ps.setInt(2, (Integer) session.getAttribute("userId"));
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        response.sendRedirect("applications.jsp?error=notfound");
                        return;
                    }
                    request.setAttribute("applicationId", rs.getInt("application_id"));
                    request.setAttribute("company", rs.getString("company"));
                    request.setAttribute("role", rs.getString("role"));
                    request.setAttribute("deadline", rs.getString("deadline"));
                    request.setAttribute("status", rs.getString("status"));
                    request.setAttribute("applicationLink", rs.getString("application_link"));
                }
            }
            request.getRequestDispatcher("/editApplication.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect("applications.jsp?error=invalid");
        } catch (SQLException e) {
            throw new ServletException("Unable to load application for editing.", e);
        }
    }
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        String company = trim(request.getParameter("company"));
        String role = trim(request.getParameter("role"));
        String deadline = trim(request.getParameter("deadline"));
        String status = trim(request.getParameter("status"));
        String link = trim(request.getParameter("application_link"));
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            if (company.isEmpty() || role.isEmpty() || !validStatus(status)) {
                response.sendRedirect("editApplication?id=" + id + "&error=invalid");
                return;
            }
            String sql = "UPDATE applications SET company=?, role=?, deadline=?, status=?, application_link=? " +
                         "WHERE application_id=? AND user_id=?";
            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, company);
                ps.setString(2, role);
                if (deadline.isEmpty()) ps.setNull(3, Types.DATE);
                else ps.setDate(3, Date.valueOf(deadline));
                ps.setString(4, status);
                ps.setString(5, link.isEmpty() ? null : link);
                ps.setInt(6, id);
                ps.setInt(7, (Integer) session.getAttribute("userId"));
                if (ps.executeUpdate() == 0) {
                    response.sendRedirect("applications.jsp?error=notfound");
                    return;
                }
            }
            response.sendRedirect("applications.jsp?updated=1");
        } catch (IllegalArgumentException e) {
            response.sendRedirect("applications.jsp?error=invalid");
        } catch (SQLException e) {
            throw new ServletException("Unable to update application.", e);
        }
    }
    private String trim(String s) { return s == null ? "" : s.trim(); }
    private boolean validStatus(String s) {
        return s.equals("Applied") || s.equals("OA") || s.equals("Interview")
                || s.equals("Selected") || s.equals("Rejected");
    }
}
