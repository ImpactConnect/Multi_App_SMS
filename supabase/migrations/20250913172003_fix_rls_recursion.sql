-- Fix infinite recursion in RLS policies
-- The issue is caused by policies that reference the same table they're applied to

-- Drop problematic policies that cause infinite recursion
DROP POLICY IF EXISTS "School staff can manage classes in their school" ON classes;
DROP POLICY IF EXISTS "Parents can view their children's classes" ON classes;
DROP POLICY IF EXISTS "School staff can manage subjects in their school" ON subjects;
DROP POLICY IF EXISTS "Parents can view subjects of their children's classes" ON subjects;
DROP POLICY IF EXISTS "Parents can view their children" ON students;
DROP POLICY IF EXISTS "Teachers can view students in their classes" ON students;
DROP POLICY IF EXISTS "School staff can manage students in their school" ON students;

-- Create fixed policies without recursion

-- Classes policies (fixed)
CREATE POLICY "School staff can manage classes in their school" ON classes FOR ALL USING (
    EXISTS (
        SELECT 1 FROM users u 
        WHERE u.id = auth.uid() 
        AND u.role IN ('admin', 'teacher', 'superAdmin') 
        AND (u.role = 'superAdmin' OR u.school_id = classes.school_id)
    )
);

CREATE POLICY "Parents can view their children's classes" ON classes FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM students s 
        WHERE s.class_id = classes.id 
        AND auth.uid() = ANY(s.parent_ids)
    )
);

-- Subjects policies (fixed)
CREATE POLICY "School staff can manage subjects in their school" ON subjects FOR ALL USING (
    EXISTS (
        SELECT 1 FROM users u 
        WHERE u.id = auth.uid() 
        AND u.role IN ('admin', 'teacher', 'superAdmin') 
        AND (u.role = 'superAdmin' OR u.school_id = subjects.school_id)
    )
);

CREATE POLICY "Parents can view subjects of their children's classes" ON subjects FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM students s 
        JOIN classes c ON c.id = s.class_id 
        WHERE auth.uid() = ANY(s.parent_ids) 
        AND subjects.id = ANY(c.subject_ids)
    )
);

-- Students policies (fixed - simplified to avoid recursion)
CREATE POLICY "Parents can view their children" ON students FOR SELECT USING (
    auth.uid() = ANY(parent_ids)
);

CREATE POLICY "Teachers can view students in their classes" ON students FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM classes c 
        WHERE c.id = students.class_id 
        AND c.class_teacher_id = auth.uid()
    )
);

CREATE POLICY "School staff can manage students in their school" ON students FOR ALL USING (
    EXISTS (
        SELECT 1 FROM users u 
        WHERE u.id = auth.uid() 
        AND u.role IN ('admin', 'teacher', 'accountant', 'superAdmin') 
        AND (u.role = 'superAdmin' OR u.school_id = students.school_id)
    )
);

-- Add a simple policy for teachers to view subjects they teach
CREATE POLICY "Teachers can view subjects they teach" ON subjects FOR SELECT USING (
    auth.uid() = ANY(teacher_ids)
);

-- Add a simple policy for teachers to view classes they teach
CREATE POLICY "Teachers can view classes they teach" ON classes FOR SELECT USING (
    class_teacher_id = auth.uid() OR auth.uid() = ANY((
        SELECT unnest(teacher_ids) FROM subjects WHERE id = ANY(subject_ids)
    ))
);