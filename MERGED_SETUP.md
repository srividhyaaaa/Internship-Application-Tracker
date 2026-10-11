# InternTrack merged project

This version combines the existing login/register/logout flow with the dashboard, analytics, and application management features.

## Before running
1. Set the `INTERNTRACK_DB_USER` and `INTERNTRACK_DB_PASSWORD` environment variables used by `DBConnection`.
2. In MySQL Workbench, run `database.sql`. It creates the `interviews` and `follow_ups` tables alongside the existing schema; existing application data is unchanged.
3. Keep `mysql-connector-j-26.7.0.jar` in `WEB-INF/lib`.

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
javac --release 11 -cp "..\\..\\lib\\servlet-api.jar;WEB-INF\\lib\\mysql-connector-j-26.7.0.jar" -d "WEB-INF\\classes" "src\\com\\interntrack\\DBConnection.java" "src\\com\\interntrack\\AnalyticsServlet.java" "src\\com\\interntrack\\AddApplicationServlet.java" "src\\com\\interntrack\\EditApplicationServlet.java" "src\\com\\interntrack\\DeleteApplicationServlet.java" "src\\com\\interntrack\\InterviewServlet.java" "src\\com\\interntrack\\FollowUpServlet.java" "src\\com\\interntrack\\LoginServlet.java" "src\\com\\interntrack\\LogoutServlet.java" "src\\com\\interntrack\\PasswordUtil.java" "src\\com\\interntrack\\RegisterServlet.java"
```

The compiled files will be placed in `WEB-INF/classes/com/interntrack`. The zip includes the source for login, register, logout, password utilities, and all added servlets; compile all source files before running.

## URLs
- Login: `/InternTrack/login.jsp`
- Dashboard: `/InternTrack/analytics` (requires login)
- Add application: `/InternTrack/addApplication.jsp`
- All applications: `/InternTrack/applications.jsp`
- Interviews: `/InternTrack/interviews`
- Follow-ups: `/InternTrack/followups`

## Interview and follow-up smoke test
1. Sign in and open Interviews. Create a future round with a date/time, mode, and notes; confirm it appears as Upcoming or Soon. Edit its details and delete it.
2. Try to submit an interview with a past date/time; the page and servlet should reject it.
3. Open Follow-ups. Add one due today, one due within three days, and one with a past due date; confirm the deadline labels update to Due today, Due soon, and Overdue.
4. Mark a follow-up completed and pending, edit its details, and delete it. Completed items should not be labeled overdue.
5. Sign in as another account and confirm neither account can see or change the other account's records.
