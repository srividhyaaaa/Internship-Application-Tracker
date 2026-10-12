
<%@ page import="java.util.List,java.util.Map" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%!
private String esc(Object value) {
    if (value == null) return "";
    return value.toString()
        .replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace("\"", "&quot;")
        .replace("'", "&#39;");
}
%>

<%
if (session.getAttribute("userId") == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
}

String context = request.getContextPath();

@SuppressWarnings("unchecked")
List<Map<String, String>> interviews =
    (List<Map<String, String>>) request.getAttribute("interviews");

if (interviews == null) {
    interviews = java.util.Collections.emptyList();
}

@SuppressWarnings("unchecked")
Map<String, String> editing =
    (Map<String, String>) request.getAttribute("editingInterview");

boolean isEditing = editing != null;
String formAction = context + "/interviews";
String selectedMode = isEditing ? editing.get("mode") : "";
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Interviews | InternTrack</title>

<link rel="stylesheet"
      href="<%= esc(context) %>/assets/applications.css">

<style>
.page-shell { margin-top: 36px; }
.page-heading { align-items: center; }

.nav-items {
    display: flex;
    align-items: center;
    gap: 22px;
}

.nav-items .nav-link { height: 68px; }

.schedule-panel {
    margin-bottom: 24px;
    padding: 24px;
    border: 1px solid var(--line);
    border-radius: 13px;
    background: var(--surface);
}

.schedule-panel h2 { margin: 0; font-size: 20px; }

.form-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 17px;
    margin-top: 20px;
}

.field { min-width: 0; }
.field-wide { grid-column: 1 / -1; }

.field label {
    display: block;
    margin-bottom: 7px;
    font-size: 13px;
    font-weight: 650;
}

.field input,
.field select,
.field textarea {
    width: 100%;
    padding: 11px 12px;
    color: var(--ink);
    border: 1px solid #dfe3eb;
    border-radius: 7px;
    background: #fff;
    font: inherit;
    font-size: 14px;
    box-sizing: border-box;
}

.field textarea { min-height: 105px; resize: vertical; }

.form-actions {
    display: flex;
    justify-content: flex-end;
    gap: 10px;
    grid-column: 1 / -1;
}

.notice {
    margin: 0 0 18px;
    padding: 13px 16px;
    border: 1px solid #c6eedb;
    border-radius: 9px;
    background: #edfaf4;
    color: #176446;
    font-size: 14px;
}

.notice-error {
    border-color: #f3cdd0;
    background: #fff2f2;
    color: #9a303a;
}

.actions-cell {
    display: flex;
    align-items: center;
    gap: 7px;
}

.actions-cell form { margin: 0; }

.actions-cell .button {
    min-height: 33px;
    padding: 0 10px;
    font-size: 12px;
}

.timeline-label {
    display: inline-flex;
    padding: 5px 9px;
    border-radius: 20px;
    font-size: 11px;
    font-weight: 700;
    white-space: nowrap;
}

.timeline-upcoming .timeline-label {
    color: #176446;
    background: #edfaf4;
}

.timeline-soon .timeline-label {
    color: #9a6712;
    background: #fff7e6;
}

.timeline-past .timeline-label {
    color: #737b8d;
    background: #f0f1f4;
}

.timeline-soon td { background: #fffdf7; }
.timeline-past { color: #737b8d; }

.notes-cell {
    min-width: 150px;
    max-width: 280px;
    white-space: pre-wrap;
    overflow-wrap: anywhere;
}

.empty-row {
    padding: 35px;
    color: var(--muted);
    text-align: center;
}

.validation-message {
    grid-column: 1 / -1;
    margin: 0;
    color: #9a303a;
    font-size: 13px;
}

@media (max-width: 760px) {
    .nav-items { gap: 12px; }
    .nav-items .nav-link { height: 60px; font-size: 12px; }
    .form-grid { grid-template-columns: 1fr; }
    .field-wide, .form-actions, .validation-message {
        grid-column: auto;
    }
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
        <a class="nav-link"
           href="<%= esc(context) %>/applications.jsp">Applications</a>
        <a class="nav-link"
           href="<%= esc(context) %>/interviews">Interviews</a>
        <a class="nav-link"
           href="<%= esc(context) %>/followups">Follow-ups</a>
    </nav>
</header>

<main class="page-shell">

<section class="page-heading">
    <div>
        <p class="eyebrow">YOUR INTERVIEW SCHEDULE</p>
        <h1>Interviews</h1>
        <p class="subtitle">
            Keep your interview dates, company details, and preparation notes together.
        </p>
    </div>

    <a class="button button-secondary"
       href="<%= esc(context) %>/analytics">Dashboard</a>
</section>

<%
String error = request.getParameter("error");
if (error != null) {
%>
<div class="notice notice-error" role="alert">
    <% if ("past".equals(error)) { %>
        Choose a future date and time.
    <% } else if ("notfound".equals(error)) { %>
        That interview could not be found.
    <% } else { %>
        Please check the interview details and try again.
    <% } %>
</div>
<% } %>

<% if ("1".equals(request.getParameter("added"))) { %>
<div class="notice">Interview scheduled successfully.</div>
<% } %>

<% if ("1".equals(request.getParameter("updated"))) { %>
<div class="notice">Interview updated successfully.</div>
<% } %>

<% if ("1".equals(request.getParameter("deleted"))) { %>
<div class="notice">Interview deleted successfully.</div>
<% } %>

<section class="schedule-panel" aria-labelledby="interview-form-title">

    <h2 id="interview-form-title">
        <%= isEditing ? "Edit interview" : "Schedule an interview" %>
    </h2>

    <form id="interview-form"
          action="<%= esc(formAction) %>"
          method="post"
          data-original-datetime="<%= isEditing ? esc(editing.get("dateTime")) : "" %>">

        <input type="hidden" name="action" value="save">

        <% if (isEditing) { %>
        <input type="hidden" name="id"
               value="<%= esc(editing.get("id")) %>">
        <% } %>

        <div class="form-grid">

            <div class="field">
                <label for="company">Company *</label>
                <input id="company" name="company" maxlength="255" required
                       placeholder="e.g. Infosys"
                       value="<%= isEditing ? esc(editing.get("company")) : "" %>">
            </div>

            <div class="field">
                <label for="position">Job position *</label>
                <input id="position" name="position" maxlength="255" required
                       placeholder="e.g. Software Engineer"
                       value="<%= isEditing ? esc(editing.get("position")) : "" %>">
            </div>

            <div class="field">
                <label for="dateTime">Interview date and time *</label>
                <input id="dateTime" name="dateTime"
                       type="datetime-local" required
                       value="<%= isEditing ? esc(editing.get("dateTime")) : "" %>"
                       min="<%= esc(request.getAttribute("now")) %>">
            </div>

            <div class="field">
                <label for="mode">Interview type *</label>
                <select id="mode" name="mode" required>
                    <option value="">Choose a type</option>
                    <option value="Online"
                        <%= "Online".equals(selectedMode) ? "selected" : "" %>>
                        Online
                    </option>
                    <option value="Phone"
                        <%= "Phone".equals(selectedMode) ? "selected" : "" %>>
                        Phone
                    </option>
                    <option value="In-person"
                        <%= "In-person".equals(selectedMode) ? "selected" : "" %>>
                        In-person
                    </option>
                </select>
            </div>

            <div class="field field-wide">
                <label for="location">Location or meeting link (optional)</label>
                <input id="location" name="location" maxlength="255"
                       placeholder="Office address or online meeting link"
                       value="<%= isEditing ? esc(editing.get("location")) : "" %>">
            </div>

            <div class="field field-wide">
                <label for="notes">Preparation notes (optional)</label>
                <textarea id="notes" name="notes" maxlength="5000" rows="4"
                          placeholder="Topics to review or questions to ask"><%= isEditing ? esc(editing.get("notes")) : "" %></textarea>
            </div>

            <p id="interview-validation"
               class="validation-message" role="alert" hidden></p>

            <div class="form-actions">
                <% if (isEditing) { %>
                <a class="button button-secondary"
                   href="<%= esc(context) %>/interviews">Cancel</a>
                <% } %>

                <button class="button button-primary" type="submit">
                    <%= isEditing ? "Save changes" : "Schedule interview" %>
                </button>
            </div>

        </div>
    </form>
</section>

<div class="panel">
    <div class="table-scroll">
        <table>
            <thead>
                <tr>
                    <th>Company</th>
                    <th>Position</th>
                    <th>Date and time</th>
                    <th>Type</th>
                    <th>Location</th>
                    <th>Notes</th>
                    <th>Timing</th>
                    <th>Actions</th>
                </tr>
            </thead>

            <tbody id="interview-list">

            <% if (interviews.isEmpty()) { %>
                <tr>
                    <td colspan="8" class="empty-row">
                        No interviews scheduled yet. Add your next interview above.
                    </td>
                </tr>
            <% } else {
                for (Map<String, String> interview : interviews) {
            %>
                <tr class="<%= esc(interview.get("timelineClass")) %>"
                    data-interview-at="<%= esc(interview.get("dateTime")) %>">

                    <td data-label="Company">
                        <span class="company">
                            <%= esc(interview.get("company")) %>
                        </span>
                    </td>

                    <td data-label="Position">
                        <%= esc(interview.get("position")) %>
                    </td>

                    <td data-label="Date and time">
                        <%= esc(interview.get("dateTime").replace('T', ' ')) %>
                    </td>

                    <td data-label="Type">
                        <%= esc(interview.get("mode")) %>
                    </td>

                    <td data-label="Location">
                        <%= esc(interview.get("location")) %>
                    </td>

                    <td data-label="Notes" class="notes-cell">
                        <% if (interview.get("notes").isEmpty()) { %>
                            <span class="muted">No notes</span>
                        <% } else { %>
                            <%= esc(interview.get("notes")) %>
                        <% } %>
                    </td>

                    <td data-label="Timing">
                        <span class="timeline-label">
                            <%= esc(interview.get("timelineLabel")) %>
                        </span>
                    </td>

                    <td data-label="Actions" class="actions-cell">
                        <a class="button button-secondary"
                           href="<%= esc(context) %>/interviews?edit=<%= esc(interview.get("id")) %>">
                            Edit
                        </a>

                        <form action="<%= esc(formAction) %>"
                              method="post"
                              onsubmit="return confirm('Delete this interview?');">

                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="id"
                                   value="<%= esc(interview.get("id")) %>">

                            <button class="button button-danger" type="submit">
                                Delete
                            </button>
                        </form>
                    </td>
                </tr>
            <%
                }
            }
            %>

            </tbody>
        </table>
    </div>
</div>

</main>

<script>
(() => {
    const form = document.getElementById("interview-form");
    const dateTime = document.getElementById("dateTime");
    const validation = document.getElementById("interview-validation");

    form.addEventListener("submit", event => {
        validation.hidden = true;
        validation.textContent = "";
        dateTime.setCustomValidity("");

        if (dateTime.value) {
            const chosen = new Date(dateTime.value);
            const original = form.dataset.originalDatetime;
            const mayKeepExisting =
                original !== "" && dateTime.value === original;

            if (Number.isNaN(chosen.getTime()) ||
                (!mayKeepExisting && chosen <= new Date())) {
                dateTime.setCustomValidity(
                    "Choose a future interview date and time."
                );
                validation.textContent =
                    "Choose a future interview date and time.";
                validation.hidden = false;
            }
        }

        if (!form.checkValidity()) {
            event.preventDefault();
            form.reportValidity();
        }
    });

    function updateInterviewLabels() {
        const now = new Date();

        document.querySelectorAll(
            "#interview-list tr[data-interview-at]"
        ).forEach(row => {
            const scheduled = new Date(row.dataset.interviewAt);
            const isPast = scheduled < now;
            const isSoon =
                !isPast && scheduled - now <= 48 * 60 * 60 * 1000;

            row.classList.toggle("timeline-past", isPast);
            row.classList.toggle("timeline-soon", isSoon);
            row.classList.toggle("timeline-upcoming", !isPast && !isSoon);

            const label = row.querySelector(".timeline-label");

            if (label) {
                label.textContent = isPast
                    ? "Past"
                    : (isSoon ? "Soon" : "Upcoming");
            }
        });
    }

    updateInterviewLabels();
    window.addEventListener("pageshow", updateInterviewLabels);

    document.addEventListener("visibilitychange", () => {
        if (!document.hidden) updateInterviewLabels();
    });
})();
</script>

</body>
</html>