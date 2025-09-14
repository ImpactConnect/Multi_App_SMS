-- =============================================
-- FRESH CLOUD DATABASE SCHEMA
-- Complete setup for wiped database with updated logic
-- =============================================

-- Note: users table already exists, so we skip it

-- =============================================
-- CORE TABLES
-- =============================================

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

-- Lesson plans table
CREATE TABLE lesson_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    teacher_id UUID NOT NULL REFERENCES users(id),
    subject_id UUID NOT NULL REFERENCES subjects(id),
    class_id UUID NOT NULL REFERENCES classes(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    objectives TEXT[],
    materials TEXT[],
    activities JSONB,
    assessment_methods TEXT[],
    homework TEXT,
    lesson_date DATE NOT NULL,
    duration_minutes INTEGER,
    status VARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'completed')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Resources table
CREATE TABLE resources (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    teacher_id UUID NOT NULL REFERENCES users(id),
    subject_id UUID REFERENCES subjects(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    resource_type VARCHAR(50) NOT NULL,
    file_url TEXT,
    file_size BIGINT,
    mime_type VARCHAR(100),
    tags TEXT[],
    is_public BOOLEAN DEFAULT false,
    download_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- INDEXES FOR PERFORMANCE
-- =============================================

-- Schools table indexes
CREATE INDEX idx_schools_name ON schools(name);
CREATE INDEX idx_schools_is_active ON schools(is_active);

-- Students table indexes
CREATE INDEX idx_students_student_id ON students(student_id);
CREATE INDEX idx_students_class_id ON students(class_id);
CREATE INDEX idx_students_school_id ON students(school_id);
CREATE INDEX idx_students_is_active ON students(is_active);
CREATE INDEX idx_students_parent_ids ON students USING GIN(parent_ids);
CREATE INDEX idx_students_name ON students(first_name, last_name);

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
CREATE INDEX idx_subjects_is_active ON subjects(is_active);

-- Payments table indexes
CREATE INDEX idx_payments_student_id ON payments(student_id);
CREATE INDEX idx_payments_payment_date ON payments(payment_date);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_reference ON payments(reference_number);
CREATE INDEX idx_payments_created_by ON payments(created_by);

-- Messages table indexes
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_receiver_id ON messages(receiver_id);
CREATE INDEX idx_messages_timestamp ON messages(timestamp);
CREATE INDEX idx_messages_is_read ON messages(is_read);

-- Events table indexes
CREATE INDEX idx_events_date ON events(event_date);
CREATE INDEX idx_events_school_id ON events(school_id);
CREATE INDEX idx_events_type ON events(event_type);
CREATE INDEX idx_events_is_public ON events(is_public);

-- Feedback table indexes
CREATE INDEX idx_feedback_parent_id ON feedback(parent_id);
CREATE INDEX idx_feedback_student_id ON feedback(student_id);
CREATE INDEX idx_feedback_status ON feedback(status);
CREATE INDEX idx_feedback_priority ON feedback(priority);

-- Audit logs indexes
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_timestamp ON audit_logs(timestamp);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);

-- Lesson plans indexes
CREATE INDEX idx_lesson_plans_teacher_id ON lesson_plans(teacher_id);
CREATE INDEX idx_lesson_plans_subject_id ON lesson_plans(subject_id);
CREATE INDEX idx_lesson_plans_class_id ON lesson_plans(class_id);
CREATE INDEX idx_lesson_plans_date ON lesson_plans(lesson_date);
CREATE INDEX idx_lesson_plans_status ON lesson_plans(status);

-- Resources indexes
CREATE INDEX idx_resources_teacher_id ON resources(teacher_id);
CREATE INDEX idx_resources_subject_id ON resources(subject_id);
CREATE INDEX idx_resources_type ON resources(resource_type);
CREATE INDEX idx_resources_is_public ON resources(is_public);
CREATE INDEX idx_resources_tags ON resources USING GIN(tags);

-- =============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =============================================

-- Enable RLS on all tables
ALTER TABLE schools ENABLE ROW LEVEL SECURITY;
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE lesson_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE resources ENABLE ROW LEVEL SECURITY;

-- Schools policies
CREATE POLICY "Super admins can manage all schools" ON schools FOR ALL USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'superAdmin')
);
CREATE POLICY "School staff can view their school" ON schools FOR SELECT USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND school_id = schools.id)
);

-- Students policies
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

-- Classes policies
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

-- Subjects policies
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

-- Payments policies
CREATE POLICY "Parents can view their children's payments" ON payments FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM students s 
        WHERE s.id = payments.student_id 
        AND auth.uid() = ANY(s.parent_ids)
    )
);
CREATE POLICY "Accountants and admins have full access to payments" ON payments FOR ALL USING (
    EXISTS (
        SELECT 1 FROM users u 
        WHERE u.id = auth.uid() 
        AND u.role IN ('accountant', 'admin', 'superAdmin')
        AND (u.role = 'superAdmin' OR EXISTS (
            SELECT 1 FROM students s 
            WHERE s.id = payments.student_id 
            AND s.school_id = u.school_id
        ))
    )
);

-- Messages policies
CREATE POLICY "Users can view messages they sent or received" ON messages FOR SELECT USING (
    sender_id = auth.uid() OR receiver_id = auth.uid()
);
CREATE POLICY "Users can send messages" ON messages FOR INSERT WITH CHECK (
    sender_id = auth.uid()
);
CREATE POLICY "Users can update their own messages" ON messages FOR UPDATE USING (
    sender_id = auth.uid()
);

-- Events policies
CREATE POLICY "Everyone can view public events" ON events FOR SELECT USING (is_public = true);
CREATE POLICY "School staff can manage events in their school" ON events FOR ALL USING (
    EXISTS (
        SELECT 1 FROM users u 
        WHERE u.id = auth.uid() 
        AND u.role IN ('admin', 'teacher', 'superAdmin') 
        AND (u.role = 'superAdmin' OR events.school_id IS NULL OR u.school_id = events.school_id)
    )
);
CREATE POLICY "Parents can view events for their school" ON events FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM users u 
        JOIN students s ON auth.uid() = ANY(s.parent_ids)
        WHERE u.id = auth.uid() 
        AND s.school_id = events.school_id
    )
);

-- Feedback policies
CREATE POLICY "Parents can manage their own feedback" ON feedback FOR ALL USING (
    parent_id = auth.uid()
);
CREATE POLICY "School staff can view and respond to feedback" ON feedback FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM users u 
        JOIN students s ON s.id = feedback.student_id
        WHERE u.id = auth.uid() 
        AND u.role IN ('admin', 'teacher', 'superAdmin')
        AND (u.role = 'superAdmin' OR u.school_id = s.school_id)
    )
);
CREATE POLICY "School staff can update feedback responses" ON feedback FOR UPDATE USING (
    EXISTS (
        SELECT 1 FROM users u 
        JOIN students s ON s.id = feedback.student_id
        WHERE u.id = auth.uid() 
        AND u.role IN ('admin', 'teacher', 'superAdmin')
        AND (u.role = 'superAdmin' OR u.school_id = s.school_id)
    )
);

-- Lesson plans policies
CREATE POLICY "Teachers can manage their own lesson plans" ON lesson_plans FOR ALL USING (
    teacher_id = auth.uid()
);
CREATE POLICY "Admins can view lesson plans in their school" ON lesson_plans FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM users u 
        JOIN users t ON t.id = lesson_plans.teacher_id
        WHERE u.id = auth.uid() 
        AND u.role IN ('admin', 'superAdmin')
        AND (u.role = 'superAdmin' OR u.school_id = t.school_id)
    )
);

-- Resources policies
CREATE POLICY "Teachers can manage their own resources" ON resources FOR ALL USING (
    teacher_id = auth.uid()
);
CREATE POLICY "Everyone can view public resources" ON resources FOR SELECT USING (is_public = true);
CREATE POLICY "School staff can view resources in their school" ON resources FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM users u 
        JOIN users t ON t.id = resources.teacher_id
        WHERE u.id = auth.uid() 
        AND u.role IN ('admin', 'teacher', 'superAdmin')
        AND (u.role = 'superAdmin' OR u.school_id = t.school_id)
    )
);

-- Audit logs policies
CREATE POLICY "Admins can view audit logs for their school" ON audit_logs FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM users u 
        WHERE u.id = auth.uid() 
        AND u.role IN ('admin', 'superAdmin')
        AND (u.role = 'superAdmin' OR u.school_id = (
            SELECT school_id FROM users WHERE id = audit_logs.user_id
        ))
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
CREATE TRIGGER update_schools_updated_at BEFORE UPDATE ON schools FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_students_updated_at BEFORE UPDATE ON students FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_classes_updated_at BEFORE UPDATE ON classes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_subjects_updated_at BEFORE UPDATE ON subjects FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON payments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON events FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_feedback_updated_at BEFORE UPDATE ON feedback FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_lesson_plans_updated_at BEFORE UPDATE ON lesson_plans FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_resources_updated_at BEFORE UPDATE ON resources FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================
-- FUNCTIONS FOR MAINTAINING BIDIRECTIONAL RELATIONSHIPS
-- =============================================

-- Function to maintain bidirectional relationship between classes and subjects
CREATE OR REPLACE FUNCTION sync_class_subject_relationship()
RETURNS TRIGGER AS $$
BEGIN
    -- When a subject is added to a class, add the class to the subject
    IF TG_OP = 'UPDATE' AND OLD.subject_ids IS DISTINCT FROM NEW.subject_ids THEN
        -- Add new subjects to class_ids in subjects table
        UPDATE subjects 
        SET class_ids = array_append(class_ids, NEW.id)
        WHERE id = ANY(NEW.subject_ids) 
        AND NOT (NEW.id = ANY(class_ids));
        
        -- Remove class from subjects that are no longer in the class
        UPDATE subjects 
        SET class_ids = array_remove(class_ids, NEW.id)
        WHERE id = ANY(OLD.subject_ids) 
        AND NOT (id = ANY(NEW.subject_ids));
    END IF;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Function to maintain bidirectional relationship between subjects and classes
CREATE OR REPLACE FUNCTION sync_subject_class_relationship()
RETURNS TRIGGER AS $$
BEGIN
    -- When a class is added to a subject, add the subject to the class
    IF TG_OP = 'UPDATE' AND OLD.class_ids IS DISTINCT FROM NEW.class_ids THEN
        -- Add new classes to subject_ids in classes table
        UPDATE classes 
        SET subject_ids = array_append(subject_ids, NEW.id)
        WHERE id = ANY(NEW.class_ids) 
        AND NOT (NEW.id = ANY(subject_ids));
        
        -- Remove subject from classes that are no longer in the subject
        UPDATE classes 
        SET subject_ids = array_remove(subject_ids, NEW.id)
        WHERE id = ANY(OLD.class_ids) 
        AND NOT (id = ANY(NEW.class_ids));
    END IF;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply relationship sync triggers
CREATE TRIGGER sync_class_subjects AFTER UPDATE ON classes FOR EACH ROW EXECUTE FUNCTION sync_class_subject_relationship();
CREATE TRIGGER sync_subject_classes AFTER UPDATE ON subjects FOR EACH ROW EXECUTE FUNCTION sync_subject_class_relationship();

-- =============================================
-- COMMENTS FOR DOCUMENTATION
-- =============================================

COMMENT ON TABLE schools IS 'School information and settings';
COMMENT ON TABLE students IS 'Student profiles matching local Student model with array relationships';
COMMENT ON TABLE classes IS 'Class information matching local SchoolClass model with subject_ids array';
COMMENT ON TABLE subjects IS 'Academic subjects with teacher_ids and class_ids arrays for relationships';
COMMENT ON TABLE payments IS 'Student payment records and invoices';
COMMENT ON TABLE messages IS 'Internal messaging system';
COMMENT ON TABLE events IS 'School calendar events';
COMMENT ON TABLE feedback IS 'Parent feedback and suggestions';
COMMENT ON TABLE audit_logs IS 'System audit trail for compliance';
COMMENT ON TABLE lesson_plans IS 'Teacher lesson plans and materials';
COMMENT ON TABLE resources IS 'Shared educational resources';

-- End of fresh database schema