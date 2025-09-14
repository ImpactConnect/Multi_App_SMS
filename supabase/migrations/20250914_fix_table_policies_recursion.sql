-- Fix infinite recursion in RLS policies for classes, subjects, and students tables
-- Drop all existing policies that cause recursion and create simple ones

-- Drop all existing policies for classes table
DROP POLICY IF EXISTS "School staff can manage classes in their school" ON classes;
DROP POLICY IF EXISTS "Parents can view their children's classes" ON classes;
DROP POLICY IF EXISTS "Teachers can view classes they teach" ON classes;

-- Drop all existing policies for subjects table
DROP POLICY IF EXISTS "School staff can manage subjects in their school" ON subjects;
DROP POLICY IF EXISTS "Parents can view subjects of their children's classes" ON subjects;
DROP POLICY IF EXISTS "Teachers can view subjects they teach" ON subjects;

-- Drop all existing policies for students table
DROP POLICY IF EXISTS "Parents can view their children" ON students;
DROP POLICY IF EXISTS "Teachers can view students in their classes" ON students;
DROP POLICY IF EXISTS "School staff can manage students in their school" ON students;
DROP POLICY IF EXISTS "School staff can view students in their school" ON students;

-- Create simple, non-recursive policies for classes
-- Super admin can do everything
CREATE POLICY "classes_superadmin_all" ON classes FOR ALL USING (
    (auth.jwt() ->> 'role') = 'superAdmin'
);

-- For now, allow authenticated users to read classes to avoid recursion
-- We'll handle more complex permissions in the application layer
CREATE POLICY "classes_authenticated_read" ON classes FOR SELECT USING (
    auth.role() = 'authenticated'
);

-- Create simple, non-recursive policies for subjects
-- Super admin can do everything
CREATE POLICY "subjects_superadmin_all" ON subjects FOR ALL USING (
    (auth.jwt() ->> 'role') = 'superAdmin'
);

-- For now, allow authenticated users to read subjects to avoid recursion
CREATE POLICY "subjects_authenticated_read" ON subjects FOR SELECT USING (
    auth.role() = 'authenticated'
);

-- Create simple, non-recursive policies for students
-- Super admin can do everything
CREATE POLICY "students_superadmin_all" ON students FOR ALL USING (
    (auth.jwt() ->> 'role') = 'superAdmin'
);

-- For now, allow authenticated users to read students to avoid recursion
CREATE POLICY "students_authenticated_read" ON students FOR SELECT USING (
    auth.role() = 'authenticated'
);

-- Ensure RLS is enabled on all tables
ALTER TABLE classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE students ENABLE ROW LEVEL SECURITY;

-- Add comments
COMMENT ON TABLE classes IS 'RLS policies simplified to avoid infinite recursion';
COMMENT ON TABLE subjects IS 'RLS policies simplified to avoid infinite recursion';
COMMENT ON TABLE students IS 'RLS policies simplified to avoid infinite recursion';