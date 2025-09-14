School Management System Project Overview
Project Summary
This project is a school management system for primary and secondary schools, built with Flutter for cross-platform development. It consists of five separate apps, each tailored to a specific role: Super Admin (School Director), Admin (Principal), Teacher, Accountant (all desktop), and Parent (mobile). The apps share a common codebase via a monorepo structure with a school_core package, ensuring efficient code reuse for models, services, and utilities. The system uses Hive for local storage and Supabase (PostgreSQL) for cloud database sync, supporting offline functionality and real-time updates. Key features include entity relationships (students, classes, subjects, etc.), unique access codes for authentication, and role-specific profile management.
Monorepo Structure
The project uses a monorepo with a shared school_core package and individual app directories:
school_management/
├── packages/
│   ├── school_core/
│   │   ├── lib/
│   │   │   ├── models/  # Student.dart, Teacher.dart, etc.
│   │   │   ├── services/  # AuthService.dart, SyncService.dart
│   │   │   ├── utilities/  # CodeGenerator.dart, PdfUtils.dart
│   │   ├── pubspec.yaml
├── apps/
│   ├── super_admin/
│   ├── admin/
│   ├── teacher/
│   ├── accountant/
│   ├── parent/
├── melos.yaml  # Monorepo management

Apps and Specifications
1. Super Admin App (Desktop)

Purpose: Manages all users and provides oversight of school operations.
Target Platform: Desktop (Windows primary, Linux/macOS optional).
Responsibilities:
Creates users: Admin, Teachers, Accountant, Other Staff.
View-only access to Students, Parents, Classes, Subjects, Payment Reports.
Assigns/manages access codes for all users.


Additional Features:
Exportable analytics dashboard (e.g., student enrollment trends, teacher performance metrics).
Audit log to track user actions (e.g., who created/edited a profile).
Multi-school oversight for directors managing multiple institutions.
Notification settings for alerts (e.g., overdue payments, low attendance).


Logic:
CRUD operations for user creation, stored in Supabase (users table) and Hive.
View dashboards fetch data from Supabase with joins (e.g., students per class).
Audit log records actions in a dedicated audit_logs table.
Notifications via Supabase Edge Functions and OneSignal for critical updates.


UI Design Structure:
Layout: Side navigation with sections (Users, Students, Classes, Subjects, Payments, Analytics, Audit Log).
Components: DataTable for lists (e.g., users, students), fl_chart for analytics (bar/pie charts), forms for user creation, notification toggle switches.
Navigation: Tabbed interface for multi-school view, modal dialogs for actions (e.g., create user).
Style: Material Design, clean and professional, with emphasis on data visibility.



2. Admin App (Desktop)

Purpose: Manages student/parent creation and entity assignments, generates report cards.
Target Platform: Desktop (Windows primary).
Responsibilities:
Creates Students and Parents.
Assigns Teachers to Classes, Teachers to Subjects, Students to Classes, Students to Parents.
Collates and generates report cards.
View-only access to students’ report records per subject.


Additional Features:
Automated timetable generation with conflict detection (e.g., no teacher double-booked).
Bulk student/parent creation via CSV upload.
Parent communication tools (e.g., bulk SMS/emails for updates).
Attendance summary reports for classes.


Logic:
Student/Parent creation updates students, parents, users tables, generates access codes.
Assignments update relationship tables (e.g., student_classes, teacher_subjects).
Report cards generated as PDFs using student grades, saved locally and synced.
Timetable logic ensures no conflicts (e.g., teacher assigned to one class per slot).
Communication via Supabase Edge Functions for SMS/email APIs.


UI Design Structure:
Layout: Side menu with sections (Students, Parents, Assignments, Reports, Communication).
Components: Forms for student/parent creation, DropdownButton for assignments, pdf preview for report cards, DataTable for attendance summaries.
Navigation: Wizard-style flow for bulk uploads, modal for assignments.
Style: Material Design, focus on form usability and data clarity.



3. Teacher App (Desktop)

Purpose: Manages student performance and attendance for assigned subjects/classes.
Target Platform: Desktop (Windows primary).
Responsibilities:
Manages student performance per assigned subject (e.g., test/exam scores).
Views profiles of students offering their subject.
Views/manages assigned class info (e.g., results, performance).
Marks attendance for assigned classes.


Additional Features:
Comment section for student grades (qualitative feedback).
Lesson plan management (upload/view plans for subjects).
Peer collaboration tools (e.g., share resources with other teachers).
Grade submission with photo evidence (adapted for desktop UI, e.g., file picker).


Logic:
Grade updates modify students.grades (JSONB) in Supabase/Hive.
Attendance updates students.attendance (array of timestamps).
Lesson plans stored in lesson_plans table or Supabase Storage.
Collaboration via shared resources table, accessible to teachers.


UI Design Structure:
Layout: Side navigation with sections (Classes, Subjects, Students, Lesson Plans, Resources).
Components: Forms for grade entry with comment fields, ListView for student profiles, file picker for lesson plans/photos, DataTable for attendance.
Navigation: Tabbed view for classes/subjects, modal for grade submission.
Style: Material Design, intuitive for data entry and profile viewing.



4. Accountant App (Desktop)

Purpose: Manages student payments and financial records.
Target Platform: Desktop (Windows primary).
Responsibilities:
Manages student payments and records (e.g., tracks fees, generates invoices).


Additional Features:
Automated payment reminders (SMS/email to parents).
Multi-currency support for international students.
Financial forecasting tools (e.g., predict revenue based on payment trends).
Integration with local bank APIs for real-time payment verification.


Logic:
Payments recorded in payments table, linked to students.
Reminders triggered via Supabase Edge Functions and external SMS/email APIs.
Multi-currency handled via conversion rates in payments table.
Forecasting uses aggregate queries on payment data.


UI Design Structure:
Layout: Side menu with sections (Payments, Invoices, Reminders, Forecasts).
Components: Forms for payment entry, DataTable for payment history, fl_chart for forecasting trends, buttons for sending reminders.
Navigation: Modal for invoice generation, dashboard for overview.
Style: Material Design, focus on financial clarity and action buttons.



5. Parent App (Mobile)

Purpose: Provides parents access to their child’s results and payment history.
Target Platform: Mobile (Android/iOS).
Responsibilities:
View-only access to child’s results and payment history.


Additional Features:
Calendar view for school events and payment deadlines.
Chat feature to communicate with class teacher/admin (restricted).
Feedback submission (e.g., rate events, report issues).
Offline access to cached results/payment history.


Logic:
Fetches child’s data from students and payments tables, cached in Hive.
Calendar events stored in events table, synced to app.
Chat uses messages table with role-based access (RLS).
Feedback stored in feedback table.
Offline mode queries Hive, syncs with Supabase when online.


UI Design Structure:
Layout: Bottom navigation with tabs (Results, Payments, Calendar, Chat, Feedback).
Components: ListTile for results/payments, table_calendar for events, text input for chat/feedback, offline indicator.
Navigation: Simple tab-based, modal for chat/feedback.
Style: Material Design, touch-friendly, minimalistic for ease of use.



Database Design (Supabase - PostgreSQL)

Backend: Supabase (PostgreSQL) for cloud storage and real-time sync.
Schema:
Tables:
users (auth): Stores user credentials, roles, access codes.
Columns: id (UUID, PK), email (TEXT), role (TEXT: super_admin, admin, teacher, accountant, parent), access_code (TEXT).


students: Student profiles and academic data.
Columns: id (UUID, PK), name (TEXT), bio (TEXT), class_id (UUID, FK → classes), parent_id (UUID, FK → parents), grades (JSONB: {subject_id: grade}), attendance (TIMESTAMP[]), login_code (TEXT).


teachers: Teacher profiles and assignments.
Columns: id (UUID, PK), name (TEXT), bio (TEXT), login_code (TEXT).


classes: Class details and relationships.
Columns: id (UUID, PK), name (TEXT), teacher_id (UUID, FK → teachers for class teacher).


subjects: Subject details.
Columns: id (UUID, PK), name (TEXT).


parents: Parent profiles.
Columns: id (UUID, PK), name (TEXT), login_code (TEXT).


payments: Payment records.
Columns: id (UUID, PK), student_id (UUID, FK → students), amount (DECIMAL), currency (TEXT), date (TIMESTAMP).


student_classes (junction): Links students to classes.
Columns: student_id (UUID, FK → students), class_id (UUID, FK → classes).


teacher_subjects (junction): Links teachers to subjects.
Columns: teacher_id (UUID, FK → teachers), subject_id (UUID, FK → subjects).


student_subjects (junction): Links students to subjects with grades.
Columns: student_id (UUID, FK → students), subject_id (UUID, FK → subjects).


lesson_plans: Stores teacher lesson plans.
Columns: id (UUID, PK), teacher_id (UUID, FK → teachers), subject_id (UUID, FK → subjects), content (TEXT or Storage reference).


resources: Shared teacher resources.
Columns: id (UUID, PK), teacher_id (UUID, FK → teachers), content (TEXT or Storage reference).


audit_logs: Tracks user actions (Super Admin).
Columns: id (UUID, PK), user_id (UUID, FK → users), action (TEXT), timestamp (TIMESTAMP).


events: School events for Parent app.
Columns: id (UUID, PK), title (TEXT), date (TIMESTAMP).


messages: Chat messages for Parent app.
Columns: id (UUID, PK), sender_id (UUID, FK → users), receiver_id (UUID, FK → users), content (TEXT), timestamp (TIMESTAMP).


feedback: Parent feedback.
Columns: id (UUID, PK), parent_id (UUID, FK → parents), content (TEXT), timestamp (TIMESTAMP).




Row-Level Security (RLS):
students: Parents access only their child’s data (parent_id = auth.uid()).
teachers: Teachers access only assigned students/classes (teacher_id = auth.uid()).
payments: Accountant full access, Parents view own child’s payments.
messages: Restricted to sender/receiver.


Real-Time: Subscriptions for updates (e.g., Teacher app listens to student_subjects for grade changes).
Storage: Supabase Storage for lesson plans, resource files, and photo evidence.



Local Storage (Hive)

Purpose: Offline caching for all apps.
Boxes:
students, teachers, classes, subjects, payments, parents (mirroring Supabase tables).
Parent app: Only caches child’s data (students, payments, events, messages, feedback).


Sync Logic:
On app start or periodically (via workmanager), sync Hive with Supabase.
Use connectivity_plus to detect online status.
Push local changes to Supabase, pull updates to Hive.
Handle conflicts using timestamps (last_modified).



Required Packages
Shared (school_core Package)
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^1.10.0  # Supabase DB, auth, storage
  hive: ^2.2.3  # Local storage
  hive_flutter: ^1.1.0
  uuid: ^3.0.6  # Access code generation
  pdf: ^3.8.0  # Report card generation
  fl_chart: ^0.55.0  # Analytics dashboards
  connectivity_plus: ^4.0.0  # Offline detection
  csv: ^5.0.0  # Bulk student/parent import
  onesignal_flutter: ^3.0.0  # Push notifications (Parent app)
  workmanager: ^0.5.0  # Background sync
  flutter_riverpod: ^2.3.0  # State management
dev_dependencies:
  hive_generator: ^2.0.0
  build_runner: ^2.0.0

Super Admin App
dependencies:
  school_core:
    path: ../../packages/school_core
  printing: ^5.9.0  # PDF printing

Admin App
dependencies:
  school_core:
    path: ../../packages/school_core
  printing: ^5.9.0  # Report card printing
  table_calendar: ^3.0.0  # Timetable generation

Teacher App
dependencies:
  school_core:
    path: ../../packages/school_core
  file_picker: ^5.2.0  # Lesson plans, photo evidence

Accountant App
dependencies:
  school_core:
    path: ../../packages/school_core

Parent App
dependencies:
  school_core:
    path: ../../packages/school_core
  table_calendar: ^3.0.0  # Calendar view

Monorepo (Root)
dev_dependencies:
  melos: ^3.0.0  # Monorepo management

Additional Notes

Access Codes: Generated via uuid (e.g., 8-character uppercase, like ABC12345) during user creation. Stored in users.login_code and Hive.
Relationships: Managed via junction tables (student_classes, teacher_subjects, student_subjects). Admin app handles assignments, updating both sides (e.g., students.class_id and student_classes).
Deployment:
Desktop: Build as .exe for Windows using flutter build windows.
Mobile: Build AAB for Play Store/App Store using flutter build appbundle.
Use Codemagic for CI/CD to automate builds across apps.


Testing:
Unit tests for school_core models/services.
Integration tests for app-specific flows (e.g., Admin report card generation).


Scalability: Designed for single-school use initially, with multi-school support via schools table for Super Admin.
