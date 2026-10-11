<%@ page import="java.util.List,java.util.Map" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%!
private String esc(Object value) {
    if (value == null) return "";
    return value.toString().replace("&", "&amp;").replace("<", "&lt;")
            .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
}
%>
<%
if (session.getAttribute("userId") == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
}
String context = request.getContextPath();
@SuppressWarnings("unchecked")
List<Map<String, String>> followUps = (List<Map<String, String>>) request.getAttribute("followUps");
if (followUps == null) followUps = java.util.Collections.emptyList();
@SuppressWarnings("unchecked")
Map<String, String> editing = (Map<String, String>) request.getAttribute("editingFollowUp");
boolean isEditing = editing != null;
String formAction = context + "/followups";
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Follow-ups | InternTrack</title>
<link rel="stylesheet" href="<%= esc(context) %>/assets/applications.css">
<style>
.page-shell { margin-top: 36px; }
.page-heading { align-items: center; }
.nav-items { display: flex; align-items: center; gap: 22px; }
.nav-items .nav-link { height: 68px; }
.schedule-panel { margin-bottom: 24px; padding: 24px; border: 1px solid var(--line); border-radius: 13px; background: var(--surface); }
.schedule-panel h2 { margin: 0; font-size: 20px; }
.form-grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 17px; margin-top: 20px; }
.field { min-width: 0; }
.field-wide { grid-column: 1 / -1; }
.field label { display: block; margin-bottom: 7px; font-size: 13px; font-weight: 650; }
.field input, .field textarea { width: 100%; padding: 11px 12px; color: var(--ink); border: 1px solid #dfe3eb; border-radius: 7px; background: #fff; font: inherit; font-size: 14px; }
.field textarea { min-height: 100px; resize: vertical; }
.form-actions { display: flex; justify-content: flex-end; gap: 10px; grid-column: 1 / -1; }
.notice { margin: 0 0 18px; padding: 13px 16px; border: 1px solid #c6eedb; border-radius: 9px; background: #edfaf4; color: #176446; font-size: 14px; }
.notice-error { border-color: #f3cdd0; background: #fff2f2; color: #9a303a; }
.deadline-badge { display: inline-flex; padding: 5px 9px; border-radius: 20px; font-size: 11px; font-weight: 700; white-space: nowrap; }
.deadline-overdue td { background: #fff2f2; }
.deadline-overdue .deadline-badge { color: #9a303a; background: #fbdfe1; }
.deadline-soon td { background: #fffdf5; }
.deadline-soon .deadline-badge { color: #9a6712; background: #fff1c9; }
.deadline-normal .deadline-badge { color: #427456; background: #edf8f0; }
.deadline-completed { color: var(--muted); }
.deadline-completed .deadline-badge { color: #176446; background: #edfaf4; }
.actions-cell { display: flex; align-items: center; gap: 7px; }
.actions-cell form { margin: 0; }
.actions-cell .button { min-height: 33px; padding: 0 10px; font-size: 12px; }
.empty-row { padding: 35px; color: var(--muted); text-align: center; }
.validation-message { grid-column: 1 / -1; margin: 0; color: #9a303a; font-size: 13px; }
@media (max-width: 760px) {
    .nav-items { gap: 12px; }
    .nav-items .nav-link { height: 60px; font-size: 12px; }
    .form-grid { grid-template-columns: 1fr; }
    .field-wide, .form-actions, .validation-message { grid-column: auto; }
}
@media (max-width: 520px) {
    .topbar { padding: 0 12px; }
    .nav-items { gap: 9px; }
    .nav-items .nav-link { font-size: 11px; }
    .schedule-panel { padding: 18px; }
    .form-actions { flex-direction: column-reverse; }
    .form-actions .button { width: 100%; }
    .actions-cell { flex-wrap: wrap; }
}
</style>
</head>
<body>
<header class="topbar">
<a class="brand" href="<%= esc(context) %>/analytics">InternTrack</a>
<nav class="nav-items" aria-label="Main navigation">
<a class="nav-link" href="<%= esc(context) %>/applications.jsp">Applications</a>
<a class="nav-link" href="<%= esc(context) %>/interviews">Interviews</a>
<a class="nav-link" href="<%= esc(context) %>/followups">Follow-ups</a>
</nav>
</header>

<main class="page-shell">
<section class="page-heading">
<div>
<p class="eyebrow">KEEP EVERY NEXT STEP ON TRACK</p>
<h1>Follow-ups</h1>
<p class="subtitle">Track recruiter check-ins and other reminders, with deadlines calculated automatically.</p>
</div>
<a class="button button-secondary" href="<%= esc(context) %>/analytics">Dashboard</a>
</section>

<% String error = request.getParameter("error"); %>
<% if (error != null) { %>
<div class="notice notice-error" role="alert">
<% if ("notfound".equals(error)) { %>That follow-up could not be found.
<% } else { %>Please check the follow-up details and try again.<% } %>
</div>
<% } %>
<% if ("1".equals(request.getParameter("added"))) { %><div class="notice">Follow-up added successfully.</div><% } %>
<% if ("1".equals(request.getParameter("updated"))) { %><div class="notice">Follow-up updated successfully.</div><% } %>
<% if ("1".equals(request.getParameter("deleted"))) { %><div class="notice">Follow-up deleted successfully.</div><% } %>

<section class="schedule-panel" aria-labelledby="follow-up-form-title">
<h2 id="follow-up-form-title"><%= isEditing ? "Edit follow-up" : "Add a follow-up" %></h2>
<form id="follow-up-form" action="<%= esc(formAction) %>" method="post">
<input type="hidden" name="action" value="save">
<% if (isEditing) { %><input type="hidden" name="id" value="<%= esc(editing.get("id")) %>"><% } %>
<div class="form-grid">
<div class="field field-wide">
<label for="description">What do you need to follow up on? <span aria-hidden="true">*</span></label>
<input id="description" name="description" maxlength="255" required
       placeholder="e.g. Email recruiter after final interview"
       value="<%= isEditing ? esc(editing.get("description")) : "" %>">
</div>
<div class="field">
<label for="dueDate">Due date <span aria-hidden="true">*</span></label>
<input id="dueDate" name="dueDate" type="date" required
       value="<%= isEditing ? esc(editing.get("dueDate")) : "" %>">
</div>
<div class="field field-wide">
<label for="notes">Notes <span class="optional">(optional)</span></label>
<textarea id="notes" name="notes" maxlength="5000" rows="3"
          placeholder="Add context or a reminder"><%= isEditing ? esc(editing.get("notes")) : "" %></textarea>
</div>
<p id="follow-up-validation" class="validation-message" role="alert" hidden></p>
<div class="form-actions">
<% if (isEditing) { %><a class="button button-secondary" href="<%= esc(context) %>/followups">Cancel</a><% } %>
<button class="button button-primary" type="submit"><%= isEditing ? "Save changes" : "Add follow-up" %></button>
</div>
</div>
</form>
</section>

<div class="panel">
<div class="table-scroll">
<table>
<thead><tr><th>Follow-up</th><th>Due date</th><th>Status</th><th>Deadline</th><th>Notes</th><th>Actions</th></tr></thead>
<tbody id="follow-up-list">
<% if (followUps.isEmpty()) { %>
<tr><td colspan="6" class="empty-row">No follow-ups yet. Add a reminder above to keep your next step visible.</td></tr>
<% } else { for (Map<String, String> followUp : followUps) { boolean completed = "true".equals(followUp.get("completed")); %>
<tr class="<%= esc(followUp.get("deadlineClass")) %>"
    data-due-date="<%= esc(followUp.get("dueDate")) %>" data-completed="<%= completed %>">
<td data-label="Follow-up"><span class="company"><%= esc(followUp.get("description")) %></span></td>
<td data-label="Due date"><%= esc(followUp.get("dueDate")) %></td>
<td data-label="Status"><span class="badge"><%= completed ? "Completed" : "Pending" %></span></td>
<td data-label="Deadline"><span class="deadline-badge"><%= esc(followUp.get("deadlineLabel")) %></span></td>
<td data-label="Notes"><%= followUp.get("notes").isEmpty() ? "<span class=\"muted\">No notes</span>" : esc(followUp.get("notes")) %></td>
<td data-label="Actions" class="actions-cell">
<form action="<%= esc(formAction) %>" method="post">
<input type="hidden" name="action" value="toggle"><input type="hidden" name="id" value="<%= esc(followUp.get("id")) %>">
<input type="hidden" name="completed" value="<%= completed ? "false" : "true" %>">
<button class="button button-secondary" type="submit"><%= completed ? "Mark pending" : "Complete" %></button>
</form>
<a class="button button-secondary" href="<%= esc(context) %>/followups?edit=<%= esc(followUp.get("id")) %>">Edit</a>
<form action="<%= esc(formAction) %>" method="post" onsubmit="return confirm('Delete this follow-up?');">
<input type="hidden" name="action" value="delete"><input type="hidden" name="id" value="<%= esc(followUp.get("id")) %>">
<button class="button button-danger" type="submit">Delete</button>
</form>
</td>
</tr>
<% } } %>
</tbody>
</table>
</div>
</div>
</main>
<script>
(() => {
    const form = document.getElementById("follow-up-form");
    const dueDate = document.getElementById("dueDate");
    const validation = document.getElementById("follow-up-validation");

    form.addEventListener("submit", event => {
        validation.hidden = true;
        validation.textContent = "";
        dueDate.setCustomValidity("");
        const [year, month, day] = dueDate.value.split("-").map(Number);
        const parsedDate = new Date(year, month - 1, day);
        const validDate = /^\d{4}-\d{2}-\d{2}$/.test(dueDate.value)
            && parsedDate.getFullYear() === year
            && parsedDate.getMonth() === month - 1
            && parsedDate.getDate() === day;
        if (dueDate.value && !validDate) {
            dueDate.setCustomValidity("Enter a valid due date.");
            validation.textContent = "Enter a valid due date.";
            validation.hidden = false;
        }
        if (!form.checkValidity()) {
            event.preventDefault();
            form.reportValidity();
        }
    });

    function updateFollowUpDeadlines() {
        const now = new Date();
        const today = Date.UTC(now.getFullYear(), now.getMonth(), now.getDate());
        document.querySelectorAll("#follow-up-list tr[data-due-date]").forEach(row => {
            const [year, month, day] = row.dataset.dueDate.split("-").map(Number);
            const due = Date.UTC(year, month - 1, day);
            const daysRemaining = Math.round((due - today) / 86400000);
            const completed = row.dataset.completed === "true";
            let label = "Upcoming";
            let deadlineClass = "deadline-normal";
            if (completed) {
                label = "Completed";
                deadlineClass = "deadline-completed";
            } else if (daysRemaining < 0) {
                label = "Overdue";
                deadlineClass = "deadline-overdue";
            } else if (daysRemaining <= 3) {
                label = daysRemaining === 0 ? "Due today" : "Due soon";
                deadlineClass = "deadline-soon";
            } else {
                label = "In " + daysRemaining + " days";
            }
            row.classList.remove("deadline-overdue", "deadline-soon", "deadline-normal", "deadline-completed");
            row.classList.add(deadlineClass);
            row.querySelector(".deadline-badge").textContent = label;
        });
    }

    updateFollowUpDeadlines();
    window.addEventListener("pageshow", updateFollowUpDeadlines);
    document.addEventListener("visibilitychange", () => {
        if (!document.hidden) updateFollowUpDeadlines();
    });
})();
</script>
</body>
</html>
