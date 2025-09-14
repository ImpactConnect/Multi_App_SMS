-- Migration: Add school_id column to users table (if not exists)
-- This migration ensures the school_id column exists in the users table
-- Note: This column may already exist in newer schemas

-- Add school_id column to users table if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'users' AND column_name = 'school_id'
    ) THEN
        ALTER TABLE users ADD COLUMN school_id UUID;
        
        -- Add foreign key constraint to schools table
        ALTER TABLE users ADD CONSTRAINT fk_users_school_id 
            FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE SET NULL;
        
        -- Add index for better query performance
        CREATE INDEX idx_users_school_id ON users(school_id);
        
        -- Add comment to document the column
        COMMENT ON COLUMN users.school_id IS 'Reference to the school this user belongs to. NULL for super admins.';
    END IF;
END $$;

-- Update existing users without school_id (if any)
-- This is optional and depends on your data migration needs
-- UPDATE users SET school_id = (SELECT id FROM schools LIMIT 1) 
-- WHERE school_id IS NULL AND role != 'superAdmin';

-- Add validation to ensure non-super admin users have a school assigned
-- (Uncomment if you want to enforce this constraint)
-- ALTER TABLE users ADD CONSTRAINT check_school_id_required 
--     CHECK (role = 'superAdmin' OR school_id IS NOT NULL);