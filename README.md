# Internship-Application-Tracker

## Application management

This repository currently contains the Application Management module as a Java 8-compatible Maven WAR application. It uses the `javax.servlet` API and is intended for a Servlet 4.0 container such as Apache Tomcat 9.

### Database setup

1. Run [`database/schema.sql`](database/schema.sql) against MySQL 8.0.16 or newer (the schema uses enforced `CHECK` constraints). The script creates the `internship_tracker` database and the `applications` table if they do not already exist; it does not drop or modify existing records.
2. Configure the web-container process with `DB_USER` and `DB_PASSWORD`. Optionally set `DB_URL` to override the default URL `jdbc:mysql://localhost:3306/internship_tracker?useSSL=false&serverTimezone=UTC`. No database credentials are stored in the project.
3. Build with `mvn clean package` and deploy `target/internship-application-tracker.war` to Tomcat 9. Open `/internship-application-tracker/applications`.

The only servlet mapping is `/applications`. Its GET routes display the dashboard, add form, and edit form; POST routes create, update, and delete. JSP views are under `WEB-INF` and are reached through the servlet. All application records are currently shared in one table because this checkout contains no authentication or user-ownership infrastructure.

If an existing deployment uses a different Servlet generation or a shared team database utility, integrate those shared components before deployment; this checkout contains no existing Java/JSP/build/database conventions to inherit.