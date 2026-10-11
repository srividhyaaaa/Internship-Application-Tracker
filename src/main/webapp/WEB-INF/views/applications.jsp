<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Applications | Internship Tracker</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/applications.css">
</head>
<body>
<header class="topbar">
    <a class="brand" href="${pageContext.request.contextPath}/applications">Internship Tracker</a>
    <nav aria-label="Main navigation"><a class="nav-link active" href="${pageContext.request.contextPath}/applications">Applications</a></nav>
</header>
<main class="page-shell">
    <section class="page-heading">
        <div>
            <p class="eyebrow">YOUR CAREER JOURNEY</p>
            <h1>Applications</h1>
            <p class="subtitle">Keep every opportunity organized, from first application to final offer.</p>
        </div>
        <a class="button button-primary" href="${pageContext.request.contextPath}/applications?action=new">＋ Add application</a>
    </section>

    <c:if test="${not empty successMessage}">
        <div class="alert alert-success" role="status"><c:out value="${successMessage}"/></div>
    </c:if>
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-error" role="alert"><c:out value="${errorMessage}"/></div>
    </c:if>

    <section class="panel" aria-label="Saved applications">
        <c:choose>
            <c:when test="${not empty applications}">
                <div class="table-scroll">
                    <table>
                        <thead>
                        <tr>
                            <th scope="col">Company &amp; role</th>
                            <th scope="col">Deadline</th>
                            <th scope="col">Priority</th>
                            <th scope="col">Status</th>
                            <th scope="col">Application link</th>
                            <th scope="col"><span class="visually-hidden">Actions</span></th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="application" items="${applications}">
                            <tr>
                                <td data-label="Company &amp; role">
                                    <span class="company"><c:out value="${application.companyName}"/></span>
                                    <span class="role"><c:out value="${application.role}"/></span>
                                </td>
                                <td data-label="Deadline"><c:out value="${application.deadline}"/></td>
                                <td data-label="Priority">
                                    <c:choose>
                                        <c:when test="${application.priority eq 'High'}"><span class="badge priority-high">High</span></c:when>
                                        <c:when test="${application.priority eq 'Low'}"><span class="badge priority-low">Low</span></c:when>
                                        <c:otherwise><span class="badge priority-medium">Medium</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td data-label="Status"><span class="badge status"><c:out value="${application.status}"/></span></td>
                                <td data-label="Application link">
                                    <c:choose>
                                        <c:when test="${not empty application.applicationLink}">
                                            <a class="external-link" href="<c:out value='${application.applicationLink}'/>" target="_blank" rel="noopener noreferrer">Open link <span aria-hidden="true">↗</span></a>
                                        </c:when>
                                        <c:otherwise><span class="muted">—</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="actions-cell" data-label="Actions">
                                    <a class="button button-small button-secondary" href="${pageContext.request.contextPath}/applications?action=edit&amp;id=${application.id}">Edit</a>
                                    <form class="inline-form" method="post" action="${pageContext.request.contextPath}/applications" onsubmit="return confirm('Delete this application? This cannot be undone.');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id" value="<c:out value='${application.id}'/>">
                                        <button class="button button-small button-danger" type="submit">Delete</button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:when>
            <c:otherwise>
                <div class="empty-state">
                    <div class="empty-icon" aria-hidden="true">✦</div>
                    <h2>No applications yet</h2>
                    <p>Your next opportunity starts here. Add an application to keep its deadline and progress close at hand.</p>
                    <a class="button button-primary" href="${pageContext.request.contextPath}/applications?action=new">Add your first application</a>
                </div>
            </c:otherwise>
        </c:choose>
    </section>
</main>
</body>
</html>
