-- Fix duplicate RLS policies causing infinite recursion
-- Drop duplicate policies that were created in add_missing_columns.sql

-- Drop duplicate users policies (these already exist from the original schema)
DROP POLICY IF EXISTS "Users can view their own profile" ON users;
DROP POLICY IF EXISTS "Users can update their own profile" ON users;
DROP POLICY IF EXISTS "Super admins can manage all users" ON users;
DROP POLICY IF EXISTS "Admins can manage users in their school" ON users;

-- Recreate the correct policies without recursion
CREATE POLICY "Users can view their own profile" ON users FOR SELECT USING (
    auth.uid() = id
);

CREATE POLICY "Users can update their own profile" ON users FOR UPDATE USING (
    auth.uid() = id
);

CREATE POLICY "Super admins can manage all users" ON users FOR ALL USING (
    auth.jwt() ->> 'role' = 'superAdmin'
);

CREATE POLICY "Admins can manage users in their school" ON users FOR ALL USING (
    EXISTS (
        SELECT 1 FROM auth.users au
        JOIN users u ON au.id = u.id
        WHERE au.id = auth.uid()
        AND u.role IN ('admin', 'superAdmin')
        AND (u.role = 'superAdmin' OR u.school_id = users.school_id)
    )
);

-- Comment
COMMENT ON TABLE users IS 'Fixed RLS policies to prevent infinite recursion';