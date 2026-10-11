package com.internshiptracker.servlet;

import com.internshiptracker.dao.ApplicationDao;
import com.internshiptracker.model.Application;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;
import java.util.regex.Pattern;

@WebServlet("/applications")
public class ApplicationServlet extends HttpServlet {
    private static final String DASHBOARD = "/WEB-INF/views/applications.jsp";
    private static final String FORM = "/WEB-INF/views/addApplication.jsp";
    private static final Set<String> PRIORITIES =
            Collections.unmodifiableSet(new HashSet<String>(Arrays.asList("High", "Medium", "Low")));
    private static final Set<String> STATUSES = Collections.unmodifiableSet(new HashSet<String>(
            Arrays.asList("Applied", "Assessment", "Interview", "Offer", "Rejected", "Withdrawn")));
    private static final Pattern ID_PATTERN = Pattern.compile("[1-9][0-9]*");
    private final ApplicationDao applicationDao = new ApplicationDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("new".equals(action)) {
            showForm(request, response, new Application(), "create");
        } else if ("edit".equals(action)) {
            showEditForm(request, response);
        } else {
            showDashboard(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if ("create".equals(action)) {
            save(request, response, false);
        } else if ("update".equals(action)) {
            save(request, response, true);
        } else if ("delete".equals(action)) {
            delete(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        }
    }

    private void showDashboard(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            request.setAttribute("applications", applicationDao.findAll());
        } catch (SQLException exception) {
            log("Unable to load internship applications.", exception);
            request.setAttribute("errorMessage",
                    "Applications could not be loaded. Check the database configuration and try again.");
        }
        setNotice(request);
        request.getRequestDispatcher(DASHBOARD).forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Long id = parseId(request.getParameter("id"));
        if (id == null) {
            redirect(response, request, "invalid-id");
            return;
        }
        try {
            Application application = applicationDao.findById(id);
            if (application == null) {
                redirect(response, request, "not-found");
                return;
            }
            showForm(request, response, application, "update");
        } catch (SQLException exception) {
            log("Unable to load an internship application for editing.", exception);
            request.setAttribute("errorMessage",
                    "This application could not be loaded. Check the database configuration and try again.");
            showDashboard(request, response);
        }
    }

    private void showForm(HttpServletRequest request, HttpServletResponse response,
                          Application application, String formAction)
            throws ServletException, IOException {
        request.setAttribute("application", application);
        request.setAttribute("formAction", formAction);
        request.getRequestDispatcher(FORM).forward(request, response);
    }

    private void save(HttpServletRequest request, HttpServletResponse response, boolean updating)
            throws ServletException, IOException {
        Application application = readApplication(request);
        if (updating) {
            Long id = parseId(request.getParameter("id"));
            if (id == null) {
                redirect(response, request, "invalid-id");
                return;
            }
            application.setId(id);
        }

        String validationError = validate(application);
        if (validationError != null) {
            request.setAttribute("errorMessage", validationError);
            showForm(request, response, application, updating ? "update" : "create");
            return;
        }

        try {
            if (updating) {
                if (!applicationDao.update(application)) {
                    redirect(response, request, "not-found");
                    return;
                }
                redirect(response, request, "updated");
            } else {
                applicationDao.insert(application);
                redirect(response, request, "created");
            }
        } catch (SQLException exception) {
            log("Unable to save an internship application.", exception);
            request.setAttribute("errorMessage",
                    "The application could not be saved. Check the database configuration and try again.");
            showForm(request, response, application, updating ? "update" : "create");
        }
    }

    private void delete(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Long id = parseId(request.getParameter("id"));
        if (id == null) {
            redirect(response, request, "invalid-id");
            return;
        }
        try {
            redirect(response, request, applicationDao.delete(id) ? "deleted" : "not-found");
        } catch (SQLException exception) {
            log("Unable to delete an internship application.", exception);
            redirect(response, request, "operation-failed");
        }
    }

    private Application readApplication(HttpServletRequest request) {
        Application application = new Application();
        application.setCompanyName(trim(request.getParameter("companyName")));
        application.setRole(trim(request.getParameter("role")));
        application.setDeadline(trim(request.getParameter("deadline")));
        application.setPriority(trim(request.getParameter("priority")));
        application.setStatus(trim(request.getParameter("status")));
        application.setApplicationLink(trim(request.getParameter("applicationLink")));
        return application;
    }

    private String validate(Application application) {
        if (isBlank(application.getCompanyName()) || isBlank(application.getRole())
                || isBlank(application.getDeadline()) || isBlank(application.getPriority())
                || isBlank(application.getStatus())) {
            return "Company, role, deadline, priority, and status are required.";
        }
        if (application.getCompanyName().length() > 150 || application.getRole().length() > 150) {
            return "Company and role must each be 150 characters or fewer.";
        }
        try {
            LocalDate.parse(application.getDeadline());
        } catch (DateTimeParseException exception) {
            return "Enter a valid application deadline.";
        }
        if (!PRIORITIES.contains(application.getPriority())) {
            return "Choose High, Medium, or Low priority.";
        }
        if (!STATUSES.contains(application.getStatus())) {
            return "Choose a valid application status.";
        }
        String link = application.getApplicationLink();
        if (link != null && !link.isEmpty()) {
            if (link.length() > 2048 || !isHttpUrl(link)) {
                return "Enter a valid application link beginning with http:// or https://.";
            }
        }
        return null;
    }

    private boolean isHttpUrl(String value) {
        try {
            URI uri = new URI(value);
            String scheme = uri.getScheme();
            return uri.isAbsolute() && uri.getHost() != null
                    && ("http".equalsIgnoreCase(scheme) || "https".equalsIgnoreCase(scheme));
        } catch (URISyntaxException exception) {
            return false;
        }
    }

    private Long parseId(String value) {
        if (value == null || !ID_PATTERN.matcher(value).matches()) {
            return null;
        }
        try {
            return Long.valueOf(value);
        } catch (NumberFormatException exception) {
            return null;
        }
    }

    private void setNotice(HttpServletRequest request) {
        String notice = request.getParameter("notice");
        if (notice == null) {
            return;
        }
        switch (notice) {
            case "created":
                request.setAttribute("successMessage", "Application added successfully.");
                break;
            case "updated":
                request.setAttribute("successMessage", "Application updated successfully.");
                break;
            case "deleted":
                request.setAttribute("successMessage", "Application deleted successfully.");
                break;
            case "not-found":
                request.setAttribute("errorMessage", "That application no longer exists.");
                break;
            case "invalid-id":
                request.setAttribute("errorMessage", "The application ID is invalid.");
                break;
            case "operation-failed":
                request.setAttribute("errorMessage", "The application could not be deleted.");
                break;
            default:
                break;
        }
    }

    private void redirect(HttpServletResponse response, HttpServletRequest request, String notice)
            throws IOException {
        response.sendRedirect(request.getContextPath() + "/applications?notice=" + notice);
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}
