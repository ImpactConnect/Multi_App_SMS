-- Final fix for RLS infinite recursion
-- Remove all problematic policies and create simple, non-recursive ones

-- Drop ALL existing users policies to start fresh
DROP POLICY IF EXISTS "Users can view their own profile" ON users;
DROP POLICY IF EXISTS "Users can update their own profile" ON users;
DROP POLICY IF EXISTS "Super admins can manage all users" ON users;
DROP POLICY IF EXISTS "Admins can manage users in their school" ON users;
DROP POLICY IF EXISTS "Super admins can view all users" ON users;
DROP POLICY IF EXISTS "Admins can view users in their school" ON users;

-- Create simple policies that don't reference the users table
-- Policy 1: Users can view their own profile (no recursion)
CREATE POLICY "users_select_own" ON users FOR SELECT USING (
    auth.uid() = id
);

-- Policy 2: Users can update their own profile (no recursion)
CREATE POLICY "users_update_own" ON users FOR UPDATE USING (
    auth.uid() = id
);

-- Policy 3: Super admin access using JWT claims (no table lookup)
CREATE POLICY "users_superadmin_all" ON users FOR ALL USING (
    (auth.jwt() ->> 'role') = 'superAdmin'
);

-- Policy 4: For now, disable admin school-based access to avoid recursion
-- We'll handle this in the application layer instead
-- CREATE POLICY "users_admin_school" ON users FOR SELECT USING (false);

-- Ensure RLS is enabled
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Add comment
COMMENT ON TABLE users IS 'RLS policies fixed - no more infinite recursion';