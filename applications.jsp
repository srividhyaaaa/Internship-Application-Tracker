<%@ page import="java.sql.*" %>
<%@ page import="com.interntrack.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%!
private String esc(Object v) {
    if (v == null) return "";
    return v.toString()
        .replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace("\"", "&quot;")
        .replace("'", "&#39;");
}
%>
<%
if (session.getAttribute("userId") == null) {
    response.sendRedirect("login.jsp");
    return;
}
int userId = (Integer) session.getAttribute("userId");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Applications | InternTrack</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/applications.css">
<style>
body { padding: 0; }
.page-shell { margin-top: 40px; }
.page-heading { align-items: center; }
.toolbar { display: flex; flex-wrap: wrap; gap: 12px; margin-bottom: 22px; }
.toolbar input, .toolbar select { min-height: 42px; padding: 0 12px; border: 1px solid #dfe3eb; border-radius: 8px; background: white; font: inherit; font-size: 13px; }
.toolbar input { flex: 1; min-width: 200px; }
.toolbar select { min-width: 150px; }
.actions-cell { display: flex; align-items: center; gap: 8px; }
.actions-cell form { margin: 0; }
.actions-cell .button { min-height: 33px; padding: 0 10px; font-size: 12px; }
.status-applied { color: #5548bf; background: #f0eeff; }
.status-oa { color: #9a6712; background: #fff7e6; }
.status-interview { color: #176446; background: #edfaf4; }
.status-selected { color: #176446; background: #edfaf4; }
.status-rejected { color: #b23c48; background: #fff2f2; }
.notice { margin-bottom: 18px; padding: 13px 16px; border: 1px solid #c6eedb; border-radius: 9px; background: #edfaf4; color: #176446; font-size: 14px; }
.error-notice { border-color: #f3cdd0; background: #fff2f2; color: #9a303a; }
.empty-row { padding: 35px; color: #737b8d; text-align: center; }
@media (max-width: 760px) {
    .actions-cell { flex-wrap: wrap; }
}
</style>
</head>
<body>
<header class="topbar">
<a class="brand" href="analytics">InternTrack</a>
<nav>
<a class="nav-link" href="applications.jsp">Applications</a>
</nav>
</header>

<main class="page-shell">
<div class="page-heading">
<div>
<p class="eyebrow">YOUR INTERNSHIP JOURNEY</p>
<h1>All Applications</h1>
<p class="subtitle">Manage and track your internship applications in one place.</p>
</div>
<div>
<a class="button button-secondary" href="analytics">Dashboard</a>
<a class="button button-primary" href="addApplication.jsp">+ Add Application</a>
</div>
</div>

<% if ("1".equals(request.getParameter("updated"))) { %>
<div class="notice">Application updated successfully.</div>
<% } %>

<% if ("1".equals(request.getParameter("deleted"))) { %>
<div class="notice">Application deleted successfully.</div>
<% } %>

<% if ("error".equals(request.getParameter("error"))) { %>
<div class="notice error-notice">The requested action could not be completed.</div>
<% } %>

<div class="toolbar">
<input type="search" id="search" placeholder="Search by company or role..." oninput="filterRows()">
<select id="filter" onchange="filterRows()">
<option value="">All Statuses</option>
<option value="Applied">Applied</option>
<option value="OA">OA</option>
<option value="Interview">Interview</option>
<option value="Selected">Selected</option>
<option value="Rejected">Rejected</option>
</select>
</div>

<div class="panel">
<div class="table-scroll">
<table id="apps">
<thead>
<tr>
<th>Company</th>
<th>Role</th>
<th>Deadline</th>
<th>Status</th>
<th>Application Link</th>
<th>Actions</th>
</tr>
</thead>
<tbody>
<%
String sql = "SELECT application_id, company, role, deadline, status, application_link FROM applications WHERE user_id=? ORDER BY deadline ASC";

try (
    Connection con = DBConnection.getConnection();
    PreparedStatement ps = con.prepareStatement(sql)
) {
    ps.setInt(1, userId);

    try (ResultSet rs = ps.executeQuery()) {
        boolean any = false;

        while (rs.next()) {
            any = true;

            int id = rs.getInt("application_id");
            String company = rs.getString("company");
            String role = rs.getString("role");
            String deadline = rs.getString("deadline");
            String status = rs.getString("status");
            String link = rs.getString("application_link");

            String statusClass = "status";
            if ("Applied".equalsIgnoreCase(status)) statusClass += " status-applied";
            else if ("OA".equalsIgnoreCase(status)) statusClass += " status-oa";
            else if ("Interview".equalsIgnoreCase(status)) statusClass += " status-interview";
            else if ("Selected".equalsIgnoreCase(status)) statusClass += " status-selected";
            else if ("Rejected".equalsIgnoreCase(status)) statusClass += " status-rejected";
%>
<tr>
<td data-label="Company">
<span class="company"><%= esc(company) %></span>
</td>
<td data-label="Role">
<span class="role"><%= esc(role) %></span>
</td>
<td data-label="Deadline">
<%= deadline == null || deadline.isBlank() ? "Not set" : esc(deadline) %>
</td>
<td data-label="Status">
<span class="<%= statusClass %> badge"><%= esc(status) %></span>
</td>
<td data-label="Application Link">
<% if (link != null && !link.isBlank()) { %>
<a class="external-link" href="<%= esc(link) %>" target="_blank" rel="noopener noreferrer">Open link ↗</a>
<% } else { %>
<span class="muted">Not provided</span>
<% } %>
</td>
<td data-label="Actions" class="actions-cell">
<a class="button button-secondary" href="editApplication?id=<%= id %>">Edit</a>
<form class="inline-form" action="deleteApplication" method="post" onsubmit="return confirm('Are you sure you want to delete this application?');">
<input type="hidden" name="id" value="<%= id %>">
<button class="button button-danger" type="submit">Delete</button>
</form>
</td>
</tr>
<%
        }

        if (!any) {
%>
<tr>
<td colspan="6" class="empty-row">No applications found. Add your first application to get started.</td>
</tr>
<%
        }
    }
} catch (SQLException e) {
    application.log("Unable to load internship applications.", e);
%>
<tr>
<td colspan="6" class="empty-row">Unable to load applications. Please check your database connection and try again.</td>
</tr>
<%
}
%>
</tbody>
</table>
</div>
</div>
</main>

<script>
function filterRows() {
    const query = document.getElementById("search").value.toLowerCase().trim();
    const selectedStatus = document.getElementById("filter").value.toLowerCase();

    document.querySelectorAll("#apps tbody tr").forEach(row => {
        if (row.cells.length < 6) return;

        const company = row.cells[0].textContent.toLowerCase();
        const role = row.cells[1].textContent.toLowerCase();
        const status = row.cells[3].textContent.trim().toLowerCase();

        const matchesSearch = company.includes(query) || role.includes(query);
        const matchesStatus = !selectedStatus || status === selectedStatus;

        row.style.display = matchesSearch && matchesStatus ? "" : "none";
    });
}
</script>
</body>
</html>