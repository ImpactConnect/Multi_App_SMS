-- =============================================
-- CORRECTED CLOUD DATABASE SCHEMA
-- Matching Local Models Structure and Naming
-- =============================================

-- =============================================
-- CORE TABLES
-- =============================================

-- Users table (handles parents, teachers, admins, super admins)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20),
    role VARCHAR(20) NOT NULL CHECK (role IN ('parent', 'teacher', 'admin', 'superAdmin', 'accountant')),
    access_code VARCHAR(10) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    school_id UUID REFERENCES schools(id),
    is_active BOOLEAN DEFAULT true,
    bio TEXT,
    profile_image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Schools table
CREATE TABLE schools (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(255),
    website VARCHAR(255),
    logo_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Students table (matching local Student model exactly)
CREATE TABLE students (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    student_id VARCHAR(50) UNIQUE NOT NULL,
    date_of_birth DATE,
    gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),
    address TEXT,
    profile_image_url TEXT,
    class_id UUID REFERENCES classes(id),
    school_id UUID NOT NULL REFERENCES schools(id),
    parent_ids UUID[] DEFAULT '{}',  -- Array of parent user IDs
    admission_date DATE DEFAULT CURRENT_DATE,
    is_active BOOLEAN DEFAULT true,
    emergency_contact JSONB,  -- {name, phone, relationship}
    medical_info JSONB,       -- {allergies, medications, conditions}
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Classes table (matching local SchoolClass model exactly)
CREATE TABLE classes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    grade VARCHAR(20) NOT NULL,
    section VARCHAR(10),
    school_id UUID NOT NULL REFERENCES schools(id),
    class_teacher_id UUID REFERENCES users(id),  -- Single teacher ID
    subject_ids UUID[] DEFAULT '{}',  -- Array of subject IDs
    student_count INTEGER DEFAULT 0,
    room_number VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(school_id, grade, section)
);

-- Subjects table (matching local Subject model exactly)
CREATE TABLE subjects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    code VARCHAR(20) UNIQUE,
    teacher_ids UUID[] DEFAULT '{}',  -- Array of teacher user IDs
    class_ids UUID[] DEFAULT '{}',    -- Array of class IDs
    school_id UUID NOT NULL REFERENCES schools(id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- FEATURE TABLES (Additional functionality)
-- =============================================

-- Payments table
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES students(id),
    amount DECIMAL(10,2) NOT NULL,
    payment_date DATE NOT NULL,
    due_date DATE,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'overdue', 'cancelled')),
    payment_type VARCHAR(50) NOT NULL,
    description TEXT,
    reference_number VARCHAR(100) UNIQUE,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Messages table
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID NOT NULL REFERENCES users(id),
    receiver_id UUID NOT NULL REFERENCES users(id),
    subject VARCHAR(255),
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    parent_message_id UUID REFERENCES messages(id),
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Events table
CREATE TABLE events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    event_date DATE NOT NULL,
    start_time TIME,
    end_time TIME,
    location VARCHAR(255),
    event_type VARCHAR(50),
    is_public BOOLEAN DEFAULT true,
    school_id UUID REFERENCES schools(id),
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Feedback table
CREATE TABLE feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id UUID NOT NULL REFERENCES users(id),
    student_id UUID REFERENCES students(id),
    subject VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    category VARCHAR(50),
    priority VARCHAR(20) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    status VARCHAR(20) DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'resolved', 'closed')),
    response TEXT,
    responded_by UUID REFERENCES users(id),
    responded_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Audit logs table
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

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
CREATE INDEX idx_classes_subject_ids ON classes USING GIN(subject_ids);

-- Subjects table indexes
CREATE INDEX idx_subjects_name ON subjects(name);
CREATE INDEX idx_subjects_code ON subjects(code);
CREATE INDEX idx_subjects_school_id ON subjects(school_id);
CREATE INDEX idx_subjects_teacher_ids ON subjects USING GIN(teacher_ids);
CREATE INDEX idx_subjects_class_ids ON subjects USING GIN(class_ids);

-- Other indexes
CREATE INDEX idx_payments_student_id ON payments(student_id);
CREATE INDEX idx_payments_payment_date ON payments(payment_date);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_receiver_id ON messages(receiver_id);
CREATE INDEX idx_events_date ON events(event_date);
CREATE INDEX idx_events_school_id ON events(school_id);
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_timestamp ON audit_logs(timestamp);

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
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

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
CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON events FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_feedback_updated_at BEFORE UPDATE ON feedback FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================
-- COMMENTS FOR DOCUMENTATION
-- =============================================

COMMENT ON TABLE users IS 'User accounts for all roles (parents, teachers, admins, super admins, accountants)';
COMMENT ON TABLE schools IS 'School information and settings';
COMMENT ON TABLE students IS 'Student profiles matching local Student model with array relationships';
COMMENT ON TABLE classes IS 'Class information matching local SchoolClass model with subject_ids array';
COMMENT ON TABLE subjects IS 'Academic subjects with teacher_ids and class_ids arrays for relationships';
COMMENT ON TABLE payments IS 'Student payment records and invoices';
COMMENT ON TABLE messages IS 'Internal messaging system';
COMMENT ON TABLE events IS 'School calendar events';
COMMENT ON TABLE feedback IS 'Parent feedback and suggestions';
COMMENT ON TABLE audit_logs IS 'System audit trail for compliance';

-- End of corrected schema