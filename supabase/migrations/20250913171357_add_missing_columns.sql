-- Add missing columns and create users table
-- This migration fixes the sync errors by adding required columns

-- Create users table if it doesn't exist (with all required columns)
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20),
    role VARCHAR(20) NOT NULL CHECK (role IN ('parent', 'teacher', 'admin', 'superAdmin', 'accountant')),
    access_code VARCHAR(10) UNIQUE,  -- This was missing and causing sync errors
    password_hash VARCHAR(255) NOT NULL,
    school_id UUID REFERENCES schools(id),
    is_active BOOLEAN DEFAULT true,
    bio TEXT,
    profile_image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add missing columns to existing tables

-- Add capacity column to classes table
ALTER TABLE classes ADD COLUMN IF NOT EXISTS capacity INTEGER DEFAULT 30;

-- Add admission_date column to students table (rename from admission_date to admissionDate for consistency)
ALTER TABLE students ADD COLUMN IF NOT EXISTS admission_date DATE DEFAULT CURRENT_DATE;

-- Enable RLS on users table
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Add users table policies
CREATE POLICY "Users can view their own profile" ON users FOR SELECT USING (
    id = auth.uid()
);

CREATE POLICY "Users can update their own profile" ON users FOR UPDATE USING (
    id = auth.uid()
);

CREATE POLICY "Super admins can manage all users" ON users FOR ALL USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'superAdmin')
);

CREATE POLICY "Admins can manage users in their school" ON users FOR ALL USING (
    EXISTS (
        SELECT 1 FROM users u 
        WHERE u.id = auth.uid() 
        AND u.role IN ('admin', 'superAdmin')
        AND (u.role = 'superAdmin' OR u.school_id = users.school_id)
    )
);

-- Add trigger for users table updated_at (only if it doesn't exist)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_users_updated_at') THEN
        CREATE TRIGGER update_users_updated_at 
            BEFORE UPDATE ON users 
            FOR EACH ROW 
            EXECUTE FUNCTION update_updated_at_column();
    END IF;
END $$;

-- Add indexes for users table
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_school_id ON users(school_id);
CREATE INDEX IF NOT EXISTS idx_users_access_code ON users(access_code);
CREATE INDEX IF NOT EXISTS idx_users_is_active ON users(is_active);

-- Comment on users table
COMMENT ON TABLE users IS 'User accounts for parents, teachers, admins, and super admins';
COMMENT ON COLUMN users.access_code IS 'Unique access code for user authentication';
COMMENT ON COLUMN classes.capacity IS 'Maximum number of students allowed in the class';
COMMENT ON COLUMN students.admission_date IS 'Date when student was admitted to the school';