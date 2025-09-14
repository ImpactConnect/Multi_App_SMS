-- School Management System - Cloud Database Schema (Supabase PostgreSQL)
-- This file contains SQL statements to create all required tables for the cloud database
-- Run these statements in your Supabase SQL editor

-- =============================================
-- CORE ENTITY TABLES
-- =============================================

-- Users table (extends Supabase auth.users)
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('superAdmin', 'admin', 'teacher', 'accountant', 'parent', 'otherStaff')),
    profile_image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    school_id UUID,
    access_code VARCHAR(50) UNIQUE NOT NULL,
    
    -- Authentication fields
    username VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL, -- Will be hashed
    
    -- Bio data fields
    address TEXT,
    date_of_birth DATE,
    gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),
    national_id VARCHAR(50),
    emergency_contact VARCHAR(100),
    emergency_contact_relation VARCHAR(50),
    qualification TEXT,
    department VARCHAR(100),
    position VARCHAR(100),
    join_date DATE,
    blood_group VARCHAR(5),
    medical_info TEXT,
    notes TEXT
);

-- Schools table
CREATE TABLE IF NOT EXISTS schools (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    address TEXT NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    email VARCHAR(255) NOT NULL,
    website VARCHAR(255),
    principal_name VARCHAR(255) NOT NULL,
    logo_url TEXT,
    established_date DATE NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('primary', 'secondary', 'combined', 'international', 'vocational')),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    description TEXT,
    settings JSONB
);

-- Classes table
CREATE TABLE IF NOT EXISTS classes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    grade VARCHAR(20) NOT NULL,
    section VARCHAR(10) NOT NULL,
    school_id UUID NOT NULL,
    class_teacher_id UUID,
    capacity INTEGER DEFAULT 30,
    classroom VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    subject_ids TEXT[], -- Array of subject IDs
    schedule JSONB -- Timetable data
);

-- Subjects table
CREATE TABLE IF NOT EXISTS subjects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    code VARCHAR(20),
    credits INTEGER,
    department VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    teacher_ids TEXT[], -- Array of teacher IDs
    class_ids TEXT[] -- Array of class IDs
);

-- Students table
CREATE TABLE IF NOT EXISTS students (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    student_id VARCHAR(50) UNIQUE NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(10) NOT NULL CHECK (gender IN ('male', 'female', 'other')),
    address TEXT NOT NULL,
    profile_image_url TEXT,
    class_id UUID NOT NULL,
    school_id UUID NOT NULL,
    parent_ids TEXT[], -- Array of parent user IDs
    admission_date DATE DEFAULT CURRENT_DATE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    emergency_contact VARCHAR(100),
    medical_info TEXT,
    grades JSONB, -- {subject_id: grade} format
    attendance TIMESTAMP[] -- Array of attendance timestamps
);

-- =============================================
-- JUNCTION/RELATIONSHIP TABLES
-- =============================================

-- Student-Class relationships (many-to-many)
CREATE TABLE IF NOT EXISTS student_classes (
    student_id UUID NOT NULL,
    class_id UUID NOT NULL,
    enrolled_date DATE DEFAULT CURRENT_DATE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (student_id, class_id)
);

-- Teacher-Subject relationships (many-to-many)
CREATE TABLE IF NOT EXISTS teacher_subjects (
    teacher_id UUID NOT NULL,
    subject_id UUID NOT NULL,
    assigned_date DATE DEFAULT CURRENT_DATE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (teacher_id, subject_id)
);

-- Student-Subject relationships with grades (many-to-many)
CREATE TABLE IF NOT EXISTS student_subjects (
    student_id UUID NOT NULL,
    subject_id UUID NOT NULL,
    grade DECIMAL(5,2),
    grade_letter VARCHAR(2),
    comments TEXT,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    teacher_id UUID, -- Who assigned the grade
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (student_id, subject_id)
);

-- =============================================
-- FEATURE TABLES
-- =============================================

-- Payments table
CREATE TABLE IF NOT EXISTS payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'NGN',
    payment_type VARCHAR(50) NOT NULL, -- tuition, books, transport, etc.
    payment_method VARCHAR(50), -- cash, bank_transfer, card, etc.
    payment_date DATE NOT NULL,
    due_date DATE,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'overdue', 'cancelled')),
    reference_number VARCHAR(100) UNIQUE,
    description TEXT,
    academic_year VARCHAR(10),
    term VARCHAR(20),
    created_by UUID, -- Accountant who created the record
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Lesson Plans table
CREATE TABLE IF NOT EXISTS lesson_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    teacher_id UUID NOT NULL,
    subject_id UUID NOT NULL,
    class_id UUID,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    objectives TEXT[],
    materials_needed TEXT[],
    lesson_date DATE,
    duration_minutes INTEGER,
    file_url TEXT, -- Supabase Storage reference
    status VARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft', 'approved', 'completed')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Resources table (shared teacher resources)
CREATE TABLE IF NOT EXISTS resources (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    teacher_id UUID NOT NULL, -- Creator
    title VARCHAR(255) NOT NULL,
    description TEXT,
    subject_id UUID,
    resource_type VARCHAR(50), -- document, video, image, link, etc.
    file_url TEXT, -- Supabase Storage reference or external URL
    file_size BIGINT, -- File size in bytes
    is_public BOOLEAN DEFAULT false, -- Can other teachers access?
    download_count INTEGER DEFAULT 0,
    tags TEXT[], -- For categorization
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Audit Logs table (for Super Admin tracking)
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    action VARCHAR(100) NOT NULL, -- create_user, update_student, delete_class, etc.
    entity_type VARCHAR(50), -- user, student, class, etc.
    entity_id UUID,
    old_values JSONB, -- Previous state
    new_values JSONB, -- New state
    ip_address INET,
    user_agent TEXT,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- COMMUNICATION TABLES
-- =============================================

-- Events table (school calendar)
CREATE TABLE IF NOT EXISTS events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    event_date DATE NOT NULL,
    start_time TIME,
    end_time TIME,
    location VARCHAR(255),
    event_type VARCHAR(50), -- holiday, exam, meeting, sports, etc.
    school_id UUID,
    class_ids TEXT[], -- Which classes are affected
    is_public BOOLEAN DEFAULT true, -- Visible to parents?
    created_by UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Messages table (chat system)
CREATE TABLE IF NOT EXISTS messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID NOT NULL,
    receiver_id UUID NOT NULL,
    subject VARCHAR(255),
    content TEXT NOT NULL,
    message_type VARCHAR(20) DEFAULT 'text' CHECK (message_type IN ('text', 'file', 'image')),
    file_url TEXT, -- For file attachments
    is_read BOOLEAN DEFAULT false,
    parent_message_id UUID, -- For threading/replies
    priority VARCHAR(10) DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Feedback table (parent feedback)
CREATE TABLE IF NOT EXISTS feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id UUID NOT NULL,
    student_id UUID, -- Which child (if applicable)
    category VARCHAR(50), -- academic, facilities, transport, etc.
    title VARCHAR(255),
    content TEXT NOT NULL,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'resolved', 'closed')),
    response TEXT, -- Admin/teacher response
    responded_by UUID,
    responded_at TIMESTAMP WITH TIME ZONE,
    is_anonymous BOOLEAN DEFAULT false,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- FOREIGN KEY CONSTRAINTS
-- =============================================

-- Users table constraints
ALTER TABLE users ADD CONSTRAINT fk_users_school FOREIGN KEY (school_id) REFERENCES schools(id);

-- Classes table constraints
ALTER TABLE classes ADD CONSTRAINT fk_classes_school FOREIGN KEY (school_id) REFERENCES schools(id);
ALTER TABLE classes ADD CONSTRAINT fk_classes_teacher FOREIGN KEY (class_teacher_id) REFERENCES users(id);

-- Students table constraints
ALTER TABLE students ADD CONSTRAINT fk_students_class FOREIGN KEY (class_id) REFERENCES classes(id);
ALTER TABLE students ADD CONSTRAINT fk_students_school FOREIGN KEY (school_id) REFERENCES schools(id);

-- Junction table constraints
ALTER TABLE student_classes ADD CONSTRAINT fk_student_classes_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE;
ALTER TABLE student_classes ADD CONSTRAINT fk_student_classes_class FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE;

ALTER TABLE teacher_subjects ADD CONSTRAINT fk_teacher_subjects_teacher FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE teacher_subjects ADD CONSTRAINT fk_teacher_subjects_subject FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE;

ALTER TABLE student_subjects ADD CONSTRAINT fk_student_subjects_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE;
ALTER TABLE student_subjects ADD CONSTRAINT fk_student_subjects_subject FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE;
ALTER TABLE student_subjects ADD CONSTRAINT fk_student_subjects_teacher FOREIGN KEY (teacher_id) REFERENCES users(id);

-- Feature table constraints
ALTER TABLE payments ADD CONSTRAINT fk_payments_student FOREIGN KEY (student_id) REFERENCES students(id);
ALTER TABLE payments ADD CONSTRAINT fk_payments_created_by FOREIGN KEY (created_by) REFERENCES users(id);

ALTER TABLE lesson_plans ADD CONSTRAINT fk_lesson_plans_teacher FOREIGN KEY (teacher_id) REFERENCES users(id);
ALTER TABLE lesson_plans ADD CONSTRAINT fk_lesson_plans_subject FOREIGN KEY (subject_id) REFERENCES subjects(id);
ALTER TABLE lesson_plans ADD CONSTRAINT fk_lesson_plans_class FOREIGN KEY (class_id) REFERENCES classes(id);

ALTER TABLE resources ADD CONSTRAINT fk_resources_teacher FOREIGN KEY (teacher_id) REFERENCES users(id);
ALTER TABLE resources ADD CONSTRAINT fk_resources_subject FOREIGN KEY (subject_id) REFERENCES subjects(id);

ALTER TABLE audit_logs ADD CONSTRAINT fk_audit_logs_user FOREIGN KEY (user_id) REFERENCES users(id);

-- Communication table constraints
ALTER TABLE events ADD CONSTRAINT fk_events_school FOREIGN KEY (school_id) REFERENCES schools(id);
ALTER TABLE events ADD CONSTRAINT fk_events_created_by FOREIGN KEY (created_by) REFERENCES users(id);

ALTER TABLE messages ADD CONSTRAINT fk_messages_sender FOREIGN KEY (sender_id) REFERENCES users(id);
ALTER TABLE messages ADD CONSTRAINT fk_messages_receiver FOREIGN KEY (receiver_id) REFERENCES users(id);
ALTER TABLE messages ADD CONSTRAINT fk_messages_parent FOREIGN KEY (parent_message_id) REFERENCES messages(id);

ALTER TABLE feedback ADD CONSTRAINT fk_feedback_parent FOREIGN KEY (parent_id) REFERENCES users(id);
ALTER TABLE feedback ADD CONSTRAINT fk_feedback_student FOREIGN KEY (student_id) REFERENCES students(id);
ALTER TABLE feedback ADD CONSTRAINT fk_feedback_responded_by FOREIGN KEY (responded_by) REFERENCES users(id);

-- =============================================
-- INDEXES FOR PERFORMANCE
-- =============================================

-- Users table indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_school_id ON users(school_id);
CREATE INDEX idx_users_access_code ON users(access_code);
CREATE INDEX idx_users_is_active ON users(is_active);

-- Students table indexes
CREATE INDEX idx_students_student_id ON students(student_id);
CREATE INDEX idx_students_class_id ON students(class_id);
CREATE INDEX idx_students_school_id ON students(school_id);
CREATE INDEX idx_students_is_active ON students(is_active);
CREATE INDEX idx_students_parent_ids ON students USING GIN(parent_ids);

-- Classes table indexes
CREATE INDEX idx_classes_school_id ON classes(school_id);
CREATE INDEX idx_classes_teacher_id ON classes(class_teacher_id);
CREATE INDEX idx_classes_grade_section ON classes(grade, section);

-- Subjects table indexes
CREATE INDEX idx_subjects_name ON subjects(name);
CREATE INDEX idx_subjects_code ON subjects(code);
CREATE INDEX idx_subjects_teacher_ids ON subjects USING GIN(teacher_ids);

-- Payments table indexes
CREATE INDEX idx_payments_student_id ON payments(student_id);
CREATE INDEX idx_payments_payment_date ON payments(payment_date);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_reference ON payments(reference_number);

-- Messages table indexes
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_receiver_id ON messages(receiver_id);
CREATE INDEX idx_messages_timestamp ON messages(timestamp);
CREATE INDEX idx_messages_is_read ON messages(is_read);

-- Events table indexes
CREATE INDEX idx_events_date ON events(event_date);
CREATE INDEX idx_events_school_id ON events(school_id);
CREATE INDEX idx_events_type ON events(event_type);

-- Audit logs indexes
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_timestamp ON audit_logs(timestamp);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);

-- =============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =============================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE schools ENABLE ROW LEVEL SECURITY;
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE lesson_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE resources ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view their own profile" ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Super admins can view all users" ON users FOR SELECT USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'superAdmin')
);
CREATE POLICY "Admins can view users in their school" ON users FOR SELECT USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('admin', 'superAdmin') AND school_id = users.school_id)
);

-- Students policies
CREATE POLICY "Parents can view their children" ON students FOR SELECT USING (
    auth.uid()::text = ANY(parent_ids)
);
CREATE POLICY "Teachers can view students in their classes" ON students FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM classes c 
        WHERE c.id = students.class_id 
        AND c.class_teacher_id = auth.uid()
    )
);
CREATE POLICY "School staff can view students in their school" ON students FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM users u 
        WHERE u.id = auth.uid() 
        AND u.role IN ('admin', 'teacher', 'accountant') 
        AND u.school_id = students.school_id
    )
);

-- Payments policies
CREATE POLICY "Parents can view their children's payments" ON payments FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM students s 
        WHERE s.id = payments.student_id 
        AND auth.uid()::text = ANY(s.parent_ids)
    )
);
CREATE POLICY "Accountants have full access to payments" ON payments FOR ALL USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('accountant', 'admin', 'superAdmin'))
);

-- Messages policies
CREATE POLICY "Users can view messages they sent or received" ON messages FOR SELECT USING (
    sender_id = auth.uid() OR receiver_id = auth.uid()
);
CREATE POLICY "Users can send messages" ON messages FOR INSERT WITH CHECK (
    sender_id = auth.uid()
);

-- Events policies
CREATE POLICY "Everyone can view public events" ON events FOR SELECT USING (is_public = true);
CREATE POLICY "School staff can manage events" ON events FOR ALL USING (
    EXISTS (
        SELECT 1 FROM users u 
        WHERE u.id = auth.uid() 
        AND u.role IN ('admin', 'teacher', 'superAdmin') 
        AND (events.school_id IS NULL OR u.school_id = events.school_id)
    )
);

-- Feedback policies
CREATE POLICY "Parents can manage their own feedback" ON feedback FOR ALL USING (
    parent_id = auth.uid()
);
CREATE POLICY "School staff can view and respond to feedback" ON feedback FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM users u 
        WHERE u.id = auth.uid() 
        AND u.role IN ('admin', 'teacher', 'superAdmin')
    )
);

-- =============================================
-- TRIGGERS FOR UPDATED_AT TIMESTAMPS
-- =============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers to all tables with updated_at columns
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_schools_updated_at BEFORE UPDATE ON schools FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_students_updated_at BEFORE UPDATE ON students FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_classes_updated_at BEFORE UPDATE ON classes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_subjects_updated_at BEFORE UPDATE ON subjects FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON payments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_lesson_plans_updated_at BEFORE UPDATE ON lesson_plans FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_resources_updated_at BEFORE UPDATE ON resources FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON events FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================
-- COMMENTS FOR DOCUMENTATION
-- =============================================

COMMENT ON TABLE users IS 'User accounts for all roles in the system';
COMMENT ON TABLE schools IS 'School information and settings';
COMMENT ON TABLE students IS 'Student profiles and academic data';
COMMENT ON TABLE classes IS 'Class/grade information and timetables';
COMMENT ON TABLE subjects IS 'Academic subjects offered by schools';
COMMENT ON TABLE payments IS 'Student payment records and invoices';
COMMENT ON TABLE messages IS 'Internal messaging system';
COMMENT ON TABLE events IS 'School calendar events';
COMMENT ON TABLE feedback IS 'Parent feedback and suggestions';
COMMENT ON TABLE audit_logs IS 'System audit trail for compliance';
COMMENT ON TABLE lesson_plans IS 'Teacher lesson plans and materials';
COMMENT ON TABLE resources IS 'Shared educational resources';

-- End of schema