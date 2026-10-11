<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Login | InternTrack</title>
<style>
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}
body {
    font-family: "Segoe UI", Arial, sans-serif;
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 24px;
    background: linear-gradient(135deg, #eef4ff, #f8faff);
    color: #172554;
}
.container {
    width: 100%;
    max-width: 420px;
    padding: 38px;
    background: #ffffff;
    border-radius: 18px;
    box-shadow: 0 15px 45px rgba(30, 64, 175, 0.12);
}
.logo {
    text-align: center;
    font-size: 32px;
    font-weight: 750;
    letter-spacing: -1px;
    color: #2563eb;
}
.subtitle {
    text-align: center;
    margin: 8px 0 30px;
    color: #64748b;
    font-size: 14px;
    line-height: 1.6;
}
h2 {
    text-align: center;
    margin-bottom: 8px;
    font-size: 24px;
    color: #172554;
}
.form-group {
    margin-bottom: 20px;
}
label {
    display: block;
    margin-bottom: 8px;
    font-size: 14px;
    font-weight: 600;
    color: #334155;
}
.password-wrap {
    position: relative;
}
input {
    width: 100%;
    padding: 13px 14px;
    border: 1px solid #cbd5e1;
    border-radius: 9px;
    outline: none;
    background: #ffffff;
    font-size: 14px;
    transition: border-color 0.2s, box-shadow 0.2s;
}
input:focus {
    border-color: #3b82f6;
    box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.13);
}
.password-wrap input {
    padding-right: 65px;
}
.toggle {
    position: absolute;
    top: 50%;
    right: 12px;
    transform: translateY(-50%);
    border: none;
    background: none;
    color: #2563eb;
    font-size: 12px;
    font-weight: 600;
    cursor: pointer;
}
button[type="submit"] {
    width: 100%;
    margin-top: 4px;
    padding: 14px;
    border: none;
    border-radius: 9px;
    background: #2563eb;
    color: #ffffff;
    font-size: 15px;
    font-weight: 650;
    cursor: pointer;
    transition: background 0.2s, transform 0.2s;
}
button[type="submit"]:hover {
    background: #1d4ed8;
    transform: translateY(-1px);
}
.footer {
    margin-top: 24px;
    text-align: center;
    color: #64748b;
    font-size: 14px;
}
.footer a {
    color: #2563eb;
    font-weight: 600;
    text-decoration: none;
}
.footer a:hover {
    text-decoration: underline;
}
@media (max-width: 480px) {
    .container {
        padding: 28px 22px;
    }
    .logo {
        font-size: 28px;
    }
}
</style>
</head>
<body>
<div class="container">
    <div class="logo">InternTrack</div>
    <p class="subtitle">Your Personal Internship Command Center</p>

    <h2>Welcome Back!</h2>
    <p class="subtitle">Log in to continue tracking your career journey.</p>

    <form action="login" method="post">
        <div class="form-group">
            <label for="email">Email Address</label>
            <input
                type="email"
                id="email"
                name="email"
                placeholder="Enter your email"
                autocomplete="email"
                required
            >
        </div>

        <div class="form-group">
            <label for="password">Password</label>
            <div class="password-wrap">
                <input
                    type="password"
                    id="password"
                    name="password"
                    placeholder="Enter your password"
                    autocomplete="current-password"
                    required
                >
                <button
                    class="toggle"
                    type="button"
                    onclick="togglePassword()"
                >Show</button>
            </div>
        </div>

        <button type="submit">Login to Your Account</button>
    </form>

    <p class="footer">
        Don't have an account?
        <a href="register.jsp">Create an account</a>
    </p>
</div>

<script>
function togglePassword() {
    const field = document.getElementById("password");
    const button = document.querySelector(".toggle");
    const visible = field.type === "password";

    field.type = visible ? "text" : "password";
    button.textContent = visible ? "Hide" : "Show";
}
</script>
</body>
</html>