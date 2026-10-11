
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Create Account | InternTrack</title>
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
    max-width: 460px;
    background: #ffffff;
    padding: 38px;
    border-radius: 18px;
    box-shadow: 0 15px 45px rgba(30, 64, 175, 0.12);
}
.logo {
    text-align: center;
    font-size: 32px;
    font-weight: 750;
    color: #2563eb;
    letter-spacing: -1px;
}
.subtitle {
    text-align: center;
    color: #64748b;
    margin: 8px 0 28px;
    font-size: 15px;
}
h2 {
    text-align: center;
    font-size: 23px;
    margin-bottom: 8px;
    color: #172554;
}
.form-group {
    margin-bottom: 18px;
}
label {
    display: block;
    margin-bottom: 7px;
    font-size: 14px;
    font-weight: 600;
    color: #334155;
}
input {
    width: 100%;
    padding: 13px 14px;
    border: 1px solid #cbd5e1;
    border-radius: 9px;
    outline: none;
    font-size: 14px;
    background: #fff;
    transition: border-color 0.2s, box-shadow 0.2s;
}
input:focus {
    border-color: #3b82f6;
    box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.13);
}
.password-wrap {
    position: relative;
}
.password-wrap input {
    padding-right: 65px;
}
.toggle {
    position: absolute;
    right: 12px;
    top: 50%;
    transform: translateY(-50%);
    border: none;
    background: none;
    color: #2563eb;
    cursor: pointer;
    font-size: 12px;
    font-weight: 600;
}
button[type="submit"] {
    width: 100%;
    padding: 14px;
    margin-top: 5px;
    border: none;
    border-radius: 9px;
    background: #2563eb;
    color: white;
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
    text-align: center;
    margin-top: 24px;
    font-size: 14px;
    color: #64748b;
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
    <p class="subtitle">Your personal internship command center</p>
    <h2>Create your account</h2>
    <p class="subtitle">Start organizing your career journey today.</p>

    <form action="register" method="post" onsubmit="return validateForm()">
        <div class="form-group">
            <label for="fullName">Full Name</label>
            <input type="text" id="fullName" name="fullName" placeholder="Enter your full name" autocomplete="name" required>
        </div>

        <div class="form-group">
            <label for="email">Email Address</label>
            <input type="email" id="email" name="email" placeholder="you@example.com" autocomplete="email" required>
        </div>

        <div class="form-group">
            <label for="password">Password</label>
            <div class="password-wrap">
                <input type="password" id="password" name="password" placeholder="At least 8 characters" autocomplete="new-password" minlength="8" required>
                <button class="toggle" type="button" onclick="togglePassword('password', this)">Show</button>
            </div>
        </div>

        <div class="form-group">
            <label for="confirmPassword">Confirm Password</label>
            <div class="password-wrap">
                <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Re-enter your password" autocomplete="new-password" minlength="8" required>
                <button class="toggle" type="button" onclick="togglePassword('confirmPassword', this)">Show</button>
            </div>
        </div>

        <button type="submit">Create Account</button>
    </form>

    <p class="footer">Already have an account? <a href="login.jsp">Login</a></p>
</div>

<script>
function togglePassword(id, button) {
    const field = document.getElementById(id);
    const visible = field.type === "password";
    field.type = visible ? "text" : "password";
    button.textContent = visible ? "Hide" : "Show";
}

function validateForm() {
    const password = document.getElementById("password").value;
    const confirmPassword = document.getElementById("confirmPassword").value;

    if (password.length < 8) {
        alert("Password must contain at least 8 characters.");
        return false;
    }

    if (password !== confirmPassword) {
        alert("Passwords do not match.");
        return false;
    }

    return true;
}
</script>
</body>
</html>