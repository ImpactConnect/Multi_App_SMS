Based on the Super Admin app's specifications in the working document, the expected pages (or screens) are designed as a modular, desktop-optimized structure using Flutter's routing and navigation (e.g., side drawer for primary navigation). These pages align with the core responsibilities (user management, view-only entity access) and additional features (analytics dashboard, audit log, multi-school oversight, notification settings). They emphasize data visibility, forms for actions, and export options, with offline-first logic via Hive and Supabase sync.

The pages are organized into primary screens (main entry points) and secondary/modals (supporting views). Navigation uses a side drawer for quick access, with tabs or sub-routes for deeper sections. Total: ~10 primary pages, plus modals for actions.

1. Login Page
Purpose: Secure entry point for Super Admin authentication.
Key Elements: Email/password fields, access code verification (optional), "Remember Me" toggle, Supabase Auth integration.
Logic: Validates credentials offline (Hive-cached sessions) or online (Supabase); redirects to Dashboard on success.
UI: Centered form on a full-screen background (school-themed image or gradient); Material Design buttons.
2. Dashboard Page
Purpose: High-level overview of school operations.
Key Elements: Widget cards for key metrics (e.g., total users, students, classes, recent payments); quick links to other pages; sync status indicator.
Logic: Fetches aggregated data from Hive/Supabase (e.g., user counts); real-time updates via Supabase subscriptions.
UI: Grid layout with cards; responsive for desktop screens; includes a welcome banner with multi-school selector dropdown.
3. User Management Page
Purpose: Core page for creating, editing, and viewing users (Admin, Teachers, Accountant, Other Staff).
Key Elements: Searchable/filterable table (DataTable) of users (columns: Name, Role, Email, Access Code, Last Modified); FAB (Floating Action Button) for "Create User"; clickable rows for edit/view.
Logic: CRUD operations via UserRepository (Hive first, then sync); generates access codes on creation; audit log auto-triggers.
UI: Full-width table with pagination; side panel for filters (by role/school); export button for CSV/PDF.
4. Students View Page
Purpose: View-only access to student records.
Key Elements: Paginated list/table of students (columns: Name, Class, Parent, Grades Summary, Attendance Rate); search by name/ID; clickable for profile details.
Logic: Queries students table with joins (e.g., to classes/parents); read-only mode enforced by role checks.
UI: DataTable with expandable rows; tabs for "All Students" vs. "By Class"; export option for lists.
5. Parents View Page
Purpose: View-only access to parent records.
Key Elements: Table of parents (columns: Name, Linked Students, Contact Info, Last Activity); filters by student or school.
Logic: Fetches from parents table with relationships to students; supports multi-parent linking.
UI: Similar to Students View; card-based list for quick scanning; modal for detailed profile.
6. Classes View Page
Purpose: View-only access to class records.
Key Elements: List/table of classes (columns: Name, Teacher, Students Count, Subjects); drill-down to class summary.
Logic: Joins classes with teachers and student_classes junction; aggregates student counts.
UI: DataTable with summary cards; sub-tabs for "Class Roster" and "Timetable Preview".
7. Subjects View Page
Purpose: View-only access to subject records.
Key Elements: Table of subjects (columns: Name, Assigned Teachers, Classes Offering It); search by name.
Logic: Queries subjects with joins to teacher_subjects and class_subjects.
UI: Simple list view; expandable for teacher/class assignments.
8. Payments Reports Page
Purpose: View aggregated payment data from Accountant.
Key Elements: Summary table/charts (e.g., total collected, overdue by student); filters by date range or class.
Logic: Aggregate queries on payments table (e.g., SUM(amount) GROUP BY student_id); read-only.
UI: fl_chart pie/bar charts; export to PDF for reports.
9. Analytics Dashboard Page
Purpose: Exportable visual analytics.
Key Elements: Interactive charts (enrollment trends via line chart, performance metrics via bar chart); date/school filters; export buttons.
Logic: Uses AnalyticsService for Supabase aggregates (e.g., COUNT(students) OVER time); supports multi-school views.
UI: Full-screen charts with legends; sidebar for filters; "Export as PDF" button.
10. Audit Log Page
Purpose: Track all user actions.
Key Elements: Searchable table of logs (columns: Timestamp, User ID, Action, Details); filters by date/user/action type.
Logic: Queries audit_logs table; auto-populated by AuditService on actions like user creation.
UI: DataTable with timestamps; export to CSV for reviews.
11. Settings Page (Includes Notification Settings and Multi-School Oversight)
Purpose: Configure app and school-wide settings.
Key Elements: Toggles for notification alerts (e.g., low attendance thresholds); multi-school management (add/edit schools, assign users); general app settings (e.g., sync frequency).
Logic: Saves to Hive/Supabase settings or schools tables; triggers Edge Functions for notifications.
UI: Form sections with switches/sliders; dropdown for school selection; save button with confirmation.
Secondary Views and Modals
Create/Edit User Modal: Popup form for user details (name, email, role, school assignment); auto-generates access code.
Profile Detail Modal: Read-only dialog for entity profiles (e.g., student bio, linked data).
Export Confirmation Dialog: For PDF/CSV downloads, with preview option.
Sync Status Overlay: Non-intrusive banner showing "Syncing..." or "Offline Mode".
Navigation and Flow
Primary Navigation: Side drawer with icons/labels linking to pages 2-11 (e.g., Icons.people for User Management).
Secondary Navigation: Tabs within pages (e.g., in Dashboard for quick entity switches); back button for modals.
Routing: Use Flutter's GoRouter or Navigator for deep links (e.g., /users/:id/edit).
Error Handling: 404 page for invalid routes; offline fallback screens.
These pages ensure comprehensive coverage of the Super Admin's role, with a focus on oversight and minimalism for desktop use. They integrate seamlessly with school_core for data handling. If expanding, add sub-pages like "School Creation" under Settings based on multi-school needs.