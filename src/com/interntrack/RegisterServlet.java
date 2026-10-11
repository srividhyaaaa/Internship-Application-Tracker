package com.interntrack;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
       String name = trim(request.getParameter("fullName"));
        String email = trim(request.getParameter("email")).toLowerCase();
        String password = request.getParameter("password");
        String confirm = request.getParameter("confirmPassword");
        if (name.isEmpty() || name.length() > 100 || email.isEmpty()
                || email.length() > 150 || password == null || confirm == null) {
            response.sendRedirect("register.jsp?error=invalid");
            return;
        }
        if (password.length() < 8 || password.length() > 128) {
            response.sendRedirect("register.jsp?error=password");
            return;
        }
        if (!password.equals(confirm)) {
            response.sendRedirect("register.jsp?error=mismatch");
            return;
        }
        try {
            String existsSql = "SELECT user_id FROM users WHERE email = ?";
            try (Connection con = DBConnection.getConnection();
                 PreparedStatement check = con.prepareStatement(existsSql)) {
                check.setString(1, email);
                try (ResultSet rs = check.executeQuery()) {
                    if (rs.next()) {
                        response.sendRedirect("register.jsp?error=exists");
                        return;
                    }
                }
                String hash = PasswordUtil.hashPassword(password);
                String insertSql = "INSERT INTO users (name, email, password) VALUES (?, ?, ?)";
                try (PreparedStatement insert = con.prepareStatement(insertSql)) {
                    insert.setString(1, name);
                    insert.setString(2, email);
                    insert.setString(3, hash);
                    insert.executeUpdate();
                }
            }
            response.sendRedirect("login.jsp?registered=1");
        } catch (Exception e) {
            throw new ServletException("Unable to register account.", e);
        }
    }
    private String trim(String s) { return s == null ? "" : s.trim(); }
}
