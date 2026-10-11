<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%!
private String esc(Object v) {
    if (v == null) return "";
    return v.toString().replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
}
%>
<%
if (session.getAttribute("userId") == null) {
    response.sendRedirect("login.jsp");
    return;
}
Object id = request.getAttribute("applicationId");
if (id == null) {
    response.sendRedirect("applications.jsp");
    return;
}
String deadline = (String) request.getAttribute("deadline");
String current = (String) request.getAttribute("status");
String[] statuses = {"Applied", "OA", "Interview", "Selected", "Rejected"};
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Edit Application | InternTrack</title>
<style>
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}
body {
    min-height: 100vh;
    padding: 35px 20px;
    font-family: "Segoe UI", Arial, sans-serif;
    background: linear-gradient(135deg, #eef4ff, #f8faff);
    color: #172554;
}
.container {
    width: 100%;
    max-width: 680px;
    margin: 0 auto;
    padding: 36px;
    background: #fff;
    border-radius: 18px;
    box-shadow: 0 15px 45px rgba(30,64,175,.12);
}
.logo {
    color: #2563eb;
    font-size: 27px;
    font-weight: 750;
    letter-spacing: -1px;
}
.header {
    margin-bottom: 30px;
}
.header h1 {
    margin-top: 25px;
    font-size: 27px;
}
.header p {
    margin-top: 8px;
    color: #64748b;
    font-size: 14px;
    line-height: 1.6;
}
.form-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px;
}
.form-group {
    margin-bottom: 20px;
}
.full-width {
    grid-column: 1 / -1;
}
label {
    display: block;
    margin-bottom: 8px;
    color: #334155;
    font-size: 14px;
    font-weight: 600;
}
input, select {
    width: 100%;
    padding: 13px 14px;
    border: 1px solid #cbd5e1;
    border-radius: 9px;
    outline: none;
    background: #fff;
    color: #1e293b;
    font-size: 14px;
}
input:focus, select:focus {
    border-color: #3b82f6;
    box-shadow: 0 0 0 3px rgba(59,130,246,.13);
}
.actions {
    display: flex;
    align-items: center;
    gap: 16px;
    margin-top: 8px;
}
button {
    padding: 13px 24px;
    border: none;
    border-radius: 9px;
    background: #2563eb;
    color: #fff;
    font-size: 14px;
    font-weight: 650;
    cursor: pointer;
}
button:hover {
    background: #1d4ed8;
}
.back-link {
    color: #64748b;
    font-size: 14px;
    font-weight: 600;
    text-decoration: none;
}
.back-link:hover {
    color: #2563eb;
}
@media (max-width: 560px) {
    .container {
        padding: 25px 20px;
    }
    .form-grid {
        grid-template-columns: 1fr;
        gap: 0;
    }
    .full-width {
        grid-column: auto;
    }
    .actions {
        align-items: stretch;
        flex-direction: column;
    }
    button {
        width: 100%;
    }
    .back-link {
        text-align: center;
    }
}
</style>
</head>
<body>
<div class="container">
<div class="logo">InternTrack</div>
<div class="header">
<h1>Edit Application</h1>
<p>Update your internship details and keep your application tracker current.</p>
</div>
<form action="editApplication" method="post">
<input type="hidden" name="id" value="<%= esc(id) %>">
<div class="form-grid">
<div class="form-group">
<label for="company">Company Name</label>
<input id="company" name="company" maxlength="100" value="<%= esc(request.getAttribute("company")) %>" required>
</div>
<div class="form-group">
<label for="role">Job Role</label>
<input id="role" name="role" maxlength="100" value="<%= esc(request.getAttribute("role")) %>" required>
</div>
<div class="form-group">
<label for="deadline">Application Deadline</label>
<input id="deadline" name="deadline" type="date" value="<%= esc(deadline) %>">
</div>
<div class="form-group">
<label for="status">Application Status</label>
<select id="status" name="status" required>
<% for (String s : statuses) { %>
<option value="<%= s %>" <%= s.equals(current) ? "selected" : "" %>><%= s %></option>
<% } %>
</select>
</div>
<div class="form-group full-width">
<label for="application_link">Application Link <span style="color:#94a3b8;font-weight:400;">(Optional)</span></label>
<input id="application_link" name="application_link" type="url" maxlength="500" value="<%= esc(request.getAttribute("applicationLink")) %>" placeholder="https://company.com/careers">
</div>
</div>
<div class="actions">
<button type="submit">Save Changes</button>
<a class="back-link" href="applications.jsp">← Back to Applications</a>
</div>
</form>
</div>
</body>
</html>