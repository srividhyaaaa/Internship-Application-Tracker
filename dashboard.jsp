<%@ page import="java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%!
private double rate(Object v) {
    return v instanceof Number ? ((Number)v).doubleValue() : 0.0;
}
private String esc(Object v) {
    if (v == null) return "";
    return v.toString().replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;");
}
%>
<%
if (session.getAttribute("userId") == null) {
    response.sendRedirect("login.jsp");
    return;
}
String userName = (String)session.getAttribute("userName");
if (userName == null) userName = "User";

int total = request.getAttribute("totalApplications") instanceof Number ? ((Number)request.getAttribute("totalApplications")).intValue() : 0;
int oa = request.getAttribute("oaCount") instanceof Number ? ((Number)request.getAttribute("oaCount")).intValue() : 0;
int interviews = request.getAttribute("interviewCount") instanceof Number ? ((Number)request.getAttribute("interviewCount")).intValue() : 0;
int selected = request.getAttribute("selectedCount") instanceof Number ? ((Number)request.getAttribute("selectedCount")).intValue() : 0;
int rejected = request.getAttribute("rejectedCount") instanceof Number ? ((Number)request.getAttribute("rejectedCount")).intValue() : 0;

List<Map<String,String>> apps = new ArrayList<>();
Object obj = request.getAttribute("applicationList");

if (obj instanceof List<?>) {
    for (Object item : (List<?>)obj) {
        if (item instanceof Map<?,?>) {
            Map<String,String> row = new HashMap<>();
            for (Map.Entry<?,?> e : ((Map<?,?>)item).entrySet()) {
                row.put(String.valueOf(e.getKey()), e.getValue() == null ? "" : String.valueOf(e.getValue()));
            }
            apps.add(row);
        }
    }
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Dashboard | InternTrack</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/applications.css">
<style>
.page-shell { margin-top: 34px; }
.dashboard-heading { display: flex; align-items: center; justify-content: space-between; gap: 20px; margin-bottom: 28px; }
.dashboard-actions { display: flex; align-items: center; flex-wrap: wrap; gap: 10px; }
.dashboard-actions form { margin: 0; }
.stats { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 14px; margin-bottom: 20px; }
.stat-card { padding: 22px; border: 1px solid var(--line); border-radius: 13px; background: var(--surface); box-shadow: 0 4px 18px rgba(32, 38, 56, .035); }
.stat-card p, .metric p { margin: 0 0 10px; color: var(--muted); font-size: 13px; }
.number { color: var(--ink); font-size: 30px; font-weight: 750; }
.dashboard-panel { margin-bottom: 20px; padding: 22px; border: 1px solid var(--line); border-radius: 13px; background: var(--surface); box-shadow: 0 4px 18px rgba(32, 38, 56, .035); }
.dashboard-panel h2 { margin: 0 0 18px; font-size: 21px; letter-spacing: -.4px; }
.metrics { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 12px; }
.metric { padding: 16px; border-radius: 8px; background: var(--background); }
.metric strong { color: var(--primary); font-size: 22px; }
.toolbar { display: flex; flex-wrap: wrap; gap: 10px; margin-bottom: 16px; }
.toolbar input, .toolbar select { min-height: 42px; padding: 0 12px; border: 1px solid #dfe3eb; border-radius: 8px; background: white; font: inherit; font-size: 13px; }
.toolbar input { flex: 1; min-width: 190px; }
.table-scroll { overflow-x: auto; }
table { width: 100%; border-collapse: collapse; text-align: left; }
th { padding: 14px 12px; color: #777f91; background: #fafbfe; border-bottom: 1px solid var(--line); font-size: 11px; font-weight: 700; letter-spacing: .5px; text-transform: uppercase; }
td { padding: 15px 12px; border-bottom: 1px solid #eef0f5; font-size: 13px; }
tbody tr:last-child td { border-bottom: 0; }
.pill { display: inline-flex; align-items: center; padding: 5px 10px; border-radius: 20px; background: #f0eeff; color: #5548bf; font-size: 11px; font-weight: 700; }
.notice { margin-bottom: 16px; padding: 13px 16px; border: 1px solid #c6eedb; border-radius: 9px; background: #edfaf4; color: #176446; font-size: 14px; }
.empty-row { padding: 30px; color: var(--muted); text-align: center; }
@media (max-width: 800px) {
    .stats, .metrics { grid-template-columns: repeat(2, minmax(0, 1fr)); }
    .dashboard-heading { align-items: flex-start; flex-direction: column; }
}
@media (max-width: 520px) {
    .stats, .metrics { grid-template-columns: 1fr 1fr; gap: 10px; }
    .stat-card, .dashboard-panel { padding: 16px; }
    .dashboard-actions { width: 100%; }
    .dashboard-actions .button, .dashboard-actions form { flex: 1; }
    .dashboard-actions form .button { width: 100%; }
    .number { font-size: 25px; }
}
</style>
</head>
<body>
<header class="topbar">
<a class="brand" href="analytics">InternTrack</a>
<nav><a class="nav-link" href="applications.jsp">Applications</a></nav>
</header>

<main class="page-shell">
<section class="dashboard-heading">
<div>
<p class="eyebrow">YOUR CAREER JOURNEY</p>
<h1>Dashboard</h1>
<p class="subtitle">Welcome, <%= esc(userName) %>! Track your internship progress in one place.</p>
</div>
<div class="dashboard-actions">
<a class="button button-primary" href="addApplication.jsp">+ Add Application</a>
<a class="button button-secondary" href="applications.jsp">View All Applications</a>
<form action="logout" method="post">
<button class="button button-danger" type="submit">Logout</button>
</form>
</div>
</section>

<% if ("1".equals(request.getParameter("added"))) { %>
<div class="notice">Application added successfully!</div>
<% } %>
<% if ("1".equals(request.getParameter("updated"))) { %>
<div class="notice">Application updated successfully.</div>
<% } %>

<section class="stats">
<div class="stat-card">
<p>Total Applications</p>
<div class="number"><%= total %></div>
</div>
<div class="stat-card">
<p>Online Assessments</p>
<div class="number"><%= oa %></div>
</div>
<div class="stat-card">
<p>Interviews</p>
<div class="number"><%= interviews %></div>
</div>
<div class="stat-card">
<p>Offers Received</p>
<div class="number"><%= selected %></div>
</div>
</section>

<section class="dashboard-panel">
<h2>Application Analytics</h2>
<div class="metrics">
<div class="metric">
<p>OA Conversion Rate</p>
<strong><%= String.format(Locale.US, "%.2f", rate(request.getAttribute("oaConversionRate"))) %>%</strong>
</div>
<div class="metric">
<p>Interview Conversion Rate</p>
<strong><%= String.format(Locale.US, "%.2f", rate(request.getAttribute("interviewConversionRate"))) %>%</strong>
</div>
<div class="metric">
<p>Selection Rate</p>
<strong><%= String.format(Locale.US, "%.2f", rate(request.getAttribute("selectionRate"))) %>%</strong>
</div>
<div class="metric">
<p>Rejected Applications</p>
<strong><%= rejected %></strong>
</div>
</div>
</section>

<section class="dashboard-panel">
<h2>Recent Applications</h2>
<div class="toolbar">
<input id="search" type="search" placeholder="Search company or role..." oninput="filterRows()">
<select id="statusFilter" onchange="filterRows()">
<option value="">All Statuses</option>
<option>Applied</option>
<option>OA</option>
<option>Interview</option>
<option>Selected</option>
<option>Rejected</option>
</select>
</div>

<div class="table-scroll">
<table id="appsTable">
<thead>
<tr>
<th>Company</th>
<th>Role</th>
<th>Deadline</th>
<th>Status</th>
</tr>
</thead>
<tbody>
<% if (apps.isEmpty()) { %>
<tr>
<td colspan="4" class="empty-row">No applications yet. <a href="addApplication.jsp">Add your first application</a>.</td>
</tr>
<% } else { for (Map<String,String> app : apps) { %>
<tr>
<td><%= esc(app.get("company")) %></td>
<td><%= esc(app.get("role")) %></td>
<td><%= esc(app.get("deadline")) %></td>
<td><span class="pill"><%= esc(app.get("status")) %></span></td>
</tr>
<% } } %>
</tbody>
</table>
</div>
</section>
</main>

<script>
function filterRows() {
    const query = document.getElementById("search").value.toLowerCase().trim();
    const statusFilter = document.getElementById("statusFilter").value.toLowerCase();

    document.querySelectorAll("#appsTable tbody tr").forEach(row => {
        if (row.cells.length < 4) return;

        const company = row.cells[0].textContent.toLowerCase();
        const role = row.cells[1].textContent.toLowerCase();
        const status = row.cells[3].textContent.trim().toLowerCase();

        const matchesSearch = company.includes(query) || role.includes(query);
        const matchesStatus = !statusFilter || status === statusFilter;

        row.style.display = matchesSearch && matchesStatus ? "" : "none";
    });
}
</script>
</body>
</html>