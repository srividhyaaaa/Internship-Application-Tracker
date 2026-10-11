# InternTrack merged project

This version combines the existing login/register/logout flow with the dashboard, analytics, and application management features.

## Before running
1. Open `src/com/interntrack/DBConnection.java`.
2. Replace `YOUR_MYSQL_PASSWORD` with your local MySQL password.
3. In MySQL Workbench, run `database.sql`. If your `applications` table already exists with these columns, keep your existing data.
4. Keep `mysql-connector-j-26.7.0.jar` in `WEB-INF/lib`.

## Java files added
- `AnalyticsServlet.java`
- `AddApplicationServlet.java`
- `EditApplicationServlet.java`
- `DeleteApplicationServlet.java`
- `RegisterServlet.java` (source included for a clean rebuild)

They use the logged-in session's `userId`; applications are not hard-coded to user ID 1.

## Compile on Tomcat 10.1
From the `InternTrack` folder, compile the source files using the `servlet-api.jar` from your Tomcat `lib` folder. Example PowerShell commands:

```powershell
javac --release 26 -cp "..\\..\\lib\\servlet-api.jar;WEB-INF\\lib\\mysql-connector-j-26.7.0.jar" -d "WEB-INF\\classes" "src\\com\\interntrack\\DBConnection.java" "src\\com\\interntrack\\AnalyticsServlet.java" "src\\com\\interntrack\\AddApplicationServlet.java" "src\\com\\interntrack\\EditApplicationServlet.java" "src\\com\\interntrack\\DeleteApplicationServlet.java" "src\\com\\interntrack\\LoginServlet.java" "src\\com\\interntrack\\LogoutServlet.java" "src\\com\\interntrack\\PasswordUtil.java" "src\\com\\interntrack\\RegisterServlet.java"
```

The compiled files will be placed in `WEB-INF/classes/com/interntrack`. The zip includes the source for login, register, logout, password utilities, and all added servlets; compile all source files before running.

## URLs
- Login: `/InternTrack/login.jsp`
- Dashboard: `/InternTrack/analytics` (requires login)
- Add application: `/InternTrack/addApplication.jsp`
- All applications: `/InternTrack/applications.jsp`
