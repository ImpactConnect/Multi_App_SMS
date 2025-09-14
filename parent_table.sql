-- Parent Table SQL for Cloud Database
-- This table stores parent-specific information that extends the users table
-- Parents are users with role 'parent' in the users table

CREATE TABLE IF NOT EXISTS parents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Parent-specific information
    occupation VARCHAR(100),
    workplace VARCHAR(200),
    work_phone VARCHAR(20),
    annual_income DECIMAL(12,2),
    education_level VARCHAR(50),
    
    -- Emergency and contact details
    alternate_email VARCHAR(255),
    home_address TEXT,
    work_address TEXT,
    
    -- Relationship and family info
    marital_status VARCHAR(20) CHECK (marital_status IN ('single', 'married', 'divorced', 'widowed', 'separated')),
    spouse_name VARCHAR(200),
    spouse_phone VARCHAR(20),
    spouse_email VARCHAR(255),
    
    -- Preferences and settings
    preferred_communication VARCHAR(20) CHECK (preferred_communication IN ('email', 'sms', 'phone', 'app')) DEFAULT 'email',
    notification_preferences JSONB DEFAULT '{}',
    
    -- School-related information
    school_id UUID NOT NULL REFERENCES schools(id),
    
    -- Metadata
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    notes TEXT
);

-- Parent-Student relationship table (many-to-many)
CREATE TABLE IF NOT EXISTS parent_students (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id UUID NOT NULL REFERENCES parents(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    relationship VARCHAR(50) NOT NULL CHECK (relationship IN ('father', 'mother', 'guardian', 'stepfather', 'stepmother', 'grandfather', 'grandmother', 'uncle', 'aunt', 'other')),
    is_primary_contact BOOLEAN DEFAULT false,
    is_emergency_contact BOOLEAN DEFAULT false,
    pickup_authorized BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Ensure unique parent-student combinations
    UNIQUE(parent_id, student_id)
);

-- Indexes for better performance
CREATE INDEX IF NOT EXISTS idx_parents_user_id ON parents(user_id);
CREATE INDEX IF NOT EXISTS idx_parents_school_id ON parents(school_id);
CREATE INDEX IF NOT EXISTS idx_parents_active ON parents(is_active);
CREATE INDEX IF NOT EXISTS idx_parent_students_parent_id ON parent_students(parent_id);
CREATE INDEX IF NOT EXISTS idx_parent_students_student_id ON parent_students(student_id);
CREATE INDEX IF NOT EXISTS idx_parent_students_primary_contact ON parent_students(is_primary_contact) WHERE is_primary_contact = true;

-- Row Level Security (RLS) Policies
ALTER TABLE parents ENABLE ROW LEVEL SECURITY;
ALTER TABLE parent_students ENABLE ROW LEVEL SECURITY;

-- Policy: Parents can only see their own data
CREATE POLICY "Parents can view own data" ON parents
    FOR SELECT USING (
        user_id = auth.uid() OR
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role IN ('superAdmin', 'admin', 'teacher')
            AND users.school_id = parents.school_id
        )
    );

-- Policy: Parents can update their own data
CREATE POLICY "Parents can update own data" ON parents
    FOR UPDATE USING (
        user_id = auth.uid() OR
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role IN ('superAdmin', 'admin')
            AND users.school_id = parents.school_id
        )
    );

-- Policy: Only admins can insert/delete parent records
CREATE POLICY "Admins can manage parents" ON parents
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role IN ('superAdmin', 'admin')
        )
    );

-- Policy: Parent-student relationships visibility
CREATE POLICY "View parent-student relationships" ON parent_students
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM parents p
            JOIN users u ON p.user_id = u.id
            WHERE p.id = parent_students.parent_id
            AND (u.id = auth.uid() OR
                 EXISTS (
                     SELECT 1 FROM users staff
                     WHERE staff.id = auth.uid()
                     AND staff.role IN ('superAdmin', 'admin', 'teacher')
                     AND staff.school_id = p.school_id
                 )
            )
        )
    );

-- Policy: Manage parent-student relationships
CREATE POLICY "Manage parent-student relationships" ON parent_students
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role IN ('superAdmin', 'admin')
        )
    );

-- Comments for documentation
COMMENT ON TABLE parents IS 'Extended parent information that references users table';
COMMENT ON TABLE parent_students IS 'Many-to-many relationship between parents and students';
COMMENT ON COLUMN parents.user_id IS 'References the user record with role parent';
COMMENT ON COLUMN parent_students.relationship IS 'Type of relationship between parent and student';
COMMENT ON COLUMN parent_students.is_primary_contact IS 'Indicates if this parent is the primary contact for the student';
COMMENT ON COLUMN parent_students.pickup_authorized IS 'Whether this parent is authorized to pick up the student';