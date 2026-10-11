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
@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        if (email == null || password == null ||
            email.trim().isEmpty() || password.isEmpty()) {
            response.sendRedirect("login.jsp?error=invalid");
            return;
        }
        email = email.trim().toLowerCase();
        String sql = "SELECT user_id, name, password FROM users WHERE email = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() &&
                    PasswordUtil.verifyPassword(password, rs.getString("password"))) {
                    // Prevent session fixation by replacing the old session.
                    HttpSession oldSession = request.getSession(false);
                    if (oldSession != null) {
                        oldSession.invalidate();
                    }
                    HttpSession session = request.getSession(true);
                    session.setAttribute("userId", rs.getInt("user_id"));
                    session.setAttribute("userName", rs.getString("name"));
                    session.setMaxInactiveInterval(30 * 60);
                    response.sendRedirect("analytics");
                } else {
                    response.sendRedirect("login.jsp?error=invalid");
                }
            }
        } catch (Exception e) {
            throw new ServletException("Unable to process login.", e);
        }
    }
}
