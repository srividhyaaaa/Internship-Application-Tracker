<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><c:choose><c:when test="${formAction eq 'update'}">Edit application</c:when><c:otherwise>Add application</c:otherwise></c:choose> | Internship Tracker</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/applications.css">
</head>
<body>
<header class="topbar">
    <a class="brand" href="${pageContext.request.contextPath}/applications">Internship Tracker</a>
    <nav aria-label="Main navigation"><a class="nav-link active" href="${pageContext.request.contextPath}/applications">Applications</a></nav>
</header>
<main class="page-shell form-shell">
    <a class="back-link" href="${pageContext.request.contextPath}/applications">← Back to applications</a>
    <section class="form-card">
        <p class="eyebrow">APPLICATION DETAILS</p>
        <h1><c:choose><c:when test="${formAction eq 'update'}">Edit application</c:when><c:otherwise>Add an application</c:otherwise></c:choose></h1>
        <p class="subtitle">Save the details now; you can update the status as you move through the process.</p>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-error" role="alert"><c:out value="${errorMessage}"/></div>
        </c:if>

        <form method="post" action="${pageContext.request.contextPath}/applications">
            <input type="hidden" name="action" value="<c:out value='${formAction}'/>">
            <c:if test="${formAction eq 'update'}">
                <input type="hidden" name="id" value="<c:out value='${application.id}'/>">
            </c:if>
            <div class="form-grid">
                <div class="field">
                    <label for="companyName">Company name <span class="required">*</span></label>
                    <input id="companyName" name="companyName" type="text" maxlength="150" autocomplete="organization" required value="<c:out value='${application.companyName}'/>" placeholder="e.g. Acme Labs">
                </div>
                <div class="field">
                    <label for="role">Internship / job role <span class="required">*</span></label>
                    <input id="role" name="role" type="text" maxlength="150" required value="<c:out value='${application.role}'/>" placeholder="e.g. Software Engineering Intern">
                </div>
                <div class="field">
                    <label for="deadline">Application deadline <span class="required">*</span></label>
                    <input id="deadline" name="deadline" type="date" required value="<c:out value='${application.deadline}'/>">
                </div>
                <div class="field">
                    <label for="priority">Priority <span class="required">*</span></label>
                    <select id="priority" name="priority" required>
                        <option value="">Choose a priority</option>
                        <option value="High" <c:if test="${application.priority eq 'High'}">selected</c:if>>High</option>
                        <option value="Medium" <c:if test="${application.priority eq 'Medium'}">selected</c:if>>Medium</option>
                        <option value="Low" <c:if test="${application.priority eq 'Low'}">selected</c:if>>Low</option>
                    </select>
                </div>
                <div class="field">
                    <label for="status">Application status <span class="required">*</span></label>
                    <select id="status" name="status" required>
                        <option value="">Choose a status</option>
                        <option value="Applied" <c:if test="${application.status eq 'Applied'}">selected</c:if>>Applied</option>
                        <option value="Assessment" <c:if test="${application.status eq 'Assessment'}">selected</c:if>>Assessment</option>
                        <option value="Interview" <c:if test="${application.status eq 'Interview'}">selected</c:if>>Interview</option>
                        <option value="Offer" <c:if test="${application.status eq 'Offer'}">selected</c:if>>Offer</option>
                        <option value="Rejected" <c:if test="${application.status eq 'Rejected'}">selected</c:if>>Rejected</option>
                        <option value="Withdrawn" <c:if test="${application.status eq 'Withdrawn'}">selected</c:if>>Withdrawn</option>
                    </select>
                </div>
                <div class="field field-wide">
                    <label for="applicationLink">Application link <span class="optional">(optional)</span></label>
                    <input id="applicationLink" name="applicationLink" type="url" maxlength="2048" inputmode="url" value="<c:out value='${application.applicationLink}'/>" placeholder="https://company.com/careers/role">
                    <span class="field-help">Include the job posting or application portal URL.</span>
                </div>
            </div>
            <div class="form-actions">
                <a class="button button-secondary" href="${pageContext.request.contextPath}/applications">Cancel</a>
                <button class="button button-primary" type="submit"><c:choose><c:when test="${formAction eq 'update'}">Save changes</c:when><c:otherwise>Save application</c:otherwise></c:choose></button>
            </div>
        </form>
    </section>
</main>
</body>
</html>
