-- Fix UUID generation issues
-- This migration adds UUID validation functions and constraints

-- Create a function to validate UUID format
CREATE OR REPLACE FUNCTION is_valid_uuid(uuid_text TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    -- Try to cast to UUID, return false if it fails
    BEGIN
        PERFORM uuid_text::UUID;
        RETURN TRUE;
    EXCEPTION WHEN invalid_text_representation THEN
        RETURN FALSE;
    END;
END;
$$ LANGUAGE plpgsql;

-- Add check constraints to ensure only valid UUIDs are inserted
-- This will prevent timestamp strings from being inserted as IDs
-- Only add constraints for existing tables

-- Check if tables exist before adding constraints
DO $$
BEGIN
    -- Add constraint for users table if it exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'users') THEN
        ALTER TABLE users ADD CONSTRAINT users_id_is_uuid 
            CHECK (is_valid_uuid(id::TEXT));
    END IF;

    -- Add constraint for schools table if it exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'schools') THEN
        ALTER TABLE schools ADD CONSTRAINT schools_id_is_uuid 
            CHECK (is_valid_uuid(id::TEXT));
    END IF;

    -- Add constraint for classes table if it exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'classes') THEN
        ALTER TABLE classes ADD CONSTRAINT classes_id_is_uuid 
            CHECK (is_valid_uuid(id::TEXT));
    END IF;

    -- Add constraint for subjects table if it exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'subjects') THEN
        ALTER TABLE subjects ADD CONSTRAINT subjects_id_is_uuid 
            CHECK (is_valid_uuid(id::TEXT));
    END IF;

    -- Add constraint for students table if it exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'students') THEN
        ALTER TABLE students ADD CONSTRAINT students_id_is_uuid 
            CHECK (is_valid_uuid(id::TEXT));
    END IF;

    -- Add constraint for payments table if it exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'payments') THEN
        ALTER TABLE payments ADD CONSTRAINT payments_id_is_uuid 
            CHECK (is_valid_uuid(id::TEXT));
    END IF;

    -- Add constraint for messages table if it exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'messages') THEN
        ALTER TABLE messages ADD CONSTRAINT messages_id_is_uuid 
            CHECK (is_valid_uuid(id::TEXT));
    END IF;

    -- Add constraint for audit_logs table if it exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'audit_logs') THEN
        ALTER TABLE audit_logs ADD CONSTRAINT audit_logs_id_is_uuid 
            CHECK (is_valid_uuid(id::TEXT));
    END IF;
END $$;

-- Add comments
COMMENT ON FUNCTION is_valid_uuid(TEXT) IS 'Validates if a text string is a valid UUID format';
COMMENT ON CONSTRAINT users_id_is_uuid ON users IS 'Ensures user IDs are valid UUIDs, not timestamps';
COMMENT ON CONSTRAINT schools_id_is_uuid ON schools IS 'Ensures school IDs are valid UUIDs, not timestamps';