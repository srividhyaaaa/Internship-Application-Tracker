<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
if (session.getAttribute("userId") == null) {
    response.sendRedirect("login.jsp");
    return;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Add Application | InternTrack</title>
<link rel="stylesheet" href="css/style.css">
<style>
* {
    box-sizing: border-box;
}
body {
    margin: 0;
    min-height: 100vh;
    padding: 40px 20px;
    font-family: "Segoe UI", Arial, sans-serif;
    background: #f4f6fb;
    color: #202638;
}
.container {
    max-width: 760px;
    margin: auto;
    padding: 35px;
    background: white;
    border: 1px solid #e7eaf0;
    border-radius: 14px;
    box-shadow: 0 4px 18px #20263809;
}
.logo {
    color: #6254d9;
    font-size: 20px;
    font-weight: 750;
}
.header {
    margin: 30px 0;
}
.eyebrow {
    color: #6254d9;
    font-size: 11px;
    font-weight: 750;
    letter-spacing: 1.2px;
}
h1 {
    margin: 10px 0;
    font-size: 30px;
    color: #202638;
}
.header p {
    color: #737b8d;
    font-size: 14px;
    line-height: 1.6;
}
.form-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px 18px;
}
.form-group {
    min-width: 0;
}
.full-width {
    grid-column: 1 / -1;
}
label {
    display: block;
    margin-bottom: 8px;
    font-size: 13px;
    font-weight: 650;
}
.required {
    color: #c4424d;
}
.optional {
    color: #737b8d;
    font-weight: 400;
}
input, select {
    width: 100%;
    height: 44px;
    padding: 0 12px;
    border: 1px solid #dfe3eb;
    border-radius: 7px;
    background: white;
    color: #202638;
    font: inherit;
    font-size: 13px;
}
input:focus, select:focus {
    outline: 3px solid #6254d926;
    border-color: #6254d9;
}
.actions {
    display: flex;
    justify-content: flex-end;
    align-items: center;
    gap: 12px;
    margin-top: 30px;
    padding-top: 22px;
    border-top: 1px solid #e7eaf0;
}
.button {
    display: inline-flex;
    justify-content: center;
    align-items: center;
    min-height: 42px;
    padding: 0 16px;
    border: 1px solid #dfe3eb;
    border-radius: 8px;
    background: white;
    color: #444b5d;
    font-size: 14px;
    font-weight: 650;
    text-decoration: none;
    cursor: pointer;
}
.primary {
    border-color: #6254d9;
    background: #6254d9;
    color: white;
}
.primary:hover {
    background: #4f43c1;
}
@media (max-width: 560px) {
    .container {
        padding: 25px 20px;
    }
    .form-grid {
        grid-template-columns: 1fr;
    }
    .full-width {
        grid-column: auto;
    }
    .actions {
        flex-direction: column-reverse;
    }
    .actions .button {
        width: 100%;
    }
}
</style>
</head>
<body>
<div class="container">
    <div class="logo">InternTrack</div>
    <div class="header">
        <p class="eyebrow">APPLICATION DETAILS</p>
        <h1>Add an Application</h1>
        <p>Save an internship opportunity and track its deadline and progress.</p>
    </div>
    <form action="addApplication" method="post">
        <div class="form-grid">
            <div class="form-group">
                <label for="company">Company Name <span class="required">*</span></label>
                <input type="text" id="company" name="company" maxlength="150" placeholder="e.g. Microsoft" required>
            </div>
            <div class="form-group">
                <label for="role">Job Role <span class="required">*</span></label>
                <input type="text" id="role" name="role" maxlength="150" placeholder="e.g. Software Intern" required>
            </div>
            <div class="form-group">
                <label for="deadline">Application Deadline <span class="required">*</span></label>
                <input type="date" id="deadline" name="deadline" required>
            </div>
            <div class="form-group">
                <label for="status">Application Status <span class="required">*</span></label>
                <select id="status" name="status" required>
                    <option value="Applied">Applied</option>
                    <option value="OA">Online Assessment</option>
                    <option value="Interview">Interview</option>
                    <option value="Selected">Selected</option>
                    <option value="Rejected">Rejected</option>
                </select>
            </div>
            <div class="form-group full-width">
                <label for="applicationLink">Application Link <span class="optional">(Optional)</span></label>
                <input type="url" id="applicationLink" name="application_link" maxlength="2048" placeholder="https://company.com/careers">
            </div>
        </div>
        <div class="actions">
            <a class="button" href="analytics">Back to Dashboard</a>
            <button class="button primary" type="submit">Save Application</button>
        </div>
    </form>
</div>
</body>
</html>