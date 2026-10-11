package com.interntrack;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
@WebServlet("/addApplication")
public class AddApplicationServlet extends HttpServlet {
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
        if (company.isEmpty() || role.isEmpty() || !validStatus(status)) {
            response.sendRedirect("addApplication.jsp?error=invalid");
            return;
        }
        String sql = "INSERT INTO applications (user_id, company, role, deadline, status, application_link) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, (Integer) session.getAttribute("userId"));
            ps.setString(2, company);
            ps.setString(3, role);
            if (deadline.isEmpty()) ps.setNull(4, Types.DATE);
            else ps.setDate(4, Date.valueOf(deadline));
            ps.setString(5, status);
            ps.setString(6, link.isEmpty() ? null : link);
            ps.executeUpdate();
            response.sendRedirect("analytics?added=1");
        } catch (IllegalArgumentException e) {
            response.sendRedirect("addApplication.jsp?error=invalid");
        } catch (SQLException e) {
            throw new ServletException("Unable to add application.", e);
        }
    }
    private String trim(String s) { return s == null ? "" : s.trim(); }
    private boolean validStatus(String s) {
        return s.equals("Applied") || s.equals("OA") || s.equals("Interview")
                || s.equals("Selected") || s.equals("Rejected");
    }
}
