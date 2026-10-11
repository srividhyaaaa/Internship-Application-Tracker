package com.interntrack;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
@WebServlet("/deleteApplication")
public class DeleteApplicationServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String sql = "DELETE FROM applications WHERE application_id = ? AND user_id = ?";
            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, id);
                ps.setInt(2, (Integer) session.getAttribute("userId"));
                ps.executeUpdate();
            }
            response.sendRedirect("applications.jsp?deleted=1");
        } catch (NumberFormatException e) {
            response.sendRedirect("applications.jsp?error=invalid");
        } catch (SQLException e) {
            throw new ServletException("Unable to delete application.", e);
        }
    }
}
