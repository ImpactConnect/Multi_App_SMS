-- Migration: Add missing columns to match local models
-- This fixes the PostgrestException errors for missing columns

-- Add missing columns to users table
ALTER TABLE users ADD COLUMN IF NOT EXISTS username VARCHAR(100);
ALTER TABLE users ADD COLUMN IF NOT EXISTS password VARCHAR(255);
ALTER TABLE users ADD COLUMN IF NOT EXISTS address TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS date_of_birth DATE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other'));
ALTER TABLE users ADD COLUMN IF NOT EXISTS national_id VARCHAR(50);
ALTER TABLE users ADD COLUMN IF NOT EXISTS emergency_contact VARCHAR(100);
ALTER TABLE users ADD COLUMN IF NOT EXISTS emergency_contact_relation VARCHAR(50);
ALTER TABLE users ADD COLUMN IF NOT EXISTS qualification TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS department VARCHAR(100);
ALTER TABLE users ADD COLUMN IF NOT EXISTS position VARCHAR(100);
ALTER TABLE users ADD COLUMN IF NOT EXISTS join_date DATE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS blood_group VARCHAR(10);
ALTER TABLE users ADD COLUMN IF NOT EXISTS medical_info TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS notes TEXT;

-- Add missing columns to schools table
ALTER TABLE schools ADD COLUMN IF NOT EXISTS principal_name VARCHAR(100);
ALTER TABLE schools ADD COLUMN IF NOT EXISTS established_date DATE;
ALTER TABLE schools ADD COLUMN IF NOT EXISTS type VARCHAR(20) DEFAULT 'primary' CHECK (type IN ('primary', 'secondary', 'high', 'university', 'other'));
ALTER TABLE schools ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE schools ADD COLUMN IF NOT EXISTS settings JSONB;

-- Add missing columns to students table
ALTER TABLE students ADD COLUMN IF NOT EXISTS phone_number VARCHAR(20);
ALTER TABLE students ADD COLUMN IF NOT EXISTS email VARCHAR(255);
ALTER TABLE students ADD COLUMN IF NOT EXISTS parent_ids TEXT; -- JSON array as text
ALTER TABLE students ADD COLUMN IF NOT EXISTS emergency_contact VARCHAR(100);
ALTER TABLE students ADD COLUMN IF NOT EXISTS emergency_contact_relation VARCHAR(50);
ALTER TABLE students ADD COLUMN IF NOT EXISTS blood_group VARCHAR(10);
ALTER TABLE students ADD COLUMN IF NOT EXISTS medical_info TEXT;
ALTER TABLE students ADD COLUMN IF NOT EXISTS notes TEXT;
ALTER TABLE students ADD COLUMN IF NOT EXISTS profile_image_url TEXT;
ALTER TABLE students ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;
ALTER TABLE students ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
ALTER TABLE students ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Add missing columns to classes table
ALTER TABLE classes ADD COLUMN IF NOT EXISTS capacity INTEGER DEFAULT 30;
ALTER TABLE classes ADD COLUMN IF NOT EXISTS room_number VARCHAR(20);
ALTER TABLE classes ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;
ALTER TABLE classes ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
ALTER TABLE classes ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Add missing columns to subjects table
ALTER TABLE subjects ADD COLUMN IF NOT EXISTS credits INTEGER DEFAULT 1;
ALTER TABLE subjects ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;
ALTER TABLE subjects ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
ALTER TABLE subjects ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_access_code ON users(access_code);
CREATE INDEX IF NOT EXISTS idx_users_school_id ON users(school_id);
CREATE INDEX IF NOT EXISTS idx_students_student_id ON students(student_id);
CREATE INDEX IF NOT EXISTS idx_students_class_id ON students(class_id);
CREATE INDEX IF NOT EXISTS idx_students_school_id ON students(school_id);

COMMIT;