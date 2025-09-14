Overview of Database Tables and Purpose
The database includes core tables for managing school entities and relationships, with Row-Level Security (RLS) ensuring the Admin role (Principal) has appropriate access (e.g., create/edit for students/parents, assign relationships, view-only for reports). The tables are designed to handle the Admin’s responsibilities: creating Students and Parents, assigning Teachers to Classes/Subjects, Students to Classes/Parents, generating report cards, and viewing student report records per subject.

Core Tables and Their Relationships
Below are the primary tables relevant to the Admin app, with their relationships described conceptually. Each relationship is explained in terms of how data connects (e.g., one-to-many, many-to-many) and how it supports Admin functionalities. I’ll use simple terms to show how records link, avoiding technical SQL syntax.

Users Table
Purpose: Stores all user accounts (Super Admin, Admin, Teachers, Accountant, Other Staff, Parents) with credentials and roles.
Key Fields: ID (unique identifier), email, username, hashed password, role (e.g., "admin", "teacher", "parent"), access code, school ID (for multi-school), isActive, last modified.
Relationships:
To Schools: Each user is tied to a school (one-to-many: one school has many users, a user belongs to one school). The school ID links to the Schools table, allowing the Admin to manage users within their school.
To Teachers/Parents: The Users table connects to Teachers and Parents tables via their IDs. For example, a user with role="teacher" has a matching record in the Teachers table for bio/subjects.
Admin Use: The Admin app queries this table to fetch Teachers for assignments and Parents for linking to Students. RLS restricts Admin to their school’s users.
Schools Table
Purpose: Defines schools for multi-school oversight (used by Super Admin, but Admin operates within one school).
Key Fields: ID, name.
Relationships:
To Users/Students/Classes: One school has many users, students, and classes (one-to-many). The school ID in these tables ensures data is scoped (e.g., Admin only sees their school’s students).
Admin Use: Filters all queries (e.g., student creation) to the Admin’s school ID, ensuring data isolation.
Students Table
Purpose: Stores student profiles and academic data.
Key Fields: ID, firstName, lastName, studentId, dateOfBirth, gender, address, profileImageUrl, classId, schoolId, parentIds (array), admissionDate, isActive, createdAt, updatedAt, emergencyContact, medicalInfo.
Relationships:
To Classes (via classId): Many-to-one (many students belong to one class). The classId links to the Classes table.
To Parents (via parentIds): Many-to-many (a student can have multiple parents, stored as array of parent IDs). No separate junction table needed.
To Schools (via schoolId): Many-to-one (many students belong to one school).
To Subjects: Relationship handled through Classes (students inherit subjects from their assigned class).
Admin Use: Admin creates students, assigns them to classes, and links multiple parents via parentIds array. No separate grades table - grades handled through other mechanisms.
Parents Table
Purpose: Parents are handled as Users with role='parent' - no separate Parents table exists in local models.
Key Fields: Stored in Users table with role='parent'.
Relationships:
To Students (via parentIds in Students table): Many-to-many (a parent can have multiple students, a student can have multiple parents). Relationship stored as array in Students.parentIds.
To Users: Parents ARE users with role='parent' - same table, not separate.
Admin Use: Admin creates parent users with role='parent' and links them to students by adding parent IDs to Students.parentIds array.
Classes Table
Purpose: Defines classes with their details.
Key Fields: ID, name, grade, section, schoolId, classTeacherId, capacity, classroom, isActive, createdAt, updatedAt, subjectIds (array), schedule (JSON).
Relationships:
To Students (via classId in Students): One-to-many (one class has many students, each student belongs to one class). No junction table needed.
To Teachers (via classTeacherId): Many-to-one (many classes can have same teacher as class teacher). Links to Users table where role='teacher'.
To Subjects (via subjectIds array): Many-to-many (a class offers multiple subjects stored as array). No separate junction table.
To Schools (via schoolId): Many-to-one (many classes belong to one school).
Admin Use: Admin assigns students to classes by setting Students.classId, assigns class teachers via classTeacherId, and manages subjects through subjectIds array.
Teachers Table
Purpose: Teachers are handled as Users with role='teacher' - no separate Teachers table exists in local models.
Key Fields: Stored in Users table with role='teacher', including bio data fields like qualification, department, position, joinDate.
Relationships:
To Classes (via classTeacherId): One-to-many (one teacher can be class teacher for multiple classes). Classes.classTeacherId links to Users.id.
To Subjects (via teacherIds in Subjects): Many-to-many (a teacher teaches multiple subjects, stored as array in Subjects.teacherIds).
To Users: Teachers ARE users with role='teacher' - same table, not separate.
Admin Use: Admin assigns teachers to classes by setting Classes.classTeacherId and to subjects by managing Subjects.teacherIds array.
Subjects Table
Purpose: Defines subjects offered in the school.
Key Fields: ID, name, description, code, credits, department, isActive, createdAt, updatedAt, teacherIds (array), classIds (array).
Relationships:
To Classes (via classIds array and Classes.subjectIds): Many-to-many (a subject is offered in multiple classes). Bidirectional arrays maintain relationship.
To Teachers (via teacherIds array): Many-to-many (a subject is taught by multiple teachers, stored as array).
To Students: Indirect relationship through Classes (students get subjects from their assigned class).
Admin Use: Admin assigns subjects to classes by managing both Subjects.classIds and Classes.subjectIds arrays, assigns teachers via Subjects.teacherIds array.
Payments Table
Purpose: Tracks student fee payments (managed by Accountant, viewed by Admin).
Key Fields: ID, student ID, amount, currency, date, last modified.
Relationships:
To Students: One-to-many (one student has multiple payment records). The student_id field links to Students.ID.
Admin Use: Admin has view-only access to payment summaries for report cards or oversight.
Junction Tables (Note: Local models use arrays instead of separate junction tables)
Student_Classes Relationship
Purpose: Links students to their class.
Implementation: Direct relationship via Students.classId field (many-to-one). No separate junction table needed.
Relationships: Each student belongs to exactly one class. Admin assigns students to classes by setting Students.classId.

Teacher_Subjects Relationship
Purpose: Links teachers to subjects they teach.
Implementation: Array field Subjects.teacherIds stores teacher IDs. No separate junction table.
Relationships: Many-to-many between Users (role='teacher') and Subjects. Admin assigns teachers to subjects by managing Subjects.teacherIds array.

Student_Subjects Relationship
Purpose: Students get subjects through their class assignment.
Implementation: Indirect relationship - Students inherit subjects from Classes.subjectIds. No direct junction table.
Relationships: Students access subjects through their assigned class. Grades handled separately (not in current local models).

Class_Subjects Relationship
Purpose: Links classes to offered subjects.
Implementation: Bidirectional arrays - Classes.subjectIds and Subjects.classIds maintain the relationship.
Relationships: Many-to-many between Classes and Subjects. Admin manages both arrays to maintain consistency.
How Relationships Support Admin Functionalities
Student/Parent Creation:
Admin creates a Parent as a User with role='parent' (single Users table entry with login credentials).
Creates a Student in the Students table, linking to Parents via parentIds array and a Class via classId field.
Example: Creating "John Doe" (student) adds parent IDs to Students.parentIds array and sets Students.classId to "Class 5A".

Assignments:
Teachers to Classes: Admin assigns a teacher as class teacher by setting Classes.classTeacherId to the teacher's user ID.
Teachers to Subjects: Admin adds teacher ID to Subjects.teacherIds array.
Students to Classes: Admin sets Students.classId field directly.
Students to Subjects: Students automatically get subjects from their class (Classes.subjectIds), no direct assignment needed.
Example: Assigning Teacher "Mr. Smith" to "Math" adds his user ID to the Math subject's teacherIds array.
Report Cards:
Admin queries Students table and joins with Classes to get class subjects (Classes.subjectIds), then joins with Subjects for subject details. Grades handled through separate mechanism (not in current local models).
Example: For "John Doe," fetch his class subjects through Students.classId -> Classes.subjectIds -> Subjects details.

View-Only Reports:
Admin queries Students joined with Classes and Subjects for academic context.
Payments table is queried for summaries (e.g., total fees paid per student), joined with Students.
Example: View "John Doe's" class subjects and payment status.
Visualizing Relationships
Imagine a web where:

Users is the hub, connecting to Teachers and Parents for credentials and roles.
Schools groups all data (Users, Students, Classes) for isolation.
Students is central, linking to Classes (their class), Parents (their guardian), and Subjects (their courses via student_subjects).
Classes connects to Students (roster), Teachers (class teacher), and Subjects (offered courses).
Teachers links to Subjects (what they teach) and Classes (where they teach).
Subjects ties to Classes, Students, and Teachers via junction tables.
Payments attaches to Students for financial tracking.
Data flows like a chain: Admin creates a Student → assigns to a Class (updates student_classes) → links to a Parent (updates parent_id) → assigns Subjects (updates student_subjects) → views grades/payments for reports.

Notes for Development
Array Relationships: Local models use arrays instead of junction tables; ensure Admin app updates both sides of bidirectional arrays (e.g., Classes.subjectIds and Subjects.classIds) for consistency.
RLS: Admin has create/edit on Students, Users (parents/teachers), write on array fields, read-only on Payments.
Sync: Hive mirrors Supabase tables locally; Admin app syncs after each action (e.g., student creation).
Validation: Check relationships during assignments (e.g., subject exists in Classes.subjectIds before assignment, teacher exists in Users with role='teacher').